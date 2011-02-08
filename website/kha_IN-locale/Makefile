
# the exit code of localedef is ignored, since it is non zero
# even in the presence of warnings
all:
	-localedef -v --force -f ISO-8859-1 -i kha_IN ./out

install:
	#-localedef -v --force -f ISO-8859-1 -i kha_IN kha_IN
	-sudo -u root localedef -v --force -f UTF-8 -i kha_IN kha_IN

kha_IN.utf8:
	-localedef -v --force -f UTF-8 -i kha_IN ./out
