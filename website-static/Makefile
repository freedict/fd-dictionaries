FREEDICTDIR?=$(realpath ../..)
LANGUAGES=ar bg bs de en fr kha ku lt nl pt ru
BASEURL=http://localhost/~$(USER)/freedict-dynamic/
DYNAMICPATH=$(FREEDICTDIR)/crafted/website
FILES=$(notdir $(basename $(wildcard $(DYNAMICPATH)/*.php) $(wildcard $(DYNAMICPATH)/*.html)))
WGET=wget --header='X-FreeDict: staticlinks' --html-extension --no-clobber
SFACCOUNT ?= micha137

upload:
	rsync -avP -e ssh --copy-links \
	static/ $(SFACCOUNT),freedict@web.sourceforge.net:htdocs/ \
	--exclude 'mb/*' \
	--exclude '*/.svn' \
	--exclude 'images/flags/src'

update: $(DYNAMICPATH)
	$(MAKE) -C $(DYNAMICPATH)
	$(MAKE) generate-static

generate-static: ~$(USER)/public_html/freedict-dynamic symlinks /etc/apache2/mods-enabled/userdir.load $(addprefix generate-, $(LANGUAGES))

/etc/apache2/mods-enabled/userdir.load:
	echo As root, please enable Apache2\'s mod_userdir.
	echo Please also make sure that in
	echo /etc/apache2/mods-enabled/userdir.conf
	echo you
	echo	 AllowOverride FileInfo AuthConfig Limit Indexes Options=MultiViews,Indexes
	echo	 MultiviewsMatch Any
	echo Otherwise you might get 500 Internal Server Error from Apache or 404 for Apache failing to negotiate .php URLs.
	echo Finally, in /etc/apache2/mods-enabled/php5.conf
	echo comment out the line
	echo php_admin_value engine Off
	echo , which disabled php for user dirs \(otherwise Firefox will
	echo allow you to download your php file as .html\)...
	sudo -u root "a2enmod userdir && /etc/init.d/apache2 restart"

~$(USER)/public_html:
	mkdir $@

~$(USER)/public_html/freedict-dynamic: $(DYNAMICPATH) ~$(USER)/public_html
	if [ ! -e "$@" ]; then ln -s `realpath "$<"` "$@"; fi

symlinks: static static/images static/debian-repository \
          static/s.css static/freedict.pot static/freedict-database.xml \
          static/index.html static/.htaccess

static:
	mkdir -p static

static/images: $(DYNAMICPATH)/images
	ln -s $(DYNAMICPATH)/images $@


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
	if [ ! -d static/inc/ ]; then ln -s $(DYNAMICPATH)/inc static/inc; fi
	if [ ! -e static/index.php ]; then ln -s ../index-freedict.org.php static/index.php; fi
	# otherwise only plain html:
	#ln -s ../index.html $@

static/.htaccess:
	ln -s $(DYNAMICPATH)/.htaccess $@

generate-%: symlinks
	if locale -a | grep '$*_.*\.utf8' >/dev/null; then :; \
	else \
	  echo locale $*_XX.utf8 is not available. && \
	  echo Please manually enable it. && \
	  sudo -u root -i /usr/sbin/dpkg-reconfigure locales && \
          sudo -u root /etc/init.d/apache2 restart; \
	fi
	mkdir -p static/$*
	( cd static/$*; \
	  $(WGET) --header='Accept-Language: $*' \
	    $(addprefix $(BASEURL), $(FILES)) )

clean:
	rm -fr static
	$(MAKE) -C $(DYNAMICPATH) clean

.PHONY: upload update generate-static generate-% symlinks clean

