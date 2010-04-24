#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;
use Pod::Usage;

my $revision='$Revision$';
my $verbose = 0;
my $reverse = 0;
my $help;
GetOptions(
  "verbose+" => \$verbose,
  "help|?" => \$help,
  "reverse" => \$reverse) or exit 1;

pod2usage(-exitval => 1, -verbose => 2) if $help;

if ($verbose)
{
  print STDERR "Revision: $revision\n",
  "Some info about the dbase file:\n",
  `dbview -ieo SZOTAR.DBF` or die $!,
  "Mode: ", $reverse ? 'eng-hun' : 'hun-eng', "\n"
}

my $cmd = 'dbview SZOTAR.DBF | iconv -f cp437 -t utf8';
open(DB, "$cmd|") or die "Can't do '$cmd': $!";

# the first two entries look like
# (i found out the encoding after fetching the exmaple only):
#Angol      : to be taken aback
#Magyar     : meg van lepve
#
#Angol      : to abase
#Magyar     : megal z
#

$| = 1;# no STDOUT buffering
my $n = 0;
my $eng = '';
my $hun = '';
my $state = 0;
my %dict = ();
my $entry;

while(<DB>)
{
  if($state==0)
  {
    if(/^Angol      : (.*)$/)
    { $eng = $1; $state = 1; next }
    die "$.: Couldn't recognize English headword in '$_'"
  }

  if($state==1)
  {
    if(/^Magyar     : (.*)$/)
    { $hun = $1; $state = 2; next }
    die "$.: Couldn't recognize Hungarian translation in '$_'"
  }

  if($state==2)
  {
    if(/^$/)
    {
      $n++;
      print STDERR "\rLine $., $n records" if $n % 1000 == 0;

      # trim trailing spaces
      $eng =~ s/\s*$//;
      $hun =~ s/\s*$//;

      # XXX escape default entities: currently not required,
      # `make validation' succeeds anyway

      # save record in a hash, grouping headwords together
      if($reverse)
      {
	if(exists $dict{$eng}) { $entry = $dict{$eng} }
	else
	{
	  # use hashes to save the Hungarian translations,
	  # so we can easily check for double records
	  $entry = {}
	}

	if($entry->{$hun})
	{ print STDERR "\rDouble definition: hun='$hun' eng='$eng'\n" }
	else
	{
	  # save translation
	  $entry->{$hun} = 1;
	  $dict{$eng} = $entry
	}
       }
      else
      {
	if(exists $dict{$hun}) { $entry = $dict{$hun} }
	else
	{
	  # use hashes to save the English translations,
	  # so we can easily check for double records
	  $entry = {}
	}

	if($entry->{$eng})
	{ print STDERR "\rDouble definition: hun='$hun' eng='$eng'\n" }
	else
	{
	  # save translation
	  $entry->{$eng} = 1;
	  $dict{$hun} = $entry
	}
      }

      # get ready for next entry
      $state = 0; $eng = ''; $hun = ''; next
    }
    die "$.: Couldn't recognize empty line between entries in '$_'";
  }

  die "Unknown state: $state"
} # while

print STDERR "\nWriting entries to TEI file...\n" if $verbose;
my $entries = 0;
foreach(sort keys %dict)
{
  $entries++;
  print STDERR "\r$entries entries" if $entries % 1000 == 0 and $verbose;

  # output entry to TEI file
  print "<entry>\n";
  # XXX if eng headword starts with 'to ' -> markup as verb
  print "  <form><orth>$_</orth></form>\n";

  $entry = $dict{$_};
  #print scalar %$entry , " ";
  foreach my $t (keys %$entry)
  {
    # We put all translation equivalents of all eventual homographs into
    # separate senses of a single entry.  This compromise we have to do,
    # because we do not have information on part of speech (to separate
    # homographs) or translation equivalents (to join senses).  Luckily, only
    # 1590 + 30 entries are affected for hun-eng:
    #
    # # of headwords | # of definitions found
    # ---------------------------------------
    #              0 |     0
    #         138323 |     1
    #           1590 |     2
    #             30 |     3

    print "  <sense><trans><tr>$t</tr></trans></sense>\n";
  }

  print "</entry>\n";
}

print "</body></text></TEI.2>\n";

print STDERR "\nFinished.\nLines: $. Records: $n Entries: $entries\n\n"
  if $verbose;

__END__

=head1 NAME

    szotar-dbf2tei.pl - Convert the "Szotar" Hungarian-English dictionary to TEI

=head1 SYNOPSIS

    szotar-dbf2tei.pl [options]

=head1 DESCRIPTION

Converts the Szotar database in SZOTAR.DBF into TEI XML format on STDOUT.

=head1 OPTIONS

=over 8

=item B<--help>

Print this manual page and exit.

=item B<--reverse>

Output as eng-hun dictionary.  Without this option, the database is printed as
hun-eng dictionary.

=item B<--verbose>

Tell what I'm doing and print warnings.  Can be given twice for more verbosity.
Messages are printed to STDERR.

=back

=head1 AUTHOR AND LICENCE

Author: Michael Bunk, 2006

This is free software, licensed under the GPL.

=cut

