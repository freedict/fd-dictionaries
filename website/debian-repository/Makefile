all: dists/unstable/main/binary-i386/Packages.gz dists/unstable/main/source/Sources.gz \
	  dists/etch/main/binary-i386/Packages.gz dists/etch/main/source/Sources.gz

dists/unstable/main/binary-i386/Packages.gz: dists/unstable/main/binary-i386/*.deb
	dpkg-scanpackages -ai386 -m dists/unstable/main/binary-i386 /dev/null | gzip -9c > $@

dists/unstable/main/source/Sources.gz: dists/unstable/main/source/*.tar.gz dists/unstable/main/source/*.dsc dists/unstable/main/source/*.diff.gz
	dpkg-scansources dists/unstable/main/source /dev/null | gzip -9c > $@

dists/etch/main/binary-i386/Packages.gz: dists/etch/main/binary-i386/*.deb
	dpkg-scanpackages -ai386 -m dists/etch/main/binary-i386 /dev/null | gzip -9c > $@

dists/etch/main/source/Sources.gz: dists/etch/main/source/*.tar.gz dists/etch/main/source/*.dsc
	dpkg-scansources dists/etch/main/source /dev/null | gzip -9c > $@

clean:
	rm -f dists/unstable/main/binary-i386/Packages.gz \
	      dists/unstable/main/source/Sources.gz \
	      dists/etch/main/binary-i386/Packages.gz \
	      dists/etch/main/source/Sources.gz
