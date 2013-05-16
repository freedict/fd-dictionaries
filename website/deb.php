<?php
require_once "inc/gettext.php";
require_once "inc/links.php";
$title = _('Debian Packages'); require_once 'inc/head.php';
$platform = 'deb';
?>
<body>

<h1><?php echo _('Debian Packages') ?></h1>

<p><?php printf(_('The %1$sDebian%2$s Linux Distribution has its own system
  of download mirrors. Since as administrator you are not so much concerned
  to download the packages, but rather to select the packages you want to
  install, only the following command is what you have to remember:'),
  '<a href="http://debian.org/" target="_top">', '</a>') ?></p>

  <pre>apt-get install dict-freedict-<i>la1-la2</i></pre>

  <p><?php printf(_('Here %1$s and %2$s are the 3-letter language codes from
  ISO 639-2 of the languages of the dictionary you require. Of course, that
  language combination has to be available in FreeDict.'), '<i>la1</i>',
  '<i>la2</i>') ?></p>

  <p><?php echo _('You can find out what FreeDict packages are available in
  Debian by visiting') ?></p>

  <blockquote><p><a href="http://packages.debian.org/source/freedict"
  target="_top">http://packages.debian.org/source/freedict</a></p></blockquote>

  <p><?php printf(_('The %1$sFreeDict pages in the
  Debian Bug Tracking System%2$s might also be of interest.'),
  '<a href="http://bugs.debian.org/cgi-bin/pkgreport.cgi?src=freedict" target="_top">',
  '</a>') ?></p>

  <p><?php printf(_('This page might as well be of interest: %1$sDebian FreeDict Packages team%2$s.'),
  '<a href="http://wiki.debian.org/freedict" target="_top">',
  '</a>') ?></p>

<? require_once 'inc/footer.php';
