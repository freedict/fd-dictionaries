# module for tei dict converter
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
# along with this program; if not, write to the Free Software 
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.



package teihandler;

use dict;

sub set_file_name {
    my ($self, $fname) = @_;
    $file_name = $fname;
}



sub new {
    my ($type) = @_;
    $file_name =~ s/^(\w*\/)+//g;         
    $file_name =~ s/(\S*)\.\w*/\1/;
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

  dict::set_headword() if ( $part eq "ORTH");

  dict::write_direct("[") if ($part eq "PRON");
  dict::write_direct(" <") if ($part eq "GRAMGRP");

  dict::write_direct("\n  ") if ($part eq "TRANS");
  dict::write_direct(", ") if (($part eq "TR") && ($aword == 1));

  dict::add_text(", ") 
      if (($part eq "POS") || ($part eq "NUM") || ($part eq "GEN"));

  dict::add_text(" (") if ($part eq "USG");

    %elements = ();
}



sub end_element {
    my ($self, $element) = @_;
  
  dict::write_text();
    
    $part  = $element->{Name};

    $header = 0 if ( $part eq "TEIHEADER");

    if ( $part eq "ORTH") {
      dict::end_headword();
      dict::write_direct(" ");
    }
  dict::write_newline() if ($part eq "ENTRY");

  dict::write_direct("]") if ($part eq "PRON");

  dict::write_direct(">") if ($part eq "GRAMGRP");

  dict::write_direct(")") if ($part eq "USG");

  dict::write_newline() if ($part eq "P");
  
  dict::add_text(".") if (($part eq "POS") || ($part eq "NUM") || ($part eq "GEN"));
  $aword = (($part eq "TR") ? 1 : 0); 


}

1;


