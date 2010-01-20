<?php
require_once "inc/gettext.php";
require_once "inc/links.php";
require_once "inc/langcodes.php";
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
<tt>.po</tt> file from SVN:') ?></p>

<blockquote><a href="http://freedict.svn.sourceforge.net/viewvc/freedict/trunk/website/locale/">http://freedict.svn.sourceforge.net/viewvc/freedict/trunk/website/locale/</a></blockquote>

<table summary="><?php echo _('Translation status for the website languages') ?>">
 <thead>
  <tr>
    <th><?php echo _('Language')?></th>
    <th><?php echo _('Status')?></th>
  </tr>
 </thead>
 <tbody>
  <?php
   global $langtag2locale, $content_language, $twoletters2threeletters;
   foreach($langtag2locale as $lt => $l)
   {
     $l3 = array_key_exists($lt, $twoletters2threeletters) ?
       $twoletters2threeletters[$lt] : $lt;
     echo '<tr><td>' .
          _(langcode2english($l3)) .
          '</td><td>'.
          `LANG=$l.utf8 msgfmt --statistics locale/$l/LC_MESSAGES/freedict.po -o /dev/null 2>&1`.
          '</td></tr>';
   }
   ?>
 </tbody>
</table>

<? require 'inc/footer.php';
