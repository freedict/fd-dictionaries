#!/usr/bin/perl -w

# extracts data from FreeDict build file tree
# and puts it into data.csv
# but only if something changed
# that file will be used by the php scripts of the website

use strict;
use Text::CSV_XS;
use File::stat;
use IO::File;

# read data.csv into %dataold
my @column_names = qw(
  headwords
  version
  last-change
  status
  sourceurl
  download-dict-tgz-url
  download-dict-tgz-size
  download-dict-bz2-url
  download-dict-bz2-size
  download-mobi-url
  download-mobi-size
  download-zbedic-url
  download-zbedic-size
  download-deb-url
  download-deb-size
  download-rpm-url
  download-rpm-size
  download-gem-url
  download-gem-size
  notes
);
my $csv = Text::CSV_XS->new( { 'eol' => "\n" } );
my $filename = "../data.csv";
my %dataold;
if(-r $filename)
{
  my $csvf = new IO::File;
  if(! $csvf->open("< $filename"))
  {
    die "Could not open '$filename'.\n";
  }
  print "Reading data from '$filename'... ";
  while(!eof($csvf))
  {
    our $columns = $csv->getline($csvf);
    my $combination = shift @$columns;
    next if(0==scalar(@$columns));
    my %h;
    for(my $i=0; $i < @column_names; $i++)
    {
      @h{ $column_names[$i] } = $columns->[$i];
    }
    $dataold{$combination} = \%h;
  }
}
print "Now I know about ", scalar(keys %dataold), " dictionaries.\n";

# generate data into %datanew
my %datanew = ();
my $dirname = "..";
my $dir;
opendir $dir, $dirname;
my $entry;
while($entry = readdir($dir))
{
  next if(! -d $dirname.'/'.$entry);
  next if($entry !~ '^(\p{IsAlpha}{3})-(\p{IsAlpha}{3})$');

  print "Getting info from dictionary in '$dirname/$entry'...";
  our $n = {};

  my $indexfile = "$dirname/dicts/$entry.index";
  if(-r $indexfile)
  {
    my @a = split ' ', `wc -l "$indexfile"`;
    $n->{'headwords'} = shift @a;
  }
  else
  { warn "where is file '$indexfile'?"; }
  
  my $teifile = "$dirname/$entry/$entry.tei";
  if(-r $teifile)
  { 
    $n->{'version'} = `sabcmd xsl/getedition.xsl "$teifile"`;
    
    my $s = stat $teifile;
    my @ss = localtime($s->mtime);
    $n->{'last-change'} = sprintf("%4d-%02d-%02d", $ss[5]+1900, $ss[4]+1, $ss[3]);
    # like "2004-06-26"

    $n->{'status'} = `sabcmd xsl/getstatus.xsl "$teifile"`;
    $n->{'status'} = 'unknown' if(!$n->{'status'});
  
    $n->{'sourceurl'} = `sabcmd xsl/getsourceurl.xsl "$teifile"`;
  }
  
  my $dict_tgz_file = "$dirname/dicts/bin/$entry.tar.gz";
  if(-r $dict_tgz_file)
  {
    my $s = stat $dict_tgz_file;
    $n->{'download-dict-tgz-url'} =
      "http://prdownloads.sourceforge.net/freedict/$entry.tar.gz?download";
    $n->{'download-dict-tgz-size'} = $s->size;
  }

# "download-dict-bz2-url",
# "download-dict-bz2-size",
# "download-mobi-url", // non-available files have emtpy url, exactly ""
# "download-mobi-size",
# "download-zbedic-url",
# "download-zbedic-size",
# "download-deb-url",
# "download-deb-size",
# "download-rpm-url",
# "download-rpm-size",
# "download-gem-url",
# "download-gem-size",
# "notes" // optional, like "No notes today." or ""
 $datanew{"$entry"} = $n;
  print "\n\t", (join "\n\t", %$n), "\n";
#  last if((scalar (keys %datanew))>3);
}
closedir($dir);

# any news?
my $news = 0;
print "\nLooking for new things...\n";
# Look for old things that changed
foreach my $ko (keys %dataold)
{
  if(defined($datanew{$ko}))
  {
    print "Dictionary $ko is in old & new.\n";
    my $o = $dataold{$ko};
    foreach my $koe (keys %$o)
    {
      no warnings 'uninitialized';
      if($o->{$koe} ne $datanew{$ko}{$koe})
      {
        $news++;
        print "  difference: $ko / $koe: '",$o->{$koe}, "' != '",
          $datanew{$ko}{$koe}, "'\n";
      }
    }
  }
  else
  {
    print "Dictionary $ko is in old only. Did it go away? Very sad.\n";
    $news++;
  }
}
# look for new dicts that are not in old
foreach my $kn (keys %datanew)
{
  next if(defined($dataold{$kn}));
  $news++;
  print "Dictionary $kn in in new only. Good work!\n";
}
print "\nThere are about $news 'changes' to the data.\n";
if($news == 0)
{
  print "No changes found. Not recreating '$filename'.\n";
  exit 0;
}

# write new data.csv
#$filename .= ".new";
print "Writing '$filename' ... ";
my $csvf = new IO::File;
if(! $csvf->open("> $filename"))
{
  die "Could not open '$filename'.\n";
}
foreach(keys %datanew)
{
  my $n = $datanew{$_};
  my @a = ($_);
  for(my $i=0; $i < @column_names; $i++)
  {
    no warnings "uninitialized";
    #print "$i: ", $n->{ $column_names[$i] }, "\n"; 
    push @a, $n->{ $column_names[$i] };
  }
  if(! $csv->print($csvf, \@a) )
  {
    warn "Error while writing!";
  }
}
print "Success.\n";

