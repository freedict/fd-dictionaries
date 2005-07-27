Summary:	Tools for building the FreeDict dictionaries from source
Name:		freedict-tools
Version:	0.2
Release:	1
License:	GPL
Vendor:		FreeDict
URL:		http://freedict.org/
Packager:	Michael Bunk <micha@luetzschena.de>
Group:		Applications/Dictionaries
Group(de):	Applikationen/Wörterbücher
Group(pl):	Aplikacje/S³owniki
Source0:	%{name}.tbz2
BuildRoot:	%{_tmppath}/%{name}-%{version}-buildroot
Requires:	perl
Requires:	sablot
#Requires:	dictd
# dictdconfig is from the debian package of dictd, somebody
# still would have to make an rpm for it
#Requires:	dictdconfig

%description 
Scripts to translate TEI XML files of the FreeDict project
into other formats, primarily dictd database format.

%prep
%setup -n tools

#%build

%pre
echo "This rpm is experimental! Use at your own risk and report bugs"
echo "to freedict-beta@lists.sourceforge.net!"

%install
mkdir -p $RPM_BUILD_ROOT/usr/src/freedict/tools/lib
mkdir -p $RPM_BUILD_ROOT/usr/src/freedict/tools/xsl
mkdir -p $RPM_BUILD_ROOT/usr/src/freedict/tools/testing
cp  -r xsl/* $RPM_BUILD_ROOT/usr/src/freedict/tools/xsl
cp  lib/* $RPM_BUILD_ROOT/usr/src/freedict/tools/lib
cp  testing/* $RPM_BUILD_ROOT/usr/src/freedict/tools/testing
cp ergane2tei.pl extractdata.pl teisort.pl add-freedict.sh \
tab2tei.pl txt2wb.pl hd2tei.pl xdf2tei.pl dict2tei.py tei2wb.pl \
xmltei2xmldict.pl dict-configure.sh Makefile tei2webster.pl dict.py \
Makefile.common tei2zbdic.py ding2tei.pl Makefile.config teiaddphon.pl \
$RPM_BUILD_ROOT/usr/src/freedict/tools

%post

%clean
%{__rm} -rf $RPM_BUILD_ROOT

%postun

%files
%defattr(-,root,root)
%doc COPYING 
%doc README
/usr/src/freedict/tools/xmltei2xmldict.pl
/usr/src/freedict/tools/Makefile
/usr/src/freedict/tools/Makefile.common
/usr/src/freedict/tools/Makefile.config
/usr/src/freedict/tools/add-freedict.sh
/usr/src/freedict/tools/dict-configure.sh
/usr/src/freedict/tools/dict.py
/usr/src/freedict/tools/dict2tei.py
/usr/src/freedict/tools/ding2tei.pl
/usr/src/freedict/tools/ergane2tei.pl
/usr/src/freedict/tools/extractdata.pl
/usr/src/freedict/tools/hd2tei.pl
/usr/src/freedict/tools/lib/Dict.pm
/usr/src/freedict/tools/lib/TEIHandlerxml_xml.pm
/usr/src/freedict/tools/tab2tei.pl
/usr/src/freedict/tools/tei2wb.pl
/usr/src/freedict/tools/tei2webster.pl
/usr/src/freedict/tools/tei2zbdic.py
/usr/src/freedict/tools/teiaddphon.pl
#/usr/src/freedict/tools/teimerge/TEIMergeMainHandler.pm
#/usr/src/freedict/tools/teimerge/TEIMergeOtherHandler.pm
#/usr/src/freedict/tools/teimerge/teimerge.pl
/usr/src/freedict/tools/teisort.pl
/usr/src/freedict/tools/testing/index2wordlist.pl
/usr/src/freedict/tools/testing/test-database.pl
/usr/src/freedict/tools/testing/test-lookupall.pl
/usr/src/freedict/tools/txt2wb.pl
/usr/src/freedict/tools/xdf2tei.pl
/usr/src/freedict/tools/xsl/getedition.xsl
/usr/src/freedict/tools/xsl/getsourceurl.xsl
/usr/src/freedict/tools/xsl/getstatus.xsl
/usr/src/freedict/tools/xsl/inc/indent.xsl
/usr/src/freedict/tools/xsl/inc/teientry2txt.xsl
/usr/src/freedict/tools/xsl/inc/teiheader2txt.xsl
/usr/src/freedict/tools/xsl/tei2bedic.xsl
/usr/src/freedict/tools/xsl/tei2c5-reverse.xsl
/usr/src/freedict/tools/xsl/tei2c5.xsl
/usr/src/freedict/tools/xsl/tei2dictxml.xsl
/usr/src/freedict/tools/xsl/tei2haali.xsl
/usr/src/freedict/tools/xsl/tei2htm.xsl
/usr/src/freedict/tools/xsl/tei2txt.xsl
/usr/src/freedict/tools/xsl/tei2vok.xsl
/usr/src/freedict/tools/xsl/tei2webster.xsl

%define date	%(echo `LC_ALL="C" date +"%a %b %d %Y"`)
%changelog
* %{date} Michael Bunk <micha@luetzschena.de>

* First rpm

