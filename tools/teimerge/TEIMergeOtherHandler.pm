# module for teimerge
#

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
# along with this program; if not, write to the Free Software 
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

package TEIMergeOtherHandler;

sub new {
    my ($type) = @_;
    return bless {}, $type;
}

sub characters {
    my ($self, $element) = @_;

    # wenn inside <entry> -> print, sonst nicht
    if (!$insideentry) {return;};

    $data = $element->{Data};
    chomp $data;
    $data =~ s/\s+$//;
    print $data;
}

sub start_element {
    my ($self, $element) = @_;
    $part = $element->{Name};
    
    $insideentry = 1 if ( ($part eq "ENTRY") || ($part eq "entry"));
    
    if ($insideentry) {
      print('<' . $part);
      my $key;
      my $attrs = $element->{Attributes};
      foreach $key (sort keys %$attrs) {
        print(" $key=\"" . $self->_escape($attrs->{$key}) . '"');
        }
      print('>');
      }
}

sub end_element {
    my ($self, $element) = @_;
    $part  = $element->{Name};

    print "</$part>\n" if ($insideentry);

    $insideentry = 0 if (($part eq "ENTRY") || ($part eq "entry"));
    }

%char_entities = (
    "\x09" => '&#9;',
    "\x0a" => '&#10;',
    "\x0d" => '&#13;',
    '&' => '&amp;',
    '<' => '&lt;',
    '>' => '&gt;',
    '"' => '&quot;',
    );
    
sub _escape {
    my $self = shift; my $string = shift;
     
    $string =~ s/([\x09\x0a\x0d&<>"])/$char_entities{$1}/ge;
    return $string;
    }

1; # muﬂ stehenbleiben, damit perl nicht meckert
