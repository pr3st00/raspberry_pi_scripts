#!/usr/bin/perl -w

use strict;
use Data::Dumper;

my $DEBUG=0;

                   #EXTINF:-1 tvg-name="A&E HDR" tvg-logo="26e.png" group-title="CanaiRa",A&E 4K FHDR
my $m3u_regex = qr/#EXTINF:-1.*tvg-name="(.*)".*tvg-logo="([^"]+)".*group-title="([^"]+)",(.*)/;

#EXTM3U
#EXT-X-SESSION-DATA:DATA-ID="com.xui.1_5_5r2"
my $num_headers     = 2;

my $LIST_ID=shift();

my %processed_groups;

my $group;
my $tvg_name;
my $tvg_logo;
my $group_title;
my $tvg_desc;
my $url;
my $raw;

&print_delete_sql();

while (<STDIN>) {

	chomp();

	my $line=$_;
	
	&debug(" ", $DEBUG);
	&debug("----------------------------------------------------------------------------------------------------", $DEBUG);
	&debug("Processing line $line", $DEBUG);
	
	if (/$m3u_regex/g) {
		&debug("Line matches!", $DEBUG);

		$tvg_name = &sanitize($1);
		$tvg_logo = &sanitize($2);
		$group_title = &sanitize($3);
		$tvg_desc = &sanitize($4);
		$raw = &sanitize($line);

		&debug("Group is [$group_title]", $DEBUG);

		if (exists $processed_groups{$group_title} ) {
			&debug("Group already processed, skipping", $DEBUG);
		} else {
			$processed_groups{$group_title}=1;
			print "INSERT IGNORE INTO `iptv_group`(`id`, `list_id`, `group-title`) VALUES (null,'$LIST_ID','$group_title');\n";
		}
	}
	elsif (/http/g) {
		chomp($line);
		$line =~ s/\r$//;
		$url = $line;
		my $inner = "(SELECT ID FROM iptv_group WHERE `group-title` = '$group_title')";
		print "INSERT IGNORE INTO `channel`(`id`, `iptv_group`, `tvg-name`, `tvg-logo`, `tvg-desc`, `url`, `raw_entry`) VALUES (null,$inner,'$tvg_name','$tvg_logo','$tvg_desc','$url','$raw');\n";
	}
}

sub debug() {
	my $mesg = shift();
	print STDERR "[DEBUG] $mesg \n" if $DEBUG;
}

sub usage() {
	print "Usage: perl generate_sql.pl <list_id>\n";
	exit 1;
}


sub print_delete_sql() {
	print "use iptv;\n\n";
	print "DELETE FROM channel;\n";
	print "DELETE FROM iptv_group;\n";
}

sub sanitize() {
	my $line = shift();

	$line =~ s/'/\\'/g;

	return $line;
}

# EOF
