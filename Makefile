parse-showfiles:
	tools/extractdata.pl -r

buildtree:
	tools/manage-buildtree.pl -a

debian-build-dep:
	sudo -u root aptitude install libxml-dom-perl dictfmt xsltproc \
	autoconf autotools-dev libxslt-dev libgtkhtml3.14-dev \
	libglade2-dev scrollkeeper xmlto openoffice.org-draw \
	libapache2-mod-php5 realpath dbview intltool rsync

.PHONY: parse-showfiles buildtree debian-build-dep

