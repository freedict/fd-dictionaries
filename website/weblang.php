<?php
include "inc/gettext.php";
include "inc/links.php";
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
 <title><?php echo _('Translate this Website') ?> - FreeDict</title>
 <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
 <link rel="stylesheet" type="text/css" href="<?php echo fdict_url('s.css') ?>" />
</head>

<body>

<h1><?php echo _('Translate this Website') ?></h1>


<p><?php echo _('To make this website available in another language,
please download the file below, add the translations for your language
below the English translations and email the file to
<a href="mailto:micha@luetzschena.de">micha@luetzschena.de</a>.') ?></p>

<p style="align: center"><a href="<?php echo fdict_url('freedict.pot') ?>">freedict.pot</a></p>

<p><?php echo _('If you want to update an existing translation, probably
because it leaves some part of the website untranslated, you can get the
<tt>.po</tt> file from CVS:') ?></p>

<blockquote><a href="http://freedict.cvs.sourceforge.net/viewvc/freedict/website/locale/">http://freedict.cvs.sourceforge.net/viewvc/freedict/website/locale/</a></blockquote>

<? require 'inc/footer.php';
