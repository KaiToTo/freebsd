#!/usr/bin/perl -wC

#
# $FreeBSD$
#

use strict;
use XML::Parser;
use Tie::IxHash;
use Data::Dumper;
use Digest::SHA qw(sha1_hex);
require "charmaps.pm";

if ($#ARGV < 2) {
	print "Usage: $0 <cldrdir> <unidatadir> <xmldirs> <charmaps> <type> [la_CC]\n";
	exit(1);
}

my $DEFENCODING = "UTF-8";
my $CLDRDIR = shift(@ARGV);
my $UNIDATADIR = shift(@ARGV);
my $XMLDIR = shift(@ARGV);
my $CHARMAPS = shift(@ARGV);
my $TYPE = shift(@ARGV);
my $doonly = shift(@ARGV);
my @filter = ();

my %convertors = ();

my %ucd = ();
my %values = ();
my %hashtable = ();
my %languages = ();
my %translations = ();
my %encodings = ();
my %alternativemonths = ();
get_languages();

my %utf8map = ();
my %utf8aliases = ();
get_unidata($UNIDATADIR);
get_utf8map("$CLDRDIR/posix/$DEFENCODING.cm");
get_encodings("$XMLDIR/charmaps");

my %keys = ();
tie(%keys, "Tie::IxHash");
tie(%hashtable, "Tie::IxHash");

my %FILESNAMES = (
	"monetdef"	=> "LC_MONETARY",
	"timedef"	=> "LC_TIME",
	"msgdef"	=> "LC_MESSAGES",
	"numericdef"	=> "LC_NUMERIC"
);

my %callback = (
	mdorder => \&callback_mdorder,
	altmon => \&callback_altmon,
	data => undef,
);

my %DESC = (

	# numericdef
	"decimal_point"	=> "decimal_point",
	"thousands_sep"	=> "thousands_sep",
	"grouping"	=> "grouping",

	# monetdef
	"int_curr_symbol"	=> "int_curr_symbol (last character always " .
				   "SPACE)",
	"currency_symbol"	=> "currency_symbol",
	"mon_decimal_point"	=> "mon_decimal_point",
	"mon_thousands_sep"	=> "mon_thousands_sep",
	"mon_grouping"		=> "mon_grouping",
	"positive_sign"		=> "positive_sign",
	"negative_sign"		=> "negative_sign",
	"int_frac_digits"	=> "int_frac_digits",
	"frac_digits"		=> "frac_digits",
	"p_cs_precedes"		=> "p_cs_precedes",
	"p_sep_by_space"	=> "p_sep_by_space",
	"n_cs_precedes"		=> "n_cs_precedes",
	"n_sep_by_space"	=> "n_sep_by_space",
	"p_sign_posn"		=> "p_sign_posn",
	"n_sign_posn"		=> "n_sign_posn",

	# msgdef
	"yesexpr"	=> "yesexpr",
	"noexpr"	=> "noexpr",
	"yesstr"	=> "yesstr",
	"nostr"		=> "nostr",

	# timedef
	"abmon"		=> "Short month names",
	"mon"		=> "Long month names (as in a date)",
	"abday"		=> "Short weekday names",
	"day"		=> "Long weekday names",
	"t_fmt"		=> "X_fmt",
	"d_fmt"		=> "x_fmt",
	"XXX"		=> "c_fmt",
	"am_pm"		=> "AM/PM",
	"d_t_fmt"	=> "date_fmt",
	"altmon"	=> "Long month names (without case ending)",
	"md_order"	=> "md_order",
	"t_fmt_ampm"	=> "ampm_fmt",

);

if ($TYPE eq "numericdef") {
	%keys = (
	    "decimal_point"	=> "s",
	    "thousands_sep"	=> "s",
	    "grouping"		=> "ai",
	);
	get_fields();
	print_fields();
	make_makefile();
}

if ($TYPE eq "monetdef") {
	%keys = (
	    "int_curr_symbol"	=> "s",
	    "currency_symbol"	=> "s",
	    "mon_decimal_point"	=> "s",
	    "mon_thousands_sep"	=> "s",
	    "mon_grouping"	=> "ai",
	    "positive_sign"	=> "s",
	    "negative_sign"	=> "s",
	    "int_frac_digits"	=> "i",
	    "frac_digits"	=> "i",
	    "p_cs_precedes"	=> "i",
	    "p_sep_by_space"	=> "i",
	    "n_cs_precedes"	=> "i",
	    "n_sep_by_space"	=> "i",
	    "p_sign_posn"	=> "i",
	    "n_sign_posn"	=> "i"
	);
	get_fields();
	print_fields();
	make_makefile();
}

if ($TYPE eq "msgdef") {
	%keys = (
	    "yesexpr"		=> "s",
	    "noexpr"		=> "s",
	    "yesstr"		=> "s",
	    "nostr"		=> "s"
	);
	get_fields();
	print_fields();
	make_makefile();
}

if ($TYPE eq "timedef") {
	%keys = (
	    "abmon"		=> "as",
	    "mon"		=> "as",
	    "abday"		=> "as",
	    "day"		=> "as",
	    "t_fmt"		=> "s",
	    "d_fmt"		=> "s",
	    "XXX"		=> "s",
	    "am_pm"		=> "as",
	    "d_fmt"		=> "s",
	    "d_t_fmt"		=> "s",
#	    "altmon"		=> ">mon",		# repeat them for now
	    "altmon"		=> "<altmon<mon<as",
	    "md_order"		=> "<mdorder<d_fmt<s",
	    "t_fmt_ampm"	=> "s",
	);
	get_fields();
	print_fields();
	make_makefile();
}

sub callback_mdorder {
	my $s = shift;
	return undef if (!defined $s);
	$s =~ s/[^dm]//g;
	return $s;
};

sub callback_altmon {
	# if the language/country is known in %alternative months then
	# return that, otherwise repeat mon
	my $s = shift;

	if (defined $alternativemonths{$callback{data}{l}}{$callback{data}{c}}) {
		return $alternativemonths{$callback{data}{l}}{$callback{data}{c}};
	}

	return $s;
}

############################

sub get_unidata {
	my $directory = shift;

	open(FIN, "$directory/UnicodeData.txt");
	my @lines = <FIN>;
	chomp(@lines);
	close(FIN);

	foreach my $l (@lines) {
		my @a = split(/;/, $l);

		$ucd{code2name}{"$a[0]"} = $a[1];	# Unicode name
		$ucd{name2code}{"$a[1]"} = $a[0];	# Unicode code
	}
}

sub get_utf8map {
	my $file = shift;

	open(FIN, $file);
	my @lines = <FIN>;
	close(FIN);
	chomp(@lines);

	my $prev_k = undef;
	my $prev_v = "";
	my $incharmap = 0;
	foreach my $l (@lines) {
		$l =~ s/\r//;
		next if ($l =~ /^\#/);
		next if ($l eq "");

		if ($l eq "CHARMAP") {
			$incharmap = 1;
			next;
		}

		next if (!$incharmap);
		last if ($l eq "END CHARMAP");

		$l =~ /^<([^\s]+)>\s+(.*)/;
		my $k = $1;
		my $v = $2;
		$k =~ s/_/ /g;		# unicode char string
		$v =~ s/\\x//g;		# UTF-8 char code
		$utf8map{$k} = $v;

		$utf8aliases{$k} = $prev_k if ($prev_v eq $v);

		$prev_v = $v;
		$prev_k = $k;
	}
}

sub get_encodings {
	my $dir = shift;
	foreach my $e (sort(keys(%encodings))) {
		if (!open(FIN, "$dir/$e.TXT")) {
			print "Cannot open charmap for $e\n";
			next;

		}
		$encodings{$e} = 1;
		my @lines = <FIN>;
		close(FIN);
		chomp(@lines);
		foreach my $l (@lines) {
			$l =~ s/\r//;
			next if ($l =~ /^\#/);
			next if ($l eq "");

			my @a = split(" ", $l);
			next if ($#a < 1);
			$a[0] =~ s/^0[xX]//;	# local char code
			$a[1] =~ s/^0[xX]//;	# unicode char code
			$convertors{$e}{uc($a[1])} = uc($a[0]);
		}
	}
}

sub get_languages {
	my %data = get_xmldata($CHARMAPS);
	%languages = %{$data{L}}; 
	%translations = %{$data{T}}; 
	%alternativemonths = %{$data{AM}}; 
	%encodings = %{$data{E}}; 

	return if (!defined $doonly);

	my @a = split(/_/, $doonly);
	if ($#a == 1) {
		$filter[0] = $a[0];
		$filter[1] = "x";
		$filter[2] = $a[1];
	} elsif ($#a == 2) {
		$filter[0] = $a[0];
		$filter[1] = $a[1];
		$filter[2] = $a[2];
	}

	print Dumper(@filter);
	return;
}

sub get_fields {
	foreach my $l (sort keys(%languages)) {
	foreach my $f (sort keys(%{$languages{$l}})) {
	foreach my $c (sort keys(%{$languages{$l}{$f}{data}})) {
		next if ($#filter == 2 && ($filter[0] ne $l
		    || $filter[1] ne $f || $filter[2] ne $c));

		$languages{$l}{$f}{data}{$c}{$DEFENCODING} = 0;	# unread
		my $file;
		$file = $l . "_";
		$file .= $f . "_" if ($f ne "x");
		$file .= $c;
		if (!open(FIN, "$CLDRDIR/posix/$file.$DEFENCODING.src")) {
			if (!defined $languages{$l}{$f}{fallback}) {
				print STDERR
				    "Cannot open $file.$DEFENCODING.src\n";
				next;
			}
			$file = $languages{$l}{$f}{fallback};
			if (!open(FIN,
			    "$CLDRDIR/posix/$file.$DEFENCODING.src")) {
				print STDERR
				    "Cannot open fallback " .
				    "$file.$DEFENCODING.src\n";
				next;
			}
		}
		print "Reading from $file.$DEFENCODING.src for ${l}_${f}_${c}\n";
		$languages{$l}{$f}{data}{$c}{$DEFENCODING} = 1;	# read
		my @lines = <FIN>;
		chomp(@lines);
		close(FIN);
		my $continue = 0;
		foreach my $k (keys(%keys)) {
			foreach my $line (@lines) {
				$line =~ s/\r//;
				next if (!$continue && $line !~ /^$k\s/);
				if ($continue) {
					$line =~ s/^\s+//;
				} else {
					$line =~ s/^$k\s+//;
				}

				$values{$l}{$c}{$k} = ""
					if (!defined $values{$l}{$c}{$k});

				$continue = ($line =~ /\/$/);
				$line =~ s/\/$// if ($continue);

				while ($line =~ /_/) {
					$line =~
					    s/\<([^>_]+)_([^>]+)\>/<$1 $2>/;
				}
				die "_ in data - $line" if ($line =~ /_/);
				$values{$l}{$c}{$k} .= $line;

				last if (!$continue);
			}
		}
	}
	}
	}
}

sub decodecldr {
	my $e = shift;
	my $s = shift;

	my $v = undef;

	if ($e eq "UTF-8") {
		#
		# Conversion to UTF-8 can be done from the Unicode name to
		# the UTF-8 character code.
		#
		$v = $utf8map{$s};
		die "Cannot convert $s in $e (charmap)" if (!defined $v);
	} else {
		#
		# Conversion to these encodings can be done from the Unicode
		# name to Unicode code to the encodings code.
		#
		my $ucc = undef;
		$ucc = $ucd{name2code}{$s} if (defined $ucd{name2code}{$s});
		$ucc = $ucd{name2code}{$utf8aliases{$s}}
			if (!defined $ucc
			 && $utf8aliases{$s}
			 && defined $ucd{name2code}{$utf8aliases{$s}});

		if (!defined $ucc) {
			if (defined $translations{$e}{$s}{hex}) {
				$v = $translations{$e}{$s}{hex};
				$ucc = 0;
			}
		}

		die "Cannot convert $s in $e (ucd string)" if (!defined $ucc);
		$v = $convertors{$e}{$ucc} if (!defined $v);

		$v = $translations{$e}{$s}{hex}
			if (!defined $v && defined $translations{$e}{$s}{hex});

		if (!defined $v && defined $translations{$e}{$s}{unicode}) {
			my $ucn = $translations{$e}{$s}{unicode};
			$ucc = $ucd{name2code}{$ucn}
				if (defined $ucd{name2code}{$ucn});
			$ucc = $ucd{name2code}{$utf8aliases{$ucn}}
				if (!defined $ucc
				 && defined $ucd{name2code}{$utf8aliases{$ucn}});
			$v = $convertors{$e}{$ucc};
		}

		die "Cannot convert $s in $e (charmap)" if (!defined $v);
	}

	return pack("C", hex($v)) if (length($v) == 2);
	return pack("CC", hex(substr($v, 0, 2)), hex(substr($v, 2, 2)))
		if (length($v) == 4);
	return pack("CCC", hex(substr($v, 0, 2)), hex(substr($v, 2, 2)),
	    hex(substr($v, 4, 2))) if (length($v) == 6);
	print STDERR "Cannot convert $e $s\n";
	return "length = " . length($v);

}

sub translate {
	my $enc = shift;
	my $v = shift;

	return $translations{$enc}{$v} if (defined $translations{$enc}{$v});
	return undef;
}

sub print_fields {
	foreach my $l (sort keys(%languages)) {
	foreach my $f (sort keys(%{$languages{$l}})) {
	foreach my $c (sort keys(%{$languages{$l}{$f}{data}})) {
		next if ($#filter == 2 && ($filter[0] ne $l
		    || $filter[1] ne $f || $filter[2] ne $c));
		foreach my $enc (sort keys(%{$languages{$l}{$f}{data}{$c}})) {
			if ($languages{$l}{$f}{data}{$c}{$DEFENCODING} eq "0") {
				print "Skipping ${l}_" .
				    ($f eq "x" ? "" : "${f}_") .
				    "${c} - not read\n";
				next;
			}
			my $file = $l;
			$file .= "_" . $f if ($f ne "x");
			$file .= "_" . $c;
			print "Writing to $file in $enc\n";

			if ($enc ne $DEFENCODING &&
			    !defined $convertors{$enc}) {
				print "Failed! Cannot convert to $enc.\n";
				next;
			};

			open(FOUT, ">$TYPE/$file.$enc.new");
			my $okay = 1;
			my $output = "";
			print FOUT <<EOF;
# \$FreeBSD\$
#
# Warning: Do not edit. This file is automatically generated from the
# tools in /usr/src/tools/tools/locale. The data is obtained from the
# CLDR project, obtained from http://cldr.unicode.org/
#
# ${l}_$c in $enc
#
# -----------------------------------------------------------------------------
EOF
			foreach my $k (keys(%keys)) {
				my $f = $keys{$k};

				die("Unknown $k in \%DESC")
					if (!defined $DESC{$k});

				$output .= "#\n# $DESC{$k}\n";

				# Replace one row with another
				if ($f =~ /^>/) {
					$k = substr($f, 1);
					$f = $keys{$k};
				}

				# Callback function
				if ($f =~ /^\</) {
					$callback{data}{c} = $c;
					$callback{data}{k} = $k;
					$callback{data}{l} = $l;
					$callback{data}{e} = $enc;
					my @a = split(/\</, substr($f, 1));
					my $rv =
					    &{$callback{$a[0]}}($values{$l}{$c}{$a[1]});
					$values{$l}{$c}{$k} = $rv;
					$f = $a[2];
					$callback{data} = ();
				}

				my $v = $values{$l}{$c}{$k};
				$v = "undef" if (!defined $v);

				if ($f eq "i") {
					$output .= "$v\n";
					next;
				}
				if ($f eq "ai") {
					$output .= "$v\n";
					next;
				}
				if ($f eq "s") {
					$v =~ s/^"//;
					$v =~ s/"$//;
					my $cm = "";
					while ($v =~ /^(.*?)<(.*?)>(.*)/) {
						my $p1 = $1;
						$cm = $2;
						my $p3 = $3;

						my $rv = decodecldr($enc, $cm);
#						$rv = translate($enc, $cm)
#							if (!defined $rv);
						if (!defined $rv) {
							print STDERR 
"Could not convert $k ($cm) from $DEFENCODING to $enc\n";
							$okay = 0;
							next;
						}

						$v = $p1 . $rv . $p3;
					}
					$output .= "$v\n";
					next;
				}
				if ($f eq "as") {
					foreach my $v (split(/;/, $v)) {
						$v =~ s/^"//;
						$v =~ s/"$//;
						my $cm = "";
						while ($v =~ /^(.*?)<(.*?)>(.*)/) {
							my $p1 = $1;
							$cm = $2;
							my $p3 = $3;

							my $rv =
							    decodecldr($enc,
								$cm);
#							$rv = translate($enc,
#							    $cm)
#							    if (!defined $rv);
							if (!defined $rv) {
								print STDERR 
"Could not convert $k ($cm) from $DEFENCODING to $enc\n";
								$okay = 0;
								next;
							}

							$v = $1 . $rv . $3;
						}
						$output .= "$v\n";
					}
					next;
				}

				die("$k is '$f'");

			}

			$languages{$l}{$f}{data}{$c}{$enc} = sha1_hex($output);
			$hashtable{sha1_hex($output)}{"${l}_${f}_${c}.$enc"} = 1;
			print FOUT "$output# EOF\n";
			close(FOUT);

			if ($okay) {
				rename("$TYPE/$file.$enc.new",
				    "$TYPE/$file.$enc.src");
			} else {
				rename("$TYPE/$file.$enc.new",
				    "$TYPE/$file.$enc.failed");
			}
		}
	}
	}
	}
}

sub make_makefile {
	return if ($#filter > -1);
	print "Creating Makefile for $TYPE\n";
	open(FOUT, ">$TYPE/Makefile");
	print FOUT <<EOF;
#
# \$FreeBSD\$
#
# Warning: Do not edit. This file is automatically generated from the
# tools in /usr/src/tools/tools/locale.
# 

LOCALEDIR=	/share/locale
FILESNAME=	$FILESNAMES{$TYPE}
.SUFFIXES:	.src .out

.src.out:
	grep -v '^\#' < \${.IMPSRC} > \${.TARGET}

EOF

	foreach my $hash (keys(%hashtable)) {
		my @files = sort(keys(%{$hashtable{$hash}}));
		if ($#files > 0) {
			my $link = shift(@files);
			$link =~ s/_x_/_/;	# strip family if none there
			foreach my $file (@files) {
				my @a = split(/_/, $file);
				my @b = split(/\./, $a[-1]);
				$file =~ s/_x_/_/;
				print FOUT "SAME+=\t\t$link:$file\t#hash\n";
				undef($languages{$a[0]}{$a[1]}{data}{$b[0]}{$b[1]});
			}
		}
	}

	foreach my $l (sort keys(%languages)) {
	foreach my $f (sort keys(%{$languages{$l}})) {
	foreach my $c (sort keys(%{$languages{$l}{$f}{data}})) {
		next if ($#filter == 2 && ($filter[0] ne $l
		    || $filter[1] ne $f || $filter[2] ne $c));
		if (defined $languages{$l}{$f}{data}{$c}{$DEFENCODING}
		 && $languages{$l}{$f}{data}{$c}{$DEFENCODING} eq "0") {
			print "Skipping ${l}_" . ($f eq "x" ? "" : "${f}_") .
			    "${c} - not read\n";
			next;
		}
		foreach my $e (sort keys(%{$languages{$l}{$f}{data}{$c}})) {
			my $file = $l . "_";
			$file .= $f . "_" if ($f ne "x");
			$file .= $c;
			next if (!defined $languages{$l}{$f}{data}{$c}{$e});
			print FOUT "LOCALES+=\t$file.$e\n";
		}

		if (defined $languages{$l}{$f}{link}) {
			foreach my $e (sort keys(%{$languages{$l}{$f}{data}{$c}})) {
				my $file = $l . "_";
				$file .= $f . "_" if ($f ne "x");
				$file .= $c;
				print FOUT "SAME+=\t\t$file.$e:$languages{$l}{$f}{link}.$e\t# legacy\n";
				
			}
			
		}

	}
	}
	}

	print FOUT <<EOF;

FILES=		\${LOCALES:S/\$/.out/}
CLEANFILES=	\${FILES}

.for f in \${SAME}
SYMLINKS+=	../\${f:C/:.*\$//}/\${FILESNAME} \${LOCALEDIR}/\${f:C/^.*://}
.endfor

.for f in \${LOCALES}
FILESDIR_\${f}.out= \${LOCALEDIR}/\${f}
.endfor

.include <bsd.prog.mk>
EOF

	close(FOUT);
}
