#!/usr/bin/perl
#use File::Grep qw( fgrep fmap fdo );
#######################################################################
#     This is a script to prep a single abc file for inclusion in the 
# big pdf hymnal.  It adds a header with a hymn number.  The header
# is different depending on whether it is a right or left page.  It
# also ensures it is run using "combinevoices 1" unless it explicitly 
# says otherwise in the input file.
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
$hymnnum = $ARGV[1];
$pagenum = $ARGV[2];
$category = "";
open (INPUT, $file );
$data = "";
$pghymn = 1;
#$NM=`present-hymn-number ${1}`

while ( <INPUT> ) {
	$_ =~ s/\!ferm\!//g;
	if ( /X:/ ) {
		$_ =~ s/X: 1/X: $hymnnum/;
	}

	if ( /%OHCATEGORY/ ) {
		$category = $_;
		$category =~ s/%OHCATEGORY //;
		$category =~ s/^ //;
		$category =~ s/\n//;
	}
	elsif ( /%OHSCRIP/ ) { # NEED TO FIX SO IT ADDS FOOTER FOR EACH HYMN IN THE FILE, NOT AT END!
		$scrip = $_;
		$scrip =~ s/%OHSCRIP //;
		$scrip =~ s/^ //;
		$scrip =~ s/\n//;
	}
	elsif ( /%OHMETRICAL/ ) {
		$metrical = $_;
		$metrical =~ s/%OHMETRICAL //;
		$metrical =~ s/^ //;
		$metrical =~ s/\n//;
		if ( /Alleluia[0-9]/ ) {
			$metrical =~ s/Alleluia4$/with Alleluia/;
			$metrical =~ s/Alleluia[0-9]+$/with Alleluias/;
			$metrical =~ s/Alleluia4 /Alleluia /;
			$metrical =~ s/Alleluia[0-9]+ /Alleluias /;
		}
		elsif ( /Gloria[0-9]/ ) {
			$metrical =~ s/Gloria3/with Gloria/;
			$metrical =~ s/Gloria[0-9]+/with Glorias/;
		}
		$metrical =~ s/CHORAL//;
		#print STDERR $scrip,"\n";
		#print STDERR $metrical,"\n";
		$str = $scrip  . "\t\t" . $metrical . "\n";
		#print STDERR $str,"\n";
		$data =~ s/%OHSCRIP/\%\%footer $str%OHSCRIP/;
		#print STDERR "\n",$data,"\n";
		$metrical = "";
		$scrip = "";
	}
	$data .= $_;
}

$_ = $data;

if ( ! /%%combinevoices/ ) {
	$data =~ s/(T: [^\n]*\n)/\1%%combinevoices 1\n/;
}

close INPUT;


if ( ($pagenum % 2)  == 1 ) {
	$data =~ s/\n%%footer/\n%%header "$category\t\t$hymnnum"\n%%footer/;
}
else {
	$data =~ s/\n%%footer/\n%%header "$hymnnum\t\t$category"\n%%footer/;
}
$pagenum++;
$pghymn++;
# Now deal with multipage abc files
$done = 0;
while ( ! $done ) {
	$old = $data;
	if ( ($pagenum % 2)  == 1 ) {
		$data =~ s/\n%%newpage/\n%%nwpage\n%%header "$category\t\t$hymnnum\($pghymn\)"/;
	}
	else {
		$data =~ s/\n%%newpage/\n%%nwpage\n%%header "$hymnnum\($pghymn\)\t\t$category"/;
	}
	$pagenum++;
	$pghymn++;
	#print STDERR $pagenum,"\n";
	if ( $old eq $data ) {
		$done = 1;
	}
}
$data =~ s/%%nwpage/%%newpage/g;

print $data;

exit;
