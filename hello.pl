#!/usr/bin/perl

my $sqlite_file = "/home/mill4138/bike.sl";

use strict;
use HTML::Template;
use DBI;
use URI::Query;
#use Switch;
use feature "switch";
use v5.10.1;

use Data::Dumper::Simple;

# open the html template
my $template = HTML::Template->new(filename => 'template/admin.tmpl');

sub view_initial_checkin_admin() {
  # Connect to Database
  my $dbh = DBI->connect("dbi:SQLite:dbname=$sqlite_file","","");


  # http://www.perl.com/pub/1999/10/DBI.html
  my $sth = $dbh->prepare('SELECT * FROM initial_view')
                or die "Couldn't prepare statement: " . $dbh->errstr;
  $sth->execute()
	or die "Couldn't execute statement: " . $sth->errstr; # Run Query
      my @bike_table;
      # Load data into HTML template from Database
      while (my @data = $sth->fetchrow_array()) {
	my %params_hash;
	$params_hash{'NAME'}       = $data[0];
	$params_hash{'EMAIL'}      = $data[1];
	$params_hash{'CHECKIN_ID'} = $data[2];
	$params_hash{'ZIP'}        = $data[3];
	$params_hash{'MILES'}      = $data[4];
#	$params_hash{'STATUS'}     = $data[5];
	$params_hash{'SECRET'}     = $data[6];
	push(@bike_table, \%params_hash);
      }

  $template->param(SHOW_MSG => 1); # There is a message to show at top of page.
  $template->param(MSG => [
		{MSG_BODY=>"Message one. Perhaps an error here."},
		{MSG_BODY => "Message Two"}
  ]);
  $template->param(BIKE_TABLE => \@bike_table);
}

my $qq = URI::Query->new($ENV{'QUERY_STRING'});
my %query = $qq->hash;

for ($query{'view_mode'}) {
	when (/^initial/) { &view_initial_checkin_admin(); }
}
	 &view_initial_checkin_admin();

# send the obligatory Content-Type and print the template output
print "Content-Type: text/html\n\n", $template->output;


#print Dumper(%qq);
#print $ENV{'QUERY_STRING'};

