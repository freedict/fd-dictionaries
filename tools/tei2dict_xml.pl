#!/usr/bin/perl -w
# w for warnings, d für debug

# V1.1 4/2002 by Michael Bunk, <kleinerwurm@gmx.net>
#  * beautified everything
#  * perl -w for warnings, use strict
# V1.0 Copyright (C) 2000 Horst Eyermann <horst@freedict.de>
#
# Note from the homepage of the package SP, where nsgmls forms a part:
#   Note that only the Win32/Unicode binaries are compiled with
#   multibyte support. To get multibyte support on other platforms,
#   you must compile from source. (If this is a problem, let me know.)
#   (James Clark)
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

use strict;
use XML::ESISParser;
use Getopt::Std;
use TEIHandler_xml;

our ($opt_f, $opt_d);
getopt('df:');

if (!defined $opt_f) {
 print STDERR "tei2dict - convert Text Encoding Initiative files to dictd database format\n";
 print STDERR "\n The TEI inputfile is expected as XML in TEI P4 format, see http://www.tei-c.org/\n";
 print STDERR " Output is on stdout.\n\n"; 
 print STDERR " Usage: tei2dict -f <teifile> [-d]\n";
 print STDERR " -d        : disable HTML in output, only give _after_ -f option (perl likes it more)\n";#FIXME
 print STDERR " <teifile> : name of tei inputfile\n\n";
 die;
 }
 
our $file = $opt_f;
die "Can't find file \"$file\"" unless -f $file;

our $my_handler = TEIHandler_xml->new();

# hand over name for .dict and .index output files,
# if "-d" given as switch, HTML_enabled is 0, else 1
$my_handler->set_options($file,$opt_d ? 0 : 1);

# FIXME the following schould be removed if we use XML,
# but if we do, we get:
# > XML::ESISParser::parse: unable to parse `file.tei'
# > nsgmls:/usr/lib/sgml/declaration/xml.decl:1:W: SGML declaration was not implied
our @additional_args;
push (@additional_args, IsSGML => 1);

XML::ESISParser->new->parse(Source => { SystemId => $file },
                            Handler => $my_handler,@additional_args);

print STDERR "Processed $Dict::headwords headwords.\n";

# EOF
