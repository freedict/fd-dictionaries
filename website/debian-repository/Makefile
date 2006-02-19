all: binary/Packages.gz source/Sources.gz

binary/Packages.gz: binary/*.deb
	dpkg-scanpackages binary /dev/null | gzip -9c > $@

source/Sources.gz: source/*.tar.gz source/*.dsc source/*.diff.gz
	dpkg-scansources source /dev/null | gzip -9c > $@

clean:
	rm -f binary/Packages.gz source/Sources.gz
