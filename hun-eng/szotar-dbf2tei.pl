#!/usr/bin/perl -w

print `dbview -ieo SZOTAR.DBF`;

`cp hun-eng.tei.header hun-eng.tei`;
open(TEI, ">>hun-eng.tei") || die "Can't write to hun-eng.tei: $!";

$cmd = 'dbview SZOTAR.DBF | iconv -f cp437 -t latin1';
open(DB, "$cmd|") || die "Can't do '$cmd': $!";

# the first two entries look like
# (i found out the encoding after fetching the exmaple only):
#Angol      : to be taken aback                                 
#Magyar     : meg van lepve                                     
#
#Angol      : to abase                                          
#Magyar     : megal z                                           
#

$| = 1;# no STDOUT buffering
$n = 0;
$eng = '';
$hun = '';
$state = 0;
%dict = ();

while(<DB>)
{
  if($state==0)
  {
    if(/^Angol      : (.*)$/)
    {
      $eng = $1;
      $state = 1;
      next;
    }
    die "$.: Couldn't recognize englisch headword in '$_'";
  }
  
  if($state==1)
  {
    if(/^Magyar     : (.*)$/)
    {
      $hun = $1;
      $state = 2;
      next;
    }
    die "$.: Couldn't recognize hungarian translation in '$_'";
  }

  if($state==2)
  {
    if(/^$/)
    {
      $n++;
      print "\rLine $., $n records" if($n % 1000 == 0);
      
      # trim trailing spaces      
      $eng =~ s/\s*$//;
      $hun =~ s/\s*$//;

      # XXX escape default entities: currently not required,
      # `make validation' succeeds anyway

      # save record in a hash, grouping headwords together
      if(exists $dict{$hun})
      {
        $entry = $dict{$hun};
      }
      else
      {
        # use hashes to save the english translations,
	# so we can easily check for double records
        $entry = {};
      }
      
      if($entry->{$eng})
      {
        print "\nDouble definition: hun='$hun' eng='$eng'\n";
      }
      else
      {
        # save translation
        $entry->{$eng} = 1;
        $dict{$hun} = $entry;
      }

      # get ready for next entry
      $state = 0;
      $eng = '';
      $hun = '';
      next;
    }
    die "$.: Couldn't recognize empty line between entries in '$_'";
  }

  die "Unknown state: $state";
} # while

print "\nWriting entries to TEI file...\n";
$entries = 0;
foreach(sort keys %dict)
{
  $entries++;
  print "\r$entries entries" if($entries % 1000 == 0);

  # output entry to TEI file
  print TEI "<entry>\n";
  print TEI "  <form><orth>$_</orth></form>\n";

  $entry = $dict{$_};
  #print scalar %$entry , " ";
  foreach $t (keys %$entry)
  {
    # Making a different sense for each homograph
    # is a compromise we have to do, as we do not have
    # information on part of speech or translation equivalents.
    # Luckily, only 1590 + 30 entries are affected:
    #
    # # of headwords | # of definitions found
    # ---------------------------------------
    #              0 |     0
    #         138323 |     1
    #           1590 |     2
    #             30 |     3
			       
    print TEI "  <sense><trans><tr>$t</tr></trans></sense>\n";
  }
  
  print TEI "</entry>\n";
}

print TEI "</body></text></TEI.2>\n";

print "\nFinished.\nLines: $. Records: $n Entries: $entries\n\n";
