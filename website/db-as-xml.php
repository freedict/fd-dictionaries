<?php
require_once "inc/gettext.php";
require_once "inc/links.php";
$title = _('Database as XML'); require_once 'inc/head.php';
?>
<body>

<h1><?php echo _('Database as XML') ?></h1>


<p><?php echo _('The Download Tables are generated from an XML file.
To access that data easily, eg. for use in a program as
<a href="http://stardict.sf.net/" target="_top">Stardict</a>, you can use this URL:') ?></p>

<p style="align: center"><a href="<?php echo fdict_url('freedict-database.xml') ?>">freedict-database.xml</a></p>

<? require_once 'inc/footer.php';
