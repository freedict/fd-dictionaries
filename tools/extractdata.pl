#!/usr/bin/perl -w

# $Revision: 1.7 $

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
#   @headwords		`wc -l formatted-db.index`
#   @date		last change of TEI file
#   @status		contents of status note in TEI header, if available
#   @sourceURL		URL in sourceDesc in TEI header (upstream project)
#   @notes		unused
#   @HEADorRelease	in CVS, unused
#   @maintainerName     Maintainer name (without email) from
#                       /TEI.2/fileDesc/titleStmt/respStmt/name[../resp='Maintainer']
#   @maintainerEmail    Email address of Maintainer from same place
#
# element: release
#  children: none
#  attributes:
#   @platform		allowed values: dict-tgz, dict-tbz2, mobi,
#			bedic, deb, rpm, gem, src
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

our($opt_v, $opt_h, $opt_a, $opt_d, $opt_f, $opt_r, $opt_l);
getopts('vhald:fr:');

sub printd
{
  return if !$opt_v;
  print @_;
}

my $FREEDICTDIR = $ENV{'FREEDICTDIR'} || "$FindBin::Bin/..";
printd "Using FREEDICTDIR=$FREEDICTDIR\n";

my $dbfile = "$FREEDICTDIR/freedict-database.xml";

if($opt_h)
{
  print <<EOT;
$0 [options] (-a | -d <la1-la2>) [-r [<file>]]
  
Gather metadata from TEI files in FreeDict file tree
and save it in the XML file $dbfile.

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
-r	extract released packages from a SourceForge file release
	HTML page. Uses STDIN if '-' given as filename.
	For FreeDict download:
	http://sourceforge.net/project/showfiles.php?group_id=1419

EOT
  exit;
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
    return $node if($name->getValue eq $entry);
  }
  return undef;
}

sub fdict_extract_metadata
{
  my($dirname, $entry, $doc) = @_;
  printd " Getting metadata from dictionary in '$dirname/$entry'\n";

  my $docel = $doc->getDocumentElement();

  # find old dictionary element -> update
  my $d = contains_dictionary($doc,  $entry);

  # else create new dictionary element
  if(!defined $d)
  {
    printd "  Dictionary not found in database. Inserting it.\n";
    $docel->appendChild( $doc->createTextNode("  ") ); 
    $d = $doc->createElement('dictionary');   
    $docel->appendChild($d); 
    $docel->appendChild( $doc->createTextNode("\n") ); 
    $d->setAttribute('name', $entry);
  }

  ###################################################################

  my($headwords, $edition, $date, $status, $sourceURL, $maintainerName,
    $maintainerEmail);

  my $indexfile = "$dirname/$entry/$entry.index";
  
  if(!-r $indexfile)
  {
    system "cd $dirname/$entry; make $entry.index";
  }
  
  if(-r $indexfile)
  {
    my @a = split ' ', `wc -l "$indexfile"`;
    $headwords = (shift @a) - 8;# substract /00-?database.*/ entries
    printd "  $headwords headwords\n";
  }
  else
  {
    print STDERR "  Where is file '$indexfile'?\n";
    $headwords = "ERROR: Could not find $indexfile";
  }

  $d->setAttribute('headwords', $headwords);

  ###################################################################

  my $teifile = "$dirname/$entry/$entry.tei";
  
  if(-r $teifile)
  {

    my $s = stat $teifile;
    my @ss = localtime($s->mtime);
    $date = sprintf("%4d-%02d-%02d", $ss[5]+1900, $ss[4]+1, $ss[3]);

    if($date le $d->getAttribute('date') and !$opt_f)
    {
      printd "  Skipping time consuming extraction steps for update (try -f).\n";
      return;
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
    my $maintainer = `cd $dirname/$entry;make --no-print-directory maintainer`;
    if($maintainer =~ /^([^<]+)\s<(.*)>$/)
    {
      $maintainerName = $1;
      $maintainerEmail = $2;
      #printd "  Extracted maintainer: name='$maintainerName' email='$maintainerEmail'\n";
    }
    else
    {
      printd "  Could not extract maintainer name or email from:\n" .
        "\t$maintainer\n";
    }

  ###################################################################
  }
  else
  {
    $edition = "ERROR: $teifile not readable";
    $date = $edition;
    $status = $edition;
    $sourceURL = $edition;
  }

  $d->setAttribute('edition', $edition);
  $d->setAttribute('date', $date);
  $d->setAttribute('status', $status);
  $d->setAttribute('sourceURL', $sourceURL);
  $d->setAttribute('maintainerName', $maintainerName);
  $d->setAttribute('maintainerEmail', $maintainerEmail);
}

sub fdict_extract_all_metadata
{
  my($dirname, $doc) = @_;
  my($dir, $entry);

  printd "Getting metadata of all databases\n";
  opendir $dir, $dirname;
  while($entry = readdir($dir))
  {
    next if(! -d $dirname.'/'.$entry);
    next if($entry !~ '^(\p{IsAlpha}{3})-(\p{IsAlpha}{3})$');

    fdict_extract_metadata($dirname, $entry, $doc);
  }
}

##################################################################

sub fdict_extract_releases
{
  my $doc = shift;
  my $docel = $doc->getDocumentElement();

  # one package looks (looked?!) like:
  #
  #<tr bgcolor="#FFFFFF">
  #<td colspan="3">
  #<h3>Afrikaans - English [<a href="showfiles.php?group_id=1419&amp;package_id=2664">show only this package</a>]</h3>
  #</td>
  #<td colspan="4">&nbsp;</td>
  #</tr>
  #<tr bgcolor="#FFFFFF">
  #<td colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<b><a href="shownotes.php?release_id=65175"><IMG src="http://images.sourceforge.net/images/ic/manual16c.png" alt="Release Notes" border="0" width="15" height="15"> 0.0.1</a></b> [<a href="showfiles.php?group_id=1419&amp;package_id=2664&amp;release_id=65175">show only this release</a>]</td>
  #<td colspan="4" align="middle"><b>2001-12-11 11:03</b></td></tr>
  #<tr bgcolor="#FFFFFF">
  #<td colspan="3"><dd><a href="http://prdownloads.sourceforge.net/freedict/afr-eng.tar.gz?download">afr-eng.tar.gz</a></td>
  #<td align="right">99947 </td>
  #<td align="right">119 </td>
  #<td>Any</td>
  #<td>Source .gz</td>
  #</tr>

  my $file = *STDIN;
  if($opt_r ne '-')
  {
    if(!open($file,'<', $opt_r))
    {
      print "Cannot read file '$opt_r'\n";
      exit;
    };
  };
  my @lines = <$file>;
  chomp foreach(@lines);
  my $line = join '', @lines;

  # tackle it with regexps
  my($packages, $filename, $size, $downloads, $URL);

  # for all packages
  while($line =~ /(show only this package)/cg)
  {
    my $myredo;
    $packages++;# counts packages
    warn "   cannot find release number"
      if($line !~ /height="15"> ([\d\.]+)<\/a>/cg);
    my $release_version = $1;
    warn "   cannot find release date"
      if($line !~ /middle"><b>([\d\- :]+)<\/b>/cg);
    my $release_date = $1;
    printd "\n   package $packages: release_number: '$release_version' " .
      "release_date: '$release_date'\n";

    # for all files of a release
    while($line =~ /<a href="(http:\/\/prdownloads[^\?]*\?download)">Download ([^<]*)<\/a><\/td>|(show only this package)/cg)
    {
      #print "1: $1 2: $2 3:$3\n";
      if($3 and $3 eq "show only this package") { $myredo=1;last; }

      #warn "cannot find filename" if($line !~ /\?download">([^<]*)<\/a><\/td>/cg);
      $filename = $2;
      $URL = $1;

      $size = -1;
      warn "   cannot find size"
        if($line !~ /<td align="right">(\d*) <\/td>/cg);
      $size = $1;
      
      $downloads = -1;
      warn "   cannot find downloads"
        if($line !~ /<td align="right"><a href="[^"]+">(\d*)<\/a><\/td>/cg);
      $downloads = $1;
 
      printd "\tfilename: $filename size: $size\n";

      ################################################################
      
      # find old dictionary element -> update
      my $name;
      if($filename =~ /^freedict-/) { $name = substr($filename, 9,7) }
      else { $name = substr($filename,0,7); }

      if($name !~ /^\w{3}-\w{3}$/)
      {
	printd "Invalid dictionary name '$name'. Skipping release.\n";
	next;
      }
      
      my $d = contains_dictionary($doc,  $name);
      if(!$d)
      {
        print "  Dictionary '$name' not in our database. Skipping release.\n";
        next;
      }

      # find platform by extracting it from filename
      # allowed values: dict-tgz, dict-tbz2, mobi, bedic, deb, rpm, gem, src
      my($platform, $fileversion, $sfn, $ssfn);

      # cut prefix "freedict-" if available
      if($filename =~ /^freedict-/) { $sfn = substr($filename, 9); }
      else { $sfn = $filename; }
      
      # cut language combination
      $ssfn = substr($sfn, 7);
     
      # cut a minus sign. if available 
      if($ssfn =~ /^-/) { $ssfn = substr($ssfn, 1); }

      if($ssfn =~ /^\.tar\.gz/)
      { $platform = 'dict-tgz'; } 
      
      elsif($ssfn =~ /^\d{1,3}\.\d{1,3}(\.\d{1,3})?\.tar\.gz/)
      { $platform = 'dict-tgz'; } 
      
      elsif($ssfn =~ /^\.tar\.bz2/)
      { $platform = 'dict-tbz2'; }
      
      elsif($ssfn =~ /^\d{1,3}\.\d{1,3}(\.\d{1,3})?\.tar\.bz2/)
      { $platform = 'dict-tbz2'; } 

      elsif($ssfn =~ /\.dic\.dz/)
      # eg. freedict-kha-deu-0.0.1.dic.dz
      { $platform = 'bedic'; } 
      
      elsif($ssfn =~ /\.ipk/)
      # eg. freedict-kha-deu-0.0.1.ipk
      { $platform = 'zbedic'; }
      
      elsif($ssfn =~ /\d{1,3}\.\d{1,3}(\.\d{1,3})?\.src(\.tar)?\.bz2/)
      { $platform = 'src'; }
      
      elsif($ssfn =~ /^\d{1,3}\.\d{1,3}(\.\d{1,3})?-(\w+)\.noarch\.rpm/)
      # eg. freedict-kha-deu-0.0.1-1.noarch.rpm
      { $platform = 'rpm'; }

      elsif($ssfn =~ /^\d{1,3}\.\d{1,3}(\.\d{1,3})?-(\w+)\.[\w\.]+/)
      { $platform = $2; }
      
      else
      {
	print "Cannot make sense of filename '$filename'. Skip.\n";
	next;
      }
      

      # find old release element
      my $r;
      for my $kid ($d->getElementsByTagName('release'))
      {
	if($kid->getAttribute('platform') eq $platform)
	{
	  $r = $kid; last;# found
	}
      }
      
      # create new release element if no previous found
      if(!$r)
      {
        print "+\tRelease not found in database. Inserting it.\n";
        $d->appendChild( $doc->createTextNode("\n") ) if( ! @{ ($d->getChildNodes) } );
        $d->appendChild( $doc->createTextNode("    ") ); 
        $r = $doc->createElement('release');   
        $d->appendChild($r); 
        $d->appendChild( $doc->createTextNode("\n") ); 
        $r->setAttribute('platform', $platform);
      }

      # if $r refers to a older release than available in the database,
      # don't update the database
#      $release_version = "0.0.1" if($release_version eq "");
#      next if($r->getAttribute('version') ge $release_version);
      
      printd "+\tUpdating release for $platform platform. Old: '" .
        $r->getAttribute('version') . "' New: '$release_version'\n";
      $r->setAttribute('version', $release_version);
      $r->setAttribute('URL', $URL);
      $r->setAttribute('size', $size);
      $r->setAttribute('date', substr($release_date,0,10));
      
    } # while
    if($myredo) { $myredo=0;redo; printd "redoing..."; }
  } # while
}
##################################################################

if($opt_d && $opt_a)
{
  print STDERR "Only one of -d and -a may be given at the same time.\n";
  exit;
}

if(!$opt_d && !$opt_a && !$opt_r)
{
  print STDERR "One of -h, -d, -a or -r must be given.\n";
  exit;
}

my $parser = new XML::DOM::Parser;

my $doc;
if(-s $dbfile)
{
  $doc = $parser->parsefile ($dbfile);
  printd "Successfully read $dbfile.\n";
  my $nodes = $doc->getElementsByTagName("dictionary");
  my $n = $nodes->getLength;
  printd "$n dictionary/-ies in my database.\n";
}
else
{
  printd "Creating new database.\n";
  $doc = new XML::DOM::Document;
  $doc->appendChild( $doc->createElement('FreeDictDatabase') );   
}

fdict_extract_metadata($FREEDICTDIR, $opt_d, $doc) if $opt_d;
fdict_extract_all_metadata($FREEDICTDIR, $doc) if $opt_a;
fdict_extract_releases($doc) if $opt_r;

if($opt_l)
{
  printd "Leaving $dbfile untouched.\n";
  exit(0);
}

# Write out freedict-database.xml
`cp $dbfile $dbfile.bak` if(-s $dbfile);
printd "Writing $dbfile\n";
$doc->printToFile ($dbfile);

