#!/usr/bin/perl
#use File::Grep qw( fgrep fmap fdo );
#######################################################################
#     
#
# Uses these scripts:
# ohroot
#
# and these files:
# bin/OH-VISITATION-ORDER.txt
# 
# it makes these files:
# - none -
# 
# version 1.0 05 Jan 2011 (bjd)
#######################################################################

$ohroot=`ohroot`;
$ohroot=~ s/\n//;

# First, see if OH-VISITATIONORDER.txt is current.  If so, just use it.  Otherwise, rebuild.
$string = "< " . $ohroot . "bin/OH-VISITATIONORDER.txt";
open (LIST, $string);
$list = "";
while ( <LIST> ) {
print $_;
}

exit;
