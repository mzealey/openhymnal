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
# version 2.0 22 Aug 2011 (bjd) add popup scripture references
# version 2.1 27 Aug 2013 (bjd) to convert to UTF-8 output
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
$filepath=$ohroot . "Complete/*/*.abc ";
@files = <$filepath >; 
$hymnnum = 0;

foreach $file (@files) {
	# Dig through the ABC files to extract and sort all of the index info
	Process_File ($file);
} 

# Build a list of Alternate titles
Build_References ();

# print main table
$newfile .=  "<a href=\"genindex.html\">Complete</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexa.html\">A</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexb.html\">B</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexc.html\">C</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexd.html\">D</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexe.html\">E</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexf.html\">F</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexg.html\">G</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexh.html\">H</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexi.html\">I</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexj.html\">J</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexk.html\">K</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexl.html\">L</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexm.html\">M</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexn.html\">N</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexo.html\">O</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexp.html\">P</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexq.html\">Q</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexr.html\">R</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexs.html\">S</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindext.html\">T</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexu.html\">U</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexv.html\">V</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexw.html\">W</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexx.html\">X</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexy.html\">Y</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexz.html\">Z</a>&nbsp;&nbsp;&nbsp;\n<a href=\"genindexother.html\">Choral and Bonus</a>&nbsp;&nbsp;&nbsp;\n<p>\n<center>\n<h4>Open Hymnal, updated " . $today . ", Index by Common Title<br>\nSongs for Congregational/Home/Educational Singing:</h4>\n<table border=\"1\" bordercolor=\"#000000\" cellpadding=\"1\" cellspacing=\"0\" bgcolor=\"#CBC5B9\"  id=\"playlist\">\n	<thead>\n		<tr valign=\"top\">\n			<th>\n				<p class=\"western\">Title (Link to Hymn)</p>\n			</th>\n			<th>\n				<p class=\"western\">Complexity</p>\n			</th>\n			<th>\n				<p class=\"western\">Words/ Translator in italics</p>\n			</th>\n			<th>\n				<p class=\"western\">Tune</p>\n			</th>\n			<th>\n				<p class=\"western\">Composer/ Arranger in italics</p>\n			</th>\n			<th>\n				<p class=\"western\">Scripture</p>\n			</th>\n			<th>\n				<p class=\"western\">MIDI Link</p>\n			</th>\n			<th>\n				<p class=\"western\">MP3 Link</p>\n			</th>\n		</tr>\n	</thead>\n	<tbody>\n";

Print_Table () ;
$newfile .=   "</tbody>   \n</table>\n<h4>Choral or Instrumental Songs:</h4>\n";



#######################################################################
# Table of Choir/Instrumental Pieces
#######################################################################
$filepath=$ohroot . "Choir/*/*.abc ";
@files = <$filepath >; 
$hymnnum = 0;

foreach $file (@files) {
	# Dig through the ABC files to extract and sort all of the index info
	Process_File ($file);
} 

# Build a list of Alternate titles
Build_References ();

# print choir table
$newfile .=   "<table border=\"1\" bordercolor=\"#000000\" cellpadding=\"1\" cellspacing=\"0\" bgcolor=\"#CBC5B9\"  id=\"playlist\">\n	<thead>\n		<tr valign=\"top\">\n			<th>\n				<p class=\"western\">Title (Link to Hymn)</p>\n			</th>\n			<th>\n				<p class=\"western\">Complexity</p>\n			</th>\n			<th>\n				<p class=\"western\">Words/ Translator in italics</p>\n			</th>\n			<th>\n				<p class=\"western\">Tune</p>\n			</th>\n			<th>\n				<p class=\"western\">Composer/ Arranger in italics</p>\n			</th>\n			<th>\n				<p class=\"western\">Scripture</p>\n			</th>\n			<th>\n				<p class=\"western\">MIDI Link</p>\n			</th>\n			<th>\n				<p class=\"western\">MP3 Link</p>\n			</th>\n		</tr>\n	</thead>\n	<tbody>\n";
Print_Table () ;
$newfile .=   "</tbody>   \n</table>\n<h4>Bonus Carol:</h4>\n";

#######################################################################
# Table of Bonus Pieces
#######################################################################
$filepath=$ohroot . "Bonus/*/*.abc ";
@files = <$filepath >; 
$hymnnum = 0;

foreach $file (@files) {
	# Dig through the ABC files to extract and sort all of the index info
	Process_File ($file);
} 

# Build a list of Alternate titles
Build_References ();


# print bonus table
$newfile .=   "<table border=\"1\" bordercolor=\"#000000\" cellpadding=\"1\" cellspacing=\"0\" bgcolor=\"#CBC5B9\"  id=\"playlist\">\n	<thead>\n		<tr valign=\"top\">\n			<th>\n				<p class=\"western\">Title (Link to Hymn)</p>\n			</th>\n			<th>\n				<p class=\"western\">Complexity</p>\n			</th>\n			<th>\n				<p class=\"western\">Words/ Translator in italics</p>\n			</th>\n			<th>\n				<p class=\"western\">Tune</p>\n			</th>\n			<th>\n				<p class=\"western\">Composer/ Arranger in italics</p>\n			</th>\n			<th>\n				<p class=\"western\">Scripture</p>\n			</th>\n			<th>\n				<p class=\"western\">MIDI Link</p>\n			</th>\n			<th>\n				<p class=\"western\">MP3 Link</p>\n			</th>\n		</tr>\n	</thead>\n	<tbody>\n";
Print_Table () ;
$newfile .=   "</tbody>   \n</table>\n</center>\n";

open (OUTPUT, "> /tmp/buildohgen" );
print OUTPUT $newfile;
close OUTPUT;
system "iconv --from-code=ISO-8859-1 --to-code=UTF-8 /tmp/buildohgen";
system "rm /tmp/buildohgen";
exit;

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
			if ( ! /^from / ) {
				$_ =~ s/ \([0-9\/thCenuryc.\?-\s]*\)//g;
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
				$_ =~ s/ \([0-9\/thCenuryc.\?-\s]*\)//g;
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
			$_ =~ s/ \([0-9\/thCenuryc.\?-\s]*\)//g;
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
			$_ =~ s/ \([0-9\/thCenuryc.\?-\s]*\)//g;
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
			$_ =~ s/%OHSCRIP //;
			$_ =~ s/\t\t"//;
			$_ =~ s/\\n/ /g;
			$_ =~ s/\t/ /g;
			$_ =~ s/  / /g;
			$_ =~ s/  / /g;
			$_ =~ s/ $//;
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
			$subtitle[$hymnnum] = "";
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
#for ($i=0; $i < $hymnnum; $i++) {
#	$unsortedrefs[$i] = "";
#	$unsortedrefskey[$i] = "";
#	$sortedrefs[$i] = "";
#	$sortedrefskey[$i] = "";
#	$tempkey[$i] = "";
#	$order[$i] = "";
#}
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
	#print STDERR "[Sortedrefs] ",$sortedrefs[$k],"\n";
}

}


sub Print_Table {
$k = 0;
for ($i=0; $i < $hymnnum; $i++) {
	if ( length($subtitle[$i]) > 0 ) {
		#print STDERR "[Subtitle] ",$subtitle[$i],"\n";
	}
	$key = $title[$i];
	$key =~ s/ /0/g;
	$key =~ s/[!,;.'?():]//g;
	$key = uc($key);
	#print STDERR $sortedrefskey[$k],"   ------>    ",$key,"\n";
	while ( $sortedrefskey[$k] lt $key && $numalts > 0) {
		$newfile .=   "\t\t" . '<tr valign="top">' . "\n";
		$newfile .=   "\t\t\t" . '<td colspan="8"><p class="western">' . $sortedrefs[$k] . '</p></td>' . "\n";
		$newfile .=   "\t\t" . '</tr>' . "\n";
		$k++;
	}
	
	$newfile .=   "\t\t" . '<tr valign="top">' . "\n";
	$newfile .=   "\t\t\t" . '<td><p class="title"><a href="javascript:new_window(';
	$newfile .=   "'Lyrics/" . $linkraw[$i] . "html'";
	$newfile .=   ')">' . $title[$i] . '</a></p></td>' . "\n";
	$newfile .=   "\t\t\t" . '<td><p class="complex" align="center">' . $complexity[$i] . '</p></td>' . "\n";
	$newfile .=   "\t\t\t" . '<td><p class="author">' . $author[$i] . '</p></td>' . "\n";
	$newfile .=   "\t\t\t" . '<td><p class="tune">' . $tune[$i] . '</p></td>' . "\n";
	$newfile .=   "\t\t\t" . '<td><p class="composer">' . $composer[$i] . '</p></td>' . "\n";
	$newfile .=   "\t\t\t" . '<td><p class="scripture">';	
	@parts = split ",", $SR[$i];
			$bookref = "";
			for ($j = 0; $j < @parts; $j++) {
				$ref = $parts[$j];
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
				#print STDERR $SR[$i],"    ->    ",$ref,"\n";
				
				$pass = `oh-lookup "$ref" 2> /dev/null`;
				#$pass = "";
				$pass =~ s/\n//g;
				$pass =~ s/“/`/g;
				$pass =~ s/”/`/g;
				$pass =~ s/‘/'/g;
				$pass =~ s/’/'/g;
#				$pass =~ s/\n/'/g;
#				$pass =~ s/\n//g;
#				$pass =~ s/\n//g;
#				$pass = `echo $pass | iconv --to-code=ISO-8859-1 --from-code=UTF-8`;
#				$command = "iconv --from-code=ISO-8859-1 --to-code=UTF-8 " . $OHROOT . "Web/genindex.html > /tmp/buildsword";
				$newfile .=   '<div title="' . $pass . '">' . $ref;
				if ( ($j+2) <= @parts ) {
					$newfile .= ", ";
				}
				$newfile .=   '</div>';
			}

	$newfile .=   '</p></td>' . "\n";
	$newfile .=   "\t\t\t" . '<td><p class="midi"><a href="Midi/' . $linkraw[$i] . 'mid"><img src="treble_clef.png" alt="MIDI"/></a></p></td>' . "\n";
	$newfile .=   "\t\t\t" . '<td><p class="mp3"><a href="Mp3/' . $linkraw[$i] . 'mp3"><img src="MP3.png" alt="MP3"/></a></p></td>' . "\n";
	$newfile .=   "\t\t" . '</tr>' . "\n";
}
while ( $k < $numalts ) {
	$newfile .=   "\t\t" . '<tr valign="top">' . "\n";
	$newfile .=   "\t\t\t" . '<td colspan="8"><p class="western">' . $sortedrefs[$k] . '</p></td>' . "\n";
	$newfile .=   "\t\t" . '</tr>' . "\n";
	$k++;
}

}
