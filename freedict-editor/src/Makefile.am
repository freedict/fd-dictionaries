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
	entryedit.c entryedit.h \
	values.c values.h

freedict_editor_LDADD = @PACKAGE_LIBS@ $(INTLLIBS)

main.c: interface.h support.h

interface.c interface.h support.c support.h: ../freedict-editor.glade
	cd .. && glade-2 --write-source freedict-editor.glade

