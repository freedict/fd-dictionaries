# module for teimerge
# Teile entnommen aus CanonXMLWriter.pm

# Copyright (C) 2002 Michael Bunk <kleinerwurm@gmx.net>
#  
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
# along with this program; if not, visit
# <http://www.gnu.org/licenses/gpl-2.0.txt>

package TEIMergeMainHandler;

# ESISParser zu verwenden ist tödlich, denn der fügt alle
# #IMPLIED-Attribute hinzu!!
#use XML::ESISParser;

# der hier ist aber eher für XML als SGML!
use XML::Parser::PerlSAX;
# Ausgabe ist in UTF-8, da das vom parser geliefert wird!!!

use TEIMergeOtherHandler;

%char_entities = (
    "\x09" => '&#9;',
    "\x0a" => '&#10;',
    "\x0d" => '&#13;',
    '&' => '&amp;',
    '<' => '&lt;',
    '>' => '&gt;',
    '"' => '&quot;',
    );
			    
sub set_otherfilenames {
    my $self = shift;
    $filenamesref = shift; 
}

sub new {
    my ($type) = @_;
    return bless {}, $type;
}

sub start_document {
    print "<!DOCTYPE TEI.2 PUBLIC \"-//TEI P3//DTD Main Document Type//EN\"\n";
    print "\"/usr/share/sgml/tei-3/tei2.dtd\" [\n";
    print " <!ENTITY % TEI.dictionaries 'INCLUDE' > ]>\n";
    }
    
sub characters {
    my ($self, $element) = @_;
    $data = $element->{Data};
    #print($self->_escape($data));
    print($data);
}

sub ignorable_whitespace {
    my ($self, $element) = @_;
    $data = $element->{Data};
    print($data);
}

sub processing_instruction {
     my $self = shift; my $pi = shift;
     if (exists $pi->{Data}) {
         print('<?' . $pi->{Target} . ' ' . $pi->{Data} . '?>');
	 }
     else {
        print('<?' . $pi->{Target} . '?>');
	}
}

sub comment {
    my $self = shift; my $comment = shift;
     
    print('<!--' . $comment->{Data} . '-->');
}

sub start_element {
    my ($self, $element) = @_;
    $part = $element->{Name};
    
    print('<' . $part);
    my $key;
    my $attrs = $element->{Attributes};
    foreach $key (sort keys %$attrs) {
	print(" $key=\"" . $self->_escape($attrs->{$key}) . '"');
    }
    print('>');
}

sub end_element {
    my ($self, $element) = @_;
    my $part  = $element->{Name};

    if ( $part eq "BODY") {
      # nun sind alle entrys von mainfile ausgegeben worden, es folgen die otherfiles
      warn "Mainfile done.\n";
      my $my_handler = TEIMergeOtherHandler->new;
     my @additional_args;
#     push (@additional_args, IsSGML => 1);
#     my $parser = XML::ESISParser->new;
      my $parser = XML::Parser::PerlSAX->new;
      
      foreach my $otherfile (@{$filenamesref}) {
        do { warn "Can't find file \"$otherfile\"\n"; next;}
	  unless -f $otherfile;
        warn "Mache mich an $otherfile...\n";
        $parser->parse(Source => { SystemId => $otherfile },
          Handler => $my_handler, @additional_args);
        }
      };
      
    print "</$part>";
    }

sub record_end {
#    print "\n";
    }
    
sub external_entity_ref {
    my ($self, $name) = @_;
    warn "external_entity_reference\n";

}

sub notation_decl {
    my ($self, $name, $sysid, $pubid, $genid) = @_;
    warn "notation_decl\n";

}

sub subdoc_entity_decl {
    my ($self, $name) = @_;
    warn "subdoc_entity_decl\n";

}
sub external_sgml_entity_decl {
    my ($self, $name, $sysid, $pubid, $genid) = @_;
    warn caller, "external_sgml_entity_decl\n";

}

sub _escape {
    my $self = shift; my $string = shift;
     
    $string =~ s/([\x09\x0a\x0d&<>"])/$char_entities{$1}/ge;
    return $string;
}

1;
