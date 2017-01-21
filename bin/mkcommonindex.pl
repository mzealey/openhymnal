#!/usr/bin/perl
#######################################################################
#     This is a script to dig through the Open Hymnal files and to 
# automatically build a html input file formatted to allow OpenOffice
# to read it in easily.
#
# Uses these scripts:
# ohroot
# This script requires iconv and vs2osisref and of course perl.
#
# and these files:
# - Web/genindex*.html (for list and order of hymns)
# 
# it makes these files:
# - none - (sent to STDOUT)
#
# version 1.0 06 Jan 2011 (bjd) 
# version 1.1 13 Jan 2011 (bjd) to fix character encoding for OpenOffice import
#######################################################################
$OHROOT=`ohroot`;
$OHROOT =~ s/\n//;
#print STDERR $OHROOT;
$hymnnum=15;


#######################################################################
# General Index - uses Web/genindex.html only
#######################################################################
#	$command = "iconv --from-code=ISO-8859-1 --to-code=UTF-8 " . $OHROOT . "Web/genindex.html > /tmp/buildsword";
	$command = "cat " . $OHROOT . "Web/genindex.html > /tmp/buildsword";
	system $command;
	open (INPUT, "/tmp/buildsword" );
	$file = "";
	$digging = 0;
	while (<INPUT>) {
		$_ =~ s/<td colspan="8">/<td colspan="7">/;
		if ( /<p class="title">/ ) {
			$fn = $_;
			$fn =~ s/.*<a href\=\"javascript\:new_window\(\'Lyrics\///;
			$fn =~ s/[.]html.*$/.abc/;
#			print $fn;
			$hymnnum = `present-hymn-number $fn`;
			$hymnnum =~ s/\n//;
			$_ =~ s/<td><p class="title">/<td>$hymnnum<\/td>\n\t\t\t<td><p class="title">/;
		}
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
		elsif ( /<!--  START ADD CORE HERE -->/ ) {
			$digging = 1;
			#$file .= $_;
		}
	}
	close INPUT;
	
	$file =~ s/(<tr valign="top">)([\n\t ]*<th>)/\1\n\t\t\t<th>No.<\/th>\2/g;
	$file =~ s/<th>[\n\t]*<p class="western">MIDI Link<\/p>[\n\t]*<\/th>//g;
	$file =~ s/<th>[\n\t]*<p class="western">MP3 Link<\/p>[\n\t]*<\/th>//g;
	$file =~ s/ \(Link to Hymn\)//g;
	$file =~ s/<a href="javascript:new_window\('[^']*'\)">//g;
	$file =~ s/<\/a>//g;
	$file =~ s/<br>/<br\/>/g;
	$file =~ s/& /&amp; /g;
	$file =~ s/<p class="complex" align="center">/<p class="complex">/g;
	$file =~ s/<table [^>]*>/<table border="1">/g;
	print $file;

exit;
