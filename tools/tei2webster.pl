#!/usr/bin/perl -w
#

# Copyright (C) 2000 Horst Eyermann <horst@freedict.de>
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

use XML::ESISParser;
use XML::Handler::Sample;


# module for tei dict converter
#

my $header;
package dict;

use Text::Wrap;



sub open_dict{
     $this = shift @_;
     $name = shift @_;
    open DATA, ">$name.web";
    print "\nopend: $name.web\n";
    $headwords = 0;
    $all_text = "";

    $prev_word = "";
    $start_article = 0;
}



sub add_text{
    $text = shift @_;
    $all_text .= $text;
}


sub write_text{
    $columns = 80;
#    print DATA fill("", "", $all_text);
    print DATA $all_text;
    flush DATA;

    $all_text = "";
    push @hwords, $text if ($header == 1);
}


sub write_direct{
    $text = shift @_;
    print DATA $text;
}



package teihandler;


sub set_file_name {
    my ($self, $fname) = @_;
    $file_name = $fname;
}



sub new {
    my ($type) = @_;
    $file_name =~ s/^(\w*\/)+//g;
    $file_name =~ s/(\S*)\.\w*/$1/;
    dict->open_dict($file_name);
    return bless {}, $type;
}

sub start_document {
}



sub characters {
    my ($self, $element) = @_;
    $data = $element->{Data};
    chomp $data;
    $data =~ s/\s+$//;
  dict::add_text( $data) if ($header != 1);
}




sub start_element {
    my ($self, $element) = @_;
    $part = $element->{Name};
    $header = 1 if ( $part eq "TEIHEADER");

    if ($header ==0 ) {

	dict::write_direct("<HW>") if ( $part eq "ORTH");

	dict::write_direct("<PR> [")  if ($part eq "PRON");

	dict::write_direct("<SD> </SD><DEF>") if (($part eq "TRANS"));

	dict::write_direct("<DEF>") if (($part eq "DEF"));
	dict::write_direct(", ") if (($part eq "TR") && ($aword == 1));

    }

    %elements = ();
}



sub end_element {
    my ($self, $element) = @_;

    $part  = $element->{Name};

  dict::write_text  if ($part ne "TEIHEADER");

    $header = 0 if ( $part eq "TEIHEADER");

    if ($header == 0) {

	if ( $part eq "ORTH") {
	    dict::write_direct("</HW>");
	      $headword += 1;
	      if (($headword % 100) == 0) {
		  print "$headword \n";
	      }
	}

      dict::write_direct( "\n")    if ($part eq "ENTRY");

	dict::write_direct("]</PR>")  if ($part eq "PRON");

	dict::write_direct("</USG>") if ($part eq "USG");

	dict::write_direct("</P>")  if ($part eq "P");
        dict::write_direct("</DEF>") if ($part eq "TRANS");
        dict::write_direct("</DEF>") if ($part eq "DEF");

	$aword = (($part eq "TR") ? 1 : 0);
    }
}


package main;

push (@additional_args, IsSGML => 1);

$file = shift @ARGV;

$input = $file ;

die "Can´t finde file \"$input\"" unless -f $input;


$my_handler = XML::Handler::Sample->new;

teihandler->set_file_name($file);

XML::ESISParser->new->parse(Source => { SystemId => $input },
                            Handler => teihandler->new,
                            @additional_args);



