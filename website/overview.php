<?php
 include 'inc/gettext.php';
 include 'inc/links.php'
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
 <title><?php echo _('Overview') ?> - FreeDict</title>
 <META http-equiv="Content-Type" content="text/html;charset=utf-8">
 <link rel="stylesheet" type="text/css" href="<?php echo fdict_url('s.css') ?>">
</head>

<body>

<h1>FreeDict - <?php echo _('free bilingual dictionaries') ?></h1>

<h2><?php printf(_('Horst Eyermann, Michael Bunk and %1$smany more%2$s'),
 '<a target="_top" href="http://sourceforge.net/project/memberlist.php?group_id=1419">',
 '</a>') ?></h2>

<p style="color: red"><?php echo _('This website is the successor of freedict.de. It is under development.
Some contents might be unavailable. In this case please send an email to the freedict-beta mailing list.') ?></p>

<p><?php echo _('On this page you find translating dictionary databases.
The databases are free. That means they are available
under the GNU General Public Licence or a less restrictive
licence. Check with the licence of the respective database!') ?></p>

<p><?php printf(_('The databases are available in XML. We support to use the
FreeDict databases with %1$sdictd, the DICT dictionary server%2$s and other
similar servers.'), '<A href="http://www.dict.org/" target="_parent">', '</a>') ?></p>

<p><?php echo _('But there are other applications for our databases as well. You could use
them to generate wordlists for spellcheckers and new dictionaries,
to build language corpora, to import them into your own terminological
database and even to print your own dictionary with XSL-FO.') ?></p>

<p><?php echo _('If you would like to see any other language included,
please read the HOWTO and join this project! Your help is appreciated
and needed, also for improving the quality of the databases.') ?></p>

<p><A href="http://sourceforge.net/" target="_parent">
<IMG src="http://sourceforge.net/sflogo.php?group_id=1419&amp;type=1" 
width="88" height="31" border="0" align="left" alt="SourceForge Logo"></A>
<?php echo _('Most resources are hosted by SourceForge:
Please support them also. Without SourceForge, FreeDict would
not have come so far!') ?></p>

<p><?php echo _('This project was started in 2000 by Horst Eyermann. The databases
are a compilation of various free sources. Please consult the
respective TEI headers, READMEs and 00-database-info entries.
The first databases were derived from Ergane.') ?></p>

<? require 'inc/footer.php';