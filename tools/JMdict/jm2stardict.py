#!/usr/bin/env python2
# 
# converts XML JMDict to Stardict idx/dict format
#
# Date: 3rd July 2003
# Author: Alastair Tse <acnt2@cam.ac.uk>
# License: BSD (http://www.opensource.org/licenses/bsd-license.php)
#
# Usage: jm2stardict expects the file JMdict.gz in the current working
#        directory and outputs to files jmdict-ja-en and jmdict-en-ja
# 
# To compress the resulting files, use:
# 
#  gzip -9 jmdict-en-ja.idx 
#  gzip -9 jmdict-ja-en.idx
#  dictzip jmdict-en-ja.dict
#  dictzip jmdict-ja-en.dict
#
# note - dictzip is from www.dict.org
# 

import xml.sax
from xml.sax.handler import *
import gzip
import struct, sys, string, codecs,os

def text(nodes):
    label = ""
    textnodes = filter(lambda x: x.nodeName == "#text", nodes)
    for t in textnodes:
	label += t.data
    return label

def strcasecmp(a, b):
    result = 0
    
    # to ascii
    #str_a = string.join(filter(lambda x: ord(x) < 128, a[0]), "").lower()
    #str_b = string.join(filter(lambda x: ord(x) < 128, b[0]), "").lower()
    #result = cmp(str_a, str_b)
    # if result == 0:

    result = cmp(a[0].lower() , b[0].lower())
	
    return result

def merge_dup(list):
    newlist = []
    lastkey = ""
    
    for x in list:
	if x[0] == lastkey:
	    newlist[-1] = (newlist[-1][0], newlist[-1][1] + "\n" + x[1])
	else:
	    newlist.append(x)
	    lastkey = x[0]
    
    return newlist

class JMDictHandler(ContentHandler):
    def __init__(self):
	self.mapping = []
	self.state = ""
	self.buffer = ""

    def startElement(self, name, attrs):
	if name == "entry":
	    self.kanji = []
	    self.chars = []
	    self.gloss = []
	    self.state = ""
	    self.buffer = ""
	elif name == "keb":
	    self.state = "keb"
	elif name == "reb":
	    self.state = "reb"
	elif name == "gloss" and not attrs:
	    self.state = "gloss"
	elif name == "xref":
	    self.state = "xref"
	
    def endElement(self, name):
	if name == "entry":
	    self.mapping.append((self.kanji, self.chars, self.gloss))
	elif name == "keb":
	    self.kanji.append(self.buffer)
	elif name == "reb":
	    self.chars.append(self.buffer)
	elif name == "gloss" and self.buffer:
	    self.gloss.append(self.buffer)
	elif name == "xref":
	    self.gloss.append(self.buffer)
	
	self.buffer = ""
	self.state = ""
	    
    def characters(self, ch):
	if self.state in ["keb", "reb", "gloss", "xref"]:
	    self.buffer = self.buffer + ch
	    

def map_to_file(dictmap, filename):    
    dict = open(filename + ".dict","wb")
    idx = open(filename + ".idx","wb")
    offset = 0
    idx.write("StarDict's idx file\nversion=2.1.0\n");
    idx.write("bookname=" + filename + "\n");
    idx.write("author=Jim Breen\nemail=j.breen@csse.monash.edu.au\n");
    idx.write("website=http://www.csse.monash.edu.au/~jwb/j_jmdict.html\n");
    idx.write("description=Converted to stardict format by Alastair Tse <liquidx@gentoo.org>, http://www-lce.eng.cam.ac.uk/~acnt2/code/\n");
    idx.write("date=2003.07.01\n")
    idx.write("sametypesequence=m\n")
    idx.write("BEGIN:\n")
    idx.write(struct.pack("!I",len(dictmap)))
    
    for k,v in dictmap:
	k_utf8 = k.encode("utf-8")
	v_utf8 = v.encode("utf-8")
	idx.write(k_utf8 + "\0")    
	idx.write(struct.pack("!I",offset))
	idx.write(struct.pack("!I",len(v_utf8)))
	offset += len(v_utf8)
	dict.write(v_utf8)    
    
    dict.close()
    idx.close()

if __name__ == "__main__":
    
    print "opening xml dict .."
    f = gzip.open("JMdict.gz")
    #f = open("jmdict_sample.xml")
    
    print "parsing xml file .."
    parser = xml.sax.make_parser()
    handler = JMDictHandler()
    parser.setContentHandler(handler)
    parser.parse(f)
    f.close()

    print "creating dictionary .."
    # create a japanese -> english mappings
    jap_to_eng = []
    for kanji,chars,gloss in handler.mapping:
	for k in kanji:
	    key = k
	    value = string.join(chars + gloss, "\n")
	    jap_to_eng.append((key,value))
	for c in chars:
	    key = c
	    value = string.join(kanji + gloss, "\n")
	    jap_to_eng.append((key,value))
	    
    eng_to_jap = []
    for kanji,chars,gloss in handler.mapping:
	for k in gloss:
	    key = k
	    value = string.join(kanji + chars, "\n")
	    eng_to_jap.append((key,value))
	
    print "sorting dictionary .."
    jap_to_eng.sort(strcasecmp)
    eng_to_jap.sort(strcasecmp)
    
    print "merging and pruning dups.."
    jap_to_eng = merge_dup(jap_to_eng)
    eng_to_jap = merge_dup(eng_to_jap)
    
    print "writing to files.."
    
    # create dict and idx file
    map_to_file(jap_to_eng, "jmdict-ja-en")
    map_to_file(eng_to_jap, "jmdict-en-ja")
