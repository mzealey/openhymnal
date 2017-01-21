#!/usr/bin/perl
#use File::Grep qw( fgrep fmap fdo );
#######################################################################
#     This is a script to dig through the abc files, and sort them
#
# Uses these scripts:
# ohroot
#
# and these files:
# Complete/*/*.abc 
# 
# it makes these files:
# - none -
# 
# version 1.0 05 Jan 2011 (bjd)
# version 2.0 24 Mar 2014 to remove choir pieces (bjd)
#######################################################################

$ohroot=`ohroot`;
$ohroot=~ s/\n//;
#$filepath=$ohroot . "Complete/*/*.abc " . $ohroot . "Choir/*/*.abc";
$filepath=$ohroot . "Complete/*/*.abc";
@realrawfiles = <$filepath >; 


# First, see if OH_ORDER.txt is current.  If so, just use it.  Otherwise, rebuild.
$string = "< " . $ohroot . "bin/OH-ORDER.txt";
open (LIST, $string);
$list = "";
for ($i=0; $i < @realrawfiles; $i++) {
	$found[$i] = 0;
}
while ( <LIST> ) {
	$list .= $_;
	$_ =~ s/\n//;
	for ($i=0; $i < @realrawfiles; $i++) {
		if ( $realrawfiles[$i] eq $_ ) {
			$found[$i] = 1;
		}
	}
}
$needtorebuild = 0;
for ($i=0; $i < @realrawfiles; $i++) {
	if ( $found[$i] == 0 ) {
		print STDERR "DIDN'T FIND ",$realrawfiles[$i],"\n";
		$needtorebuild = 1;
	}
}

if ($needtorebuild == 0) {
	print $list;
	exit;
}


@categories = ("OPENING SONGS", "CLOSING SONGS", "ADVENT", "CHRISTMAS", "EPIPHANY", "LIFE", "TRANSFIGURATION", "LENT", "PALM SUNDAY", "GOOD THURSDAY", "GOOD FRIDAY", "EASTER", "ASCENSION", "PENTECOST", "TRINITY", "REFORMATION", "BAPTISMAL LIFE", "CONFESSION/ABSOLUTION", "LORD'S SUPPER", "WORD OF GOD", "REDEEMER", "JUSTIFICATION", "CROSS AND COMFORT", "END TIMES", "HEAVEN", "COMMUNION OF SAINTS", "CONSECRATION", "NEW OBEDIENCE", "PRAYER", "PRAISE", "THANKSGIVING", "TRUST", "FUNERAL", "MISSIONS", "STEWARDSHIP", "CHRISTIAN HOME", "MORNING", "EVENING");

for ($c=0; $c < @categories; $c++) {
#for ($c=0; $c < 5; $c++) {
#print $categories[$c],"\n";

#######################################################################
# Sort the files by hymn name in OH-style alphabetical order
#######################################################################
$numuse = 0;
$string = "%OHCATEGORY " . $categories[$c];
#print $string,"\n";
for ($i=0; $i < @realrawfiles; $i++) {
	$use = `grep \"$string\" $realrawfiles[$i]`;
	if ( length ( $use ) > 0 ) {
		$rawfiles[$numuse] = $realrawfiles[$i];
		$numuse++;
	}
}


for ($i=0; $i < $numuse; $i++) {
		$sortfile[$i] = $rawfiles[$i];
		$sortfile[$i] =~ s/_/0/g;
		$sortfile[$i] =~ s/^.*\///g;
		$sortfile[$i] =~ s/-.*//g;
		$sortfile[$i] =~ s/[.].*//g;
		$sortfile[$i] =~ s/[!,;.'?()]//g;
		$sortfile[$i] = uc($sortfile[$i]);
		$order[$i] = -1;
}
for ($i=0; $i < $numuse; $i++) {
		$guess = 0;
		for ($j=1; $j < $numuse; $j++) {
			if ( $sortfile[$j] lt $sortfile[$guess] ) {
				$guess = $j;
			}
		}
		$order[$i] = $guess;
		$sortfile[$guess] = "~";
}
for ($i=0; $i < $numuse; $i++) {
	$files[$i] = $rawfiles[$order[$i]];
	print $files[$i],"\n";
}
for ($i=0; $i < $numuse; $i++) {
	$rawfiles[$i] = "";
}

}
exit;

