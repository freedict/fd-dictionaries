#!/usr/bin/python
# -*- coding: utf-8; -*-

# Import.py

# This file imports a TEI (XML) dictionary (esp. for freedict) and
# turns it into a dic format for ZBdic

#-------------------------------------------------------------------------------

from cStringIO import StringIO
#from test.test_support import verbose, TestFailed, findfile
# --- 

import xml.sax.handler
import codecs

from string import *


import os
import re

class TEISplit(xml.sax.handler.ContentHandler):
    """
    """
    def __init__(self, write, Dictionary):
        xml.sax.handler.ContentHandler.__init__(self)
        self._write = write
	if (Dictionary == None):
            Dictionary = "Unknown"

        self._write.write("id=%s (FreeDict)\n" % Dictionary)
        self._write.write("max-entry-length=65000\n")
        self._write.write("max-word-length=1000\n")
        self._write.write("search-ignore-chars=-.\n")
        self._write.write("\000")

        self._element = ""
        self._hw = ""
        self._pron=""
        self._pos=""
        self._tran=""
        self._re = re.compile("[\.-]")
        
        self._wordcount = 0
        
    # ContentHandler methods

    def startDocument(self):        
        pass        
        # converted HEY

    def endDocument(self):       
        #del self
        pass
            
    def startPrefixMapping(self, prefix, uri):
        self._ns_contexts.append(self._current_context.copy())
        self._current_context[uri] = prefix
        self._undeclared_ns_maps.append((prefix, uri))

    def endPrefixMapping(self, prefix):
        self._current_context = self._ns_contexts[-1]
        del self._ns_contexts[-1]

    def startElement(self, name, attrs):        
        self._element = lower(name)

        if (name == "entry"):
            self._hw = ""
            self._pron=""
            self._pos=""
            self._tran=""
            
        if (name == "gramgrp"):
            self._pos += "{ps}"

        if (name == "trans"):
            self._tran += "{s}"

    def endElement(self, name):
        # XXX: we should not set an empty element
        # but rather pop of the prev. one from a list
        # this does for now.
        if (name == "gramgrp"):
            self._pos += "{/ps}"
            
        if (name == "trans"):
            self._tran += "{/s}"
            
        self._element = ""
        
        if (name == "entry"):
            self._write.write("\000")
            self._hw = self._re.sub("", self._hw)
            self._write.write(self._hw.encode("utf-8"))
            self._write.write("\n")
            self._write.write(self._pron.encode("utf-8"))
            self._write.write(self._pos.encode("utf-8"))
            self._write.write(self._tran.encode("utf-8"))
                                    
            self._wordcount += 1;
            if (self._wordcount % 100 == 0):
                print "%s Words processed" % self._wordcount


    def startElementNS(self, name, qname, attrs):
        pass
        

    def endElementNS(self, name, qname):
        pass

    def characters(self, content):
        if ((self._element == "orth") & (self._hw == "")):
            self._hw = content
            
        if ((self._element == "pron") & (self._pron == "")):
            self._pron = "{pr}%s{/pr}" % content
            
        if ((self._element == "pos") ):
            self._pos = "%s %s." % (self._pos, content)

        if ((self._element == "num") ):
            self._pos = "%s %s." % (self._pos, content)
            
        if ((self._element == "gen") ):
            self._pos = "%s %s." % (self._pos, content)
            
        if ((self._element == "tr") ):
            self._tran = "%s{ss}%s{/ss}" % (self._tran, content)            
            

    def ignorableWhitespace(self, content):
        pass

    def processingInstruction(self, target, data):
        pass


 
if __name__ == '__main__':
    
    import xmllib
    import sys
    # create a parser
    parser = xml.sax.make_parser()  
    # ceate a content handler
    write = open ( sys.argv[2], "wb" )

    gen = TEISplit(write, os.path.basename(sys.argv[1]))
    parser.setContentHandler(gen)
    parser.parse( sys.argv[1] )          
