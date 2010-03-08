all: unstable

unstable: dists/unstable/main/binary-i386/Packages.gz \
	  dists/unstable/main/source/Sources.gz

lenny: dists/lenny/main/binary-i386/Packages.gz \
	  dists/lenny/main/source/Sources.gz

dists/unstable/main/binary-i386/Packages.gz: dists/unstable/main/binary-i386/*.deb
	dpkg-scanpackages -ai386 -m dists/unstable/main/binary-i386 /dev/null | gzip -9c > $@

distsunstablemainsourcediffgz=$(wildcard dists/unstable/main/source/*.diff.gz)

dists/unstable/main/source/Sources.gz: dists/unstable/main/source/*.tar.gz dists/unstable/main/source/*.dsc $(distsunstablemainsourcediffgz)
	dpkg-scansources dists/unstable/main/source /dev/null | gzip -9c > $@

dists/lenny/main/binary-i386/Packages.gz: dists/lenny/main/binary-i386/*.deb
	dpkg-scanpackages -ai386 -m dists/lenny/main/binary-i386 /dev/null | gzip -9c > $@

dists/lenny/main/source/Sources.gz: dists/lenny/main/source/*.tar.gz dists/lenny/main/source/*.dsc
	dpkg-scansources dists/lenny/main/source /dev/null | gzip -9c > $@

clean:
	rm -f dists/unstable/main/binary-i386/Packages.gz \
	      dists/unstable/main/source/Sources.gz \
	      dists/lenny/main/binary-i386/Packages.gz \
	      dists/lenny/main/source/Sources.gz

.PHONY: all unstable lenny
