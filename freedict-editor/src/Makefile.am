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
	Spell-1.0.5-common.c Spell-1.0.5-stubs.c Spell-1.0.5.h

freedict_editor_LDADD = @PACKAGE_LIBS@ $(INTLLIBS)

# might not be very portable...
callbacks.c: Spell-1.0.5.h

Spell-1.0.5-common.c Spell-1.0.5-stubs.c Spell-1.0.5.h:
	orbit-idl-2 --noskels /opt/gnome/share/idl/Spell-1.0.5.idl

maintainer-clean-generic:
	-rm Spell-1.0.5-common.c Spell-1.0.5-stubs.c Spell-1.0.5.h
