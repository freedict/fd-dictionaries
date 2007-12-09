## Process this file with automake to produce Makefile.in

SUBDIRS = src po data help

EXTRA_DIST = \
	autogen.sh \
	freedict-editor.glade \
	freedict-editor.gladep \
	data/entry-template.xml \
	data/freedict.keys \
	data/freedict.mime \
	data/la1-la2.template.tei \
	help/C/imipa.c \
	help/C/make-ipatable.pl \
	help/C/make-ipatable.sh \
	help/C/view.sh \
	intltool-extract.in \
	intltool-merge.in \
	intltool-update.in

install-data-local:
	@$(NORMAL_INSTALL)
	if test -d $(srcdir)/pixmaps; then \
	  $(mkinstalldirs) $(DESTDIR)$(datadir)/pixmaps/$(PACKAGE); \
	  for pixmap in $(srcdir)/pixmaps/*; do \
	    if test -f $$pixmap; then \
	      $(INSTALL_DATA) $$pixmap $(DESTDIR)$(datadir)/pixmaps/$(PACKAGE); \
	    fi \
	  done \
	fi
	$(INSTALL_DATA) freedict-editor.glade $(DESTDIR)$(datadir)/$(PACKAGE)

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
