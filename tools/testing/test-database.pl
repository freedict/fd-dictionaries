#!/usr/bin/perl -w
# (w) April 2004, Michael Bunk, GPL
# looks up all words in a dictd database file pair (.index/.dict[.dz])
# by starting a dictd with an extra generated config file to serve
# this database and then looking up every headword from the index,
# reporting the missing headwords

use strict;
use Getopt::Std;
use File::Temp qw/ tempfile tempdir /;
use File::Spec;
use FindBin;

our ($opt_f, $opt_h, $opt_d, $opt_l, $opt_t);
getopts('hd:f:l:t');

if($opt_h || $opt_f eq "")
{ print "\nUsage: $0 [-h] [-d <path>] -f <dbfiles> [-l <locale>] [-t]\n\n".
 "\t<path>\t\tis the path to a dictd binary, defaults to /usr/local/sbin/dictd\n".
 "\t<dbfiles>\tis the path and name of dictd database files\n".
 "\t<locale>\twhat to pass as --locale to dictd\n".
 "\t\t\tthe extensions .index and .dict[.dz] are added automatically\n".
 "\t-t\t\ttest using dictd's --test-file option instead of ./test-lookupall\n";
 exit;
}

my $dictd = $opt_d || '/usr/local/sbin/dictd';
die 'dictd binary not found' if(! -x $dictd);

my $port = 2629;

my ($dictfile, $indexfile);
$dictfile = $opt_f .'.dict';
$dictfile .= '.dz' if(! -f $dictfile);
die "Could not find $opt_f.dict or $dictfile" if(! -f $dictfile);

$indexfile = $opt_f .'.index';
die "Could not find $indexfile" if(! -f $indexfile);

# generate dictd config file
my $dir = tempdir( CLEANUP => 1 );
my ($fh, $conffilename) = tempfile( DIR => $dir );
print "Generating config file in $conffilename\n";

my $abs_dict = $dictfile;
my $abs_index = $indexfile;
$abs_dict = File::Spec->rel2abs($dictfile)
  if(!File::Spec->file_name_is_absolute($dictfile));
$abs_index = File::Spec->rel2abs($indexfile)
  if(!File::Spec->file_name_is_absolute($indexfile));

print $fh <<HERE;
database test {
  data "$abs_dict"
  index "$abs_index"
  }
HERE

# generate wordlist from index
my ($fh2, $wordlist) = tempfile( DIR => $dir );
print "Generating wordlist in $wordlist\n";
my $cmdline = "$FindBin::Bin/index2wordlist.pl $indexfile >$wordlist";
system $cmdline || die "Could not run '$cmdline': $!";

my $commandline = "-c $conffilename -d nodetach -l none -p $port";
if($opt_l) { $commandline .= " --locale $opt_l"; }

# use alternative testing method: --test-file
if($opt_t)
{
  $commandline .= " --test-file $wordlist --test-strategy exact --test-nooutput";
  system "$dictd $commandline";
  exit;
}

# primary testing method: ./test-lookupall.pl

# start dictd as a child
defined(my $pid = fork) or die "Can't fork: $!";
if($pid == 0)
{
  print "Starting dictd: $dictd $commandline\n";
  exec "$dictd $commandline" || die "Could not exec $dictd: $!";
  die "Starting dictd failed.";
}
sleep 3;
print "Child has pid $pid.\n";

# lookup all headwords and report missing ones
$cmdline = "$FindBin::Bin/test-lookupall.pl 127.0.0.1 test $wordlist $port";
system $cmdline || die "Could not run '$cmdline': $!";

# terminate dictd
print "Terminating $pid\n";
kill "TERM", $pid;

