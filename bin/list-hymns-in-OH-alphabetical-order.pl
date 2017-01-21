#!/usr/bin/perl
#use File::Grep qw( fgrep fmap fdo );
#######################################################################
#     This is a script to dig through the abc files, and sort them
#
# Uses these scripts:
# ohroot
#
# and these files:
# Complete/*/*.abc Choir/*/*.abc
# 
# it makes these files:
# - none -
# 
# version 1.0 05 Jan 2011 (bjd)
#######################################################################

$ohroot=`ohroot`;
$ohroot=~ s/\n//;
$filepath=$ohroot . "Complete/*/*.abc " . $ohroot . "New/Ready/*/*.abc";
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
	print $files[$i],"\n";
}



$filepath= $ohroot . "Choir/*/*.abc";
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
	print $files[$i],"\n";
}

exit;
