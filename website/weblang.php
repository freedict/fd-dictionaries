<?php
include "inc/gettext.php";
include "inc/links.php";
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
 <title><?php echo _('Translate this Website') ?> - FreeDict</title>
 <META http-equiv="Content-Type" content="text/html;charset=utf-8">
 <link rel="stylesheet" type="text/css" href="<?php echo fdict_url('s.css') ?>">
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
<tt>.mo</tt> file from CVS:') ?></p>

<blockquote><a href="http://cvs.sourceforge.net/viewcvs.py/freedict/website/locale/">http://cvs.sourceforge.net/viewcvs.py/freedict/website/locale/</a></blockquote>
