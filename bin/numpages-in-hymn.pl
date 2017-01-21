#!/usr/bin/perl
#######################################################################
#     This is a script to count the number of printed pages used by a
# specific hymn.
#
# Uses these scripts:
# ohroot
#
# and these files:
# as-called abc
# 
# it makes these files:
# - none - (sent to STDOUT)
#
# version 1.0 05 Jan 2011 (bjd)
#######################################################################

$ohroot=`ohroot`;
$ohroot=~ s/\n//;
$file = $ARGV[0];
$numpages = 1;
open (INPUT, $file );
$data = "";

while ( <INPUT> ) {
	if ( /%%newpage/ ) {
		$numpages += 1;
	}
}

close INPUT;

print $numpages,"\n";

exit;
