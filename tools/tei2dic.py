#!/usr/bin/python
# -*- coding: utf-8; -*-
# vim:fileencoding=utf-8

# This is a converter from TEI (XML) dictionary format (esp. from FreeDict)
# to dic format for BEDic. BEDic is a libary. ZBEDic is a dictionary
# application on the Sharp Zaurus "Linux Palmtop". The dic format is
# documented in a file that comes with libbedic.

# We adhere to BEDic format version 0.9.4, but we do not insist on the
# headwords ("word value" in the bedic format description) being unique,
# so the {s} tag is not used in its intended way!
# The {sa} (see also) and {ex} (example) tags are not supported as I
# intend to switch to an XSLT conversion style.

# Version 0.1 Horst Eyermann 2003
# Version 0.2 Michael Bunk Jan 2005
#  * code cleanup
#  * turned off external general entity parsing
# Version 0.3 Michael Bunk Mar 2005
#  * support for bedic format 0.9.4, new properties:
#	* id (now taken from teiHeader instead of filename)
#	* maintainer (requires a teiHeader convention!)
#	* copyright
#	* no support for properties: description, char-precedence
#	  (see writeHeader())
#  * fixed handling of gramGrp
#  * more code cleanup (removed unnecessary function stumps and
#    headword character filtering)
#  * fixed characters() handler being called multiple times
#    facing entity references
#-------------------------------------------------------------------------------

import xml.sax.handler
#from string import *
#import os
#import re

class TEISplit(xml.sax.handler.ContentHandler):
    """
    """
    def __init__(self, write):
        xml.sax.handler.ContentHandler.__init__(self)
        self._write = write

        self._hw = ""
        self._pron = ""
        self._pos = ""
        self._tran = ""
	self._resp = ""
	self._respName = ""

	# from the TEI header
        self._id = ""
        self._maintainer = ""
        self._copyright = ""

	#self._re = re.compile("[\.-]")
        self._elementnamestack = []
        self._wordcount = 0
        
    def writeHeader(self):
        # id: title of the dictionary
        self._write.write("id=%s\n" % self._id)

	# maintainer: Firstname Lastname <email>
	if(self._maintainer != ""):
           self._write.write("maintainer=%s\n" % self._maintainer)

	# copyright: How many lines?
	if(self._copyright != ""):
           self._write.write("copyright=%s\n" % self._copyright)
	
	# We don't set "description" and "commentXX"
	# as it is too hard to fill them nicely with a SAX based
	# converter (An XSLT stylesheet is better suited for this).
	
	# We do not use char-precedence, as it could
	# be extracted from libc locale descriptions
	# (LC_COLLATE property).
	
	# additional properties will be added by the xerox tool
	# (builddate, compression-method, dict-size,
	# max-entry-length, max-word-length, index, items,
	# search-irgnore with '-' and '.')

	# end of header
        self._write.write("\000")
      
#    def startDocument(self):        
#        pass        

#    def endDocument(self):       
#        pass

# required??
#    def startPrefixMapping(self, prefix, uri):
#        self._ns_contexts.append(self._current_context.copy())
#        self._current_context[uri] = prefix
#        self._undeclared_ns_maps.append((prefix, uri))

#    def endPrefixMapping(self, prefix):
#        self._current_context = self._ns_contexts[-1]
#        del self._ns_contexts[-1]

    def startElement(self, name, attrs):        
        # save element name for use in characters()
        self._elementnamestack.append(name) 

        if (name == "tr" or name == "def"):
            self._tran += "{ss}"
	    return

        if (name == "entry"):
            self._hw = ""
            self._pron = ""
            self._pos = ""
            self._tran = ""
            return
	  
        if (name == "gramGrp"):
            self._pos += "{ps}"
	    return

	if (name == "resp"):
            self._resp = ""
	    return
            
        if (name == "name"):
            self._respName = ""
	    return
	  
        if (name == "title"):
            self._title = ""
	    return
	  
    def endElement(self, name):
        self._elementnamestack.pop()
	
        if (name == "tr" or name == "def"):
            self._tran += "{/ss}"
	    return

        if (name == "gramGrp"):
            self._pos += "{/ps}"
            return
	  
        if (name == "entry"):
	    self._wordcount += 1
	    if(self._wordcount % 100 == 0):
               print "\r%s Entries processed" % self._wordcount,
	       sys.stdout.flush()

	    if(self._hw == ""):
	      print "Skipping empty headword @ entry " + str(self._wordcount)
	      return

	    self._write.write("\000")

	    # remove - and . (not required!?)
	    #self._hw = self._re.sub("", self._hw)
    
            self._write.write(self._hw.encode("utf-8"))
            self._write.write("\n")
            self._write.write("{s}")
            self._write.write(self._pron.encode("utf-8"))
            self._write.write(self._pos.encode("utf-8"))
            self._write.write(self._tran.encode("utf-8"))
            self._write.write("{/s}")
	    return

	if (name == "respStmt"):
	  if("titleStmt" in self._elementnamestack and \
	      self._resp == "Maintainer"):
	    self._maintainer = self._respName
	  self._resp = ""
	  self._respName = ""

        if (name == "title"):
	  if("titleStmt" in self._elementnamestack):
            self._id = self._title
	  return
	  
	if (name == "teiHeader"):
	    self.writeHeader()
	    return

#    def startElementNS(self, name, qname, attrs):
#        pass
        

#    def endElementNS(self, name, qname):
#        pass

    # this function is called several times with different pieces
    # of element content of the same element in case of entity references!
    def characters(self, content):
        # fetch top of stack
        name = self._elementnamestack[len(self._elementnamestack)-1]

        if (name == "tr" or name == "def"):
            self._tran += content
	    return

        if ((name == "orth") & (self._hw == "")):
            self._hw = content
            
        if ((name == "pron") & (self._pron == "")):
            self._pron = "{pr}%s{/pr}" % content
            
        if (name == "pos"):
	  if(self._pos == ""): self._pos += " "
          self._pos += content + "."

        if (name == "num"):
            self._pos += " " + content + "."
	    return
            
        if (name == "gen"):
            self._pos += " " + content + "."
	    return
            
        if (name == "resp"):
            self._resp += content
	    return
            
        if (name == "name"):
            self._respName += content
	    return
            
        if (name == "title"):
            self._title += content
	    return
            
        if (name == "p" and "availability" in self._elementnamestack):
            self._copyright += content
	    return

#    def ignorableWhitespace(self, content):
#        pass

#    def processingInstruction(self, target, data):
#        pass

if __name__ == '__main__':
    import sys

    if(len(sys.argv) != 3):
      print >> sys.stderr, \
       "Call me as: %s <teifilename> <dicfilename>" % sys.argv[0]
      sys.exit(1)
      
    # create a parser
    parser = xml.sax.make_parser()
    #print "Parse external general entitites: " + \
    # str(parser.getFeature(xml.sax.handler.feature_external_ges))
    parser.setFeature(xml.sax.handler.feature_external_ges, 0)
    
    # ceate a content handler
    write = open(sys.argv[2], "wb")
    gen = TEISplit(write)
    parser.setContentHandler(gen)
    
    parser.parse(sys.argv[1])

