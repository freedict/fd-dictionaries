#!/usr/bin/perl -w

# $Revision$

# the produced freedict-database.xml has the following schema:
#
# document element: FreeDictDatabase
#  attributes: none
#  children: dictionary*
#
# element: dictionary
#  children: release*
#  attributes:
#   @name		language-combination, eg. eng-deu
#   @edition		taken from TEI header, will be used as release version
#   @headwords		`wc -l dictd-formatted-db.index`
#   @date		last change of TEI file
#   @status		contents of status note in TEI header, if available
#   @sourceURL		URL in sourceDesc in TEI header (upstream project)
#   @notes		unused
#   @HEADorRelease	in CVS, unused
#   @maintainerName	Maintainer name (without email) from
#			/TEI.2/fileDesc/titleStmt/respStmt/name[../resp='Maintainer']
#   @maintainerEmail	Email address of Maintainer from same place
#   @unsupported	space separated list of platforms, eg. "evolutionary bedic"
#
# element: release
#  children: none
#  attributes:
#   @platform		allowed values: dict-tgz, dict-tbz2, mobi,
#			bedic, deb, rpm, gem, src, evolutionary
#   @version		version of the dictionary this is a release of
#   @URL		URL where this release can be downloaded
#			(additional click may be required by SourceForge)
#   @size		size of this release in bytes
#   @date		when this release was made, eg. 2004-12-25

use FindBin;
use Getopt::Std;
use XML::DOM;
use File::stat;
use strict;
use WWW::Mechanize;
use HTML::TreeBuilder;

our($opt_v, $opt_h, $opt_a, $opt_d, $opt_f, $opt_r, $opt_l);
getopts('vhald:fr');

sub printd
{
  return unless $opt_v;
  print @_
}

my $sfurl = 'http://sourceforge.net/projects/freedict/files/';
my $FREEDICTDIR = $ENV{'FREEDICTDIR'} || "$FindBin::Bin/..";

printd "Using FREEDICTDIR=$FREEDICTDIR\n";

my $dbfile = "$FREEDICTDIR/freedict-database.xml";

if($opt_h)
{
  print <<EOT;
$0 [options] (-a | -d <la1-la2> | -r)

Gather metadata from TEI files in FreeDict file tree
and save it in the XML file $dbfile.  Also collect information about
available file releases from SourceForge download pages.

The location is taken from the environment variable
FREEDICTDIR or, if that is not set, the parent directory
of the script is taken, assuming the script resides
in the tools subdirectory of the FreeDict file tree.

Options:

-h	help & exit
-v	verbose
-a	extract metadata from all available databases
-d	extract data only from database la1-la2
-f	force update of extracted data from TEI file,
	even if its modification time is less than the last update
-l	leave $dbfile untouched
-r	extract released packages from the SourceForge file release pages
	at $sfurl

EOT
  exit
}

sub contains_dictionary
{
  my($doc, $entry) = @_;
  my $nodes = $doc->getElementsByTagName("dictionary");
  my $n = $nodes->getLength;

  for(my $i = 0; $i < $n; $i++)
  {
    my $node = $nodes->item($i);
    my $name = $node->getAttributeNode("name");
    next unless $name;
    return $node if $name->getValue eq $entry
  }
  return undef
}

sub fdict_extract_metadata
{
  my($dirname, $entry, $doc) = @_;
  printd " Getting metadata from dictionary in '$dirname/$entry'\n";

  # find old dictionary element -> update
  my $d = contains_dictionary($doc,  $entry);

  # else create new dictionary element
  unless(defined $d)
  {
    printd "  Dictionary not found in database. Inserting it.\n";
    my $docel = $doc->getDocumentElement();
    $docel->appendChild( $doc->createTextNode("  ") );
    $d = $doc->createElement('dictionary');
    $docel->appendChild($d);
    $docel->appendChild( $doc->createTextNode("\n") );
    $d->setAttribute('name', $entry)
  }

  ###################################################################

  my($headwords, $edition, $date, $status, $sourceURL, $maintainerName,
    $maintainerEmail, $unsupported);

  my $indexfile = "$dirname/$entry/$entry.index";

  unless(-r $indexfile)
  {
    system "cd $dirname/$entry && make $entry.index"
      or print STDERR "  ERROR: Failed to remake $entry.index\n"
  }

  if(-r $indexfile)
  {
    my @a = split ' ', `wc -l "$indexfile"`;
    $headwords = (shift @a) - 8;# substract /00-?database.*/ entries
    printd "  $headwords headwords\n"
  }
  else
  {
    print STDERR "  Where is file '$indexfile'?\n";
    $headwords = "ERROR: Could not find $indexfile"
  }

  $d->setAttribute('headwords', $headwords);

  ###################################################################

  my $teifile = "$dirname/$entry/$entry.tei";

  unless(-r $teifile)
  {
    system "cd $dirname/$entry && make $teifile"
      or print STDERR "  ERROR: Failed to remake $teifile\n"
  }

  if(-r $teifile)
  {

    my $s = stat $teifile;
    my @ss = localtime($s->mtime);
    $date = sprintf("%4d-%02d-%02d", $ss[5]+1900, $ss[4]+1, $ss[3]);

    if($date le $d->getAttribute('date') and !$opt_f)
    {
      printd "	Skipping time consuming extraction steps for update (try -f).\n";
      return
    }

  ###################################################################

    #$edition = `sabcmd xsl/getedition.xsl "$teifile"`;
    # the --no-print-directory switch is required if extractdata is
    # run from inside a Makefile
    $edition = `cd $dirname/$entry;make --no-print-directory version`;

  ###################################################################

    #$status = `sabcmd xsl/getstatus.xsl "$teifile"`;
    $status = `cd $dirname/$entry;make --no-print-directory status`;
    $status = 'unknown' if(!$status);

  ###################################################################

    #$sourceURL = `sabcmd xsl/getsourceurl.xsl "$teifile"`;
    $sourceURL = `cd $dirname/$entry;make --no-print-directory sourceURL`;

  ###################################################################

    #my $maintainer = `sabcmd xsl/getmaintainer.xsl "$teifile"`;
    use Encode;
    my $maintainer = decode_utf8(`cd $dirname/$entry;make --no-print-directory maintainer`);
    if($maintainer =~ /^([^<]+)\s<(.*)>$/)
    {
      $maintainerName = $1;
      $maintainerEmail = $2;
      #printd "  Extracted maintainer: name='$maintainerName' email='$maintainerEmail'\n";
    }
    else
    {
      printd "	Could not parse maintainer name and email from:\n" .
	"\t$maintainer\nUsing the whole as maintainer name.\n";
      $maintainerName = $maintainer
    }

  ###################################################################

    $unsupported = `cd $dirname/$entry && make --no-print-directory print-unsupported`;
    printd "  Failed to get info on unsupported platforms: $! $?\n" unless defined $unsupported;

  ###################################################################
  }
  else
  {
    $edition = "ERROR: $teifile not readable";
    $date = $edition;
    $status = $edition;
    $sourceURL = $edition
  }

  $d->setAttribute('edition', $edition);
  $d->setAttribute('date', $date);
  $d->setAttribute('status', $status);
  $d->setAttribute('sourceURL', $sourceURL);
  $d->setAttribute('maintainerName', $maintainerName);
  $d->setAttribute('maintainerEmail', $maintainerEmail);

  if(defined $unsupported && $unsupported =~ /[^\s]/)
  {
    $d->setAttribute('unsupported', $unsupported)
  }
  else
  {
    $d->removeAttribute('unsupported')
  }
}

sub fdict_extract_all_metadata
{
  my($dirname, $doc) = @_;
  my($dir, $entry);

  printd "Getting metadata of all databases\n";
  opendir $dir, $dirname;
  my @entries;
  while($entry = readdir($dir))
  {
    next unless -d $dirname.'/'.$entry;
    next if $entry !~ '^(\p{IsAlpha}{3})-(\p{IsAlpha}{3})$';
    push @entries, $entry
  }
  foreach $entry (sort @entries)
  { fdict_extract_metadata $dirname, $entry, $doc }
}

##################################################################

sub update_database
{
  my($doc, $URL, $size, $release_date) = @_;

  unless($URL =~ qr"^http://sourceforge.net/projects/freedict/files/[^/]+/[^/]+/(freedict-)(\w{3}-\w{3})-([\d\.]+)\.([^/]+)/download")
  { printd "filename in URL '$URL' not recognized\n"; return }
  my $la1la2 = $2;
  my $version = $3;
  my $extension = $4;

  my $d = contains_dictionary $doc, $la1la2;
  unless($d)
  {
    printd "$la1la2: Not in our database. Run '$0 -d $la1la2'. Skipping.\n";
    return
  }

  # find platform from extension
  # platforms: dict-tgz, dict-tbz2, mobi, bedic, deb, rpm, gem, src
  my %ext2platform =
  (
    'tar.gz' => 'dict-tgz',
    'tar.bz2' => 'dict-tbz2',
    'dic.dz' => 'bedic',
    'ipk' => 'zbedic',
    'evolutionary.zip' => 'evolutionary',
    'src.tar.bz2' => 'src',
    'noarch.rpm' => 'rpm'
  );
  my $platform = $ext2platform{$extension};
  unless(defined $platform)
  { printd "Cannot make sense of extension '$extension' of filename in URL $URL. Skip.\n"; return }

  # find old release element
  my $r;
  for my $kid ($d->getElementsByTagName('release'))
  {
    next if $kid->getAttribute('platform') ne $platform;
    $r = $kid; last # found
  }

  # create new release element if no previous found
  unless($r)
  {
    printd "$la1la2: Release version $version for platform $platform not found in database. Inserting it.\n";
    $d->appendChild( $doc->createTextNode("\n") )
      if( ! @{ ($d->getChildNodes) } );
    $d->appendChild( $doc->createTextNode("    ") );
    $r = $doc->createElement('release');
    $d->appendChild($r);
    $d->appendChild( $doc->createTextNode("\n") );
    $r->setAttribute('platform', $platform);
    return
  }

  # if $version is older release than available in the database,
  # don't update the database
  return if $r->getAttribute('version') gt $version;

  printd "$la1la2: New release for $platform platform. Old: '" .
    $r->getAttribute('version') . "' New: '$version'\n"
    if $r->getAttribute('version') gt $version;
  $r->setAttribute('version', $version);
  $r->setAttribute('URL', $URL);
  $r->setAttribute('size', $size);
  $r->setAttribute('date', substr($release_date,0,10))
}

sub fdict_extract_releases
{
  my $doc = shift;

  # Probably WWW::Mechanize is overkill now, LWP might be enough
  my $mech = WWW::Mechanize->new;
  printd "Getting $sfurl\n";
  $mech->get($sfurl);
  my $tree = HTML::TreeBuilder->new_from_content($mech->content);

  my @tablerows = $tree->look_down('_tag', 'tr');
  printd scalar(@tablerows), " <tr> elements in web page.\n";
  for my $tr (@tablerows)
  {
    # find $releasedate, $size, $URL
    my $a = $tr->look_down(
      '_tag', 'a',
      sub
      {
	#print $_[0]->attr('href'), "\n";
	$_[0]->attr('href') =~
	qr"^/projects/freedict/files/[^/]+/[^/]+/freedict-(\w{3})-(\w{3})-([\d\.]+).([\w\.]+)/download"
      }
    );
    next unless defined $a;
    my $URL = "http://sourceforge.net" . $a->attr('href');
    #printd "Got URL: $URL\n";

    my $date_td = $tr->look_down(
      '_tag', 'td',
      sub { $_[0]->as_text =~ /^\d\d\d\d-\d\d-\d\d$/ }
    );
    unless(defined $date_td)
    { printd "Did not find release date.\n"; next }
    my $release_date = $date_td->as_text;
    #printd "Got release date: $release_date\n";

    my $size_td = $tr->look_down(
      '_tag', 'td',
      sub { $_[0]->as_text =~ /^[\d.]+ [KM]B$/ }
    );
    next unless defined $size_td;
    my $s = $size_td->as_text;
    $s =~ /^([\d.]+) ([KM])B$/;
    my $size = int($1 * ($2 eq 'K' ? 1024 : 1024*1024));

    #printd "\n\t$URL $size $release_date\n";
    update_database $doc, $URL, $size, $release_date
  } # foreach(@links)
  $tree->delete
}
##################################################################

if($opt_d && $opt_a)
{ print STDERR "Only one of -d and -a may be given at the same time.\n"; exit }

if(!$opt_d && !$opt_a && !$opt_r)
{ print STDERR "One of -h, -d, -a or -r must be given.\n"; exit }

my $parser = new XML::DOM::Parser;

my $doc;
if(-s $dbfile)
{
  $doc = $parser->parsefile($dbfile);
  printd "Successfully read $dbfile.\n";
  my $nodes = $doc->getElementsByTagName("dictionary");
  my $n = $nodes->getLength;
  printd "$n dictionary/-ies in my database.\n"
}
else
{
  printd "Creating new database.\n";
  $doc = new XML::DOM::Document;
  $doc->appendChild( $doc->createElement('FreeDictDatabase') )
}

fdict_extract_metadata $FREEDICTDIR, $opt_d, $doc if $opt_d;
fdict_extract_all_metadata $FREEDICTDIR, $doc if $opt_a;
fdict_extract_releases $doc if $opt_r;

if($opt_l)
{ printd "Leaving $dbfile untouched.\n"; exit }

# Write out freedict-database.xml
`cp $dbfile $dbfile.bak` if -s $dbfile;
printd "Writing $dbfile\n";
$SIG{INT} = 'IGNORE';
my $fh = new FileHandle ($dbfile, "w") ||
  die "Can't open output file $dbfile: $!";
$fh->binmode(':utf8');
#$doc->printToFileHandle($fh);
$doc->print($fh);
$fh->close();
$SIG{INT} = 'DEFAULT'
