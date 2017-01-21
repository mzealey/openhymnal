#!/usr/bin/perl
#use File::Grep qw( fgrep fmap fdo );
#use Time::localtime;
#######################################################################
#     This is a script to dig through the abc files, and build a 
# alphabetical tune index from them.
#
# Uses these scripts:
# ohroot
# list-hymns-in-OH-order.pl
#
# and these files:
# Complete/*/*.abc
# Choir/*/*.abc
# Bonus/*/*.abc
# 
# it makes these files:
# ?
#
# version 1.0 01 Mar 2011 (bjd)
#######################################################################
$ohroot=`ohroot`;
$ohroot=~ s/\n//;
$tm=localtime;
@parts = split " ",$tm;
$today=$parts[2]." ".$parts[1]." ".$parts[4];
my $newfile = "";


#######################################################################
# Main Table of Congregational Hymns
#######################################################################
@files = `list-hymns-in-OH-order.pl`;
$hymnnum = 0;

foreach $file (@files) {
	# Dig through the ABC files to extract and sort all of the index info
	Process_File ($file);
} 

Sort_Tunes ();


# print main table
$newfile .= "<h2>Open Hymnal, updated " . $today . ", Metrical Index of Tunes</h2>\n";
Print_Table () ;
$newfile .= "\n";

open (OUTPUT, "> /tmp/buildohmet" );
print OUTPUT $newfile;
close OUTPUT;
system "iconv --from-code=ISO-8859-1 --to-code=UTF-8 /tmp/buildohmet";
system "rm /tmp/buildohmet";


exit;
#######################################################################
# END MAIN PROGRAM
#######################################################################


sub Process_File {
   $linkabc[$hymnnum] = $_[0];
	$linkraw[$hymnnum] = $_[0];
	$linkraw[$hymnnum] =~ s/[.]abc/./;
	$linkraw[$hymnnum] =~ s/^.*\/([^\/]*)$/\1/;
	$linkraw[$hymnnum] =~ s/\n//;
	#print STDERR $file;
	$formal_hymn_number[$hymnnum] = `present-hymn-number $_[0]`;
	$formal_hymn_number[$hymnnum] =~ s/\n//;
	open (INPUT, $_[0]);
	$gottitle = 0;
	$reflistraw = "";
	while (<INPUT>) {
		if ( /Music: '/ || /Music and Setting: '/ ) {
			$_ =~ s/\n//;
			$_ =~ s/^.*Music and Setting: //;
			$_ =~ s/^.*Music: //;
			$_ =~ s/Setting:.*$//;
			$_ =~ s/'[^']*$/'/;
			$_ =~ s/' or '/ <i>or<\/i> /g;
			$_ =~ s/^'//;
			$_ =~ s/'$//;
			$_ =~ s/'.*$//;
			#print STDERR $_,"\n";
			$tune[$hymnnum] = $_;
			#print STDERR $tune[$hymnnum],"\n";
		}
		elsif ( /%OHMETRICAL/ ) {
			$_ =~ s/\n//;
			$_ =~ s/%OHMETRICAL //;
			$metrical[$hymnnum] = $_;
		}
		elsif ( ( /T:/ ) && ( $gottitle == 0 ) ) {
			#print $_;
			$title[$hymnnum] = $_;
			$title[$hymnnum] =~ s/T: //;
			$title[$hymnnum] =~ s/\n//;
			$gottitle = 1;
		}
		elsif ( /T:/ ) {
			$_ =~ s/T: //;
			$_ =~ s/\n/ /;
			if ( /\(also known as/ || length($subtitle[$hymnnum]) > 0 ) {
				$subtitle[$hymnnum] .= $_;
				$subtitle[$hymnnum] =~ s/\(also known as //;
				$subtitle[$hymnnum] =~ s/\)//;
				$subtitle[$hymnnum] =~ s/  / /g;
				$subtitle[$hymnnum] =~ s/ or /\n/g;
			}
		}
	}
	close INPUT;
	$hymnnum++;
}

sub Sort_Tunes {
	# start by making a simple unsorted list of all people
	$numtunes = 0;
	for ($i=0; $i < $hymnnum; $i++) {
		$_ = $metrical[$i];
		if ( $metrical[$i]."0" eq "0" ) {
			print STDERR $title[$i], " should be looked at\n";
		}
		elsif ( /Alleluia[0-9]/ ) {
			$metrical[$i] =~ s/Alleluia4$/with Alleluia/;
			$metrical[$i] =~ s/Alleluia[0-9]+$/with Alleluias/;
			$metrical[$i] =~ s/Alleluia4 /Alleluia /;
			$metrical[$i] =~ s/Alleluia[0-9]+ /Alleluias /;
		}
		elsif ( /Gloria[0-9]/ ) {
			$metrical[$i] =~ s/Gloria3/with Gloria/;
			$metrical[$i] =~ s/Gloria[0-9]+/with Glorias/;
		}
	}
	for ($i=0; $i < $hymnnum; $i++) {
		$found = 0;
		for ($j=0; $j < $numtunes; $j++) {
			if ( $metrical[$i] eq $name[$j] ) {
				$found = $j;
			}
		}
		if ( $found == 0 ) {
			$name[$numtunes] = $metrical[$i];
			#print STDERR $name[$numtunes],"\n";
			$numtunes++;
		}
	}

	#######################################################################
	# Sort the names in OH-style alphabetical order
	#######################################################################
	for ($i=0; $i < $numtunes; $i++) {
		@parts = split " ", $name[$i];
		$rebuilt = "";
		for ($k = 0; $k < @parts; $k++) {
			if ( length($parts[$k]) == 1) {
				$rebuilt .= "0" . $parts[$k];
			}
			else {
				$rebuilt .= $parts[$k];
			}
		}
		$sortkey[$i] = $rebuilt;
		$sortkey[$i] =~ s/withAlleluias//g;
		$sortkey[$i] =~ s/withAlleluia//g;
		$sortkey[$i] =~ s/withGlorias//g;
		$sortkey[$i] =~ s/Alleluias//g;
		$sortkey[$i] =~ s/Alleluia//g;
		$order[$i] = -1;
		#print STDERR $name[$i],"    ----->      ",$sortkey[$i],"\n";
	}
	for ($i=0; $i < $numtunes; $i++) {
		$guess = 0;
		for ($j=1; $j < $numtunes; $j++) {
			if ( $sortkey[$j] lt $sortkey[$guess] ) {
				$guess = $j;
			}
		}
		$order[$i] = $guess;
		#print STDERR $name[$order[$i]],"    ----->      ",$sortkey[$order[$i]],"\n";
		$sortkey[$guess] = "~";
	}
}


sub Print_Table {
	for ($j=0; $j < $numtunes; $j++) {
		$_ = $name[$order[$j]];
		if ( $name[$order[$j]] ne "CHORAL" ) {
			#print STDERR "<h4>",$name[$order[$j]],"</h4>\n";
			$newfile .= "<h4>" . $name[$order[$j]] . "</h4>\n";
			for ($i=0; $i < $hymnnum; $i++) {
				$ind = index $tune[$i],$name[$order[$j]];
				if ( $metrical[$i] eq $name[$order[$j]] ) {
					$newfile .= "<p><a href=\"javascript:new_window('Lyrics/" . $linkraw[$i] . "html')\">" . $tune[$i] . " (" . $title[$i] . ")" . "</a></p>\n";
				}
			}
		}
	}
}
