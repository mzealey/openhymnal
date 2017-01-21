#!/usr/bin/perl
#use File::Grep qw( fgrep fmap fdo );
#######################################################################
#     This is a script to dig through the abc files, and build a 
# scriture reference index and from them.
#
# Uses these scripts:
# ohroot
#
# and these files:
# Complete/*/*.abc
# Choir/*/*.abc
# 
# it makes these files:
# topical-big.html
#
# version 1.0 03 Jan 2011 (bjd)
# version 2.0 27 Aug 2013 (bjd) to convert to UTF-8 output
#######################################################################
$ohroot=`ohroot`;
$ohroot=~ s/\n//;
$filepath=$ohroot . "Complete/*/*.abc " . $ohroot . "Choir/*/*.abc";
@rawfiles = <$filepath >; 


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
	#print $files[$i],"\n";
}


$numrefs = 0;
#######################################################################
# Dig through the ABC files to extract and sort all of the topical
# index information into an array of all the hymns which fit each
# specific topic.
#######################################################################
foreach $file (@files) {
#   print $file . "\n";
	open (INPUT, $file);
	$formal_hymn_number=`present-hymn-number $file`;
	$formal_hymn_number =~ s/\n//;
	$gottitle = 0;
	$reflistraw = "";
	while (<INPUT>) {
		if ( /%OHSCRIP/ ) {
			$_ =~ s/^%OHSCRIP //g;
			$_ =~ s/\t\t[\\][n]/ /g;
			$_ =~ s/\t\t[^\t]*$//g;
			$_ =~ s/[\\]n//g;
			$_ =~ s/\n//g;
			#print $_,"\n";
			$reflistraw = $_;
		}
		elsif ( ( /T:/ ) && ( $gottitle == 0 ) ) {
			#print $_;
			$title = $_;
			$title =~ s/T: //;
			$title =~ s/\n//;
			$gottitle = 1;
			@parts = split ",", $reflistraw;
			$bookref = "";
			for ($i = 0; $i < @parts; $i++) {
				$ref = $parts[$i];
				$ref =~ s/^[ ]*//;
				$_ = $ref;
				
				# this adds a proper book reference when there is a reference 
				# without full explicit book names like:
				# Ex 14:19-25, 19:16-20, 25:10, 31:18, 34:4-5
				if ( /[A-Z]/ ) {  
					$bookref = $ref;
					$bookref =~ s/[^A-Za-z]*$//
				}
				else {
					$ref = $bookref . " " . $ref;
				}
				
				# For error-prevention, normalize the reference using vs2osisref
				$command = 'vs2osisref "' . $ref . '"';
				$refnorm = "";
				$refnorm = `$command`;
				$refnorm =~ s/<reference osisRef="//g;
				$refnorm =~ s/".*$//g;
				$refnorm =~ s/\n//g;
				# Add book numbers for internal sorting - Apocrypha are added this way
				# straight-up gives a typical Protestant ordering
				# subtracting 1000 from all numbers over 1000 will give a Roman book ordering
				$refnorm =~ s/^Gen/10|Gen/;
				$refnorm =~ s/^Exod/20|Exod/;
				$refnorm =~ s/^Lev/30|Lev/;
				$refnorm =~ s/^Num/40|Num/;
				$refnorm =~ s/^Deut/50|Deut/;
				$refnorm =~ s/^Josh/60|Josh/;
				$refnorm =~ s/^Judg/70|Judg/;
				$refnorm =~ s/^Ruth/80|Ruth/;
				$refnorm =~ s/^1Sam/90|1Sam/;
				$refnorm =~ s/^2Sam/100|2Sam/;
				$refnorm =~ s/^1Kgs/110|1Kgs/;
				$refnorm =~ s/^2Kgs/120|2Kgs/;
				$refnorm =~ s/^1Chr/130|1Chr/;
				$refnorm =~ s/^2Chr/140|2Chr/;
				$refnorm =~ s/^Ezra/150|Ezra/;
				$refnorm =~ s/^Neh/160|Neh/;
				$refnorm =~ s/^Esth/190|Esth/;
				$refnorm =~ s/^Job/220|Job/;
				$refnorm =~ s/^Ps/230|Ps/;
				$refnorm =~ s/^Prov/240|Prov/;
				$refnorm =~ s/^Eccl/250|Eccl/;
				$refnorm =~ s/^Song/260|Song/;
				$refnorm =~ s/^Isa/290|Isa/;
				$refnorm =~ s/^Jer/300|Jer/;
				$refnorm =~ s/^Lam/310|Lam/;
				$refnorm =~ s/^Ezek/330|Ezek/;
				$refnorm =~ s/^Dan/340|Dan/;
				$refnorm =~ s/^Hos/350|Hos/;
				$refnorm =~ s/^Joel/360|Joel/;
				$refnorm =~ s/^Amos/370|Amos/;
				$refnorm =~ s/^Obad/380|Obad/;
				$refnorm =~ s/^Jonah/390|Jonah/;
				$refnorm =~ s/^Mic/400|Mic/;
				$refnorm =~ s/^Nah/410|Nah/;
				$refnorm =~ s/^Hab/420|Hab/;
				$refnorm =~ s/^Zeph/430|Zeph/;
				$refnorm =~ s/^Hag/440|Hag/;
				$refnorm =~ s/^Zech/450|Zech/;
				$refnorm =~ s/^Mal/460|Mal/;
				$refnorm =~ s/^Matt/470|Matt/;
				$refnorm =~ s/^Mark/480|Mark/;
				$refnorm =~ s/^Luke/490|Luke/;
				$refnorm =~ s/^John/500|John/;
				$refnorm =~ s/^Acts/510|Acts/;
				$refnorm =~ s/^Rom/520|Rom/;
				$refnorm =~ s/^1Cor/530|1Cor/;
				$refnorm =~ s/^2Cor/540|2Cor/;
				$refnorm =~ s/^Gal/550|Gal/;
				$refnorm =~ s/^Eph/560|Eph/;
				$refnorm =~ s/^Phil/570|Phil/;
				$refnorm =~ s/^Col/580|Col/;
				$refnorm =~ s/^1Thess/590|1Thess/;
				$refnorm =~ s/^2Thess/600|2Thess/;
				$refnorm =~ s/^1Tim/610|1Tim/;
				$refnorm =~ s/^2Tim/620|2Tim/;
				$refnorm =~ s/^Titus/630|Titus/;
				$refnorm =~ s/^Phlm/640|Phlm/;
				$refnorm =~ s/^Heb/650|Heb/;
				$refnorm =~ s/^Jas/660|Jas/;
				$refnorm =~ s/^1Pet/670|1Pet/;
				$refnorm =~ s/^2Pet/680|2Pet/;
				$refnorm =~ s/^1John/690|1John/;
				$refnorm =~ s/^2John/700|2John/;
				$refnorm =~ s/^3John/710|3John/;
				$refnorm =~ s/^Jude/720|Jude/;
				$refnorm =~ s/^Rev/730|Rev/;
				$refnorm =~ s/^Tob/1170|Tob/;
				$refnorm =~ s/^Jdt/1180|Jdt/;
				$refnorm =~ s/^AddEsth/1191|AddEsth/;
				$refnorm =~ s/^1Macc/1200|1Macc/;
				$refnorm =~ s/^2Macc/1210|2Macc/;
				$refnorm =~ s/^3Macc/2211|3Macc/;
				$refnorm =~ s/^4Macc/2212|4Macc/;
				$refnorm =~ s/^Wis/1270|Wis/;
				$refnorm =~ s/^Sir/1280|Sir/;
				$refnorm =~ s/^Bar/1320|Bar/;
				$refnorm =~ s/^Sus/1341|Sus/;
				$refnorm =~ s/^Bel/1342|Bel/;
				$refnorm =~ s/^1Esd/2740|1Esd/;
				$refnorm =~ s/^2Esd/2750|2Esd/;
				$refnorm =~ s/^EpJer/2760|EpJer/;
				$refnorm =~ s/^PrAzar/2770|PrAzar/;
				$refnorm =~ s/^PrMan/2790|PrMan/;
				$refnorm =~ s/^Ps151/2800|Ps151/;
				$bookversestart = $refnorm;
				$bookversestart =~ s/^[^|]*[|][^.]*[.]//g;
				$bookversestart =~ s/[-].*//g;
				$booknum = $bookversestart;
				$booknum =~ s/[.].*//g;
				$versenum = $bookversestart;
				$versenum =~ s/.*[.]//g;
				# this converts the book and verse into a decimal - no book or verse has 200 chapters
				$bookversestart = ($booknum + $versenum/200.0)/200.0; 
				
				$refnorm =~ s/^([0-9]*)|/\1$bookversestart/; # now $refnorm before the "|" is a numerical search index
				#print $refnorm,"  -->  ", $title,"  -->  ",$ref,"\n";

 				$link = $file;
				$link =~ s/^.*\//Lyrics\//g;
				$link =~ s/[.]abc/.html/g;
				$reforder[$numrefs] = $refnorm;
				$reforder[$numrefs] =~ s/[|].*//;
				$refhymn[$numrefs] = $title;
				$reflink[$numrefs] = $link;
				$refhymnnum[$numrefs] = $formal_hymn_number;
				$reference[$numrefs] = $ref;
				$numrefs++;
			}
		}
	}
	close INPUT;
} 


#######################################################################
# Sort the references in numerical order and write out
#######################################################################
for ($i=0; $i < $numrefs; $i++) {
	$order[$i] = -1;
	$sort[$i] = $reforder[$i];
}
for ($i=0; $i < $numrefs; $i++) {
	$guess = 0;
	for ($j=1; $j < $numrefs; $j++) {
		if ( $reforder[$j] < $reforder[$guess] ) {
			$guess = $j;
		}
	}
	$order[$i] = $guess;
	$reforder[$guess] = "99999999";
}

$string = $ohroot . "Web/Build/scripref-core.html";
open (OUTPUT, "> /tmp/buildohscr");
print OUTPUT "<h3>Open Hymnal, Index of Scripture References</h3>\n<table>\n";
for ($l=0; $l < $numrefs; $l++) {
	print OUTPUT '<tr><td>',$reference[$order[$l]],"</td><td><a href=\"javascript:new_window('",$reflink[$order[$l]],"')\">",$refhymn[$order[$l]],"</a></td></tr>\n";
}
print OUTPUT "</table>\n";
close OUTPUT;
system "iconv --from-code=ISO-8859-1 --to-code=UTF-8 /tmp/buildohscr > $string";
system "rm /tmp/buildohscr";

$string = $ohroot . "Web/Build/mobile-scripref-core.html";
open (OUTPUT, "> /tmp/buildohscr");
print OUTPUT "<h1>Scripture Reference Index</h1>\n";
for ($l=0; $l < $numrefs; $l++) {
	print OUTPUT '<div style="margin-bottom: 5; padding-bottom: 5; margin-top: 5; padding-top: 5; margin-right: 5; padding-right: 5; margin-left: 5; padding-left: 5; font-size:20pt"><p>',$reference[$order[$l]]," ~ <a href=\"javascript:new_window('",$reflink[$order[$l]],"')\">",$refhymn[$order[$l]],"</a></p></div>\n";
}
print OUTPUT "\n";
close OUTPUT;
system "iconv --from-code=ISO-8859-1 --to-code=UTF-8 /tmp/buildohscr > $string";
system "rm /tmp/buildohscr";

exit;
