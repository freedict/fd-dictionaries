<?php
require_once 'inc/links.php';
require_once 'inc/gettext.php';
$title = _('Overview'); require_once 'inc/head.php';
?>
<body>

<h1>FreeDict - <?php echo _('free bilingual dictionaries') ?></h1>

<h2><?php printf(_('Horst Eyermann, Michael Bunk and %1$smany more%2$s'),
 '<a target="_top" href="http://sourceforge.net/project/memberlist.php?group_id=1419">',
 '</a>') ?></h2>

<p><?php echo _('On this page you can find translation dictionary databases.
The databases are free. That means they are available
under a free license like the GNU GPL or similar. Please check with the respective dictionary.') ?></p>

<p><?php printf(_('The databases are available in TEI, a XML language to encode human language. This way the dictionaries can be used both by humans and machines.
We support the conversion of FreeDict databases from their native %4$sTEI%2$s
format for use with %1$sdictd, the DICT dictionary server%2$s and other
similar servers. Our own online dictionary lookup page can be found at %3$shttp://freedict.org/dict%2$s. Please note that
you can also install a plugin on that page which will let you query FreeDict dictionaries straight from your
browser search window.'), '<a href="http://www.dict.org/w/" target="_parent">', '</a>',
'<a href="http://freedict.org/dict" target="_top">', '<a href="http://www.tei-c.org/" target="_top">') ?></p>

<p><?php echo _('There are other applications for our databases as well. It is
possible to use them to generate wordlists for spellcheckers and to create new dictionaries, to import them 
into your own terminological database and even to print your own dictionary with XSL-FO.') ?></p>

<p><?php echo _('If you would like to see any other language included,
please read the HOWTO and join this project! Your help is appreciated
and needed, also for improving the quality of the databases.') ?></p>

<p><a href="http://sourceforge.net/" target="_parent">
<img src="http://sourceforge.net/sflogo.php?group_id=1419&amp;type=1"
width="88" height="31" border="0" align="left" alt="SourceForge Logo" /></a>
<?php echo _('Most resources are hosted by SourceForge:
Please support them also. Without SourceForge, FreeDict would
not have come so far!') ?></p>

<h2><?php echo _('History') ?></p>
<p><?php echo _('This project was started in 2000 by Horst Eyermann. 
The first databases were derived from Ergane.
Since then, FreeDict has much evolved and now offers both imported and hand-crafted dictionaries in various sizes.
With the switch to TEI P5 in 2010, the project uses a comprehensive standard to encode human speech. This format also allows for the usage of the dictionaries in yet unforeseen use case scenario's, because it decouples from the actual output format.') ?></p>

<!-- TODO: document michael's work

TODO: Piotr
-->

<!-- where to put this:
The databases
are a compilation of various free sources. Please consult the
respective TEI headers, READMEs and 00-database-info entries.
-->

<? require_once 'inc/footer.php';
