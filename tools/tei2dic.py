#!/usr/bin/python
# -*- coding: utf-8; -*-
# vim:fileencoding=utf-8

# This is a converter from TEI XML dictionary format (esp. from FreeDict)
# to dic format for the BEDic project. ZBEDic is a dictionary application
# for the Sharp Zaurus "Linux Palmtop", using the library libbedic. The dic
# format is documented in a file that comes with libbedic.

# We adhere to BEDic format version 0.9.4, but we do not insist on the
# headwords ("word value" in the bedic format description) being unique
# here. Make sure the TEI input has homographs already grouped with the
# <hom> element, or the resulting file will violate the BEDic format!

# Version 0.1 Horst Eyermann 2003
# Version 0.2 Michael Bunk Jan 2005
#  * code cleanup
#  * turned off external general entity parsing
# Version 0.3 Michael Bunk Mar 2005
#  * support for bedic format 0.9.4, new properties:
#	* id (now taken from frist word of teiHeader instead of filename)
#	* description (teiHeader//title)
#	* maintainer (requires a teiHeader convention!)
#	* copyright
#  * no support for property char-precedence, see writeHeader()
#  * fixed handling of gramGrp
#  * more code cleanup (removed unnecessary function stumps and
#    headword character filtering)
#  * fixed characters() handler being called multiple times
#    facing entity references
#  * proper handling of homographs from <hom> elements
#  * support for the {sa} (see also) and {ex} (example) tags
#  * multiple orth elements result in a 'see also' to the first orth
#  * limitation: TEI <sense> element not handled, all translation equivalents
#	of all different <senses> get listed as separate subsenses ({ss}),
#	examples get listed as {ss}, though they belong to specific <sense>s
#-------------------------------------------------------------------------------

import xml.sax.handler
import string

class TEISplit(xml.sax.handler.ContentHandler):
    """
    """
    def __init__(self, write):
        xml.sax.handler.ContentHandler.__init__(self)
        self._write = write

	# declare members of this class
	self._hw = []
        self._hw1 = ""
        self._pron = ""
        self._pos = ""
        self._tran = ""
	self._resp = ""
	self._respName = ""
	self._seealso = []
	self._seealso1 = ""
	self._ex = ""

	# from the TEI header
        self._id = ""
        self._maintainer = ""
        self._copyright = ""

        self._elementnamestack = []
        self._wordcount = 0
        
    def writeHeader(self):
        # _id: title of the dictionary

	# The length of the id property is practically limited
	# by the Zaurus screen size, so only the first word of the
	# TEI title is used. The complete title is saved in the
	# description property.

        self._write.write("description=%s\n" % self._id)

	# use only first word, if several words exist
	if(string.find(self._id, " ") > 1):
	  self._id = self._id[0:string.find(self._id, " ")]

        self._write.write("id=%s\n" % self._id)

	# maintainer: Firstname Lastname <email>
	if(self._maintainer != ""):
           self._write.write("maintainer=%s\n" % self._maintainer)

	# copyright: There should be just one line of copyright
	# information. However, ZBEDic uses a HTML widget, so the
	# line can have arbitrary length.
	if(self._copyright != ""):
           self._write.write("copyright=%s\n" % self._copyright)
	
	# We don't set "commentXX" as it is too hard to fill them
	# nicely with a SAX based converter. An XSLT stylesheet would
	# be better suited for this.
	
	# We do not use char-precedence, as it could
	# be extracted from libc locale descriptions
	# (LC_COLLATE property). But actually we should
	# do that extraction, as we are the ones who
	# know the language of the words in the index...
	
	# Additional properties will be added by the xerox tool:
	# builddate, compression-method, dict-size,
	# max-entry-length, max-word-length, index, items,
	# search-ignore with '-' and '.'

	# end of header
        self._write.write("\000")
     
    def skippedEntity(name):
      print >> sys.stderr, \
	  "Warning: Skipped entity %s." % name
	  
    def startElement(self, name, attrs):        
        # save element name for use in characters()
        self._elementnamestack.append(name) 

        if (name == "tr" or name == "def"):
          self._tran += "{ss}"
	  return

        if (name == "entry"):
	  # clear everything, as some elements may not exist
	  self._hw = []
	  self._hw1 = ""
	  self._pron = ""
	  self._pos = ""
          self._tran = ""
	  self._homographs = []
	  self._ex = ""
          return
	  
        if (name == "gramGrp"):
	  self._pos = "{ps}"
	  return

        if (name == "orth"):
	  self._hw1 = ""
          return
	  
        if (name == "ref"):
	    self._seealso1 = ""
	    return
	  
        if (name == "hom"):
	    self._pos = ""
	    self._tran = ""
	    self._ex = ""
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

        if (name == "orth"):
	  if(self._hw1 == ""): return
	  self._hw.append(self._hw1)
	  return
	  
        if (name == "gramGrp"):
            self._pos += "{/ps}"
            return

	if (name == "hom"):
	  hom = self._pos.encode("utf-8") + \
                self._pron.encode("utf-8") + \
                self._tran.encode("utf-8")
	  while(self._seealso != []):
	    hom += "{ss}see also {sa}" + \
                   self._seealso.pop().encode("utf-8") + \
                   "{/sa}{/ss}"
	  if(self._ex):
            hom += "{ss}{ex}" + self._ex.encode("utf-8") + "{/ex}{/ss}"
	  self._homographs.append(hom)
	  return
	  
        if (name == "ref"):
	    self._seealso.append(self._seealso1)
	    return
	  
        if (name == "entry"):
	    self._wordcount += 1
	    if(self._wordcount % 100 == 0):
               print "\r%s Entries processed" % self._wordcount,
	       sys.stdout.flush()

	    if(self._hw == []):
	      print "Skipping entry without headwords @ entry " + str(self._wordcount)
	      return

	    # create references from alternate headwords to us
	    while(len(self._hw) > 1):
	      self._write.write("\000" +
		  		self._hw.pop().encode("utf-8") +
				"\n{s}{ss}see also {sa}" +
				self._hw[0].encode("utf-8") +
	      			"{/sa}{/ss}{/s}")

	    self._write.write("\000")
            self._write.write(self._hw[0].encode("utf-8"))
            self._write.write("\n")

	    # usual entry
	    if(self._homographs == []):
              self._write.write("{s}")
              self._write.write(self._pos.encode("utf-8"))
              self._write.write(self._pron.encode("utf-8"))
              self._write.write(self._tran.encode("utf-8"))
	      if(self._seealso != []):
		self._write.write("{ss}see also: ")
	        while(self._seealso != []):
                  self._write.write("{sa}" +
		      self._seealso.pop().encode("utf-8") + "{/sa}")
		  if(len(self._seealso) > 0):
		    self._write.write(", ")
                self._write.write("{/ss}")
	      if(self._ex):
                self._write.write("{ex}" + self._ex.encode("utf-8") + "{/ex}")
              self._write.write("{/s}")
	    else:
	      while(self._homographs != []):
	        self._write.write("{s}")
                self._write.write(self._homographs.pop())
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

    # this function is called several times with different pieces
    # of element content of the same element in case of entity references!
    def characters(self, content):
        # fetch top of stack
        name = self._elementnamestack[len(self._elementnamestack)-1]

        if (name == "tr" or name == "def"):
            self._tran += content
	    return

        if (name == "orth"):
            self._hw1 += content
           
        # XXX not entity reference safe!
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
            
        if (name == "q" and "eg" in self._elementnamestack):
	    self._ex += content
	    return

        if (name == "ref"):
	    self._seealso1 += content
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

