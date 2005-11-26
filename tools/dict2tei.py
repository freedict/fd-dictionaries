#!/usr/bin/python
# Written by Petergozz, Jan 2004
#
# micha137: renamed from dict2xml.py
#
## todo GPL 2+ ##
##### THIS IS ALPHA LEVEL NOT FOR PRODUCTION USE ###########
####### Requires Python2.3 or later ###########################
##  TODO will need TEI header > proper tei stuff too !! 
##	d2X_write_tei_header() (not here)
## TODO add detect for .dz files and uncompress
## (if tools on board if not .. explore the gzip modules :)
## dz is a modded version of gzip so _might_ be  doable ?


import sys
import time
import os
import string
import re
#cool new way to do getopts :)
#import optparse
from optparse import OptionParser, OptionGroup



#
# Globals
#
VERSION = "-0.1.1"
chatty = None
app = os.path.basename(sys.argv[0])
start_time = time.asctime()
#
# regex defs (pre-compiles) these are used in d2x_format_xml
#
rex_hdwd = re.compile('^\w.*$') #Headword  starts with anything not a white space
rex_descpt = re.compile('^\s\s+.*$') #Description starts with more than one white space
## TODO add matches for parts of speech pronounciation etc. here hmm more command line options ... 

## TODO add matches for file names here (to autogen out names)

## TODO add matches for 00-data etc for dictd headers (possibly)
def d2x_getInput():
	d2x_usage = '%prog -f dictfile [options]\n\n Defaults are provided for _everything_ except the dictfmt FILE to read from '
	cl_parser = OptionParser(d2x_usage, version="%prog"+VERSION )
	
	cl_parser.add_option("-f", "--file", type="string", action="store",  dest="readfile",  help="read dictfmt file  from FILENAME" )
	cl_parser.add_option("-v", "--verbose", action="store_true", dest="verbose",  help="Tell me whats going on.  ")
	cl_parser.add_option("-o", "--out", type="string", action="store", dest="writefile", default="dicttei.xml",  help="write TEI/XML format file to FILENAME" )
	groupDocT = OptionGroup( cl_parser, "Advanced Options for changing the DOCTYPE", "Use these to set a doctype string that works for your system")
	groupDocT.add_option("-s", "--dtdsys", type="string", action="store", dest="DTDsys",default='http://www.tei-c.org/Guidelines/DTD/tei2.dtd' , help="set System DTD  to PATH.  NB: If your not using an XML/SGML catalog system you should set this to: /your/path/to/tei2.dtd" )
	groupDocT.add_option("-p", "--dtdpub", type="string",action="store", dest="DTDpub",default='-//TEI P4//DTD Main Document Type//EN', help="set public DTD to \"Formal Public Identifier\"  NB: You _will_ need to quote it" )
	groupDocT.add_option("-t", "--dtdtype", type="string", action="store", dest="DTDtype", default="TEI.2", help="set non default DOCTYPE [TEI.2] " )
	cl_parser.add_option_group( groupDocT )
	groupXML = OptionGroup( cl_parser, "Advanced options for altering the default XML header.", "Use these if you need to change the defaults. There are no single switch options for these." )
	
	groupXML.add_option("--xmlver" , type="string", action="store", dest="XMLver", default='1.0', help="Set XML version attribute. [\"1.0\" ]" )
	groupXML.add_option("--xmllang", type="string", action="store", dest="XMLlang", default='en', help="set the XML code language attribute. [en]")
	groupXML.add_option("--xmlstand", type="string", action="store", dest="XMLstand", default='no', help="set the XML \"standalone\"  attribute. [no]")
	groupXML.add_option("--xmlenc", type="string", action="store", dest="XMLenc", default='utf-8', help="set the XML character ISO code attribute. [utf-8] \n ")
	cl_parser.add_option_group( groupXML )
	## TODO a really quiet option and a logging option and a dotfile prefs section and group the options so they don't scare the crap out of innocent bystanders.
	(cl_options, cl_args)  = cl_parser.parse_args()
	
	#pull the exports out of the "getopt"
	dictFileIN = cl_options.readfile
	teiFileOut = cl_options.writefile
	dtdType = cl_options.DTDtype
	dtdSys = cl_options.DTDsys
	dtdPub = cl_options.DTDpub
	chat = cl_options.verbose
	xml_v = cl_options.XMLver
	xml_lang = cl_options.XMLlang
	xml_stand = cl_options.XMLstand
	xml_enc = cl_options.XMLenc
	
	# catch-me's here
	if len(cl_args) << 1: ## this still broken i will fix later
		cl_parser.error("We need at least one thing to do.\n\n Have you supplied a file name for reading ?\n <::For help type::> "+ app +" -h")
	elif dictFileIN == None :
		print app +"      ::>   No input file  <::\n"
		cl_parser.print_help()
		sys.exit(0)
	else:
		print app +"        Reading from:::> "+ dictFileIN + "  <::\n"
		print app +"        Writing to:  ::> "+ teiFileOut +" <::\n"
	
	#Test for verbosity
	# (damm and blast this is clunky)
	
	print app+" REMINDER ::> This is Alpha level software ! <::"
	print app+ VERSION +" !!!!!!!!!!!!  not for production use !!!!!!!!!!!!!!!!"
	if chat == True :
		print "command line options   :", cl_options
		chatty = "Y"
		print "Chat mode is on" +chatty
	else :
		chatty = "N"
		print app +" Chat mode off"


		
	#
	#Now get to work
	#call the workhorses up
	#
	d2x_write_prolog( app, teiFileOut, dtdType, dtdPub, dtdSys, xml_v, xml_lang, xml_stand, xml_enc, chatty  )
	d2x_format_xml( dictFileIN, teiFileOut, chatty  )
	return()


def d2x_write_prolog( this_app, fout, doc_t,  doc_type_pub, doc_type_sys,  xml_v, xml_lang, xml_stand, xml_enc,  chatty ):
	if chatty == "Y":
		print "entered write prolog function"

	xmlfile = file(fout, "w+")
	
	if chatty == "Y":
		print "Writing to ::> ", xmlfile

	
	# prolog is just a concat of all the following:
	doc_type =  '<!DOCTYPE  '+ doc_t+ '  PUBLIC \"'+ doc_type_pub +'\"  \"' + doc_type_sys +'\" [ \n<!ENTITY % TEI.XML            "INCLUDE" >\n<!ENTITY % TEI.dictionaries \"INCLUDE\" > \n]>\n<!--this file  auto generated on   ' +start_time +'   by ' + this_app + VERSION +' \n     please edit and rename  --> ' 
	xml_head = '<?xml version=\"'+xml_v+'\"  encoding=\"'+xml_enc+'\"  lang =\"'+xml_lang+'\" standalone=\"'+xml_stand+'\" ?>'
	#
	#So putting it all together we get 
	#
	prolog = xml_head+'\n'+doc_type+'\n\n'
	if chatty == "Y" :
		print(prolog)
				
	xmlfile.write( prolog )
	xmlfile.close() # this seems safer and dumps the buffer (we need a lot of ram for big files)
	
	
def d2x_format_xml(fin, fout, chatty ) :
	"""d2x_format_xml()	
	
	takes a dictd format file and wraps it in TEI print dictionary xml tags.
	Command line options exist for most sgml, XML attributes and file in and out names.
	Defaults are supplied for all but the file in name.
	 """

	dictfmt = file( fin, 'r+',1 ) #open file in read and write mode line buffed only

	xmlfile = file( fout, 'a' ) # reopen the output file for appending

	# read all of dictfmt file to a list (as it only has new lines to differentiate with)
	dictlist = dictfmt.read()
	##TODO break into 100 line (+/- 8K) blocks use seek to increment through the whole file?
	# now split the buffer by "2 or more new lines"
	dictarray = dictlist.split('\n\n')
		
	# TODO make a spinner or % readout(after you improve cache and speed)
	
	for record in dictarray:
		recSub1 = re.sub('^\n', "" , record)#tidy any leading newlines
		recSub2  = re.sub('\t', '    ', recSub1) # replace tabs with 4 spaces
		recSub3 = recSub2+'\n'+'</entry>' # tag the true end
		sub_string = recSub3.split('\n')
	#
	#note do not strip leading space from defs (yet)
	#
		# it should now be the case that headwords start on "col one" and defs etc don't
		xmlfile.write('\n<entry>')
		for field in sub_string:
			if chatty == "Y":
				print "found field"
				
			match_H =  rex_hdwd.match( field )
			match_D =  rex_descpt.match( field )
			match_End = re.search('</entry>', field)
			if  match_H :
				if chatty == "Y":
					print 'Headword Match found: ', match_H.group()
					
				xmlfile.write('\n<form><orth>' )
				xmlfile.write(match_H.group())
				xmlfile.write('</orth></form>')
			elif match_D :
				if chatty == "Y":
					print 'Description Match found: ',  match_D.group()
					
				xmlfile.write( '\n<def>')
				xmlfile.write( match_D.group() )
				xmlfile.write ('</def>')
			elif match_End :
				if chatty == "Y":
					print 'end entry'
					
				xmlfile.write ('\n</entry>')
			else:
				if chatty == "Y":
					print 'No match'

#
#detect mode of operation and gather an environment etc
#we actually start from here if called to execute
#
if  __name__ == "__main__":
	d2x_getInput() # NTS this is not C
	print app+ ": End Run"

