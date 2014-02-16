#!/usr/bin/perl

use strict;
use utf8;
use LWP::Simple;
use Getopt::Std;

our($opt_l, $opt_s, $opt_m,$opt_h);
getopts('l:s:m:h');


sub HELP_MESSAGE
{
  print <<EOT;

$0 -l <language name> [-s <sleep seconds>] [-m <mark>] [-h] [in_file [out_file]]

This script scans .tei dictionary for translations values marked with <quote>
tags, and tries to query http://en.wiktionary.org online dictionary for articles
titled as value found between <quote></quote>. If article is found and has a
section <language name> inside, then this translation is considered to be ok.
Otherwise translation is considered to be dubious and marked with a <mark> sign
at the beginning ot the line.

Then you can use `diff -u10` and deal with dubious translation only.

This script can be useful if you start maintaining buggy dictionary and want to
eliminate typos and misspelling.


Options:

-h	help & exit
-l	language name as used in en.wiktionary.org section names. I.e. "Russian"
-s	sleep time between fetches in seconds, in order not to DDoS wiktionary.
	Default is 3
-m	a symbol for marking dubious translations. Default is '☹'

Usage examples:

  $0 -l Russian eng-rus.tei eng-rus.tei.marked
  
  $0 -l Russian <eng-rus.tei >eng-rus.tei.marked

Author:
  Nikolay Shaplov <dhyan\@nataraj.su>, 2014

License:
  GNU General Public License ver. 2.0 and any later version.

EOT
  exit
}

HELP_MESSAGE if $opt_h or (!$opt_l);

my $target_lang = $opt_l;
my $sleep = $opt_s || 3;
my $error_mark = $opt_m || '☹'; # do not use symblos that might be insde your dictionary!!!

my $in;
if ($ARGV[0])
{
  open $in, "<:utf8" , $ARGV[0] or die "cannot open ".$ARGV[0]." $!";
} else
{
  binmode(STDIN, ":utf8");
  $in = *STDIN;
}
my $out;
if ($ARGV[1])
{
  open $out, "<:utf8" , $ARGV[1] or die "cannot open ".$ARGV[1]." $!";
} else
{
  binmode(STDOUT, ":utf8");
  $out = *STDOUT;
}

binmode(STDERR, ":utf8");

my $buf = "";

my $text = "";
while (my $s = <$in>)
{
  $text.= $s;
}

my $res = "";
while ($text=~s{^(.*?)(<quote.*?>)(.*?)(</quote.*?>)}{}s)
{
  my $ok = 1;
  my $header = $1;
  my $open = $2;
  my $def = $3;
  my $close = $4;
  
  print STDERR $def;
  
  my $content = get("http://en.wiktionary.org/wiki/$def");
  
  if ( !($content =~/<h2><span class="mw-headline" id="$target_lang">$target_lang/s ))
  {
    $ok = 0;
    $open =~ s/</$error_mark</s;
  }
  
  print STDERR " Ok\n" if $ok;
  print STDERR " Error!\n" unless $ok;
  my_print("$header$open$def$close");
}

my_print($text);
print $out $buf;


# If you do not know perl well consider this function a magic, that moves $error_mark
# from the middle of the line to the beggining
sub my_print
{
  my $str = shift;
  my @l = split /\n/,$str,-1;
  
  if (int @l == 1)
  {
    $buf.= shift @l;
    return 0;
  }
  $l[0]=$buf.$l[0];
  
  while (int @l > 1)
  {
    my $s = shift @l;
    if ($s =~ s/$error_mark//g)
    {
      $s=$error_mark.$s;
    }
    print $out $s, "\n";
  }
  $buf = shift @l;
}