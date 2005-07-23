#!/usr/bin/perl -w
# (w) August 2003, Michael Bunk, GPL

use strict;
# get Net::Dict from http://www.cpan.org/modules/by-module/Net/
# I used 2.07 from 2003-May-05
use Net::Dict;

die "This program is for testing indices, not search strategies\n".
"Call me as '$0 <hostname> <database> <filename> <port>'\n". 
 " where <hostname> is the name of a DICT server,\n".
 "       <database> is the name of the database to query and\n".
 "       <filename> is the name of the wordlist file\n".
 "	 <port> at which the DICT server listens\n".

 "There should not be any headword yielding 0 definitions.\n".
 "Otherwise it means the server was unable to find those headwords.\n".
 "Assuming the wordlist used was generated out of a dict index file,\n".
 "this could mean the index is incorrectly sorted or there is something\n".
 "wrong with the server.\n" if ($#ARGV != 3);

my $port = $ARGV[3];
my $host = $ARGV[0];print "Using host:port: $host:$port\n";
my @databases = ($ARGV[1]); 
open my $f,$ARGV[2] or die $!;

my $words = 0;
my $dict = Net::Dict->new($host, "Port", $port) or die $!;

my %dbhash = $dict->dbs();
print "Available dictionaries:\n";
while ((my $db, my $title) = each %dbhash)
{
  print "  $db : $title\n";
}

$dict->setDicts(@databases);

print "Using database(s): @databases.\n\n";

my %counters;
$counters{0} = 0;

while (<$f>) {

  chop;

  # actually we should check for repeating headwords
  # and expect as many definitions

  # use 'define' strategy
  my $h = $dict->define($_);
  
  my $count = $#{@$h};

  $counters{$count+1}++;

  if ($count == -1)
  {
    if($counters{0} == 10)
    {
      print "Will not print further missing headwords.\n";
    }
    print "Headword without definition: '$_'\n" if($counters{0}<10);
  }
 
  $words++;

  if ($words % 50 == 0)
  {
     printf "%7d headwords. %7d missing\r", $words, $counters{0}; flush STDOUT;
  }

 }

print "\nLooked up $words words.\n";

print "# of headwords | # of definitions found\n";
print "---------------------------------------\n";

for(sort {$a <=> $b} keys %counters)
{
  printf "%10d | %5d\n", $counters{$_}, $_;
}

