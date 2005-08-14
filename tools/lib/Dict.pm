# V1.5 5/2004
#   * generate warnings on empty headwords that appear after
#     punctuation removal
# V1.4 4/2004
#   * trim leading spaces after punctuation removal from headwords
#   * made warnings of non-acsii characters in non utf8 index work
# V1.3 2/2004
#   * use LC_ALL instead of LANG environment variable
#     for setting locale for 'sort'
#   * don't use -df switches to 'sort' when generating
#     00-database-utf8 headword
#   * do headword mangling in the same way (hopefully) like dictd
#     does in its tolower_alnumspace_utf8() function
# V1.2 5/2003
#   *  gave optional argument 'locale' to open_dict()
# V1.1 improved by Michael Bunk, <kleinerwurm at gmx.net>
#   *  This API is undocumented & cruel! But at least I added
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
use Encode 'decode_utf8';
use utf8;

our ($headwords, $prev_word, $start_article, $head, $fill2, $end_article,
 @hwords, $text, $all_text, $utf8mode);

# there is CPAN module MIME::Base64 for this! but anyway,
# without it we are independent
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
    my ($this, $name, $locale, $d, $sortcmd);
    
    $this = shift @_;
    $name = shift @_;
    $locale = shift @_;
    $utf8mode = shift @_;
    
    # set locale 
    # otherwise collating sequence (sorting oder) might be
    # wrong (space after letters and things like that)
    printf STDERR "Dict.pm: Using LC_ALL: $locale\n";
    $ENV{'LC_ALL'}=$locale;
   
    # open file where definitions will go 
    open DATA, ">$name.dict";

    # open a pipe and output the index in a sorted way

    # dictfmt uses only -df (and no options in utf8 / 8bit mode) 
    # in bash we enter: sort -t $'\t' -k 1,1bdf
    # the sort options:
    # -t: give field separator, the TAB
    # -k: only use first field for sorting
    #  b: ignore trailing blanks (might not be needed or even harmful)
    #  df: as usual (dictionary order, ignore case)

    # don't give -df option when we generate 00-database-utf8 index
    $d = ($utf8mode) ? "" : "df";
    $sortcmd = "|sort -t \"\t\" -k 1,1b".$d." >$name.index";
    warn "using sort command: '$sortcmd'\n";
    open INDEX, $sortcmd;
    if ($utf8mode) { binmode(INDEX, ":utf8"); }
    warn "\nopened: $name.dict and \n       $name.index\n";    

    $headwords = 0;
    $prev_word = "";
    $start_article = 0;
    $head = 0;
    $fill2 = "";
}

sub write_newline {
    # directly write into data file
    # newlines in the INDEX don't make sense anyway
    print DATA "\n";
}


sub set_headword {
    # Here a marker is set for the next entries being headwords

    # But how does it work for the first entry? You cannot call set_headword
    # before having one??

    # For the first time set_headword is called, NOTHING is written to index!
    # At second call, first entry's headword is written.

    # this also means that for the very last entry to appear in the index,
    # after outputting the last entry we once again have to call set_headword!
    # couldn't this be done in a better way? yes, new api!

    $head = 1;
    $end_article = tell DATA;


    # Output status
    if (($headwords % 100) == 0)
    {
      printf STDERR "%8d Headwords.\r", $headwords
    }

    # that hwords is an array means multiple headwords
    # can reference the same definition! good.
    if(@hwords != 0) {
	foreach (@hwords) {
	    # warn about non-ascii chars if not in utf8 mode
	    if(!$utf8mode && /\P{IsASCII}/)
	    {
		warn "Non ASCII char in headword: \"$_\"\n";
		# btw, dictfmt quits here!
	    }
	  
	    # make perl believe it is utf8
	    # see 'man perluniintro' 
	    if($utf8mode) { $_ = decode_utf8($_); }

	    # generate two headwords for "00-database-*":
	    # first with, second without "-" characters
	    if(/^00-database-/) {
	      print INDEX "$_\t" . b64_encode($start_article);
	      print INDEX "\t" . b64_encode($end_article-$start_article) . "\n";	    }

	    # do headword mangling in the same way (hopefully) like dictd
	    # does in its str.c:tolower_alnumspace_utf8() function:
	    # if not in allchars mode (we can't be since we don't support it),
	    # - any whitespace characters are translated to simple space
	    # - only alphanumeric characters are considered
	    # AlexeyCheusov> Minus should also be removed unless you use "allchars" mode.
	    # AlexeyCheusov> In last case, ALL characters from the query should be matched.
	    s/\s/ /g;
 	    s/[^\s\p{IsAlnum}]//g;

	    # thereafter characters are translated to lower case (required
	    # even in allchars mode!)
	    $_ = lc $_;

	    # sanity checks
            if(/^\s+(.+)/)
	    {
	      warn "\nWarning: Trimmed leading space(s) from headword '$_'\n";
	      $_ = $1;
	      warn "Now it is '$_'\n";
	    }

            if(/^\s*$/)
	    {
	      warn "\nSkipping empty or whitespace-only headword!\n";
	      warn "\t\@hwords: ", @hwords, "\n";
	    }
	    else
	    {
	      print INDEX "$_\t" . b64_encode($start_article);
	      print INDEX "\t" . b64_encode($end_article-$start_article) . "\n";	    }
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

    if ($head == 1) {
	push @hwords, $text;# FIXME $text is an ugly global var!
	$headwords += 1;
	}

    # FIXME $text is an ugly global var!
    $text = "";
}

sub add_headword{
    $text = shift @_;
    return if ((!defined $text) || ($text eq ""));

    if ($head == 1) {
	push @hwords, $text;# FIXME $text is an ugly global var!
	$headwords += 1;
	}
	
    $text = "";
}


sub write_direct{  
    $text = shift @_;
    print DATA $text;
}

1;
