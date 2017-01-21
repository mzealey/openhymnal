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
# topical-big.html
#
# version 1.0 03 Jan 2011 (bjd)
# version 1.1 27 Jan 2011 (bjd) - include "New/Ready/*/*.abc"
#######################################################################
$ohroot=`ohroot`;
$ohroot=~ s/\n//;

@files = `list-hymns-in-OH-order.pl`;
for ($i=0; $i < @files; $i++) {
	$files[$i] =~ s/\n//;
	#print $files[$i],"\n";
}
#exit;

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
	$formal_hymn_number=`present-hymn-number $file`;
	$formal_hymn_number=~ s/\n//;
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
							$entrycheck = "<p>".$formal_hymn_number.". ".$title." ".$extras."</p>";
							#$entrycheck = $title." ".$extras."</a><br/>";
						}
						else {
							$entrycheck = "<p>".$formal_hymn_number.". ".$title."</p>";
							#$entrycheck = $title."</a><br/>";
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
								$topiclist[$l] .= "<p>".$formal_hymn_number.". ".$title." ".$extras."</p>\n";
								#$topiclist[$l] .= '<a href="'."javascript:new_window('".$link."')".'">'.$title." ".$extras."</a><br/>\n";
							}
							else {
								$topiclist[$l] .= "<p>".$formal_hymn_number.". ".$title."</p>\n";
								#$topiclist[$l] .= '<a href="'."javascript:new_window('".$link."')".'">'.$title."</a><br/>\n";
							}
 						}
 						else {
							print STDERR "double on ".$title." for ".$topic[$l]."\n";
 						}
						$found = 1;
 					}
 				}
 				if ( $found == 0 ) {
 					$numtopics += 1;
 					$topic[$numtopics] = $topicbare;
					if ( length($extras) > 1 ) {
						$topiclist[$numtopics] .= "<p>".$formal_hymn_number.". ".$title." ".$extras."</p>\n";
						#$topiclist[$numtopics] .= '<a href="'."javascript:new_window('".$link."')".'">'.$title." ".$extras."</a><br/>\n";
					}
					else {
						$topiclist[$numtopics] .= "<p>".$formal_hymn_number.". ".$title."</p>\n";
						#$topiclist[$numtopics] .= '<a href="'."javascript:new_window('".$link."')".'">'.$title."</a><br/>\n";
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
$fileindex = 0;
$string = ">> back-indices.html";
open (OUTPUT, $string);
print OUTPUT "<h2>Topical Index</h2>\n";
for ($l=1; $l <= $numtopics; $l++) {
	$FI = $topic[$order[$l]];
	$FI =~ s/^(.).*/\1/;
		print OUTPUT "<h3>".$topic[$order[$l]]."</h3>\n";
		#print OUTPUT "<h3>".$topic[$order[$l]]."</h3>\n";
		print OUTPUT $topiclist[$order[$l]],"\n\n";
}
close OUTPUT;

exit;
