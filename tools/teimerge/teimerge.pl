#!/usr/bin/perl -w


# V1.0 3/2002 Michael Bunk <kleinerwurm@gmx.net>
#  * sgml output only, not xml yet
#  * no sorting of any kind

# Vorgehen:
# zwei parser+handler werden benoetigt: mainfile/otherfiles
#  1. mainfile ausgeben (header + alle entries, aber nicht footer)
#  2. otherfilesparser auf file1 ansetzen
#  3. header des otherfile ueberlesen
#  4. entries ausgeben
#  5. otherfile schlieﬂen 
#  6. schritt 2 fuer file[2..N]...
#  7. footer ausgeben (</body></text></tei.2>)

#use XML::ESISParser;
use XML::Parser::PerlSAX;

use TEIMergeMainHandler;

my $mainfile = shift @ARGV;

if ($mainfile eq "") {
  warn "Usage: teimerge <mainfile> <file1> [<file2...>]\n";
  warn " To merge TEI encoded dict files. Output is on stdout.\n";
  warn " The header of the mainfile is taken, others discarded.\n";
  die;
  }
     
die "Can't find file \"$mainfile\"" unless -f $mainfile;

#push (@additional_args, IsSGML => 1);

# an dieser stelle sollten die IMPLIED-Attribute auzuschalten sein
# ? ist das mˆglich mit nsgmls?

#$XML::ESISParser::NSGMLS_FLAGS_sgml = $XML::ESISParser::NSGMLS_FLAGS_sgml." -D/usr/share/sgml -cCATALOG.tei-3 ";

my $mergemainhandler = TEIMergeMainHandler->new;
$mergemainhandler->set_otherfilenames(\@ARGV);

#XML::Parser::PerlSAX
#XML::ESISParser

XML::Parser::PerlSAX->new->parse(Source => { SystemId => $mainfile },
                            Handler => $mergemainhandler, @additional_args);

# EOF
