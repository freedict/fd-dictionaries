#!/usr/bin/perl -w -I../tools
# w for warnings, d for debug

# V1.2 5/2002 Michael Bunk
#  * switches:
#    * to turn off header treatment
#    * to turn on cross references (off by default, as not standardized)
#    * html switch default: off
#  * sorting done more precisely, in C-locale
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

our ($opt_f, $opt_h, $opt_s, $opt_c);
getopt('df:');

if (!defined $opt_f) {
 print STDERR "\ntei2dict - convert Text Encoding Initiative files to dictd database format\n\n";
 print STDERR " The TEI inputfile is expected as XML in TEI P4 format, see\n";
 print STDERR " http://www.tei-c.org/\n";
 print STDERR " Outputs .index and .dict file. The index is sorted with 'sort ...'\n";
 print STDERR " according to the C locale. If you want to convert old style SGML\n";
 print STDERR " TEI files, consider using tei2dict.pl, available from freedict.sf.net.\n";
 print STDERR " This help is outputted, because here was no tei file to process given.\n\n"; 
 print STDERR "Usage: tei2dict -f <teifile> [-h] [-s] [-c]\n";
 print STDERR " -h        : enable HTML in output, only give _after_ -f option\n";
 print STDERR "             (perl likes it more??)\n";#FIXME
 print STDERR " -s        : skip TEI header: do not treat it to generate\n";
 print STDERR "             00-database-info & co special entrys (good to convert adapted\n";
 print STDERR "             SGML tei files)\n";
 print STDERR " -c        : turn on generating cross references from <xr>-element\n";
 print STDERR " <teifile> : name of tei inputfile\n\n";
 die;
 }
 
our $file = $opt_f;
die "Can't find file \"$file\"" unless -f $file;

our $my_handler = TEIHandler_xml->new();

# hand over name for .dict and .index output files,
# if "-h" given as switch, HTML_enabled is 1, else 0
$my_handler->set_options($file,$opt_h ? 1 : 0, $opt_s ? 1 : 0, $opt_c ? 1 : 0);

# FIXME the following schould be removed if we use XML,
# but if we do, we get:
# > XML::ESISParser::parse: unable to parse `file.tei'
# > nsgmls:/usr/lib/sgml/declaration/xml.decl:1:W: SGML declaration was not implied
our @additional_args;
push (@additional_args, IsSGML => 1);

XML::ESISParser->new->parse(Source => { SystemId => $file },
                            Handler => $my_handler,@additional_args);

print STDERR "Processed $Dict::headwords headwords (including multiple orths).\n";

# EOF
