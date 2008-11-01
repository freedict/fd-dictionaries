<?php

include "inc/gettext.php";
include "inc/links.php";

$platform = 'rock';


?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
 <title><?php echo _('Rock Linux Packages - FreeDict') ?></title>
 <META http-equiv="Content-Type" content="text/html;charset=utf-8">
 <link rel="stylesheet" type="text/css" href="<?php echo fdict_url('s.css') ?>">
</head>

<body>

<h1><?php echo _('Rock Linux Packages') ?></h1>

<p><?php printf(_('The %1$sRock Linux%2$s Distribution Build Kit includes a
dictd package as well as packages of the FreeDict dictionaries in the dictd
database format. For Rock 2.0, when dictd/FreeDict packages were not yet part
of the proper distribution, you have to get their .desc files from the
subversion repository and build the packages (which will install the files at
the same time):'),
  '<a href="http://rocklinux.org/" target="_top">', '</a>') ?></p>
 
  Get required desc files from svn:
  <pre>svn checkout <a href="https://www.rocklinux.net/svn/rock-linux/trunk/package/misc/dictd/">https://www.rocklinux.net/svn/rock-linux/trunk/package/misc/dictd/</a></pre>

  <pre>cd /usr/src/rock-src
./scripts/Download -package dictd
./scripts/Build-Pkg dictd</pre>
For Rock 2.1:
<pre>./scripts/Emerge-Pkg dictd
./scripts/Download -package freedict
./scripts/Build-Pkg freedict-<i>la1-la2</i></pre>

  <p><?php printf(_('Here %1$s and %2$s are the 3-letter language codes from
  ISO 639-2 of the languages of the dictionary you require. Of course, that
  language combination has to be available in FreeDict.'), '<i>la1</i>',
  '<i>la2</i>') ?></p>

  <p><?php echo _('Using the stone tool you can activate dictionaries for use
with dictd. The stone script is included in the dictd package, but was not included
in the 2.0 release of Rock Linux.') ?></p>

  <p><?php echo _('Please note that the project fork "t2" does not include any
    freedict-* packages.') ?></p>

<? require 'inc/footer.php';
