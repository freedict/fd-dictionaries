# SAX handler module for tei2dict converter

# V1.3 5/2003 Mcihael Bunk
#      See tei2dict_xml.pl for changes
# V1.1 4/2002 Michael Bunk <kleinerwurm at gmx.net>
#      - switched from SGML to XML (TEI P4)
#      - 00-database-info / ~-short / ~-url optionally taken from tei header
# V1.0 Copyright (C) 2000 Horst Eyermann <horst@freedict.de>

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software 
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

# thinking about event & calling order of the Dict subs (there is no other doc?):
# for V1.0:
# 1. set_file_name()    -> open_dict()
# 2. <orth>             -> set_headword()
# 3. characters()       -> add_text()
# 4. end_tag	        -> write_text()
# 5. </orth>            -> end_headword()
# 6. several start_tags -> ( write_direct() | add_text() )
# 7. several end_tags   -> write_text()
# 8. </entry>	        -> write_newline()
# 9. continue with 2. for all other entrys
# 10. closing the filehandles not needed

# for encoding tei header we need some extra:
# V1.1.:
# 1. same
# 2. <teiHeader>          -> set_headword(); write_text("00-database-info"); end_headword();
# 3. header start_tags    -> add_text(" Info: ");
# 4. tag content (if any) -> add_text($data); and occasionally save to some $var
# 5. header end_tags      -> add_text("\n");
# 6. </teiHeader>	  -> write_text();
#                            set_headword(); write_text("00-database-short"); end_headword();
#			     write_direct($database-short);
#			     set_headword(); write_text("00-database-url"); end_headword();
#			     write_direct($database-url);
# 7. go on with entrys like in V1.0 (go on at 2. there)

# basically we have 3 types of elements:
# 1. they consist only of other elements
# 2. they consist of #PCDATA mixed with some
#    markup (in html it would be floating text markup like <i>, <b>, ...
# 3. they consist only of #PCDATA (somewhat basic elements)

# every kind has a similar approach to handle its events
# but this is "ignored" here (i found out only afterwards)

# elements to process in teiHeader:
#  fileDesc (contains only elements, type 1)
#   titleStmt (contains only elements)
#    title -> save in $database_short -> 00-database-short
#    respStmt (contains only elements)
#     resp (person function)
#     name (only characters, type 3)
#   editionStmt (contains only elements)
#    edition
#   extent # dont process, dicdt gives a more precise number via serverinfo
#   publicationStmt (contains only elements)
#    publisher
#    date
#    availability
#   notesStmt (contains only elements)
#    note
#  sourceDesc
#   p -> save in $database_url -> ...
#  revisionDesc (contains only elements)
#   change (similar to a list item, contains only elements)
#    date
#    respStmt
#     resp (see titleStmt)
#     name (also)
#    item
  

package TEIHandler_xml;

use strict;
use Dict;
#use POSIX qw(strftime);
    
our ($header, $preLastStartTag, $lastStartTag,
     $database_short, $database_url, @higherElements,
     $file_name, $HTML_enabled, $crossrefs_enabled, $skip_header,
     $noteCharacters);

# i copied _escape() from XML::Handler::CanonXMLWriter
# for escaping special chars in HTML/XML/SGML
my %char_entities = (
    "\x09" => '&#9;',
    "\x0a" => '&#10;',
    "\x0d" => '&#13;',
    '&' => '&amp;',
    '<' => '&lt;',
    '>' => '&gt;',
    '"' => '&quot;',
    );

sub _escape {
    my $string = shift;
     
    if ($HTML_enabled) {
     $string =~ s/([\x09\x0a\x0d&<>\"])/$char_entities{$1}/ge }
    return $string;
    }

sub new {
    my ($type) = shift;
    $header = 0;
    return bless {}, $type;
}

sub set_options {
    my ($self,$filename,$aHTML_enabled,$askip_header,
     $acrossrefs_enabled,$aGenerate00DatabaseUtf8,$aLocale) = @_;
    $file_name = $filename;
    $file_name =~ s/^(\w*\/)+//g;         
    $file_name =~ s/(\S*)\.\w*/$1/;
    $HTML_enabled = $aHTML_enabled;
    $skip_header=$askip_header;
    $crossrefs_enabled=$acrossrefs_enabled;
    Dict->open_dict($file_name,$aLocale);
    
    if($aGenerate00DatabaseUtf8) {
	print STDERR "Generating 00-database-utf8\n";
    	Dict::set_headword(); Dict::add_text("00-database-utf8");
	Dict::write_text(); Dict::end_headword();
	
	# might not be needed at all, but we give a hint
        Dict::write_direct("\n  ");
	Dict::write_direct("This dictionary is UTF-8 encoded. If you use dictd, ".
		           "make sure to start it with the appropriate --locale option.");
        Dict::write_newline();
	}
}

sub start_element {
    my ($self, $element) = @_;
    my $part = $element->{Name};

    $preLastStartTag = $lastStartTag; $lastStartTag = $part;
    push @higherElements,$part;

    # for multiple orths at beginning of <form>
    if (($Dict::head) && ($part ne "orth")) { Dict::end_headword() };
    
    # see what tag we have (& remember XML is case sensitive!)
    # most frequent tags on top
    if   (($part eq "entry") ||
          ($part eq "sense") ||
          ($part eq "form")) {
        return
	}
	
    elsif ($part eq "orth") {
        if ($preLastStartTag eq "form") {Dict::set_headword()} }
	
    elsif ($part eq "pron") {
	Dict::write_direct(" [") }

    elsif ($part eq "gramGrp") {
        Dict::write_direct($HTML_enabled ? " &lt;" : " <") }

    elsif ($part eq "trans") {
        Dict::write_direct("\n  ") }
    
    elsif ($part eq "def") {
        Dict::write_direct("\n  ".H("<i>")) }
	
    elsif ($part eq "tr") {
        Dict::write_direct(", ") if ($preLastStartTag eq "tr") }

    elsif ($part eq "pos") {
        }

    elsif (($part eq "num") || ($part eq "gen")) {
        Dict::add_text(", ") }

    elsif ($part eq "usg") {
        Dict::add_text(" (") }
	
    elsif (($part eq "note") && (!$header)) {
        $noteCharacters = 0;
	Dict::add_text(" (") }

    elsif ($part eq "ref") {
        Dict::add_text(" {") if $crossrefs_enabled }

    elsif (($part eq "TEI.2") ||
	   ($part eq "body") ||
           ($part eq "p") ||
	   ($part eq "xr") ||
	   ($part eq "text")
	   ) {
        # NOP, just to avoid "unimplemented" warning
	}
	
    elsif ($part eq "teiHeader") {
        $header = 1;
	if (!$skip_header) {
	  Dict::set_headword();
	  $Dict::text="00-database-info";
	  Dict::write_text();
	  Dict::end_headword();
	  Dict::add_text(" ");
	  Dict::write_text();
          Dict::write_newline();
	  }
	}
    
    elsif ($header) {
      return if ($skip_header);
      
      if ($part eq "edition") {
	 Dict::add_text(" Edition: ") }

      elsif ($part eq "publisher") {
	  Dict::add_text(" Published by: ") }

      elsif ($part eq "availability") {
          Dict::write_text(); Dict::write_newline();
	  Dict::write_direct("\n Availability: ") }

      elsif (($part eq "note") && ($higherElements[-2] eq "notesStmt")) {
          $noteCharacters = 0;
          Dict::add_text($HTML_enabled ? "<li>" : "\n     * ") }
    
      elsif ($part eq "notesStmt") {
	  Dict::add_text(" Notes: ".H("\n<ul>"));
	  Dict::write_text();
          Dict::write_newline();
	  }

      elsif ($part eq "revisionDesc") {
	  Dict::add_text(" Changelog:".H("\n<ul>"));
	  Dict::write_text();
	
	  # add myself as
	  # <change>
	  #  <date>now</date>
	  #  <respStmt><name>tei2dict_xml.pl</name></respStmt>
	  #  <item>converted TEI database into .dict format</item>
	  # </change>
	  start_element(Element => { Name => "change"});

           start_element(Element => { Name => "date"});
	    my $now_string = gmtime();
	    characters(Element => { Data => $now_string});
 	   end_element(Element => { Name => "date"});

	   start_element(Element => { Name => "respStmt"});
            start_element(Element => { Name => "name"});
             characters(Element => { Data => "tei2dict_xml.pl"});
            end_element(Element => { Name => "name"});
	   end_element(Element => { Name => "respStmt"});

	   start_element(Element => { Name => "item"});
	    characters(Element => { Data => "converted TEI database into .dict format"});
	   end_element(Element => { Name => "item"});
	   
	  end_element(Element => { Name => "change"});
	  }

      elsif ($part eq "change") {
          Dict::write_newline();
	  Dict::write_direct($HTML_enabled ? "<li>" : "     * ");
	  $Dict::fill2 = "       "; }

      elsif ($part eq "date") {
	  Dict::add_text(", ") if ($preLastStartTag eq "publisher") }

      elsif (($part eq "item") && ($higherElements[-2] eq "change")) {
          Dict::add_text(":") }

      elsif ((($part eq "name") ||
	      ($part eq "resp") )
	   && ($preLastStartTag eq "respStmt")) {
	  Dict::add_text(" ") }

      elsif (($part eq "fileDesc") ||
	     ($part eq "fileStmt") ||
	     ($part eq "titleStmt") ||
	     ($part eq "title") ||
	     ($part eq "editionStmt") ||
	     ($part eq "extent") ||
	     ($part eq "publicationStmt") ||
	     ($part eq "sourceDesc") ||
	     ($part eq "respStmt") ||
	     ($part eq "name") ||
             ($part eq "p")) { return }
      }	# ^header
   
    else { print STDERR "unimplemented starttag: $part\n" }
}

sub H {
    # takes one arg and returns it, if HTML output is enabled
    # should depend on command line switch
    ($HTML_enabled) ? shift : "";
    }

sub H2 {
    # calls _escape if $HTML_enabled, otherwise just returns arg
    ($HTML_enabled) ? _escape(shift) : shift;
    }
    
sub characters {
    my ($self, $element) = @_;
    my $data = $element->{Data};
    
    # FIXME: maybe with other parser than ESISParser?
    # my guess: sometimes our loved ESISParser calls this handler
    # while it shouldn't: to notify us of a line break and white
    # space. there are handlers end_record() and white_space() for
    # this. anyway: since we don't have <pre>-element where newlines
    # are important inside, we just replace all \n by ' '
    # then all multiple white space by single ' '
    # then remove all ' ' at beginning or end
    # and skip everything if we get empty $data 
    
    
    $data =~ s/\n/ /;
    $data =~ s/\s+/ /;
    $data =~ s/\A\s//;
    $data =~ s/\s\Z//;

    if ($data eq "") {
       # better not warn, because there are so many newlines
       #warn "<$lastStartTag>\ndata : '$data'\ndata2: '$data2'\n\n";
       return;
       }

    if ($header == 1) {
        return if ($skip_header);
	if    (($preLastStartTag eq "titleStmt") &&
	       ($lastStartTag    eq "title")) { $database_short = $data }
	elsif  ($lastStartTag    eq "name") { 
	  Dict::add_text(" ".H("<b>").H2($data).H("<\/b>"));
	  Dict::write_text();
          if ($higherElements[-3] eq "titleStmt") {
	    Dict::write_newline(); }
	   }
	elsif (($preLastStartTag eq "sourceDesc") &&
	       ($lastStartTag    eq "p")) { $database_url=$data }
	elsif ($lastStartTag    eq "item") { Dict::add_text(" ".H2($data)) }
	elsif (($preLastStartTag eq "availability") &&
	       ($lastStartTag    eq "p")) { Dict::add_text(H2($data)) }
	elsif  ($lastStartTag    eq "note") {
	       # damn parser calls characters() multiple times if #PCDATA
	       # extends for more than one line!
	       Dict::add_text( ($noteCharacters ? " " : "") . H2($data));
	       $noteCharacters = 1;# workaround for multiple calls
	       # because then data lacks leading & trainling spaces...

	       #warn "add: '$data'\n";
	       # even though the pod says different things: not only
	       # tabs are allowed in fill() parameters
	       #warn "fill2: '".$Dict::fill2."'";
               }
	elsif (($preLastStartTag eq "titleStmt") &&
	       ($lastStartTag    eq "resp")) {
	       Dict::add_text(H2($data));
	       Dict::write_text();
               Dict::write_newline() }	  
	elsif (($lastStartTag    eq "edition") ||
	       ($lastStartTag    eq "resp") ||
	       ($lastStartTag    eq "publisher") ||
	       ($lastStartTag    eq "date")
	       ) { Dict::add_text(H2($data)) }
    }
    else {
	if (($lastStartTag eq "orth")) {
	    if (($preLastStartTag eq "form") ||
	        ($preLastStartTag eq "orth")) {
	      #warn "headwords add_text: '$data'\n";
	      Dict::add_text(H2($data)) }
	    else {
	      print STDERR "multiple <orth>-s only at beginning of <form> supported. Skipping the others!\n" }
	    }
	elsif ($lastStartTag eq "def") {
	    Dict::add_text(H2($data)." ");
	    }
	else {
	    Dict::add_text(H2($data)) }
	}
}


sub end_element {
    my ($self, $element) = @_;
    my $part  = $element->{Name};

    pop @higherElements;
    
    Dict::write_text();

    if ((defined $higherElements[-1]) && ($higherElements[-1] eq "sense")) {
     Dict::add_text("\n") }
    
    if   (($part eq "tr") || ($part eq "trans")) {
        # NOP
	}
    
    elsif ($part eq "orth") {
        # Dict::end_headword() has to be called later, because we don't know now
	# if there is another orth coming (multiple headwords for one entry)
	}	    

    elsif ($part eq "entry") {
        Dict::write_newline() }

    elsif ($part eq "pron") {
        Dict::write_direct("]") }

    elsif ($part eq "gramGrp") {
        Dict::write_direct(H2(">")) }

    elsif ($part eq "usg") {
        Dict::write_direct(")") }

    elsif (($part eq "pos") || ($part eq "num") || ($part eq "gen")) {
        Dict::add_text(".") }
	
    elsif ($part eq "p") {
        Dict::write_newline() }

    elsif ($part eq "def") {
        Dict::add_text(H("</i>")) }

    elsif ($part eq "ref") {
        Dict::add_text("} ") if $crossrefs_enabled }

    elsif (($part eq "teiHeader")) {
        $header = 0;
        return if $skip_header;
        Dict::write_text();
        Dict::write_newline();
	
	Dict::set_headword(); Dict::add_text("00-database-short");
	Dict::write_text(); Dict::end_headword();
	Dict::write_direct("\n  ");
	Dict::write_direct($database_short);
        Dict::write_newline();
	
	# FIXME who defined 00-database-url and where is it used? it seems not in kdict
	Dict::set_headword(); Dict::add_text("00-database-url");
	Dict::write_text(); Dict::end_headword();
	Dict::write_direct(" ");
	Dict::write_direct($database_url);
        Dict::write_newline();
	
	}
	
    elsif ($header) {
        return if ($skip_header);
	
        if ($part eq "note") {
          if ($higherElements[-1] eq "notesStmt") {
	    Dict::add_text($HTML_enabled ? "</li>" : ")") }
	  $noteCharacters = 0;
	  }
	  
        elsif ($part eq "change") {
          $Dict::fill2 = "" }
  
        elsif (($part eq "notesStmt") || ($part eq "revisionDesc")) {
          Dict::add_text(H("</ul>\n"));
          Dict::write_text();
          Dict::write_newline();
	  }

        elsif (($part eq "edition") ||
               ($part eq "titleStmt") ||
	       ($part eq "editionStmt") ||
	       ($part eq "publicationStmt")
	      ) {
          Dict::write_text();
          Dict::write_newline();
	  }	  
	  
	} # ^header
	    
    elsif ($part eq "note") {
	Dict::add_text(")");        
        $Dict::fill2 = "" }
    
    elsif ($part eq "body") {
        Dict::set_headword();# to have the last headword appear in INDEX
	};

}

sub processing_instruction {
  # for experimenting
  my ($self,$pi) = @_;
  
  # in xml it would look like this: "<?tei2dict printloc?>"
  if ($pi->{Data} eq "tei2dict printloc") {
    #print STDERR "tei2dict: crossed my Processing Instruction...\n";
    }

# FIXME: maybe with another parser than ESISParser
# The following would be right according to my understanding,
# but XML::ESISParser gives us _BOTH_ {Target} and {Data} inside Data:

#  if (($pi->{Target} eq "tei2dict") && (exists $pi->{Data})) {
#    if ($pi->{Data} eq "printloc") {
#     warn 'tei2dict: now processing line xxx';#FIXME, but parser has to support it
#     }
#  }
}

1;
