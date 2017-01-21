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


# First, see if OH-EASTER-ORDER.txt is current.  If so, just use it.  Otherwise, rebuild.
$string = "< " . $ohroot . "bin/OH-EASTERORDER.txt";
open (LIST, $string);
$list = "";
while ( <LIST> ) {
print $_;
}
exit;
