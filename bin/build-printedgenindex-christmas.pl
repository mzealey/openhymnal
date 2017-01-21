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
# table of christmas hymns
#######################################################################
$string = "< " . $ohroot . "bin/OH-CHRISTMASORDER.txt";
open (LIST, $string);
$numlist = "";
while ( <LIST> ) {
	$_ =~ s/\n//;
	$list[$numlist] = $_;
	$numlist++;
}
close LIST;


#######################################################################
# Main Table of Congregational Hymns
#######################################################################
$filepath=$ohroot . "Complete/*/*.abc ";
@filesall = <$filepath >; 
$hymnnum = 0;

$numfiles = 0;
# reduce to only include files found in This Edition
foreach $file (@filesall) {
	if ( InEdition($file) ) {
		$files[$numfiles] = $file;
		$numfiles++;
	}
}

foreach $file (@files) {
	# Dig through the ABC files to extract and sort all of the index info
	Process_File ($file);
} 

# Build a list of Alternate titles
Build_References ();

# print main table
print "<h4>Congregational/Home/Educational Hymns:</h4>\n<table border=\"1\">\n	<thead>\n		<tr valign=\"top\">\n			<th>Title</th>\n			<th>No.</th>\n			<th>Section</th>\n			<th>Complexity</th>\n			<th>Author/ Translator in italics</th>\n			<th>Tune</th>\n			<th>Composer/ Arranger in italics</th>\n		</tr>\n	</thead>\n	<tbody>\n";

Print_Table () ;
print "</tbody>   \n</table>\n";

#######################################################################
# Table of Choir/Instrumental Pieces
#######################################################################
$filepath=$ohroot . "Choir/*/*.abc ";
@filesall = <$filepath >; 
$hymnnum = 0;
$numfiles = 0;
@files = {};

# reduce to only include files found in This Edition
foreach $file (@filesall) {
	if ( InEdition($file) ) {
		$files[$numfiles] = $file;
		$numfiles++;
	}
}

if ($numfiles > 0) {
foreach $file (@files) {
	# Dig through the ABC files to extract and sort all of the index info
	Process_File ($file);
} 

# Build a list of Alternate titles
Build_References ();

# print choir table
print "<h4>Choral or Instrumental Songs:</h4>\n";
print "<table border=\"1\">\n	<thead>\n		<tr valign=\"top\">\n			<th>Title</th>\n			<th>No.</th>\n			<th>Section</th>\n			<th>Complexity</th>\n			<th>Author/ Translator in italics</th>\n			<th>Tune</th>\n			<th>Composer/ Arranger in italics</th>\n		</tr>\n	</thead>\n	<tbody>\n";
Print_Table () ;
print "</tbody>   \n</table>\n";
}

#######################################################################
# Table of Bonus Pieces
#######################################################################
$filepath=$ohroot . "Bonus/*/*.abc ";
@filesall = <$filepath >; 
$hymnnum = 0;
$numfiles = 0;
@files = {};

# reduce to only include files found in This Edition
foreach $file (@filesall) {
	if ( InEdition($file) ) {
		$files[$numfiles] = $file;
		$numfiles++;
	}
}

if ($numfiles > 0) {
foreach $file (@files) {
	# Dig through the ABC files to extract and sort all of the index info
	Process_File ($file);
} 

# Build a list of Alternate titles
Build_References ();

# print bonus table
print "<h4>Bonus Carol:</h4>\n";
print "<table border=\"1\">\n	<thead>\n		<tr valign=\"top\">\n			<th>Title</th>\n			<th>No.</th>\n			<th>Section</th>\n			<th>Complexity</th>\n			<th>Author/ Translator in italics</th>\n			<th>Tune</th>\n			<th>Composer/ Arranger in italics</th>\n		</tr>\n	</thead>\n	<tbody>\n";
Print_Table () ;
print "</tbody>   \n</table>\n";
}
exit;
#######################################################################
# END MAIN PROGRAM
#######################################################################

sub InEdition {
	$ret = 0;
	for ($i = 0; $i < $numlist; $i++) {
		if ( $_[0] eq $list[$i] ) {
			$ret = 1;
		}
	}
	return $ret;
}

sub Process_File {
   $linkabc[$hymnnum] = $_[0];
	$linkraw[$hymnnum] = $_[0];
	$linkraw[$hymnnum] =~ s/[.]abc/./;
	$linkraw[$hymnnum] =~ s/^.*\/([^\/]*)$/\1/;
	#print STDERR $file;
	$formal_hymn_number[$hymnnum] = `present-hymn-number-christmas $_[0]`;
	$formal_hymn_number[$hymnnum] =~ s/\n//;
	open (INPUT, $_[0]);
	$gottitle = 0;
	$reflistraw = "";
	while (<INPUT>) {
		if ( /%OHCOMPOSER/ ) {
			$_ =~ s/\n//;
			$_ =~ s/%OHCOMPOSER //;
			if ( ! /^from / ) {
				$_ =~ s/ \([A-Za-z0-9.\/\? -]*\)//g;
				if ( /;/ ) {
					$_ =~ s/, [A-Z][^;]*//g;
					$_ =~ s/;/ &amp; /g;
				}
				else {
					$_ =~ s/(, [A-Z])[^;]*/\1./g;
					$_ .= "@"; #Flag to add arranger
				}
			}
			else {
					$_ .= "@"; #Flag to add arranger
			}
			$composer[$hymnnum] = $_;
		}
		elsif ( /%OHARRANGER/ ) {
			$_ =~ s/\n//;
			$_ =~ s/%OHARRANGER //;
			if ( ! /^from / ) {
				$_ =~ s/none//;
				$_ =~ s/unknown//;
				$_ =~ s/composite//;
				$_ =~ s/ \([A-Za-z0-9.\/\? -]*\)//g;
				if ( /;/ ) {
					$_ =~ s/, [A-Z][^;]*//g;
					$_ =~ s/;/ &amp; /g;
				}
				else {
					$_ =~ s/, [A-Z].*//g;
				}
				$arranger[$hymnnum] = $_;
				$_ = $composer[$hymnnum];
				if ( /@/ ) {
					if ( length($arranger[$hymnnum]) > 0 ) {
						$temp = $composer[$hymnnum];
						$temp =~ s/, [A-Z].\@$//;
						if ( $arranger[$hymnnum] ne $temp ) {
							#print STDERR $arranger[$hymnnum],"\n",$composer[$hymnnum],"\n\n\n";
							$composer[$hymnnum] =~ s/, [A-Z].\@$/ &amp; <i>$arranger[$hymnnum]<\/i>/;
							$composer[$hymnnum] =~ s/\@$/ &amp; <i>$arranger[$hymnnum]<\/i>/;
						}
						else {
							$composer[$hymnnum] =~ s/@//;
						}
					}
					else {
						$composer[$hymnnum] =~ s/@//;
					}
				}
			}
			else {
				$composer[$hymnnum] =~ s/@//;
			}
		}
		elsif ( /%OHAUTHOR/ ) {
			$_ =~ s/\n//;
			$_ =~ s/%OHAUTHOR //;
			$_ =~ s/ \([A-Za-z0-9.\/\? -]*\)//g;
			if ( /;/ ) {
				$_ =~ s/, [A-Z][^;]*//g;
				$_ =~ s/;/ &amp; /g;
			}
			else {
				$_ =~ s/(, [A-Z])[^;]*/\1./g;
				$_ .= "@"; #Flag to add translator
			}
			$author[$hymnnum] = $_;
		}
		elsif ( /%OHTRANSLATOR/ ) {
			$_ =~ s/\n//;
			$_ =~ s/%OHTRANSLATOR //;
			$_ =~ s/none//;
			$_ =~ s/unknown//;
			$_ =~ s/composite//;
			$_ =~ s/ \([A-Za-z0-9.\/\? -]*\)//g;
			if ( /;/ ) {
				$_ =~ s/, [A-Z][^;]*//g;
				$_ =~ s/;/ &amp; /g;
			}
			else {
				$_ =~ s/, [A-Z].*//g;
			}
			$translator[$hymnnum] = $_;
			$_ = $author[$hymnnum];
			if ( /@/ ) {
				if ( length($translator[$hymnnum]) > 0 ) {
					#print STDERR $translator[$hymnnum];
					$author[$hymnnum] =~ s/, [A-Z].\@$/ &amp; <i>$translator[$hymnnum]<\/i>/;
					$author[$hymnnum] =~ s/\@$/ &amp; <i>$translator[$hymnnum]<\/i>/;
				}
				else {
					$author[$hymnnum] =~ s/@//;
				}
			}
		}
		elsif ( /%OHCOMPLEXITY/ ) {
			$_ =~ s/\n//;
			$_ =~ s/%OHCOMPLEXITY //;
			$complexity[$hymnnum] = $_;
		}
		elsif ( /%OHSCRIP/ ) {
			$_ =~ s/\n//;
			$_ =~ s/%OHSCRIP "//;
			$_ =~ s/\t\t"//;
			$SR[$hymnnum] = $_;
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


sub Build_References {
$numalts = 0;
for ($i=0; $i < $hymnnum; $i++) {
	if ( length($subtitle[$i]) > 0 ) {
		$subtitle[$i] =~ s/ $//g;
		@parts = split "\n",$subtitle[$i];
		for ($j=0; $j<@parts; $j++) {
			$duplicate = 0;
			$string = $parts[$j]." see ".$title[$i];
			for ($k=0; $k < $numalts; $k++) {
				if ( $unsortedrefs[$k] eq $string ) {
					$duplicate = 1;
				}
			}
			if ( $duplicate == 0 ) {
				$unsortedrefs[$numalts] = $string;
				$unsortedrefskey[$numalts] = $string;
				$unsortedrefskey[$numalts] =~ s/ /0/g;
				$unsortedrefskey[$numalts] =~ s/[!,;.'?():]//g;
				$unsortedrefskey[$numalts] = uc($unsortedrefskey[$numalts]);
				#print STDERR $string,"\n";
				#print STDERR $unsortedrefskey[$numalts],"\n";
				$order[$numalts] = -1;
				$numalts++;
			}
		}
	}
}

# sort alternate titles
for ($k=0; $k < $numalts; $k++) {
	$tempkey[$k] = $unsortedrefskey[$k];
}
for ($k=0; $k < $numalts; $k++) {
	$guess = 0;
	for ($j=1; $j < $numalts; $j++) {
		if ( $tempkey[$j] lt $tempkey[$guess] ) {
			$guess = $j;
		}
	}
	$order[$k] = $guess;
	$tempkey[$guess] = "~";
}
for ($k=0; $k < $numalts; $k++) {
	$sortedrefs[$k] = $unsortedrefs[$order[$k]];
	$sortedrefskey[$k] = $unsortedrefskey[$order[$k]];
	#print STDERR $sortedrefs[$k],"\n";
}

}


sub Print_Table {
$k = 0;
for ($i=0; $i < $hymnnum; $i++) {
	#if ( length($subtitle[$i]) > 0 ) {
	#	print STDERR $subtitle[$i],"\n";
	#}
	$key = $title[$i];
	$key =~ s/ /0/g;
	$key =~ s/[!,;.'?():]//g;
	$key = uc($key);
	#print STDERR $sortedrefskey[$k],"   ------>    ",$key,"\n";
	while ( $sortedrefskey[$k] lt $key && $numalts > 0 && $k < $numalts) {
		print "\t\t",'<tr valign="top">',"\n";
		print "\t\t\t",'<td colspan="7"><p class="western">',$sortedrefs[$k],'</p></td>',"\n";
		print "\t\t",'</tr>',"\n";
		$k++;
	}
# Title, Number, Section, Complexity, Author/ Translator in italics, Tune, Composer/ Arranger in italics
$num = `present-hymn-number-christmas $linkabc[$i]`;
$sec = `present-hymn-section $linkabc[$i]`;
$sec =~ s/\// \/ /;
	print "\t\t",'<tr valign="top">' . "\n";
	print "\t\t\t",'<td><p class="title">' . $title[$i] . '</p></td>' . "\n";
	print "\t\t\t",'<td><p class="num" align="center">' . $num . '</p></td>' . "\n";
	print "\t\t\t",'<td><p class="section" align="center">' . $sec . '</p></td>' . "\n";
	print "\t\t\t",'<td><p class="complex" align="center">' . $complexity[$i] . '</p></td>' . "\n";
	print "\t\t\t",'<td><p class="author">' . $author[$i] . '</p></td>' . "\n";
	print "\t\t\t",'<td><p class="tune">' . $tune[$i] . '</p></td>' . "\n";
	print "\t\t\t",'<td><p class="composer">' . $composer[$i] . '</p></td>' . "\n";
#	print "\t\t\t",'<td><p class="scripture"><scripRef passage="' . $SR[$i] . '">' . $SR[$i] . '</scripRef></p></td>' . "\n";
#	print "\t\t\t",'<td><p class="midi"><a href="Midi/' . $linkraw[$i] . 'mid"><img src="treble_clef.png" alt="MIDI"/></a></p></td>' . "\n";
#	print "\t\t\t",'<td><p class="mp3"><a href="Mp3/' . $linkraw[$i] . 'mp3"><img src="MP3.png" alt="MP3"/></a></p></td>' . "\n";
	print "\t\t",'</tr>' . "\n";
}
while ( $k < $numalts ) {
	print "\t\t",'<tr valign="top">',"\n";
	print "\t\t\t",'<td colspan="7"><p class="western">',$sortedrefs[$k],'</p></td>',"\n";
	print "\t\t",'</tr>',"\n";
	$k++;
}

}
