## Process this file with automake to produce Makefile.in

INCLUDES = \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	@PACKAGE_CFLAGS@

bin_PROGRAMS = freedict-editor

freedict_editor_SOURCES = \
	main.c \
	support.c support.h \
	interface.c interface.h \
	utils.c utils.h \
	xml.c xml.h \
	callbacks.c callbacks.h \
	entryedit.c entryedit.h

freedict_editor_LDADD = @PACKAGE_LIBS@ $(INTLLIBS)

