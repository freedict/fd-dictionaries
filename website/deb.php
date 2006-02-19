<?php
include "inc/gettext.php";
include "inc/links.php";
$platform = 'deb';
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
 <title><?php echo _('Debian Packages - FreeDict') ?></title>
 <META http-equiv="Content-Type" content="text/html;charset=utf-8">
 <link rel="stylesheet" type="text/css" href="<?php echo fdict_url('s.css') ?>">
</head>

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
  
  <blockquote><p><a href="http://packages.debian.org/testing/text/dict-freedict"
  target="_top">http://packages.debian.org/testing/text/dict-freedict</a></p></blockquote>
  
  <p><?php printf(_('The %1$sFreeDict pages in the
  Debian Bug Tracking System%2$s might also be of interest.'),
  '<a href="http://bugs.debian.org/cgi-bin/pkgreport.cgi?src=freedict" target="_top">',
  '</a>') ?></p>
