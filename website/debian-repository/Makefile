all: unstable/main/binary-i386/Packages.gz unstable/main/source/Sources.gz \
	  etch/main/binary-i386/Packages.gz etch/main/source/Sources.gz

unstable/main/binary-i386/Packages.gz: unstable/main/binary-i386/*.deb
	dpkg-scanpackages -ai386 -m unstable/main/binary-i386 /dev/null | gzip -9c > $@

unstable/main/source/Sources.gz: unstable/main/source/*.tar.gz unstable/main/source/*.dsc unstable/main/source/*.diff.gz
	dpkg-scansources unstable/main/source /dev/null | gzip -9c > $@

etch/main/binary-i386/Packages.gz: etch/main/binary-i386/*.deb
	dpkg-scanpackages -ai386 -m etch/main/binary-i386 /dev/null | gzip -9c > $@

etch/main/source/Sources.gz: etch/main/source/*.tar.gz etch/main/source/*.dsc etch/main/source/*.diff.gz
	dpkg-scansources etch/main/source /dev/null | gzip -9c > $@

clean:
	rm -f unstable/main/binary-i386/Packages.gz \
	  unstable/main/source/Sources.gz \
	  etch/main/binary/Packages.gz \
	  etch/main/source/Sources.gz
