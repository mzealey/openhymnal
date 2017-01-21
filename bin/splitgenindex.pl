#!/usr/bin/perl
#######################################################################
#     This is a script to dig through the Open Hymnal general index
# and break it into the split general indices
#
# Uses these scripts:
# ohroot
#
# and these files:
# - Web/Build/genindex-core.html (for list and order of hymns)
# 
# it makes these files:
# Web/Build/genindex?-core.html Web/Build/genindexother-core.html
#
# version 1.0 19 Jan 2011 (bjd) 
#######################################################################
$OHROOT=`ohroot`;
$OHROOT =~ s/\n//;
#print STDERR $OHROOT;
$hymnnum=15;
@alphabet = ("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z");
$currnum = 0;
$openindex = -1;

#######################################################################
# General Index - uses Web/genindex.html only
#######################################################################
#	$command = "iconv --from-code=ISO-8859-1 --to-code=UTF-8 " . $OHROOT . "Web/genindex.html > /tmp/buildsword";
	$command = "cat " . $OHROOT . "Web/Build/genindex-core.html > /tmp/buildsword";
	system $command;
	open (INPUT, "/tmp/buildsword" );
	for ($i=0; $i<27; $i++) {
		$file[$i] = "";
	}
	$header = "";
	$footer = "";
	$footertouse = "\t</tbody>\n</table>\n</center>\n";

	$digging = 0;
	while (<INPUT>) {
		if ($digging == 2) {
			$footer .= $_;
		}
		elsif ($digging == 1) {
			# digging == 1 means we're in the main hymn section
			#print "Digging\n";
			if ( /<\/tbody>/ ) {
				$digging = 2;
				$footer .= $_;
			}
			elsif ( /<tr valign\=\"top\">/ ) {
				# New hymn entry
				$entry = $_;
				while ( ! /<\/tr>/ ) {
					$_ = <INPUT>;
					$entry .= $_;
					
					#print " ---> ",$_;
				}
				$title = $entry;
				$_ = $title;
				if ( /<p class="title">/ ) {
					#real hymn
					$title =~ s/\n/ /g;
					$title =~ s/.*<p class\=\"title\">//;
					$title =~ s/^[^>]*>//;
					$title =~ s/<.*$//;
					$title =~ s/([A-Z]).*/\1/;
					$title =~ s/.*([A-Z])/\1/;					
					while ( uc($title) ne uc($alphabet[$currnum]) ) {
						$currnum++;
					}
					if ( $currnum != $openindex ) {
						if ( $openindex >= 0 ) {
							# write the footer to the old split index file
							print OUTPUT $footertouse;
							#print "Write FOOTER to genindex",lc($alphabet[$openindex]),"-core.html\n";
							# close the old split index file
							close OUTPUT;
						}
						$openindex = $currnum;
						# open the new split index
						$newfile = "> " . $OHROOT . "Web/Build/genindex".lc($alphabet[$openindex])."-core.html";
						open (OUTPUT, $newfile );
						# write the header
						print OUTPUT $header;
						#print "Write HEADER to genindex",lc($alphabet[$openindex]),"-core.html\n";
					}
					# write to the split index file
					print OUTPUT $entry;
					#print $title,"  -->  ",uc($alphabet[$currnum]),"\n";
					#print "BREAK TO START ",uc($alphabet[$currnum]),"\n";
#					index[$currnum] .= $entry;						
				}
				else {
					# redirect <p class="western">
					$title =~ s/\n/ /g;
					$title =~ s/.*<p class\=\"western\">//;
					#$title =~ s/^[^>]*>//;
					#$title =~ s/<.*$//;
					$title =~ s/([A-Z]).*/\1/;
					$title =~ s/.*([A-Z])/\1/;					
					#print "redirect ",$title,"\n";
					while ( uc($title) ne uc($alphabet[$currnum]) ) {
						$currnum++;
					}
					if ( $currnum != $openindex ) {
						if ( $openindex >= 0 ) {
							# write the footer to the old split index file
							print OUTPUT $footertouse;
							#print "Write FOOTER to genindex",lc($alphabet[$openindex]),"-core.html\n";
							# close the old split index file
							close OUTPUT;
						}
						$openindex = $currnum;
						# open the new split index
						$newfile = "> " . $OHROOT . "Web/Build/genindex".lc($alphabet[$openindex])."-core.html";
						open (OUTPUT, $newfile );
						# write the heading
						print OUTPUT $header;
						#print "Write HEADER to genindex",lc($alphabet[$openindex]),"-core.html\n";
					}
					# write to the split index file
					print OUTPUT $entry;
					#print $title,"  -R>  ",uc($alphabet[$currnum]),"\n";
#					index[$currnum] .= $entry;						
				}
				#print $entry;
				#exit;
			}
			else {
				# what is this?
				$file .= $_;
			}
		}
		elsif ( /<tbody>/ ) {
			$digging = 1;
			$header .= $_;
		}
		else {
			$header .= $_;
		}
	}
	close INPUT;
	print OUTPUT $footertouse;
	#print "Write FOOTER to genindex",lc($alphabet[$openindex]),"-core.html\n";
	close OUTPUT;

	# Now time to dig through $footer to make the Choral/Bonus Section
	$newfile = "> " . $OHROOT . "Web/Build/genindexother-core.html";
	open (OUTPUT, $newfile );
	# write the header
	print OUTPUT $header;
	@parts = split "<tbody>", $footer;
	@parts1 = split "</tbody>", $parts[1];
	#$footer =~ s/

	print OUTPUT $parts1[0],"\n";
	print OUTPUT "\t\t",'<tr valign="top">',"\n\t\t\t",'<TD colspan="8"><p class="western">Bonus Carol:</p></td>',"\n\t\t","</tr>","\n";
	@parts1 = split "</tbody>", $parts[2];
	print OUTPUT $parts1[0],"\n";
	print OUTPUT $footertouse;
	close OUTPUT;
	
#	print $file;

exit;
