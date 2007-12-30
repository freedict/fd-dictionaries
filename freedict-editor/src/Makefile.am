## Process this file with automake to produce Makefile.in

AM_CPPFLAGS = \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	@PACKAGE_CFLAGS@

bin_PROGRAMS = freedict-editor

freedict_editor_SOURCES = \
	main.c \
	utils.c utils.h \
	xml.c xml.h \
	callbacks.c callbacks.h \
	entryedit.c entryedit.h \
	values.c values.h

freedict_editor_LDADD = @PACKAGE_LIBS@ $(INTLLIBS)
freedict_editor_LDFLAGS = -export-dynamic
