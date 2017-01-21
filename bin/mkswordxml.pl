#!/usr/bin/perl
#######################################################################
#     This is a script to dig through the Open Hymnal files and to 
# automatically build a ThML SWORD input file.
#
# Uses these scripts:
# ohroot
# This script requires iconv and vs2osisref and of course perl.
#
# and these files:
# - Web/genindex*.html (for list and order of hymns)
# - Web/Lyrics/*.html (for Lyrics and copyright info)
# - Web/Lyrics/Abc/*.abc (for Scripture references)
# - Web/topical?.html (for topical indices)
# - Web/people.html (for people index)
# - Web/scripture.html (for Scripture index)
# - Web/tune.html (for tune index)
# 
# it makes these files:
# - none - (sent to STDOUT)
#
# version 1.0 23 Dec 2010 (bjd)
# version 1.1 05 Jan 2011 (bjd) to move file to new bin directory
# version 1.2 28 Jan 2011 (bjd) to handle change to page numbering system for multipage hymns and 3-table genindex.html
# version 1.3 05 Apr 2011 (bjd) initial cut at adding sword:// links in topical index - still need to fix for Choral pieces
# version 1.4 06 Mar 2012 (bjd) better cut at adding sword:// links in topical index and general index - still need to fix for "My Song Shall Be Of Jesus" - always links to Choral Version, but this needs fundamental re-think
#                               also added People Index, Scripture Reference Index, and Alphabetical Tune Index
#
# TO DO:
# NEED TO UPDATE TO AUTO-CHANGE creation date
# INCLUDE METRICAL INDEX 
#######################################################################
$EDITION="2014.06";
$EDYEAR = $EDITION;
$EDYEAR =~ s/[.].*$//;
$OHROOT=`ohroot`;
$OHROOT =~ s/\n//;
#print STDERR $OHROOT;

#######################################################################
# HEADER - this section uses no files
#######################################################################
print '<?xml version="1.0" encoding="UTF-8"?>',"\n";
print '<!DOCTYPE ThML PUBLIC "-//CCEL/DTD Theological Markup Language//EN" "http://www.ccel.org/dtd/ThML10.dtd">',"\n";
print '<ThML>',"\n";
print '<ThML.head>',"\n";
print '<generalInfo>',"\n";
print '<description>Open Hymnal Project Edition ',$EDITION,"\n";
print '</description>',"\n";
print '<pubHistory/>',"\n";
print '<comments/>',"\n";
print '</generalInfo>',"\n";
print '<printSourceInfo>',"\n";
print '<published/>',"\n";
print '</printSourceInfo>',"\n";
print '<electronicEdInfo>',"\n";
print '<publisherID/>',"\n";
print '<authorID>various</authorID>',"\n";
print '<bookID>openhymnal</bookID>',"\n";
print '<version>',$EDITION,'</version>',"\n";
print '<editorialComments/>',"\n";
print '<revisionHistory/>',"\n";
print '<status>This is the ThML version of the Open Hymnal Project</status>',"\n";
print '<DC>',"\n";
print ' <DC.Title>Open Hymnal Project',"\n";
print '</DC.Title>',"\n";
print ' <DC.Creator sub="Author" scheme="short-form">Brian Dumont</DC.Creator>',"\n";
print ' <DC.Creator sub="Author" scheme="file-as">Dumont, Brian</DC.Creator>',"\n";
print ' <DC.Publisher>Open Hymnal Project</DC.Publisher>',"\n";
print ' <DC.Subject scheme="lcsh1">Christian Hymnody</DC.Subject>',"\n";
print ' <DC.Date sub="Created">2012-03-06</DC.Date>',"\n";
print ' <DC.Type>Text.Monograph</DC.Type>',"\n";
print ' <DC.Source/>',"\n";
print ' <DC.Language>en</DC.Language>',"\n";
print ' <DC.Rights>Public Domain</DC.Rights>',"\n";
print '</DC>',"\n";
print '</electronicEdInfo>',"\n";
print '</ThML.head>',"\n";
print '<ThML.body>',"\n";
print '<div1 title="Title_Page">',"\n";
print '<h1>The Open Hymnal Project</h1>',"\n";
print '<h3>Edition ',$EDITION,'</h3>',"\n";
print '<p>',"\n";
print 'This module is a part of the Open Hymnal Project to create a freely distributable, downloadable database of Christian hymns, spiritual songs, and prelude/postlude music.  I am doing my best to create a final product that is "Hymnal-quality", and could feasibly be used as the basis for a printed church hymnal.  This music is to be distributed as complete scores (words and music), using all accompaniment parts, in formats that are easily accessible on most computer OS\'s and which can be freely modified by anyone.  ',"\n";  
print '</p><p>',"\n";
print 'The maintainer of the Open Hymnal Project is Brian J. Dumont (brian dot j dot dumont at gmail dot com).  I have gone through serious efforts to make sure that no copyright mistakes make it into this database.  If I am in error, please inform me as soon as possible.  More information may be found at http://www.openhymnal.org/ ',"\n";
print '</p><p>',"\n";
print 'If you would like to contribute to the Open Hymnal Project, please send an email to me, I would love the help!  PLEASE EMAIL ME IF YOU FIND ANY MISTAKES, no matter how small.  I want to ensure that every slur, stem, 
hyphenation, and punctuation mark is correct; and I\'m sure that there must be mistakes right now.',"\n";
print '</p><p>',"\n";
print 'Open Hymnal Project, ',$EDYEAR,' Edition	<br/>"Freely you received, so freely give." - Matthew 10:8 (WEB) ',"\n";
print '</p>',"\n",'</div1>',"\n";

#######################################################################
# Hymns Sorted Alphabetically - this section uses Web/genindex?.html
#######################################################################
print "\t" . '<div1 title="Hymns">',"\n";
print "\t" . '<h1>All Hymns Sorted Alphabetically</h1>',"\n";
@alphabet = ("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","other");
#@alphabet = ("a");
$numother=0;
foreach $j (@alphabet) {
	print "\t\t" . '<div2 title="Alphabetical_' . uc($j) . '">' , "\n";
	print "\t\t" . '<h2>All Hymns Starting with ' . uc($j) . '</h2>' , "\n";
	$webindexfilename = $OHROOT . "Web/genindex" . $j . ".html";
	#print $webindexfilename,"\n";
	open (INPUT, $webindexfilename );
	$file = "";
	$digging = 0;
	while (<INPUT>) {
		if ($digging == 1) {
			if ( /<\/tbody>/ ) {
				$digging = 0;
			}
			else {
				$file .= $_;
			}
		}
		elsif ( /<tbody>/ ) {
			$digging = 1;
		}
	}
	close INPUT;
	#print $file;
	@parts = split '<p class="title">', $file;
	for ($i=1; $i < @parts; $i++) {
		@bits = split '</p>', $parts[$i];
		$bits[0] =~ s/<a href="javascript:new_window\('//;
		$bits[0] =~ s/'\)">[^<]*<\/a>//;
		if ( $j eq "other" ) {
			$other[$numother] = $bits[0];
			$other[$numother] =~ s/^Lyrics\/([A-Z])/sword:\/\/OpenHymnal\/Hymns\/Alphabetical_\1\/\1/;
			$other[$numother] =~ s/.html$//;
			$other[$numother] =~ s/-.*$//;
			#<a href="sword:\/\/OpenHymnal\/Hymns\/Alphabetical_\1\/\1\2
			#<a href="sword:\/\/OpenHymnal\/Hymns\/Alphabetical_\1\/\1\2
			#print STDERR "OTHER: " . $other[$numother] . "\n";
			$numother += 1;
		}
		$lyricfile = $OHROOT . "Web/" . $bits[0];
		$giffile = $bits[0];
		$giffile =~ s/Lyrics\///;
		$giffile =~ s/[.]html/.gif/;
		$abcfile = $OHROOT . "Web/" . $bits[0];
		$abcfile =~ s/Lyrics\//Abc\//;
		$abcfile =~ s/[.]html/.abc/;
		$title = $bits[0];
		$title =~ s/[-].*//;
		$title =~ s/Lyrics\///;
		#print $title,"\n";
		print "\t\t\t" . '<div3 title="' . $title . '">' , "\n";
		#system "iconv --from-code=ISO-8859-15 --to-code=UTF-8 $lyricfile > /tmp/buildsword";
		#open (INPUT, "/tmp/buildsword" );
		open (INPUT, $lyricfile );
		$lyrics = "";
		$digging = 0;
		while (<INPUT>) {
			if ($digging == 1) {
				if ( /jquery_jplayer/ ) {
					$digging = 2;
				}
				elsif ( /<table/ ) {
					$digging = 2;
				}
				else {
					$lyrics .= $_;
				}
			}
			elsif ( /<BODY/ ) {
				$digging = 1;
			}			
		}
		$lyrics =~ s/cellpadding="[0-9]*"//g;
		$lyrics =~ s/& /&amp; /g;
		close INPUT;
		print $lyrics, "\n";
		print "\t\t\t\t" . '<p><img src="/images/' . $giffile . '" alt="Missing score, Gif apparently not supported"/></p>' . "\n";
		open (INPUT, $abcfile );
		while (<INPUT>) {
			if ( /%OHSCRIP/ ) {
				$footer = $_;
			}
		}
		close INPUT;
		$footer =~ s/^%OHSCRIP //;
		#if ( /Page / ) {
		#	print STDERR $footer, "\n";
		#	}
		$footer =~ s/\t\t[^\\]*Page \$P of [0-9]*"$//;
		$footer =~ s/\t\t"$//;
		$footer =~ s/\t\t//;
		$footer =~ s/\\n/ /g;
		$footer =~ s/\n/ /g;
		$footer =~ s/Rm /Rom /g;
		$footer =~ s/1Tm /1 Tim /g;
		$footer =~ s/2Tm /2 Tim /g;
		$footer =~ s/1Jn /1 Jn /g;
		$footer =~ s/2Jn /2 Jn /g;
		$footer =~ s/3Jn /3 Jn /g;
		$footer =~ s/1Pt /1 Pt /g;
		$footer =~ s/1Pt /2 Pt /g;
		$command = 'vs2osisref "' . $footer . '"';
		$ref = "";
		$ref = `$command`;
		$ref =~ s/<reference osisRef=/<scripRef passage=/g;
		$ref =~ s/<\/reference>/<\/scripRef>/g;
		#print STDERR $ref, "\n";
		#print STDERR $ref, "\n";
		print "\t\t\t\t" . '<p>' . $ref . '</p>' . "\n";

		print "\t\t\t" . '</div3>' , "\n";
	}
	print "\t\t" . '</div2>' , "\n";

}
print "\t" . '</div1>' , "\n";

#######################################################################
# General Index - uses Web/genindex.html only 
#######################################################################
print "\t" . '<div1 title="General_Index">',"\n";
	#$command = "iconv --from-code=ISO-8859-1 --to-code=UTF-8 " . $OHROOT . "Web/genindex.html > /tmp/buildsword";
	#system $command;
	#open (INPUT, "/tmp/buildsword" );
	open (INPUT, $OHROOT . "Web/genindex.html" );
	$file = "";
	$digging = 0;
	while (<INPUT>) {
		$_ =~ s/<td colspan="8">/<td colspan="6">/;
		if ($digging == 1) {
			if ( /<!--  END ADD CORE HERE -->/ ) {
				$digging = 0;
				#$file .= $_;
			}
			elsif ( /<p class="midi">/ || /<p class="mp3">/ ) {
			}
			else {
				$file .= $_;
			}
		}
		elsif ( /<h4>/ ) {
			$digging = 1;
			$file .= $_;
		}
	}
	close INPUT;
	$file =~ s/(<tr valign="top">)([\n\t ]*<th>)/\1\n\t\t\t\2/g;
	$file =~ s/<th>[\n\t]*<p class="western">MIDI Link<\/p>[\n\t]*<\/th>//g;
	$file =~ s/<th>[\n\t]*<p class="western">MP3 Link<\/p>[\n\t]*<\/th>//g;
	$file =~ s/ \(Link to Hymn\)//g;
#	$file =~ s/<a href="javascript:new_window\('[^']*'\)">//g;
	$file =~ s/<a href=\"javascript\:new_window\(\'Lyrics\/([A-Z])([^.-]*)[^>]*>/<a href="sword:\/\/OpenHymnal\/Hymns\/Alphabetical_\1\/\1\2">/g;
	for ($i=0; $i < $numother; $i++) {
		$new = $other[$i];
		$new =~ s/Alphabetical_[A-Z]/Alphabetical_OTHER/;
		#print STDERR "NEED TO FIX" . $other[$i] . "  becomes  " . $new . "\n";		
		$file =~ s|$other[$i]|$new|g;
	}


#	$file =~ s/<\/a>//g;
	$file =~ s/<[\/]?center>//g;
	$file =~ s/<br>/<br\/>/g;
	$file =~ s/& /&amp; /g;
	$file =~ s/<p class="complex" align="center">/<p class="complex">/g;
	$file =~ s/<table [^>]*>/<table border="1">/g;
	$file =~ s/<div title="[^\"]*">([^<]*)<\/div>/<scripRef passage="\1">\1<\/scripRef>/g;

	print $file;
	print "\t" . '</div1>' , "\n";
	
#######################################################################
# Topical Index - this section uses Web/topical?.html - UPDATE FOR FIXED (read: valid) html
#######################################################################
print "\t" . '<div1 title="Topical_Index">',"\n";
print "\t" . '<h1>Topical Index</h1>',"\n";
@alphabet = ("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z");
foreach $j (@alphabet) {
	print "\t\t" . '<div2 title="Topical_' . uc($j) . '">' , "\n";
	print "\t\t" . '<h2>All Topics Starting with ' . uc($j) . '</h2>' , "\n";
	$webindexfilename = $OHROOT . "Web/topical" . $j . ".html";
	#print $webindexfilename,"\n";
	open (INPUT, $webindexfilename );
	$file = "";
	$digging = 0;
	while (<INPUT>) {
		if ($digging == 1) {
			if ( /<!--  END ADD CORE HERE -->/ ) {
				$digging = 0;
			}
			elsif ( /<a href="topical/ ) {
			}
			else {
				$file .= $_;
			}
		}
		elsif ( /<!--  START ADD CORE HERE -->/ ) {
			$digging = 1;
		}
	}
	close INPUT;
	#$file =~ s/
	# <a href="javascript:new_window('Lyrics/A_Mighty_Fortress_Is_Our_God-Ein_Feste_Burg_Rhythmic.html')">
	# <a href="sword://OpenHymnal/Hymns/Alphabetical_A/A_Mighty_Fortress_Is_Our_God">
	$file =~ s/<a href=\"javascript\:new_window\(\'Lyrics\/([A-Z])([^.-]*)[^>]*>/<a href="sword:\/\/OpenHymnal\/Hymns\/Alphabetical_\1\/\1\2">/g;
	for ($i=0; $i < $numother; $i++) {
		$new = $other[$i];
		$new =~ s/Alphabetical_[A-Z]/Alphabetical_OTHER/;
		#print STDERR "NEED TO FIX" . $other[$i] . "  becomes  " . $new . "\n";		
		$file =~ s|$other[$i]|$new|g;
	}

	#$file =~ s/<\/a>//g;
	$file =~ s/<br>/<br\/>/g;
	$file =~ s/& /&amp; /g;
#	$file =~ s/^<p>\n//;
#	$file =~ s/<p><b>/<h4>/;
#	$file =~ s/<p><b>/<\/p>\n\t\t<h4>/g;
#	$file =~ s/<\/b><\/p>/<\/h4>\n\t\t<p>\n/g;
	print $file;

#	if ( $file eq "\n" ) {
		print "\t\t" . '</div2>' , "\n";
#	}
#	else {
#		print "\t\t" . '</p>' . "\n\t\t" . '</div2>' , "\n";
#	}

}
print "\t" . '</div1>' , "\n";


#######################################################################
# People Index - this section uses Web/people.html
#######################################################################
print "\t" . '<div1 title="People_Index">',"\n";
print "\t" . '<h1>Index of Authors, Translators, Composers, and Arrangers</h1>',"\n";
	#$command = "iconv --from-code=ISO-8859-1 --to-code=UTF-8 " . $OHROOT . "Web/people.html > /tmp/buildsword";
	#system $command;
	#open (INPUT, "/tmp/buildsword" );
	open (INPUT, $OHROOT . "Web/people.html" );
	$file = "";
	$digging = 0;
	while (<INPUT>) {
		$_ =~ s/<td colspan="8">/<td colspan="6">/;
		if ($digging == 1) {
			if ( /<!--  END ADD CORE HERE -->/ ) {
				$digging = 0;
				#$file .= $_;
			}
			else {
				$file .= $_;
			}
		}
		elsif ( /<h3>/ ) {
			$digging = 1;
			#$file .= $_;
		}
	}
	close INPUT;
	$file =~ s/<a href=\"javascript\:new_window\(\'Lyrics\/([A-Z])([^.-]*)[^>]*>/<a href="sword:\/\/OpenHymnal\/Hymns\/Alphabetical_\1\/\1\2">/g;
	for ($i=0; $i < $numother; $i++) {
		$new = $other[$i];
		$new =~ s/Alphabetical_[A-Z]/Alphabetical_OTHER/;
		#print STDERR "NEED TO FIX" . $other[$i] . "  becomes  " . $new . "\n";		
		$file =~ s|$other[$i]|$new|g;
	}
	
print $file;
print "\t" . '</div1>' , "\n";


#######################################################################
# Scripture Index - this section uses Web/scripref.html
#######################################################################
print "\t" . '<div1 title="Scripture_Index">',"\n";
print "\t" . '<h1>Index of Scripture References</h1>',"\n";
	#$command = "iconv --from-code=ISO-8859-1 --to-code=UTF-8 " . $OHROOT . "Web/scripref.html > /tmp/buildsword";
	#system $command;
	#open (INPUT, "/tmp/buildsword" );
	open (INPUT, $OHROOT . "Web/scripref.html" );
	$file = "";
	$digging = 0;
	while (<INPUT>) {
		$_ =~ s/<td colspan="8">/<td colspan="6">/;
		if ($digging == 1) {
			if ( /<!--  END ADD CORE HERE -->/ ) {
				$digging = 0;
				#$file .= $_;
			}
			else {
				$file .= $_;
			}
		}
		elsif ( /<h3>/ ) {
			$digging = 1;
			#$file .= $_;
		}
	}
	close INPUT;
	$file =~ s/<a href=\"javascript\:new_window\(\'Lyrics\/([A-Z])([^.-]*)[^>]*>/<a href="sword:\/\/OpenHymnal\/Hymns\/Alphabetical_\1\/\1\2">/g;
	for ($i=0; $i < $numother; $i++) {
		$new = $other[$i];
		$new =~ s/Alphabetical_[A-Z]/Alphabetical_OTHER/;
		#print STDERR "NEED TO FIX" . $other[$i] . "  becomes  " . $new . "\n";		
		$file =~ s|$other[$i]|$new|g;
	}
	
	$file =~ s/<tr><td>([A-Za-z0-9 :,-]*)<\/td>/<tr><td><scripRef passage="\1">\1<\/scripRef><\/td>/g;
print $file;
print "\t" . '</div1>' , "\n";


#######################################################################
# Tune Index - this section uses Web/tune.html
#######################################################################
print "\t" . '<div1 title="Tune_Index">',"\n";
print "\t" . '<h1>Index of Tunes in Alphabetical Order</h1>',"\n";
	#$command = "iconv --from-code=ISO-8859-1 --to-code=UTF-8 " . $OHROOT . "Web/tune.html > /tmp/buildsword";
	#system $command;
	#open (INPUT, "/tmp/buildsword" );
	open (INPUT, $OHROOT . "Web/tune.html" );
	$file = "";
	$digging = 0;
	while (<INPUT>) {
		$_ =~ s/<td colspan="8">/<td colspan="6">/;
		if ($digging == 1) {
			if ( /<!--  END ADD CORE HERE -->/ ) {
				$digging = 0;
				#$file .= $_;
			}
			else {
				$file .= $_;
			}
		}
		elsif ( /<h2>/ ) {
			$digging = 1;
			#$file .= $_;
		}
	}
	close INPUT;
	$file =~ s/<a href=\"javascript\:new_window\(\'Lyrics\/([A-Z])([^.-]*)[^>]*>/<a href="sword:\/\/OpenHymnal\/Hymns\/Alphabetical_\1\/\1\2">/g;
	for ($i=0; $i < $numother; $i++) {
		$new = $other[$i];
		$new =~ s/Alphabetical_[A-Z]/Alphabetical_OTHER/;
		#print STDERR "NEED TO FIX" . $other[$i] . "  becomes  " . $new . "\n";		
		$file =~ s|$other[$i]|$new|g;
	}
	
	$file =~ s/<tr><td>([A-Za-z0-9 :,-]*)<\/td>/<tr><td><scripRef passage="\1">\1<\/scripRef><\/td>/g;
print $file;
print "\t" . '</div1>' , "\n";




print '</ThML.body></ThML>' , "\n";
exit;
