#!/usr/bin/perl
#xmltei2xmldict.pl requires:
#
#- nsgmls from SP 1.3.4 from http://www.jclark.com/jade/
#  or OpenSP from http://openjade.sourceforge.net/
#- ESISParser.pm from libxml-perl-0.07, available via
#	(su)
#	perl -MCPAN -e shell
#	install K/KM/KMACLEOD/libxml-perl-0.07.tar.gz
#- TEI P4 DTDs, available from http://www.tei-c.org/Guidelines2/index.html
#- make SGML_CATALOG_FILES point to the right location(s), e.g.
#	export SGML_CATALOG_FILES="/usr/share/doc/packages/sp/\
#html-xml/xml.soc:/var/lib/sgml/CATALOG.tei_4xml:/var/lib/sgml/\
#CATALOG.iso_ent"
#- Sablotron library and Perl module:
#
# $Id$

# V1.5 10/2006 Michael Bunk
#   * removed -l option completely
#   * cosmetic changes / rewrite
#   * new option -n to set NSGMLS option of XML:ESISParser
#
# V1.4 5/2004 Michael Bunk
#   * added option to generate 00-database-allchars header
#
# V1.3 4/2004 Michael Bunk kleinerwurm-at-gmx.net
#   * finally used FindBin
#   * use warnings; instead of #!perl -w to avoid warnings
#     in foreign code (Sablotron module)
#
# V1.1 2/2004 Michael Bunk kleinerwurm-at-gmx.net
#   * put .pm files into lib/
#
# V1.0 6/2003 Michael Bunk kleinerwurm-at-gmx.net
#   * based on tei2dict_xml.pl
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

use warnings;
use strict;
use FindBin;
use lib "$FindBin::Bin";
use XML::ESISParser;
use Getopt::Std;
use XML::Sablotron;
use XML::Sablotron::DOM;
use lib::TEIHandlerxml_xml;

our ($opt_f, $opt_h, $opt_s, $opt_c, $opt_u, $opt_i,
  $opt_r, $opt_t, $opt_a, $sab, $sit, $opt_n, $opt_d);
getopts 'surai:f:t:n:d:';

unless (defined $opt_f)
{
 print STDERR <<END;

$0 - convert Text Encoding Initiative files to
 dictd database format, optionally keeping the xml in the <entry> elements


 The TEI input file is expected as XML in TEI P4 format, see
 http://www.tei-c.org/
 Outputs .index and .dict file. The index is sorted with sort(1).
 This help is printed, because there was no TEI file given.

 Usage: $0 -f <teifile> [-sura] [-i <filtercmd>|-t <stylesheet.xsl>]
           [-n <nsgmls>] [-d <declaration>]

 -s   skip TEI header: do not treat it to generate 00-database-info & co
      special entrys (good to convert adapted SGML TEI files)
 -u   generate headword 00-database-utf8 in index file to mark the database
      being in UTF-8 encoding.  When this is given, 'sort' is called without -d
      option, ie. all characters are used in comparisons.
 -r   generate reverse index (use <tr> instead of <orth>)
 -a   generate headword 00-database-allchars (but no change in index mangling!)
      This converter cannot generate the 00-database-alphabet entry, so -a is
      required for non-latin scripts.  You should prefer to use dictfmt(1)
      then.
 -i <filtercmd>\t execute filtercmd for each entry (eg. 'sabcmd style.xsl')
 -t <stylesheet.xsl>\t use an XSLT stylesheet for filtering the entries with
      the Sablotron library. Excludes -i.
 -n <nsgmls>\tSets the NSGMLS option of XML::ESISParser.  By default 'nsgmls'
      is used.  To use OpenSP, set this option to 'onsgmls'.
 -d <declaration>\tSets the Declaration option of XML::ESISParser.
      XML::ESISParser expects the SGML declaration by default in
      /usr/lib/sgml/declaration/xml.decl.  In Debian
      /usr/share/xml/declaration/xml1n.dcl works best with nsgmls from the SP
      XML parser.
 <teifile>\t name of TEI input file

END
 exit 1
 }

our $file = $opt_f;
unless (-f $file)
{ print STDERR "Can't find file \"$file\""; exit 2 }

if ($opt_i && $opt_t)
{ print STDERR "Only one of -i and -t may be given"; exit 2 }

our $my_handler = lib::TEIHandlerxml_xml->new();

$my_handler->set_options(
    $file, # hand over name for .dict and .index output files
    $opt_s ? 1 : 0,		# skip TEI header
    $opt_u ? 1 : 0,		# generate 00-database-utf8
    "C",			# locale
    $opt_i ? $opt_i : "",	# filter command
    $opt_t,			# stylesheet for Sablotron
    $opt_r ? 1 : 0,		# generate reverse index
    $opt_a ? 1 : 0);		# generate 00-database-allchars

unless (defined $ENV{SGML_CATALOG_FILES})
{
 $ENV{SGML_CATALOG_FILES} =
   "/var/lib/sgml/CATALOG.tei_4xml:/var/lib/sgml/CATALOG.iso_ent";
 print STDERR <<END;
Warning: The environment variable SGML_CATALOG_FILES is not set.
Please point it to the TEI catalog file(s).

Setting SGML_CATALOG_FILES=$ENV{SGML_CATALOG_FILES}
END
 }

our %additional_args;
$additional_args{'Declaration'} = $opt_d if defined $opt_d;

# Handling of the 'NSGMLS' option is broken in XML::ESISParser
#$additional_args{'NSGMLS'} = $opt_n if defined $opt_n;
$XML::ESISParser::NSGMLS_xml = $opt_n if defined $opt_n;

XML::ESISParser->new->parse(Source => { SystemId => $file },
                            Handler => $my_handler, %additional_args);

print STDERR "Created $Dict::headwords headwords (including multiple <orth>-s / from the <tr>-s).\n";

