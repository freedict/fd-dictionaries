FREEDICTDIR?=$(realpath ..)
LANGUAGES=en de kha ru ku fr ar bg lt nl
BASEURL=http://localhost/~$(USER)/freedict-dynamic/
DYNAMICPATH=$(FREEDICTDIR)/website
FILES=$(notdir $(basename $(wildcard $(DYNAMICPATH)/*.php) $(wildcard $(DYNAMICPATH)/*.html)))
WGET=wget --no-verbose --header='X-FreeDict: staticlinks' --html-extension --no-clobber

upload:
	# For the lftp to connect using the proper password, a bookmark
	# with the name "freedict.org" is required.  To create it, connect
	# to the ftp server with "lftp user@freedict.org", enter the password,
	# "set bmk:save-passwords yes", and finally "bookmark add freedict.org".
	# This creates a file "~/.lftp/bookmarks" containing the line
	# "freedict.org	user:pass@freedict.org/".
	lftp freedict.org -e \
	"mirror -ReLnv \
	--exclude-glob logs/* \
	--exclude-glob mb/* \
	--exclude-glob */.svn/* \
	--exclude-glob images/flags/src/* \
	--exclude-glob howto/images/*.gif \
	--exclude-glob howto/images/*.svg \
	--exclude-glob howto/images/*.tif \
	--exclude-glob t/* \
	--exclude-glob ergane/* \
	--exclude-glob tmp/* \
	static .; exit"

update: $(DYNAMICPATH)
	$(MAKE) -C $(DYNAMICPATH)
	$(MAKE) generate-static

generate-static: ~$(USER)/public_html/freedict-dynamic symlinks $(addprefix generate-, $(LANGUAGES)) /etc/apache2/mods-enabled/userdir.load

/etc/apache2/mods-enabled/userdir.load:
	echo As root, please enable Apache2's mod_userdir.
	echo Please also make sure that in
	echo /etc/apache2/mods-enabled/userdir.conf
	echo you
	echo AllowOverride FileInfo AuthConfig Limit Indexes Options=MultiViews,Indexes echo Otherwise you might get 500 Internal Server Error from Apache.
	echo Finally, in /etc/apache2/mods-enabled/php5.conf
	echo comment out the line
	echo php_admin_value engine Off
	echo , which disabled php for user dirs (otherwise Firefox will
	echo allow you to download your php file as .html)...
	sudo -u root "a2enmod userdir && /etc/init.d/apache2 restart"

~$(USER)/public_html:
	mkdir $@

~$(USER)/public_html/freedict-dynamic: $(DYNAMICPATH) ~$(USER)/public_html
	ln -s `realpath "$<"`  $@

symlinks: static static/images static/howto static/debian-repository \
          static/s.css static/freedict.pot static/freedict-database.xml \
          static/index.html static/.htaccess

static:
	mkdir -p static

static/images: $(DYNAMICPATH)/images
	ln -s $(DYNAMICPATH)/images $@

static/howto: $(FREEDICTDIR)/howto
	ln -s $(FREEDICTDIR)/howto $@

static/debian-repository: $(DYNAMICPATH)/debian-repository
	ln -s $(DYNAMICPATH)/debian-repository $@

static/s.css: $(DYNAMICPATH)/s.css
	ln -s $(DYNAMICPATH)/s.css $@

static/freedict.pot: $(DYNAMICPATH)/freedict.pot
	ln -s $(DYNAMICPATH)/freedict.pot $@

static/freedict-database.xml:
	ln -s $(FREEDICTDIR)/freedict-database.xml $@

static/index.html:
	# when the webspace has php, use this (but then, no need for static version at all):
	# if [ ! -d static/inc/ ]; then ln -s $(DYNAMICPATH)/inc static/inc; fi
	# if [ ! -e static/index.php ]; then ln -s ../index-freedict.org.php static/index.php; fi
	# otherwise only plain html:
	ln -s ../index.html $@

static/.htaccess:
	ln -s $(DYNAMICPATH)/.htaccess $@

generate-%: symlinks
	echo Checking for locale $*_XX.utf8 being enabled...
	echo If it is disabled, please manually enable it and
	echo restart Apache2.
	locale -a | grep '$*_.*\.utf8' \
	  || sudo -u root 'dpkg-reconfigure locales && /etc/init.d/apache2 restart'
	mkdir -p static/$*
	( cd static/$*; \
	  $(WGET) --header='Accept-Language: $*' \
	    $(addprefix $(BASEURL), $(FILES)) )

clean:
	rm -fr static
	$(MAKE) -C $(DYNAMICPATH) clean

.PHONY: upload update generate-static generate-% symlinks clean

