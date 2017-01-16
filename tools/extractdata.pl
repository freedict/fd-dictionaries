#!/usr/bin/perl
print "TODO: this script doesn't yet know that the layout of FREEDICTDIR/ changed.\nQuick, but necessary fix!";
exit 88;
# Dependencies in debian (possibly not complete): libxml-dom-perl make xsltproc

$::VERSION = '$Revision$';

use strict;
use warnings;
use FindBin;
use Getopt::Std;
use XML::DOM;
use File::stat;
use File::stat;
use POSIX qw(strftime);
use URI::Escape;

our($opt_v, $opt_h, $opt_a, $opt_d, $opt_f, $opt_r, $opt_l, $opt_u, $opt_s, $opt_R);

sub printd
{
  return unless $opt_v;
  print @_
}

my $FREEDICTDIR = $ENV{'FREEDICTDIR'} || "$FindBin::Bin/..";
our $dbfile = "$FREEDICTDIR/freedict-database.xml";
getopts('vhald:frusR');

sub HELP_MESSAGE
{
  print <<EOT;
$0 [options] (-a | -d <la1-la2> | -r[s] | -u | -R)

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
-a	extract metadata from all available dictionaries
-d	extract data only from database la1-la2
-f	force update of extracted data from TEI file,
	even if its modification time is less than the last update
-l	leave $dbfile untouched
-r	extract released packages from the SourceForge file releases
-s	skip calling rsync (useful when local files are up to date anyway)
-u	remove metadata for unavailable (renamed or deleted) dictionaries
-R	list missing releases

The produced freedict-database.xml has the following schema:

 document element: FreeDictDatabase
  attributes: none
  children: dictionary*

 element: dictionary
  children: release*
  attributes:
   \@name		language-combination, eg. eng-deu
   \@edition		taken from TEI header, will be used as release version
   \@headwords		`wc -l dictd-formatted-db.index`
   \@date		last change of TEI file
   \@status		contents of status note in TEI header, if available
   \@sourceURL		URL in sourceDesc in TEI header (upstream project)
   \@notes		unused
   \@HEADorRelease	in CVS, unused
   \@maintainerName	Maintainer name (without email) from
			/TEI.2/fileDesc/titleStmt/respStmt/name[../resp='Maintainer']
   \@maintainerEmail	Email address of Maintainer from same place
   \@unsupported	space separated list of platforms, eg. "evolutionary bedic"

 element: release
  children: none
  attributes:
   \@platform		allowed values: dict-tgz, dict-tbz2, mobi,
			bedic, deb, rpm, gem, src, evolutionary
   \@version		version of the dictionary this is a release of
   \@URL		URL where this release can be downloaded
			(additional click may be required by SourceForge)
   \@size		size of this release in bytes
   \@date		when this release was made, eg. 2004-12-25

EOT
  exit
}


HELP_MESSAGE if $opt_h or (!$opt_d && !$opt_a && !$opt_r && !$opt_u && !$opt_R);

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
    if(system("cd $dirname/$entry && make $entry.index")!=0)
    {
      print STDERR "  ERROR: Failed to remake $entry.index: $?\n";
      exit 1
    }
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
    $headwords = "ERROR: Could not find $indexfile";
    exit 1
  }

  $d->setAttribute('headwords', $headwords);

  ###################################################################

  my $teifile = "$dirname/$entry/$entry.tei";

  unless(-r $teifile)
  {
    if(system("cd $dirname/$entry && make $teifile")!=0)
    {
      print STDERR "  ERROR: Failed to remake $teifile: $?\n";
      exit 1
    }
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

    # the --no-print-directory switch is required if extractdata is
    # run from inside a Makefile
    $edition = `cd $dirname/$entry;make --no-print-directory version`;

  ###################################################################

    $status = `cd $dirname/$entry;make --no-print-directory status`;
    $status = 'unknown' if(!$status);

  ###################################################################

    $sourceURL = `cd $dirname/$entry;make --no-print-directory sourceURL`;

  ###################################################################

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
    print STDERR "ERROR: $teifile not readable";
    exit 1
  }

  $d->setAttribute('edition', $edition);
  $d->setAttribute('date', $date);
  $d->setAttribute('status', $status);
  if(length $sourceURL) # only add source URL if present
  {
    $d->setAttribute('sourceURL', $sourceURL);
  }
  $d->setAttribute('maintainerName', $maintainerName);
  $d->setAttribute('maintainerEmail', $maintainerEmail);

  if($unsupported =~ /^\s*$/)
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
  my($dirname, $doc, $unavailablemode) = @_;
  my($dir, $entry);

  if(defined $unavailablemode) { printd "Removing unavailable dictionaries\n" }
  else { printd "Getting metadata of all dictionaries\n" };
  opendir $dir, $dirname;
  my @entries;
  while($entry = readdir($dir))
  {
    next unless -d $dirname.'/'.$entry;
    next if $entry !~ '^(\p{IsAlpha}{3})-(\p{IsAlpha}{3})$';
    push @entries, $entry
  }

  if(defined $unavailablemode)
  {
    my $ds = $doc->getElementsByTagName("dictionary");
    my $n = $ds->getLength;
    my $removed = 0;
    for(my $i = 0; $i < $n; ++$i)
    {
      my $node = $ds->item($i);
      my $name = $node->getAttributeNode("name")->getValue;
      next if grep /^$name$/, @entries;
      printd "Unavailable dictionary: $name\n";
      $node->setParentNode(undef);
      ++$removed;
    }
    printd "Removed $removed unavailable dictionaries\n";
    return
  }
  foreach $entry (sort @entries)
  { fdict_extract_metadata $dirname, $entry, $doc }
  printd "Got all metadata\n";
}

##################################################################

sub compare_version
{
  my($v1, $v2) = @_;
  my $isdate1 = $v1 =~ /^\d\d\d\d-\d\d-\d\d$/;
  my $isdate2 = $v2 =~ /^\d\d\d\d-\d\d-\d\d$/;
  return $v1 cmp $v2 if $isdate1 and $isdate2;# compare dates stringwise
  # dates sort after version numbers
  return  1 if $isdate1 and !$isdate2;
  return -1 if $isdate2 and !$isdate1;

  warn "Doomed comparison: $v1 <=> $v2"
    if $v1 !~ /^\d+([\.\-]\d+)*$/ or $v2 !~ /^\d+([\.\-]\d+)*$/;
  my @v1 = split /[\.\-]/, $v1;
  my @v2 = split /[\.\-]/, $v2;
  my $pieces = scalar(@v1);
  $pieces = scalar(@v2) if scalar(@v2) > $pieces;# max
  for(my $i=0; $i<$pieces; $i++)
  {
    my $result = ($v1[$i] || 0) <=> ($v2[$i] || 0);
    return $result unless $result == 0;
  }
  return 0;
}


# See
# http://sourceforge.net/apps/trac/sourceforge/wiki/Release%20files%20for%20download
# for ideas if it breaks again
sub update_database
{
  my($doc, $URL, $size, $release_date) = @_;

  unless($URL =~ qr"^http://sourceforge.net/projects/freedict/files/([^/]+/)?[^/]+/(freedict-)(\w{3}-\w{3})-([\d\.\-]+)\.([^/]+)/download")
  { printd "filename in URL '$URL' not recognized\n"; return }
  my $la1la2 = $3;
  my $version = $4;
  my $extension = $5;

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
    'src.zip' => 'src',
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

  my $v = $r->getAttribute('version');
  if(compare_version($v, $version) > 0)
  {
    printd "\trelease version $version is older than $v available in the database\n";
    # don't update the database
    return
  }

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

  unless($opt_s)
  {
    my $sfaccount = $ENV{'SFACCOUNT'} || 'micha137';
    my $rsynccmd = "rsync -avrltD" . ($opt_v ? 'v' : '') . "e ssh $sfaccount,freedict\@frs.sourceforge.net:/home/pfs/project/freedict $FREEDICTDIR/releases";
    printd "Rsyncing all released FreeDict files from SF using command: '$rsynccmd'...\n";
    system($rsynccmd)
  }
  my $findcmd = "find $FREEDICTDIR/releases -type f -print0";
  open my $fh, "$findcmd|" or die $!;
  my $found = 0;
  my @filenames = split '\0', <$fh>;
  close $fh;
  for my $f (@filenames)
  {
    unless($f =~ m"/frs/freedict/(([^/]+/)?[^/]+/freedict-(\w{3})-(\w{3})-([\d\.\-]+)\.([\w\.]+))$")
    {
      printd "Skipping not matching path: $f\n";
      next
    }

    $found++;

    # find $URL, $releasedate, $size
    my $path = $1;
    my @paths = split '/', $path;
    $path = join '/', map {uri_escape $_} @paths;
    my $URL = "http://sourceforge.net/projects/freedict/files/$path/download";

    my $sb = stat($f);
    my $release_date = strftime '%Y-%m-%d', gmtime($sb->mtime);

    my $size = $sb->size;

    #printd "$found:\t$path\n\trelease date: $release_date\n\tsize: $size\n";
    update_database $doc, $URL, $size, $release_date
  } # foreach
  warn "Found only $found dictionary releases.  Something is broken?"
    if $found < 419;
}

sub fdict_list_required_releases
{
  my $doc = shift;
  my $ds = $doc->getElementsByTagName("dictionary");
  my $n = $ds->getLength;
  my @rrs = ();
  my ($current, $outdated) = (0,0);
  my @platforms = ('dict-tbz2', 'src');
  my %platforms = ();
  for my $p (@platforms) { $platforms{$p} = 1 };
  # XXX exclude secondary platforms for now
  #push @platforms, 'dict-tgz';
  #push @platforms, 'bedic', 'zbedic', 'evolutionary', 'rpm';

  for(my $i = 0; $i < $n; ++$i)
  {
    my $d = $ds->item($i);
    my $headwords = $d->getAttributeNode("headwords")->getValue;
    next if $headwords < 100;
    my $name = $d->getAttributeNode("name")->getValue;
    my $edition = $d->getAttributeNode("edition")->getValue;
    my @unsupported = ();
    my $u = $d->getAttributeNode("unsupported");
    @unsupported = split /\s/, $u->getValue if defined $u;
    my %unsupported = ();
    foreach my $u (@unsupported) { $unsupported{$u} = 1 };
    #printd "$name: Version in XML: $edition\n";

    my %released_for_platform = ();
    for my $r ($d->getElementsByTagName('release'))
    {
      my $p = $r->getAttribute('platform');
      my $v = $r->getAttribute('version');
      #printd "  $p: $v\n";
      $released_for_platform{$p} = 1;
      if($v eq $edition)
      {
	# XXX Compare release date with last change of .tei file
	# (or better with last commit date in dictionary directory)
	# to identify changed dictionaries where the edition was not changed yet.
	$current++; next
      }
      next unless exists $platforms{$p};
      my @missing = ($name, $edition, $p, $v);
      push @rrs, [ @missing ];
    }
    # add
    for my $p (@platforms)
    {
      next if exists $released_for_platform{$p};
      next if exists $unsupported{$p};
      my @missing = ($name, $edition, $p, 'Never released');
      push @rrs, [ @missing ];
    }
  }

  my $rrcount = scalar(@rrs);# number of required releases
  if($rrcount>0)
  {
    print "\nDictionary | Edition in XML | Platform   | Last released version\n";
    print "-" x 64, "\n";
    for my $rr (@rrs) { printf "%10s | %14s | %10s | %21s\n", @$rr; }
  }
  printd "\n$rrcount outstanding releases\n";
  exit ($rrcount > 0) ? 1 : 0;
}
##################################################################

printd "Using FREEDICTDIR=$FREEDICTDIR\n";

if($opt_d && ($opt_a || $opt_u))
{ print STDERR "Only one of -d and -a may be given at the same time.\n"; exit }

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
fdict_extract_all_metadata $FREEDICTDIR, $doc, 'unavailable' if $opt_u;
fdict_extract_releases $doc if $opt_r;
fdict_list_required_releases $doc if $opt_R;

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
