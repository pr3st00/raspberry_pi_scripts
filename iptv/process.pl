#!/usr/bin/perl -w

use strict;
use Data::Dumper;

my $DEBUG=0;

my $just_found_group;
my $hide_channel;
                   #EXTINF:-1 tvg-name="A&E HDR" tvg-logo="26e.png" group-title="CanaiRa",A&E 4K FHDR
my $m3u_regex = qr/#EXTINF:-1.*tvg-name="(.*)".*tvg-logo="([^"]*)".*group-title="([^"]+)",(.*)/;

#EXTM3U
#EXT-X-SESSION-DATA:DATA-ID="com.xui.1_5_5r2"

my $hide_file_list  = shift();
my $allow_file_list = shift();
my $max_entries     = shift();

if (! $hide_file_list || ! $allow_file_list) {
	&usage;
}

if (! -f $hide_file_list) {
	die "[ERROR] Cannot open file ($hide_file_list) ($!)\n";
	exit 155;
}

if (! -f $allow_file_list) {
	die "[ERROR] Cannot open file ($allow_file_list) ($!)\n";
	exit 155;
}

my $deny_regex_list = &read_regex_file($hide_file_list);
my $deny_regex_string = join '|', @{$deny_regex_list};

my $allow_regex_list = &read_regex_file($allow_file_list);
my $allow_regex_string = join '|', @{$allow_regex_list};

&debug("Final deny  regex is [$deny_regex_string]", $DEBUG);
&debug("Final allow regex is [$allow_regex_string]", $DEBUG);

$| = 1;
my $num_entries = 0;

while (<STDIN>) {

	if ($max_entries && $num_entries >= $max_entries) {
		&debug("Max entries reached, no more entries will be processed", $DEBUG);
		last;
	}

	my $group;
	my $line=$_;

	chomp($line);
	$line =~ s/\r$//;
	
	&debug(" ", $DEBUG);
	&debug("----------------------------------------------------------------------------------------------------", $DEBUG);
	&debug("Processing line [$line]", $DEBUG);
	
	if (/$m3u_regex/g) {
		&debug("Line matches a group definition", $DEBUG);

		my $group = $3;
		
		&debug("Group is [$group]", $DEBUG);

		if ($group =~ /$allow_regex_string/) {
			&debug("Allowing group [$group]", $DEBUG);
			print "$line \n";
		} elsif ($group =~ /$deny_regex_string/) {
			&debug("Hiding group [$group]", $DEBUG);
			$hide_channel=1;
		} else {
			&debug("Defaulting allow for group [$group]", $DEBUG);
			print "$line \n";
		}
	}
	else {
		if ($hide_channel) {
			&debug("Not adding line and resetting group hiding", $DEBUG);
			undef $hide_channel;
		} else {
			$num_entries++;
			&debug("Adding line", $DEBUG);
			print "$line \n";
		}
	}

	&debug("----------------------------------------------------------------------------------------------------", $DEBUG);
}

sub debug() {
	my $mesg = shift();
	print STDERR "$mesg \n" if $DEBUG;
}

sub usage() {
	print "Usage: perl process.pl <hide_list_file> <allow_file_list> [max_entries]\n";
	exit 1;
}

sub read_regex_file() {
	
	my $file=shift();
	my @list;
	
	open(FILE,$file);
	
	while (<FILE>) {
		chomp();
		push(@list,$_);
	}
	
	close(FILE);
	
	return \@list;
}

# EOF
