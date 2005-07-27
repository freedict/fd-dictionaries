#!/usr/bin/perl
# 4/2002 Michael Bunk <kleinerwurm@gmx.net>
# This code generates sgml tei by formatting a tab delimited text file.
# It is specific for khasi language, but may be a starting point for you.

# features:
#  + Khasi-Artikel u/ka, Deutsche Artikel der/die/das
#  + Pluralangaben im Dt. ("--" == gleich Sg./Pl., wird übernommen)
#    (Kodierung in TEI ok?)
#  + Zusatzangabe Wortart -> half-hardcoded

# wishlist:
#  - recognize/encode things:
#   - uebersetzungalternativen
#   - Kommentare in runden Klammern ()
#  - what about unicode? im falle khasi-deutsch hinterher möglich

# Parameter:

# alle Worte der Eingangsdatei sind von dieser Wortart
# ("v" = Verben, "n" - Substantive, "" gemischte Wortliste
$PART_OF_SPEECH = "n";

# Übersetzungsrichtung der Wortliste ("deu" oder "kha")
$FIRST_LANG = "kha";

##########################################################

sub erkenne_artikel_deu {
     # Deutsche Artikel erkennen
     # Parameter: $1 - Referenz auf String "<Deutsches Wort>, <Artikel>"
     #		  $2 - Referenz auf TEI-Ausgabestring, ist "", wenn kein
     #		       Artikel erkannt wurde
     my $wortref = shift;
     my $artikelerkanntref = shift;  
     
     if(${$wortref} =~ /, *(der|die|das) */) {
       if (${$wortref} =~ /der */) { ${$artikelerkanntref}="  <gen>m</gen>\n";}
       elsif (${$wortref} =~ /die */) { ${$artikelerkanntref}="  <gen>f</gen>\n";}
       elsif (${$wortref} =~ /das */) { ${$artikelerkanntref}="  <gen>n</gen>\n";}
       ${$wortref} =~ s/, *(der|die|das) *//;
       }
     else {${$artikelerkanntref}="";}
     }

sub erkenne_artikel_kha {
     # Khasi-Artikel erkennen
     # Parameter: $1 - Referenz auf String "<Khasiwort>, <Artikel>"
     #		  $2 - Referenz auf TEI-Ausgabestring, ist "", wenn kein
     #		       Artikel erkannt wurde
     my $wortref = shift;
     my $artikelerkanntref = shift;  
     
     if(${$wortref} =~ /, *(u|ka) */) {
       if (${$wortref} =~ /u */) { ${$artikelerkanntref}="  <gen>m</gen>\n";}
       elsif (${$wortref} =~ /ka */) { ${$artikelerkanntref}="  <gen>f</gen>\n";}
       ${$wortref} =~ s/, *(u|ka) *//;
       }
     else {${$artikelerkanntref}="";}
     }

# Main
$tabfile = shift @ARGV;

if ($tabfile eq "") {
 print stderr "Usage: tab2tei <tabfile>\n";
 print stderr " To convert tab delimited wordlists to TEI format. Output\n";
 print stderr " is on stdout.\n";
 die;
 }

die "Can't find file \"$tabfile\"" unless -f $tabfile;

open(TABHANDLE, "<".$tabfile);

while (<TABHANDLE>) {
 push(@zeilen,$_);
 }

print "<!DOCTYPE TEI\.2 PUBLIC \"\-//TEI P3//DTD Main Document Type//EN\"\n";
print "\"/usr/share/sgml/tei-3/tei2\.dtd\" \[\n";
print " <!ENTITY % TEI\.dictionaries 'INCLUDE' > \]>\n";
print "<\?xml version='1\.0' encoding='ISO-8859-1'>\n";
print "<tei\.2>\n<teiheader>\n<filedesc>\n<titlestmt><title>".$hdfile."</title>\n";
print "  <respStmt><resp>converted with</resp><name>tab2tei\.pl</name></respStmt>\n";
print "  </titleStmt>\n<publicationStmt><p>freedict\.de\n";

# Statement aus Quelldatei uebernehmen (Zeilen vor der ersten mit TAB)
for(@zeilen) {
 if (/[\t]/) {last;}# Schleife abbrechen
 print $_;
 }

print "  </p></publicationStmt>\n<sourceDesc><p>".$tabfile."</p></sourceDesc></fileDesc></teiHeader>\n";

print "<text><body>\n";

for(@zeilen) {
     chomp;# \n entf.
     s/\r\Z//;# evtl. CR entfernen (DOS-Datei)
     
     if(/\t/) {
       @felder = split(/\t/,$_,2);

# deu/kha-spezifisch!

     # "<Singular>/<Plural>" decodieren
     @sgplur = split(/\//,$felder[0]);
     if($sgplur[1] ne "") {
       $felder[0] = $sgplur[0];
       }

     if ($FIRST_LANG eq "deu") {
       erkenne_artikel_deu(\$felder[0],\$artikelerkannt);  
       erkenne_artikel_kha(\$felder[1],\$artikeltrerkannt);
       }
     else {
       erkenne_artikel_deu(\$felder[1],\$artikeltrerkannt);  
       erkenne_artikel_kha(\$felder[0],\$artikelerkannt);
       }

       # remove leading/trailing whitespace
       $felder[0] =~ s/\A\s*//;
       $felder[0] =~ s/\Z\s*//;
       $felder[1] =~ s/\A\s*//;
       $felder[1] =~ s/\Z\s*//;
       $sgplur[1] =~ s/\A\s*//;
       $sgplur[1] =~ s/\Z\s*//;

       print "<entry>\n <form><orth>".$felder[0]."</orth>\n";
       print "  </form>\n";
       print " <gramgrp>\n";
       if ($PART_OF_SPEECH ne "") {
         print "  <pos>$PART_OF_SPEECH</pos>\n";
	 }
       print    $artikelerkannt;
       print "  </gramgrp>\n";
       
       # give german plural form
       if($sgplur[1] ne "") {
        print " <form type=infl>\n";
        print "  <orth>",$sgplur[1],"</orth>\n";
        print "  </form>\n";
	}
	     
       print " <trans>\n";
       print "  <tr>",$felder[1],"</tr>\n";
       print    $artikeltrerkannt;
       print "  </trans>\n </entry>\n"; 
       next;
       };
     print stderr "Zeile ohne TAB: ".$_."\n";
     }
 
print "</body></text></tei.2>\n";

close(TABHANDLE);
