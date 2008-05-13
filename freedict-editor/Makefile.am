## Process this file with automake to produce Makefile.in

SUBDIRS = src po data help pixmaps

EXTRA_DIST = \
	autogen.sh \
	freedict-editor.gladep \
	help/C/imipa.c \
	help/C/make-ipatable.pl \
	help/C/make-ipatable.sh \
	help/C/view.sh \
	intltool-extract.in \
	intltool-merge.in \
	intltool-update.in

DISTCLEANFILES = po/stamp-it intltool-extract intltool-merge intltool-update

dist_pkgdata_DATA = freedict-editor.glade

#install-data-local:
#	@$(NORMAL_INSTALL)
#	if test -d $(srcdir)/pixmaps; then \
#	  $(mkinstalldirs) $(DESTDIR)$(datadir)/pixmaps/$(PACKAGE); \
#	  for pixmap in $(srcdir)/pixmaps/*; do \
#	    if test -f $$pixmap; then \
#	      $(INSTALL_DATA) $$pixmap $(DESTDIR)$(datadir)/pixmaps/$(PACKAGE); \
#	    fi \
#	  done \
#	fi

dist-hook:
	if test -d pixmaps; then \
	  mkdir $(distdir)/pixmaps; \
	  for pixmap in pixmaps/*; do \
	    if test -f $$pixmap; then \
	      cp -p $$pixmap $(distdir)/pixmaps; \
	    fi \
	  done \
	fi

deb:
	fakeroot debuild
