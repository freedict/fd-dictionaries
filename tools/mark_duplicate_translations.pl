#!/usr/bin/perl

use strict;
use utf8;
use LWP::Simple;
use Getopt::Std;

our($opt_l, $opt_s, $opt_m,$opt_h);
getopts('l:s:m:h');


sub HELP_MESSAGE
{
  binmode(STDOUT, ":utf8");
  print <<EOT;

$0 [-m <mark>] [-h] [in_file [out_file]]

This script scans .tei dictionary for duplicate translation values. First it splits 
the whole file by <entry></entry> tags. Then in each entry it finds <quote></quote>
tags. If there are two equal values found between different <quote></quote> tags
the whole entry is considered to have duplicate translations and is marked with 
<mark> sign at the beginning of each entry line.

This script is rather dumb, it might consider two different senses i.e. noun
and verb as duplicate translation, when they are translated as same word. One should
check it\'s work manually.

You might also want to edit only diff file after translations marking. Then you might
need this simple script in order to fix diff format when you remove unneeded lines.

 ======================
#!/usr/bin/perl

use strict;

my (\$header, \$buf, \$m, \$p) = (undef,undef,undef,undef);
while (my \$s = <STDIN>)
{
  if (\$s=~/^\\@/)
  {
    if (\$header)
    {
      print_chunk();
    }
    \$buf = '';
    \$header = \$s;
    \$m=0;
    \$p=0;
    next;
  }  elsif (\$s=~/^\-/)
  {
    \$m++;
  }elsif (\$s=~/^\+/)
  {
    \$p++;
  } else
  {
    \$p++;
    \$m++;
  }
  \$buf.=\$s;
}
print_chunk();
      
sub print_chunk
{
  \$header=~s{(^\\@\\@ \-\d*,)\d*( \+\d*,)\d*( \\@\\@\$)}{\$1\$m\$2\$p\$3};
      print \$header;
      print \$buf;

}
 ======================
Options:

-h	help & exit
-m	a symbol for marking entries with duplicate translations. Default is '☹'

Usage examples:

  $0 eng-rus.tei eng-rus.tei.marked
  
  $0 <eng-rus.tei >eng-rus.tei.marked

Author:
  Nikolay Shaplov <dhyan\@nataraj.su>, 2014

License:
  GNU General Public License ver. 2.0 and any later version.

EOT
  exit
}

HELP_MESSAGE if $opt_h;

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
while ($text=~s{^(.*?)(<entry.*?>)(.*?)(</entry.*?>)}{}s)
{
  my $ok = 1;
  my $header = $1;
  my $open = $2;
  my $entry = $3;
  my $close = $4;
  
  my @translations = ();
  my $entry_copy = $entry;
  
  while ($entry_copy =~s{^.*?<quote.*?>(.*?)</quote.*?>}{}s)
  {
    my $word = $1;
#    if ($word ~~ @translations)
   if (grep{$1 eq $word} @translations)
    {
      $ok = 0;
      last;
    }
    push @translations, $word;
  }
  if (! $ok)
  {
    $entry =~ s/\n/\n$error_mark/gs;
    $entry = $error_mark.$entry
  }
  my_print("$header$open$entry$close");
  
}

my_print($text);
print $out $buf;


# If you do not know perl well consider this function a magic, that moves $error_mark
# from the middle of the line to the beginning
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