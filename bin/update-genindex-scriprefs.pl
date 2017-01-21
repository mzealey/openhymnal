#!/usr/bin/perl

$OHROOT=`ohroot`;
$OHROOT =~ s/\n//;
$file = "<".$OHROOT."Web/Build/genindex-core.html";
open (INPUT, $file );

$file = "";
while (<INPUT>) {
	$file .= $_;
}
close INPUT;


@parts = split '<tr valign="top">', $file;
$rebuilt = $parts[0] . '<tr valign="top">' . $parts[1] ;
for ($i=2; $i<@parts;$i++) {
	$_ = $parts[$i];
	if ( /<p class="scripture">/ ) {
		@bits = split '<p class="scripture">', $parts[$i];
		$fn = $bits[0];
		$_ = $bits[1];
		if ( /<\/scripRef>/ ) {
			@bits2 = split '</scripRef>', $bits[1];
			$ref = $bits2[0];
			$ref =~ s/.*<p class\=\"scripture\">([^\n]*)<\/p>.*/\1/;
			#print $ref;
			#exit;
			$fn =~ s/.*<a href\=\"javascript:new_window\(\'Lyrics\///;
			#$fn =~ s/\'\)\">[A-Za-z0-9 "<>',.\/\n\t=\(\)\&;:?-]*//;
			$fn =~ s/\'\)\">.*\n.*\n*.*\n*.*\n*.*\n*.*\n?//;
			$fn =~ s/^\n//;
			$fn =~ s/[.]html/.abc/;
			$path = $fn;
			$_ = $path;
			if ( /-/ ) {
				$path =~ s/[-].*//;
			}
			else {
				$path =~ s/[.].*//;
			}
			$full = $OHROOT . "Complete/" . $path . "/" . $fn,"\n";
			if ( -f $full ) {
				$footer = `grep "%%footer" $full`;
			}
			else {
				$full =~ s/\/Complete\//\/Choir\//;
				if ( -f $full ) {
					$footer = `grep "%%footer" $full`;
				}
				else {
					$full =~ s/\/Choir\//\/Bonus\//;
					$footer = `grep "%%footer" $full`;
				}
			}
			$footer =~ s/\n//g;
			$footer =~ s/^[^"]*"//;
			$footer =~ s/".*//;
			$footer =~ s/\t*$//;
			$footer =~ s/\t*\\n/ /;
			#print STDERR $fn,": ",$footer,"\n";
			#$rebuilt .= '<tr valign="top">' . $bits[0] . '<p class="scripture">' . $bits2[0] . '</scripRef>' . $bits2[1];
			$rebuilt .= '<tr valign="top">' . $bits[0] . '<p class="scripture"><scripRef passage="' . $footer . '">' . $footer . '</scripRef>' . $bits2[1];
		}
		else {
			$rebuilt .= '<tr valign="top">' . $bits[0] . '<p class="scripture">' . $bits[1];
		}
	}
	else {
		$rebuilt .= '<tr valign="top">' . $parts[$i];
	
	}
} 
print $rebuilt;
