all: xhtml

xhtml: *.xml
	xmlto xhtml -o xhtml freedicthowto.xml

xhtml-nochunks: *.xml
	xmlto xhtml-nochunks -o xhtml freedicthowto.xml

clean:
	-rm *~ xhtml/*.html

.PHONY: all xhtml

