# SAX handler module for tei2dictxml_xml converter

# V1.2 5/2004 Michael Bunk
#	* added option to generate 00-database-allchars header
#	* if reverse index is generated, 00-database-short will indicate it now
# V1.1 4/2004 Michael Bunk
#	* when headwords contain entities, characters()
#	  is called multiple times for the same element:
#	  now only one call to add_headword()
#	  will be done
# V1.0 6/2003 Michael Bunk

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
# 1. set_file_name()    -> open_dict()
# 2. <orth>             -> set_headword()
# 3. characters()       -> $current_headword .= $data;
# 4. end_tag	        -> add_headword($current_headword)
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

package lib::TEIHandlerxml_xml;

use strict;
use warnings;
use lib::Dict;
use utf8;

# for filtering:
use FileHandle;
use IPC::Open2;

# for sablotron:
use XML::Sablotron;
use XML::Sablotron::DOM;

our ($header, $preLastStartTag, $lastStartTag,
     $database_short, $database_url, @higherElements,
     $file_name, $skip_header, $state, $quoted,
     $filtercmd, $sit, $sab, $reverse_index, $sab_templ,
     $current_headword);

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

    $string =~ s/([\x09\x0a\x0d&<>\"])/$char_entities{$1}/ge;
 
    return $string;
    }


sub new {
    my ($type) = shift;
    $header = 0;
    $state="";
    return bless {}, $type;
}

sub dumpTag {
    my $element = shift;

    #dump attributes
    my $attr="";
    if(!defined $element)
    {
      die "Please make sure the input file is valid!";
    }
    my %attrhash = %{$element->{Attributes}};
    foreach(keys %attrhash) {
     $attr .= ' '.$_.'="'._escape($attrhash{$_}).'"';
     }
    
    return "<".$element->{Name}.$attr.">";

}

sub apply_filter_cmd {
    my ($filtercommand, $quoted) = @_;
    
    if($filtercmd ne "") {
        print STDERR ".";
        #print "calling open2 with '$filtercmd'...";
	#TODO: catch errors from executed filtercmd
        # according to 'man perlipc'
        my $pid = open2(*Reader, *Writer, $filtercmd );
        #print "handing over...";flush STDOUT;
	print Writer "$quoted\n";
	close(Writer);
        #print "reading...";flush STDOUT;
        $quoted = <Reader>;
        while(!eof(Reader)) { $quoted .= <Reader>; };
        #print "\n";flush STDOUT;
	waitpid $pid, 0;
    }
    elsif ($sab) {

#        print STDERR "+";
	$sab->addArg($sit, 'input', $quoted);

#	print STDERR "\ncalling addArgTree...";
	$sab->addArgTree($sit, 'template', $sab_templ);

#	print STDERR "\ncalling process...";
	$sab->process($sit, 'arg:/template', 'arg:/input', 'arg:/output');

#	print STDERR "\ncalling getResultArg...";
	$quoted = $sab->getResultArg('arg:/output');
	
#	print STDERR "\ngot: $quoted\n\n\n\n";
	}

    return $quoted;
}

sub set_options {
    my ($self, $filename, $askip_header, $aGenerate00DatabaseUtf8, $aLocale,
      $aFilterCmd, $aStyleSheet, $aReverseindex, $aAllchars) = @_;
    $file_name = $filename;
    $file_name =~ s/^(\w*\/)+//g;         
    $file_name =~ s/(\S*)\.\w*/$1/;
    $skip_header=$askip_header;
    $filtercmd=$aFilterCmd;
    $reverse_index=$aReverseindex;

    if ($aStyleSheet) {
	print STDERR "initializing Sablotron...\n";
	$sab = new XML::Sablotron;
	$sit = new XML::Sablotron::Situation;
	$sab_templ = XML::Sablotron::DOM::parseStylesheet($sit, $aStyleSheet);
	}

    Dict->open_dict($file_name,$aLocale,$aGenerate00DatabaseUtf8);
    
    if($aGenerate00DatabaseUtf8)
    {
	print STDERR "Generating 00-database-utf8\n";
    	Dict::set_headword(); Dict::add_text("00-database-utf8");
	Dict::write_text(); Dict::end_headword();
	
	# might not be needed at all, but we give a hint
        Dict::write_direct("\n  ");
	Dict::write_direct("This dictionary is UTF-8 encoded. If you use dictd, ".
		           "make sure to start it with the appropriate --locale option.");
        Dict::write_newline();
    }
    
    if($aAllchars)
    {
	print STDERR "Generating 00-database-allchars\n";
    	Dict::set_headword(); Dict::add_text("00-database-allchars");
	Dict::write_text(); Dict::end_headword();
        Dict::write_newline();
    }	
}

sub start_element {
    my ($self, $element) = @_;
    my $part = $element->{Name};

    $preLastStartTag = $lastStartTag; $lastStartTag = $part;

    # for multiple orths at beginning of <form>
    if (!$reverse_index && ($Dict::head) && ($part ne "orth")) { Dict::end_headword() };
    
    
    # see what tag we have (& remember XML is case sensitive!)
    # most frequent tags on top
    if (($part eq "entry") ||
        ($part eq "teiHeader")) {
	$quoted = "";
	$state = "quoting";
	}
	
    elsif ($part eq "orth" && !$reverse_index) {
        if ($preLastStartTag eq "form") {Dict::set_headword()}
	$state = "orth";$current_headword='';
	}
	
    elsif ($part eq "tr" && $reverse_index) {
        if (!$Dict::head) {Dict::set_headword()}
	$state = "tr";$current_headword='';
	}

	
    if ($part eq "revisionDesc") {	
	  # add myself as
	  # <change>
	  #  <date>now</date>
	  #  <respStmt><name>tei2dict_xml.pl</name></respStmt>
	  #  <item>converted TEI database into .dict format</item>
	  # </change>
          my $now_string = gmtime();
	  my $s .= "<change>\n <date>$now_string</date>\n";
	  $s .= " <respStmt><name>tei2dictxml_xml.pl</name></respStmt>\n";
	  $s .= " <item>converted TEI database into .dict format</item></change>\n";
	  $quoted .= dumpTag($element) . $s;
#          printf STDERR "new revisionDesc: $quoted";
	  }
    elsif (($state eq "quoting") ||
        ($state eq "orth") ||
	($state eq "tr")) { 
	  $quoted .= dumpTag($element);
	  }

    elsif (($part eq "text") ||
        ($part eq "body") ||
	($part eq "TEI.2")) {
	# skip these tags without warnings
	}
    else {
	  print STDERR "warning: skipping start tag: $part\n" }
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
    
    # do some whitespace stripping:
    return if ($data =~ /\A\s*\Z/);

    $data =~ s/\n/ /;
    $data =~ s/\s+/ /;

    if ($data eq "") {
       # can happen because of newlines
       return;
       }
       
    if (($state eq "quoting") ||
        ($state eq "orth") ||
	($state eq "tr")) {
	$quoted .= _escape($data);
	}

    if    (($preLastStartTag eq "titleStmt") &&
           ($lastStartTag    eq "title")) { $database_short = $data }
    elsif ($lastStartTag     eq "pubPlace") { $database_url=$data }

    if ($reverse_index && ($lastStartTag eq "tr")) {
	$current_headword .= $data;
	}
	
    elsif (!$reverse_index && ($lastStartTag eq "orth")) {
       if (($preLastStartTag eq "form") ||
           ($preLastStartTag eq "orth")) {
	      #warn "headwords add_text: '$data'\n";
	      $current_headword .= $data;
	     }
       else {
         print STDERR "multiple <orth>-s only at beginning of <form> supported. Skipping the others!\n" }
       }
}


sub end_element {
    my ($self, $element) = @_;
    my $part  = $element->{Name};

    pop @higherElements;
    


    if (($state eq "quoting") || ($state eq "orth") || ($state eq "tr")) {
	$quoted .= "</$part>\n";
	}
	
    if ($part eq "orth") {
	Dict::add_headword($current_headword);
        # Dict::end_headword() has to be called later, because we don't know now
	# if there is another orth coming (multiple headwords for one entry)
	if($state eq "orth") {$state = "quoting"};
	}	    

    if ($part eq "tr") {
	Dict::add_headword($current_headword);
        # Dict::end_headword() has to be called later, because we don't know now
	# if there is another tr coming
	if($state eq "tr") {$state = "quoting"};
	}	    

    elsif ($part eq "entry") {
        if ($reverse_index && $Dict::head) { Dict::end_headword() };

	$quoted = apply_filter_cmd($filtercmd,$quoted);
							      
    	Dict::write_direct($quoted);	 
        Dict::write_newline();
	$state = "";
	}

    elsif (($part eq "teiHeader")) {
        return if $skip_header;
	
	$state = "";

        Dict::write_text();
        Dict::write_newline();

        # 00-database-short	
	Dict::set_headword(); Dict::add_text("00-database-short");
	Dict::write_text(); Dict::end_headword();
        Dict::write_direct("\n  ");
        Dict::write_direct($database_short);
	if($reverse_index)
	{
          Dict::write_direct(' [reverse index]');
	}
        Dict::write_newline();

	## 00-database-info
        Dict::set_headword();
	$Dict::text="00-database-info";
	Dict::write_text();
	Dict::end_headword();

	$quoted = apply_filter_cmd($filtercmd,$quoted);

	Dict::add_text($quoted);# will do wrapping
	Dict::write_text();
        Dict::write_newline();
	
	# FIXME who defined 00-database-url and where is it used? it seems not in kdict
	Dict::set_headword(); Dict::add_text("00-database-url");
	Dict::write_text(); Dict::end_headword();
	Dict::write_direct(" ");
	Dict::write_direct($database_url);
        Dict::write_newline();
          
	} # ^header
	    
    elsif ($part eq "body") {
        Dict::set_headword();# to have the last headword appear in INDEX
	};

}


1;
