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

package dict;

use Text::Wrap;

$b64_list =  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


sub b64_encode {
    $val = shift @_;
    $result = "";

    $tempo = ($val &  0xC0000000) >> 30;
    if ( $tempo != 0) {
	$result = substr $b64_list, $tempo, 1;
	}

    $tempo = ($val &  0x3f000000) >> 24;
    
    if ( $result ne "" || $tempo != 0) {
	$result .= substr $b64_list, $tempo, 1;
	}

    $tempo = ($val &  0x00fc0000) >> 18;
    
    if ( $result ne "" || $tempo != 0) {
	$result .= substr $b64_list, $tempo, 1;
	}

    $tempo = ($val &  0x0003f000) >> 12;
    
    if ( $result ne "" || $tempo != 0) {
	$result .= substr $b64_list, $tempo, 1;
	}

    $tempo = ($val &  0x00000fc0) >> 6;
    
    if ( $result ne "" || $tempo != 0) {
	$result .= substr $b64_list, $tempo, 1;
	}

    $tempo = ($val &  0x0000003f);
    $result .= substr $b64_list, $tempo, 1;

    return $result;
}


sub open_dict{
     $this = shift @_;
     $name = shift @_;
    open DATA, ">$name.dict";
    open INDEX, ">$name.index";
    print "\nopend: $name.dict and \n       $name.index\n";    
    $headwords = 0;

    $prev_word = "";
    $start_article = 0;
}

sub write_newline {
    print DATA "\n";
}


sub set_headword {
# Here a marker is set for the next entries beeing headwords
    $head = 1;
    $end_article = tell DATA;

    $headwords += 1;
    if (($headwords % 100) == 0) {
    print  $headwords;
    print " Headwords\n"; 
    }

    if ( @hwords != 0) {
	foreach $hw  (@hwords) {
	    print INDEX "$hw\t" . b64_encode(     $start_article);
	    print INDEX "\t" . b64_encode($end_article-$start_article) . "\n";	    
	}
    }

    $start_article = $end_article;
    @hwords = ();
}

sub end_headword {
    $head = 0;
}




sub add_text{
    $text = shift @_;
    $all_text .= $text;
}


sub write_text{  
    $columns = 80;
    print DATA fill("", "", $all_text);
    $all_text = "";
    push @hwords, $text if ($head == 1);
}


sub write_direct{  
    $text = shift @_;
    print DATA $text;
}

1;






