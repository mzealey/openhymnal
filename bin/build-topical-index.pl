#!/usr/bin/perl
#use File::Grep qw( fgrep fmap fdo );
#######################################################################
#     This is a script to dig through the abc files, and build a 
# topical index and from them.
#
# Uses these scripts:
# ohroot
#
# and these files:
# Complete/*/*.abc
# New/Ready/*/*.abc
# Choir/*/*.abc
# 
# it makes these files:
# Web/Build/topical?-core.html
# Web/Build/mobile-topical?-core.html
#
# version 1.0 02-03 Dec 2011 (bjd)
# version 1.1 05 Dec 2011 (bjd) - move to new "bin" directory within OH
# version 1.2 27 Jan 2011 (bjd) - include "New/Ready/*/*.abc"
#######################################################################

$ohroot=`ohroot`;
$ohroot=~ s/\n//;
$filepath=$ohroot . "Complete/*/*.abc " . $ohroot . "New/Ready/*/*.abc " . $ohroot . "Choir/*/*.abc";
#print $filepath,"\n";
@rawfiles = <$filepath >; 
#print @rawfiles,"\n";
my $newfile = "";

#@rawfiles = <[L]ook*/*.abc>; 
#######################################################################
# Sort the files by hymn name in OH-style alphabetical order
#######################################################################
for ($i=0; $i < @rawfiles; $i++) {
	$sortfile[$i] = $rawfiles[$i];
	$sortfile[$i] =~ s/_/0/g;
	$sortfile[$i] =~ s/^.*\///g;
	$sortfile[$i] =~ s/-.*//g;
	$sortfile[$i] =~ s/[.].*//g;
	$sortfile[$i] =~ s/[!,;.'?()]//g;
	$sortfile[$i] = uc($sortfile[$i]);
	$order[$i] = -1;
}
for ($i=0; $i < @rawfiles; $i++) {
	$guess = 0;
	for ($j=1; $j < @rawfiles; $j++) {
		if ( $sortfile[$j] lt $sortfile[$guess] ) {
			$guess = $j;
		}
	}
	$order[$i] = $guess;
	$sortfile[$guess] = "~";
}
for ($i=0; $i < @rawfiles; $i++) {
	$files[$i] = $rawfiles[$order[$i]];
#	print $files[$i],"\n";
}


# THIS IS WHERE TO ADD TOPICS WITHOUT ENTRIES!
$numtopics = 87;
# first bogus entry is because topic list starts at 1 not 0
@topic = ("bogus",
"Acceptance of God's Plans (see Submission)", 
"Adoration (see Worship)", 
"Afflictions (see Courage in Affliction)", 
"Alms (see Tithing)", 
"Ascension &amp; Return of Christ (see Second Coming)", 
"Believers (see Brotherhood and Church)", 
"Bereavement (see Consolation)", 
"Bible (see Scripture)", 
"Blessings (see God - Care, Gratitude)", 
"Burdens (see Courage In Affliction)", 
"Burial (see Consolation)", 
"Call of the Lord (see Invitation <God's to Us>)", 
"Changing Year (see Seasons)", 
"Charity (see also Tithing)", 
"Children (see also God's Children - the Faithful)", 
"Christ (see Jesus)", 
"Christian Unity (see Brotherhood)", 
"Commandments (see Obedience)", 
"Communion (see Lord's Supper)", 
"Confession (see Contrition)", 
"Covenant (see Promises)", 
"Creation (see Nature)", 
"Death (see Consolation)", 
"Decision (see Following Jesus - Sanctification)", 
"Dedication (see Commitment, Following Jesus, Zeal)", 
"Defense (see Security)", 
"Diligence (see Activity, Duty, Following Jesus, Zeal)", 
"Duty (see also Law)", 
"Earnestness (see Activity, Zeal)", 
"Encouragement (see Courage in Affliction, Trust)", 
"Enduring (see Courage in Affliction, Trust, Submission)", 
"Enthusiasm (see Zeal)", 
"Exaltation (see Eternal Life, Salvation)", 
"Family (see Christian Home)", 
"Flock, Christian (see Brotherhood, Church, Shepard)", 
"Foundation (see Cornerstone)", 
"Funeral (see Consolation)", 
"Gethsemane (see Easter/ Easter Week / Passion)", 
"God, Protection of (see Assurance, Comfort, Courage in Affliction, God, Care of)", 
"God's Children - the Faithful (see also Saints, People of the World)", 
"Good Friday (see Easter Week / Passion)", 
"Good Thursday (see Easter Week / Passion)", 
"Happiness (see Joy, Peace)", 
"Home (see Christian Home)", 
"Honesty (see Integrity)", 
"Justice (see God, Justness of)", 
"Justification (see Atonement, Faith, Gospel, Grace, Salvation)", 
"King (see God, as King)", 
"Lamb (see Shepherd/Lamb)", 
"Learning (see Education, Knowledge)", 
"Life (see Brevity of Life, Christian Life, Eternal Life) ", 
"Marriage (see Christian Home)", 
"Maundy Thursday (see Easter Week / Passion)", 
"Mercy (see God - Mercy Of)", 
"Ministry (see Activity, Charity, Missions, Service)", 
"Moderation (see Temperance)", 
"Morality (see also Law)", 
"Motivation (see Activity, Zeal)", 
"Music (see Art &amp; Music)", 
"Palm Sunday (see Easter Week / Passion)", 
"Passion (see Easter Week / Passion)", 
"Penitence (see Repentance, Contrition)", 
"Perseverance (see Activity, Courage in Affliction, Following Jesus, Zeal)", 
"Pride (see also Humility)", 
"Promises (see also Gospel)", 
"Protection (see Security)", 
"Redemption (see Salvation)", 
"Rejoicing (see Joy)", 
"Resignation (see Assurance, Calmness, Courage in Affliction, Obedience, Submission)", 
"Safety (see Security)", 
"Schools (see Education)", 
"Self Control (see also Law)", 
"Self Sacrifice (see Sacrifice)", 
"Sheep (see Shepherd/Lamb)", 
"Social Service (see Charity, Duty, Education, Fellowship, God's Children / The World's People, Service)", 
"Sorrow (see Assurance, Consolation, Courage in Affliction, Darkness <Spiritual>)", 
"Submission (see also Following Jesus, God - Providence of, Trust)", 
"Substitutionary Atonement (see Atonement)", 
"Surrender (see Submission)", 
"Temperance &amp; Moral Reform (see also Law)", 
"Thanksgiving (see Gratitude)", 
"Trials (see Courage In Affliction)", 
"Unity (see Brotherhood, Church, Fellowship)", 
"Watchfulness (see Preparedness)", 
"Word of God (see Scripture, Jesus)", 
"Work (see Activity, Duty, Service, Zeal)", 
"World (see God's Children / The World's People)");

$numhymns = 0;
#######################################################################
# Dig through the ABC files to extract and sort all of the topical
# index information into an array of all the hymns which fit each
# specific topic.
#######################################################################
foreach $file (@files) {
#   print $file . "\n";
	open (INPUT, $file);
	$gottitle = 0;
	$topiclistraw = "";
	while (<INPUT>) {
		if ( /%OHTOPICS/ ) {
#			print $_;
			$topiclistraw = $_;
		}
		elsif ( ( /T:/ ) && ( $gottitle == 0 ) ) {
#			print $_;
			$title = $_;
			$title =~ s/T: //;
			$title =~ s/\n//;
			$gottitle = 1;
			@parts = split "{", $topiclistraw;
			for ($i = 1; $i < @parts; $i++) {
				@topicsplit = split "}", $parts[$i];
				$topicfull = $topicsplit[0];
				$extras = $topicfull;
				$topicbare = $topicfull;
				$topicbare =~ s/[\[][^\]]*[0-9]+[^\]]*[\]]//;
				$topicbare =~ s/ $//;
				$_ = $extras;
				if ( /[\[][^\]]*[0-9]+[^\]]*[\]]/ ) {
					$extras =~ s/.*([\[][^\]]*[0-9]+[^\]]*[\]])/\1/;
				}
				else {
					$extras = "";
				}
				#print $topicbare,"  -->  ", $title," ",$extras ,"\n";
				
 				$found = 0;
 				$link = $file;
				$link =~ s/^.*\//Lyrics\//g;
				$link =~ s/[.]abc/.html/g;
 				
 				for ($l=1; $l <= $numtopics; $l++) {
 					if ( $topic[$l] eq $topicbare ) {
						
						# A bit of logic to remove double-entries when there are 2 tunes for the same hymn
						$_ = $topiclist[$l];
						if ( length($extras) > 1 ) {
							#$entrycheck = $title." ".$extras."<br/>";
							$entrycheck = $title." ".$extras."</a><br/>";
						}
						else {
							#$entrycheck = $title."<br/>";
							$entrycheck = $title."</a><br/>";
						}						
						$_ =~ s/\[/</g;
						$_ =~ s/\]/>/g;
						$_ =~ s/[!,;.'?()-]//g;
						$entrycheck =~ s/\[/</g;
						$entrycheck =~ s/\]/>/g;
						$entrycheck =~ s/[!,;.'?()-]//g;
						#print $_,"  -->  ",$entrycheck,"  -->  ",$topic[$l],"\n";
						if ( ! /$entrycheck/ ) {
#							$topiclist[$l] .= $title." ".$extras."<br/>\n";
							if ( length($extras) > 1 ) {
								#$topiclist[$l] .= $title." ".$extras."<br>\n";
								$topiclist[$l] .= '<a href="'."javascript:new_window('".$link."')".'">'.$title." ".$extras."</a><br/>\n";
							}
							else {
								#$topiclist[$l] .= $title."<br>\n";
								$topiclist[$l] .= '<a href="'."javascript:new_window('".$link."')".'">'.$title."</a><br/>\n";
							}
 						}
 						else {
							#print STDERR "double on ".$title." for ".$topic[$l]."\n";
							if ( length($extras) > 1 ) {
								#$topiclist[$l] .= $title." ".$extras."<br>\n";
								$topiclist[$l] .= '<a href="'."javascript:new_window('".$link."')".'">'.$title." ".$extras."</a> (2nd tune)<br/>\n";
							}
							else {
								#$topiclist[$l] .= $title."<br>\n";
								$topiclist[$l] .= '<a href="'."javascript:new_window('".$link."')".'">'.$title."</a> (2nd tune)<br/>\n";
							}
 						}
						$found = 1;
 					}
 				}
 				if ( $found == 0 ) {
 					$numtopics += 1;
 					$topic[$numtopics] = $topicbare;
					if ( length($extras) > 1 ) {
						#$topiclist[$numtopics] .= $title." ".$extras."<br>\n";
						$topiclist[$numtopics] .= '<a href="'."javascript:new_window('".$link."')".'">'.$title." ".$extras."</a><br/>\n";
					}
					else {
						#$topiclist[$numtopics] .= $title."<br>\n";
						$topiclist[$numtopics] .= '<a href="'."javascript:new_window('".$link."')".'">'.$title."</a><br/>\n";
					}
 					
 				}
			}
		}
	}
	close INPUT;
} 

#######################################################################
# Sort the topics in OH-style alphabetical order and write out
#######################################################################
for ($i=1; $i <= $numtopics; $i++) {
	$sorttopic[$i] = $topic[$i];
	$sorttopic[$i] =~ s/ /0/g;
	$sorttopic[$i] =~ s/[!,;.'?()-]//g;
	$sorttopic[$i] = uc($sorttopic[$i]);
	$order[$i] = -1;
}
for ($i=1; $i <= $numtopics; $i++) {
	$guess = 1;
	for ($j=2; $j <= $numtopics; $j++) {
		if ( $sorttopic[$j] lt $sorttopic[$guess] ) {
			$guess = $j;
		}
	}
	$order[$i] = $guess;
	$sorttopic[$guess] = "~";
}
for ($i=1; $i <= $numtopics; $i++) {
	$topic[$i] =~ s/</[/g;
	$topic[$i] =~ s/>/]/g;
}

@alphabet = ("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z");

#######################################################################
# Build Web topical index
#######################################################################
$fileindex = 0;
$topicalpath = $ohroot . "Web/Build/topical";
#print $topicalpath,"\n";
$string = $topicalpath . $alphabet[$fileindex] . "-core.html";
#open (OUTPUT, $string);
open (OUTPUT, "> /tmp/buildohtop");
print OUTPUT '<a href="topicala.html">A</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalb.html">B</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalc.html">C</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicald.html">D</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicale.html">E</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalf.html">F</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalg.html">G</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalh.html">H</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicali.html">I</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalj.html">J</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalk.html">K</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicall.html">L</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalm.html">M</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicaln.html">N</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalo.html">O</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalp.html">P</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalq.html">Q</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalr.html">R</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicals.html">S</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalt.html">T</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalu.html">U</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalv.html">V</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalw.html">W</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalx.html">X</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicaly.html">Y</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalz.html">Z</a>&nbsp;&nbsp;&nbsp;',"\n\n";

for ($l=1; $l <= $numtopics; $l++) {
	$FI = $topic[$order[$l]];
	$FI =~ s/^(.).*/\1/;
	if ( lc($FI) eq $alphabet[$fileindex] ) {
		#print OUTPUT "<p><b>".$topic[$order[$l]]."</b></p>\n";
		print OUTPUT "<h3>".$topic[$order[$l]]."</h3>\n";
		print OUTPUT "<p>\n",$topiclist[$order[$l]],"</p>\n\n";
	}
	else {
		close OUTPUT;
system "iconv --from-code=ISO-8859-1 --to-code=UTF-8 /tmp/buildohtop > $string";
system "rm /tmp/buildohtop";
		#print STDERR "CLOSED ",$alphabet[$fileindex],"\n";
		#print $l,"     ",$topic[$order[$l]],"     ",$fileindex,"\n";
#		print "<p>\n",$topiclist[$order[$l]],"</p>\n\n";
		$l--;
		$fileindex++;
		$string = $topicalpath . $alphabet[$fileindex] . "-core.html";
#		open (OUTPUT, $string);
open (OUTPUT, "> /tmp/buildohtop");
print OUTPUT '<a href="topicala.html">A</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalb.html">B</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalc.html">C</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicald.html">D</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicale.html">E</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalf.html">F</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalg.html">G</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalh.html">H</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicali.html">I</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalj.html">J</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalk.html">K</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicall.html">L</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalm.html">M</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicaln.html">N</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalo.html">O</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalp.html">P</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalq.html">Q</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalr.html">R</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicals.html">S</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalt.html">T</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalu.html">U</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalv.html">V</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalw.html">W</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalx.html">X</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicaly.html">Y</a>&nbsp;&nbsp;&nbsp;',"\n";
print OUTPUT '<a href="topicalz.html">Z</a>&nbsp;&nbsp;&nbsp;',"\n\n";
		#print $l,"     ",$topic[$order[$l]],"     ",$fileindex,"\n";
#		if ( $fileindex == 26 ) {
#		exit;
#		}
	}
}
close OUTPUT;
system "iconv --from-code=ISO-8859-1 --to-code=UTF-8 /tmp/buildohtop > $string";
system "rm /tmp/buildohtop";

#######################################################################
# Build Mobile version
#######################################################################
$fileindex = 0;
$topicalpath = $ohroot . "Web/Build/mobile-topical";
#print $topicalpath,"\n";
$string = $topicalpath . $alphabet[$fileindex] . "-core.html";
#open (OUTPUT, $string);
open (OUTPUT, "> /tmp/buildohtop");

for ($l=1; $l <= $numtopics; $l++) {
	$FI = $topic[$order[$l]];
	$FI =~ s/^(.).*/\1/;
	if ( lc($FI) eq $alphabet[$fileindex] ) {
		#print OUTPUT "<p><b>".$topic[$order[$l]]."</b></p>\n";
		print OUTPUT "<h1>".$topic[$order[$l]]."</h1>\n";
		$out = $topiclist[$order[$l]];
		$out =~ s/javascript:new_window\('([^']*)'\)/\1/g;
		$out =~ s/<a href/<div style="margin-bottom: 5; padding-bottom: 5; margin-top: 5; padding-top: 5; margin-right: 5; padding-right: 5; margin-left: 5; padding-left: 5; font-size:20pt"><a href/g;
		$out =~ s/<\/a>/<\/a><\/div>/g;
		$out =~ s/<\/div> \(2nd tune\)/ \(2nd tune\)<\/div>/g;
		print OUTPUT "\n", $out ,"\n\n";
	}
	else {
		close OUTPUT;
system "iconv --from-code=ISO-8859-1 --to-code=UTF-8 /tmp/buildohtop > $string";
system "rm /tmp/buildohtop";
		#print STDERR "CLOSED ",$alphabet[$fileindex],"\n";
		#print $l,"     ",$topic[$order[$l]],"     ",$fileindex,"\n";
#		print "<p>\n",$topiclist[$order[$l]],"</p>\n\n";
		$l--;
		$fileindex++;
		$string = $topicalpath . $alphabet[$fileindex] . "-core.html";
#		open (OUTPUT, $string);
open (OUTPUT, "> /tmp/buildohtop");
		#print $l,"     ",$topic[$order[$l]],"     ",$fileindex,"\n";
#		if ( $fileindex == 26 ) {
#		exit;
#		}
	}
}
close OUTPUT;
system "iconv --from-code=ISO-8859-1 --to-code=UTF-8 /tmp/buildohtop > $string";
system "rm /tmp/buildohtop";



exit;
