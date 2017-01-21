#!/usr/bin/perl
#use File::Grep qw( fgrep fmap fdo );
#use Time::localtime;
#######################################################################
#     This is a script to dig through the abc files, and build a 
# general index from them.
#
# Uses these scripts:
# ohroot
#
# and these files:
# Complete/*/*.abc
# Choir/*/*.abc
# Bonus/*/*.abc
# 
# it makes these files:
# ?
#
# version 1.0 16 Feb 2011 (bjd)
#######################################################################
$ohroot=`ohroot`;
$ohroot=~ s/\n//;
$tm=localtime;
@parts = split " ",$tm;
$today=$parts[2]." ".$parts[1]." ".$parts[4];


#######################################################################
# Main Table of Congregational Hymns
#######################################################################
#$filepath=$ohroot . "Complete/*/*.abc " . $ohroot . "Choir/*/*.abc ";
#@files = <$filepath >; 
$hymnnum = 0;
@files = `list-hymns-in-OH-order.pl`;
for ($i=0; $i < @files; $i++) {
	$files[$i] =~ s/\n//;
	#print $files[$i],"\n";
}

foreach $file (@files) {
	# Dig through the ABC files to extract and sort all of the index info
	Process_File ($file);
} 

# Build a list of Alternate titles
Sort_People ();

exit;
#######################################################################
# END MAIN PROGRAM
#######################################################################


sub Process_File {
   $linkabc[$hymnnum] = $_[0];
	$linkraw[$hymnnum] = $_[0];
	$linkraw[$hymnnum] =~ s/[.]abc/./;
	$linkraw[$hymnnum] =~ s/^.*\/([^\/]*)$/\1/;
	#print STDERR $file;
	$formal_hymn_number[$hymnnum] = `present-hymn-number $_[0]`;
	$formal_hymn_number[$hymnnum] =~ s/\n//;
	open (INPUT, $_[0]);
	$gottitle = 0;
	$reflistraw = "";
	while (<INPUT>) {
		if ( /%OHCOMPOSER/ ) {
			$_ =~ s/\n//;
			$_ =~ s/%OHCOMPOSER //;
			$composer[$hymnnum] = $_;
		}
		elsif ( /%OHARRANGER/ ) {
			$_ =~ s/\n//;
			$_ =~ s/%OHARRANGER //;
			$arranger[$hymnnum] = $_;
		}
		elsif ( /%OHAUTHOR/ ) {
			$_ =~ s/\n//;
			$_ =~ s/%OHAUTHOR //;
			$author[$hymnnum] = $_;
		}
		elsif ( /%OHTRANSLATOR/ ) {
			$_ =~ s/\n//;
			$_ =~ s/%OHTRANSLATOR //;
			$translator[$hymnnum] = $_;
		}
		elsif ( /Music: '/ || /Music and Setting: '/ ) {
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
		}
		elsif ( ( /T:/ ) && ( $gottitle == 0 ) ) {
			#print $_;
			$title[$hymnnum] = $_;
			$title[$hymnnum] =~ s/T: //;
			$title[$hymnnum] =~ s/\n//;
			$gottitle = 1;
		}
	}
	close INPUT;
	$hymnnum++;
}


sub Sort_People {
	# start by making a simple unsorted list of all people
	$numpeople = 0;
	for ($i=0; $i < $hymnnum; $i++) {
		@parts = split ";", $author[$i];
		for ($k=0; $k < @parts; $k++) {
			#print STDERR $parts[$k],"\n";
			$found = 0;
			for ($j=0; $j < $numpeople; $j++) {
				if ($parts[$k] eq $name[$j] ) {
					$found = $j;
				}
			}
			if ( $found == 0 ) {
				$name[$numpeople] = $parts[$k];
				$numpeople++;
			}
		}
	}
	for ($i=0; $i < $hymnnum; $i++) {
		@parts = split ";", $translator[$i];
		for ($k=0; $k < @parts; $k++) {
			$found = 0;
			for ($j=0; $j < $numpeople; $j++) {
				if ($parts[$k] eq $name[$j] ) {
					$found = $j;
				}
			}
			if ( $found == 0 ) {
				$name[$numpeople] = $parts[$k];
				$numpeople++;
			}
		}
	}
#######################################################################
# Sort the names in OH-style alphabetical order
#######################################################################
for ($i=0; $i < $numpeople; $i++) {
	$sortkey[$i] = $name[$i];
	$sortkey[$i] =~ s/ /0/g;
#	$sortkey[$i] =~ s/^.*\///g;
	$sortkey[$i] =~ s/-.*//g;
	$sortkey[$i] =~ s/[.].*//g;
	$sortkey[$i] =~ s/[!,;.'?()]//g;
	$sortkey[$i] = uc($sortkey[$i]);
	$order[$i] = -1;
#	print $sortkey[$i],"\n";
}
for ($i=0; $i < $numpeople; $i++) {
	$guess = 0;
	for ($j=1; $j < $numpeople; $j++) {
		if ( $sortkey[$j] lt $sortkey[$guess] ) {
			$guess = $j;
		}
	}
	$order[$i] = $guess;
	$sortkey[$guess] = "~";
}


$string = ">> back-indices.html";
open (OUTPUT, $string);

# print main table
print OUTPUT "<h2>Index of Authors and Translators</h2>\n";
print OUTPUT "<p><i>Translated hymns in italics</i></p>\n";
Print_Table (1) ;
#   print STDERR "HERE\n";
$numpeople=0;

	for ($i=0; $i < $hymnnum; $i++) {
		@parts = split ";", $composer[$i];
		for ($k=0; $k < @parts; $k++) {
			$found = 0;
			for ($j=0; $j < $numpeople; $j++) {
				if ($parts[$k] eq $name[$j] ) {
					$found = $j;
				}
			}
			if ( $found == 0 ) {
				$name[$numpeople] = $parts[$k];
				$numpeople++;
			}
		}
	}
	for ($i=0; $i < $hymnnum; $i++) {
		@parts = split ";", $arranger[$i];
		for ($k=0; $k < @parts; $k++) {
			$found = 0;
			for ($j=0; $j < $numpeople; $j++) {
				if ($parts[$k] eq $name[$j] ) {
					$found = $j;
				}
			}
			if ( $found == 0 ) {
				$name[$numpeople] = $parts[$k];
				$numpeople++;
			}
		}
	}
#   print STDERR $numpeople,"\n";
#######################################################################
# Sort the names in OH-style alphabetical order
#######################################################################
for ($i=0; $i < $numpeople; $i++) {
	$sortkey[$i] = $name[$i];
	$sortkey[$i] =~ s/ /0/g;
#	$sortkey[$i] =~ s/^.*\///g;
	$sortkey[$i] =~ s/-.*//g;
	$sortkey[$i] =~ s/[.].*//g;
	$sortkey[$i] =~ s/[!,;.'?()]//g;
	$sortkey[$i] = uc($sortkey[$i]);
	$order[$i] = -1;
#	print $sortkey[$i],"\n";
}
for ($i=0; $i < $numpeople; $i++) {
	$guess = 0;
	for ($j=1; $j < $numpeople; $j++) {
		if ( $sortkey[$j] lt $sortkey[$guess] ) {
			$guess = $j;
		}
	}
	$order[$i] = $guess;
	$sortkey[$guess] = "~";
}


# print main table
print OUTPUT "<h2>Index of Composers and Arrangers</h2>\n";
print OUTPUT "<p><i>Arranged hymns in italics</i></p>\n";
Print_Table (0) ;


}


sub Print_Table {
	# present people	
#	print $name[0],"\n\n\n";
for ($j=0; $j < $numpeople; $j++) {
	$_ = $name[$order[$j]];
	if ( ! ( /unknown/ || /none/ || /composite/ ) ) {
		print OUTPUT "<h4>",$name[$order[$j]],"</h4>\n";
		for ($i=0; $i < $hymnnum; $i++) {
			if ( $_[0] == "1" ) {
				$ind = index $author[$i],$name[$order[$j]];
				if ( $ind >= 0 ) {
					print OUTPUT "<p>",$formal_hymn_number[$i],".",$title[$i],"</p>\n";
				}
				else {
					$ind = index $translator[$i],$name[$order[$j]];
					if ( $ind >= 0 ) {
						print OUTPUT "<p>",$formal_hymn_number[$i],".","<i>",$title[$i],"</i></p>\n";
					}
				}
			}
			else {
				$ind = index $composer[$i],$name[$order[$j]];
				if ( $ind >= 0 ) {
					print OUTPUT "<p>",$formal_hymn_number[$i],".",$title[$i],"</p>\n";
				}
				else {
					$ind = index $arranger[$i],$name[$order[$j]];
					if ( $ind >= 0 ) {
						print OUTPUT "<p>",$formal_hymn_number[$i],".","<i>",$title[$i],"</i></p>\n";
					}
				}
			}
		}
		#print OUTPUT "</p>\n";
	}
}
}
