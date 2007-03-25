#!/usr/bin/python

# TODO: convert this to use a dictionary, in memory, as the primary data
# structure. Write a second routine to iterate through that dictionary
# and re-produce the xml output.
# Add routines to use this dictionary to do the following:
# * check for doubled words in definitions
# * check for doubled words.
# * check the spelling of the english translations; if they are wrong,
#   keep a record of them. Then again, there could be a lot of these.
# * read in and out an editable usable form for editing the words with a
#   text editor.

# And the biggy.. write something which will take a text and check every
# word with the dictionary.

import string
import sys

print """
This file is a hack. It does not use any proper XML libraries and
assumes far too much about the structure of the file. It's also
very slow.

Please read the code first and use it directly
from the python interactive prompt. Note that it will and possibly damage
your dictionary. This does _not_ preserve multiple translation groups
(<trans><tr></tr></trans>) and simply merges them all.
"""

class Dict:

    def __init__(self):
	self.__dict = {}   # this is _it_ - a python dict that stores all.

	self.line = ""
	self.lineptr = 0
	self.tags = []
	self.word = ""
	self.definitions = []
	self.state = ""

	self.tagstack = [] # a stack of tags.

	# used for writing tei files.
	self.translating = 0
	self.translated = 0
        self.flush_buffer = 0
        self.discard_buffer = 0
	self.buffered_lines = []

	self.output = None # output file for writing.

##    def p_head(self):
##	"Parses the header. Basically, just ignore it."
##	depth = 0
##
##	# Kick-start
##	c = self.input.read(1)
##	if c == '<':
##	    depth = depth + 1
##	else:
##	    print "Error: document doesn't start with a '<'"
##	    assert 0
##
##	# and just keep reading < or >'s until we run out.
##	while depth > 0:
##	    c = self.input.read(1)
##	    if c == '<':
##		depth = depth+1
##	    elif c == '>':
##		depth = depth-1

    def import_tei(self, filename):
	# imports a tei file, provided that it's very basic.

	input = open(filename, 'r')


	#This skips past the header of a tei file.
	depth = 0
	c = input.read(1)
	if c == '<':
	    depth = depth + 1
	else:
	    print "Error: document doesn't start with a '<'"
	    assert 0

	# and just keep reading < or >'s until we run out.
	while depth > 0:
	    c = input.read(1)
	    if c == '<':
		depth = depth+1
	    elif c == '>':
		depth = depth-1
	self.state = "text"


	# Read the first line to get started.
	line = input.readline()
	#print "Parsing first line:", line
	sptr = 0
	notEOF = 1

	while notEOF: # for the whole file.
	    # Parse one line.
	    while sptr < len(line) and sptr >= 0:
		if line[sptr] == '<':
		    sptr = sptr + 1
		    # then check for a matching '>'
		    eptr = string.find(line, '>', sptr)
		    if eptr>0:
			if line[sptr] == '/': # if it's a </endtag>
			    sptr = sptr + 1
			    self.p_endtag(line[sptr:eptr])
			else:
			    #self.p_starttag(line[sptr:eptr])
			    # faster:
			    self.tags.append(line[sptr:eptr])
			sptr = eptr + 1
		    else:
			print "Parse error: no ending '>'"
			assert 0
		else:
		    eptr = string.find(line, '<', sptr)
		    if eptr > 0:
			self.p_data(line[sptr:eptr])
			sptr = eptr
		    else:
			# it wasn't found.. so maybe it's on the next line.
			self.p_data(line[sptr:])
			sptr = len(line) # which does the next iteration.

	    # Get a new line
	    line = input.readline()
	    # This code ignores blank lines while watching for
	    # the end of the file.
	    if len(line) == 0:
		notEOF = 0
	    else:
		line = string.strip(line)
		while not line:
		    line = input.readline()
		    if not line:
			notEOF = 0
			break
		    else:
			line = string.strip(line)
	    #print "Parsing now line:", line
	    sptr = 0

	input.close()

    def p_endtag(self, tag):
	end = self.tags.pop()
	#if tag != end:
	#    print "Error: tags don't match:", tag, end
	#    assert 0

	if tag == "entry":
	    # Then save the entry and get ready for a new one.
	    if self.__dict.has_key(self.word):
		print "Warning: There is more than one definition of ", self.word
		print "         Merging definitions.."
		for d in self.definitions:
		    if d not in self.__dict[word]:
			self.__dict[self.word].append(d)
	    else:
		self.__dict[self.word] = self.definitions
	    self.word = ""
	    self.definitions = []

    def p_data(self, data):
	if len(self.tags) < 1:
	    return
	state = self.tags[len(self.tags)-1]
	if state == "orth":
	    self.word = data
	elif state == "tr":
	    if data not in self.definitions:
		self.definitions.append(data)
	    else:
		print "Warning: duplicate definition: ", self.word, "/", data

    def update_tei(self, teifile):
	# puts changes back to the tei file.
	# Note that this will merge multiple translations;
	# I'm not sure if this is an intended feature (most seperate
	# translations are wrong) or a bug.
	# Any superfluous information in the .TEI file is retained.

	input = open(teifile, 'r')
	self.output = open(teifile+".changed", 'w')
        self.translating = 0

	# retain the header.
	depth = 0
	c = input.read(1)
	self.output.write(c)
	if c == '<':
	    depth = depth + 1
	else:
	    print "Error: document doesn't start with a '<'"
	    assert 0
	# and just keep reading < or >'s until we run out.
	while depth > 0:
	    c = input.read(1)
	    self.output.write(c)
	    if c == '<':
		depth = depth+1
	    elif c == '>':
		depth = depth-1
	self.state = "text"


	# This is to check if there are new words. If there are,
	# they need to be added.
	self.allwords = self.__dict.keys()
	self.allwords.sort()
	self.allwords_counter = 0

	# Read the first line to get started.
	rawline = input.readline()
	# This line is probably not of parsing importance:
	self.output.write(rawline) # this line already has a CR.
	line = rawline
	#print "Parsing first line:", line
	sptr = 0
	notEOF = 1

	while notEOF: # for the whole file.
	    # Parse one line.
	    while sptr < len(line) and sptr >= 0:
		if line[sptr] == '<':
		    sptr = sptr + 1
		    # then check for a matching '>'
		    eptr = string.find(line, '>', sptr)
		    if eptr>0:
			if line[sptr] == '/': # if it's a </endtag>
			    sptr = sptr + 1
			    self.w_endtag(line[sptr:eptr])
			else:
			    self.w_starttag(line[sptr:eptr])
			    # faster:
			    #self.tags.append(line[sptr:eptr])
			sptr = eptr + 1
		    else:
			print "Parse error: no ending '>'"
			assert 0
		else:
		    eptr = string.find(line, '<', sptr)
		    if eptr > 0:
			self.w_data(line[sptr:eptr])
			sptr = eptr
		    else:
			# it wasn't found.. so maybe it's on the next line.
			self.w_data(line[sptr:])
			sptr = len(line) # which does the next iteration.

	    if not self.translating:
		self.buffered_lines.append(rawline)
	    elif not self.translated:
		# Write my own translation instead of the file's.
                for l in self.__get_translation(rawline, self.word):
                    self.buffered_lines.append(l)
		self.translated = 1

            if self.discard_buffer:
                self.buffered_lines = []
                self.discard_buffer = 0
            elif self.flush_buffer:
                self.__flush_buffer()

	    # Get a new line
	    rawline = input.readline()
	    line = rawline
	    # This code ignores blank lines while watching for
	    # the end of the file.
	    if len(line) == 0:
		notEOF = 0
	    else:
		line = string.strip(line)
		while not line:
		    rawline = input.readline()
		    line = rawline
		    if not line:
			notEOF = 0
			break
		    else:
			line = string.strip(line)
	    #print "Parsing now line:", line
	    sptr = 0

        self.__flush_buffer()
	input.close()
	self.output.close()

    def w_starttag(self, tag):
	self.tags.append(tag)
	if tag == "trans":
	    self.translating = 1
        elif tag == 'body':
            self.flush_buffer = 1

    def w_endtag(self, tag):
	end = self.tags.pop()
	#if tag != end:
	#    print "Error: tags don't match:", tag, end
	#    assert 0

	if tag == "entry":
	    # end of the entry.
	    if self.allwords_counter < len(self.allwords):
		current_word = self.allwords[self.allwords_counter]
	    else:
		# I've run out of words.
		self.translated = 0
		self.translating = 0
		return

	    print "DEBUG: word:", current_word, " from file:", self.word
	    if self.word < current_word:
		# Case one: word missing.
		print "Warning: word ", self.word, " appears to be missing in memory; discarding."
                self.discard_buffer = 1
		# and nothing needs to be done.
	    elif self.word > current_word:
		# case two: word added. Write all words from here to the new word.
		while self.allwords[self.allwords_counter] < self.word:
		    print "DEBUG: Adding word: ",self.allwords[self.allwords_counter]
		    self.__write_word(self.allwords[self.allwords_counter])
		    self.allwords_counter = self.allwords_counter + 1
		# but don't write the last word
		self.allwords_counter = self.allwords_counter + 1
	    else:
		print "DEBUG: read word", self.allwords[self.allwords_counter]
		self.allwords_counter = self.allwords_counter + 1

	    self.flush_buffer = 1
	    self.word = ""
	    self.definitions = []
	    self.translated = 0
	    self.translating = 0

    def w_data(self, data):
	if len(self.tags) < 1:
 	    return
	state = self.tags[len(self.tags)-1]
	if state == "orth":
	    print "DEBUG: read word from file:", data
	    self.word = data

    def __flush_buffer(self):
	for i in self.buffered_lines:
	    self.output.write(i)
	self.buffered_lines = []
        self.flush_buffer = 0

    def __write_word(self, word):
	# This is really a hack. Hard-coded indentation; bad thing.
	# writes the "current" word to the output.
	w = self.output.write
	w("      <entry>\n")
	w("        <!-- Added by mikevdg; there is a duplicate somewhere.-->\n")
	w("        <form>\n")
	w("          <orth>"+word+"</orth>\n")
	w("        </form>\n")
        for l in self.__get_translation("        <trans>", word):
            w(l)
	w("      </entry>\n")

    def __get_translation(self, line, word):
	# Write the tranlation of the current word.
	indentation = line[:string.find(line, string.lstrip(line))]
        return_me = []

	return_me.append(indentation+"<trans>\n")
	for d in self.__dict[word]:
	    return_me.append(indentation+"  <tr>"+d+"</tr>\n")
	return_me.append(indentation+"</trans>\n")
        return return_me

    def import_voc(self, filename):
	# imports an eddict file and merges the changes
	input = open(filename)
	for line in input.readlines():
	    l = string.strip(line)
	    if l[0] == "[": # ignore all section headers.
		if l=="[words]":
		    continue
		else:
		    break
	    # parse one line.
	    word, d = string.split(l, '/')
	    word = string.strip(word)
	    definitions = string.split(d, ';')
	    if self.__dict.has_key(word):
		current_definitions = self.__dict[word]
		for c in current_definitions:
		    if c not in definitions:
			definitions.append(c)
	    self.__dict[word]=definitions

	input.close()

    def export_voc(self, filename):
	# Exports to an eddict file.

	# A voc file is a file that will be accepted by the
	# "dictionary" program for the palmpilot; http://www.evolutionary.net.
	# I've purchased this program and it does the job. Use the convertion
	# program at their website to build your .pdb file.

	# The structure of the file is as follows (from the help file):
    	##[words]
    	##    word/translated-word
    	##    word2/translated-word2
    	##        .
    	##        .
    	##
    	##    [phrases]
    	##    >category-name
    	##    phrase/translated-phrase
    	##        .
    	##        .
    	##    >category-name
    	##    phrase/translated-phrase
    	##        .
    	##        .
    	##
    	##    [notes]
    	##    <any-text>
    	##
    	##
    	##  NOTE: do NOT put spaces around the '/' character.

        # You can list a series of words by seperating them
	# with semicolons, e.g. "dag;goede dag/hello;hi"
	#
	# ***** There can only be 16 translations max for each entry. *****
	#
	# Words must be less than 128 chars (not worth checking.)
	# Entries must be less than 1024 chars.
	# And you can only have up to 1 million words.

	outputfile = open(filename, 'w')
	outputfile.write("[words]\n")

	for w,d in self.__dict.items():
	    o = w+'/'
	    notfirst = 0
	    for i in d[:15]:
		if notfirst:
		    o = o+';'
		else:
		    notfirst = 1
		o = o + i
	    outputfile.write(o+'\n')

	outputfile.write("[phrases]\n")
	outputfile.write(">uncatagorized\n")
	outputfile.write("mike says/enter your custom phrases here.\n")
	outputfile.write("[notes]\n")
	outputfile.write("You can include your personal notes here.\n")
	outputfile.close()

## Old code. Not guaranteed to work.
##if __name__ == '__main__':
##    # For the output parser.
##    state = "inputfilename"
##    inputfilename = ""
##    outputfilename = ""
##
##    for arg in sys.argv[1:]: # btw.. next time don't forget the [1:]..
##                             # otherwise you lose your source code.
##	# I love turing machines..
##	if arg == "-o":
##	    state = "outputfilename"
##	elif arg == "-i":
##	    state = "inputfilename"
##	else:
##	    if state == "inputfilename":
##		inputfilename = arg
##		state = "outputfilename"
##	    elif state == "outputfilename":
##		outputfilename = arg
##		state = "inputfilename"
##
##    if len(inputfilename) < 1:
##	print "Usage: tei2editable <input>"
##	sys.exit(0)
##    if len(outputfilename) < 1:
##	outputfilename = inputfilename + ".eddict"
##
##    p = tei2eddict()
##    p.go(inputfilename, outputfilename)
##    print "Output in ", outputfilename

def make_voc(filename):
    d = Dict()
    print "Importing dict.."
    d.import_tei(filename+".tei")
    print "Exporting.."
    d.export_voc(filename+".voc")
    print "Done."

def change_tei(filename):
    d = Dict()
    print "Importing tei.."
    d.import_tei(filename)
    print "Exporting.."
    d.update_tei(filename)

# for debugging.
if __name__=='__main__':
    change_tei('head.tei')
