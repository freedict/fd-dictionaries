# V1.1 improved by Michael Bunk, <kleinerwurm@gmx.net>
#      This API is undocumented & cruel! But at least I added
#      some comments here.
#  
# V1.0 Copyright (C) 2000 Horst Eyermann <horst@freedict.de>
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

package Dict;

use strict;
use Text::Wrap;# for fill() or wrap()

our ($headwords, $prev_word, $start_article, $head, $fill2, $end_article,
 @hwords, $text, $all_text);

# there is CPAN module MIME::Base64 for this! but anyway,
# without it we are inpedendent
our $b64_list =  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
sub b64_encode {
    my $val = shift @_;
    my $result = "";

    my $tempo = ($val &  0xC0000000) >> 30;
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
    my ($this, $name) = @_;

    open DATA, ">$name.dict";

    # open a pipe and output the index in a sorted way (more like
    # dictfmt USES it, but this is a long story)
    # may be useless for unicode (but dictd server 1.7x
    # isn't unicode capable anyway)
    
    # in bash we enter: sort -t $'\t' -k1,1bdf
    # the sort options:
    # -t: give field separator, the TAB
    # -k: only use first field for sorting
    #  b: ignore trailing blanks (might not be needed)
    #  df: as usual
    $ENV{'LANG'}="C";# otherwise collating sequence (sorting oder) might be
                     # wrong (space after letters and things like that)
    
    open INDEX, "|sort -t \"\t\" -k1,1bdf >$name.index";

    warn "\nopened: $name.dict and \n       $name.index\n";    

    $headwords = 0;
    $prev_word = "";
    $start_article = 0;
    $head = 0;
    $fill2 = "";
}

sub write_newline {
    print DATA "\n";# this is direct then! well newlines in the INDEX don't make sense anyway
}


sub set_headword {
# Here a marker is set for the next entries being headwords

# But how does it work for the first entry? You cannot call set_headword
# before having one??

# For the first time set_headword is called, NOTHING is written to index!
# At second call, first entry's headword is written

# this also means that for the very last entry to appear in the index,
# after outputting the last entry we once again have to call set_headword!!!
# couldn't this be done in a better way? yes, new api!

    $head = 1;
    $end_article = tell DATA;

    $headwords += 1;

    # Output status
    if (($headwords % 100) == 0) { warn $headwords." Headwords\n" }

    # that hwords is an array means multiple ways to write one headword
    # can reference the same definition! good.
    if ( @hwords != 0) {
	foreach my $hw  (@hwords) {
	    print INDEX "$hw\t" . b64_encode($start_article);
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
    
    # FIXME api <-> layout not independent!
    # connect multiple headwords with comma in dict file
    if (($head) && (defined $hwords[0])) { $all_text .= ", ". $text}
    # usual output
    else { $all_text .= $text};
}


sub write_text{
    $Text::Wrap::columns = 70;
    print DATA fill("", $fill2, $all_text);
    $all_text = "";
    return if ((!defined $text) || ($text eq ""));
    push @hwords, $text if ($head == 1);# FIXME $text is an ugly global var!
    $text = "";
}


sub write_direct{  
    $text = shift @_;
    print DATA $text;
}

1;
