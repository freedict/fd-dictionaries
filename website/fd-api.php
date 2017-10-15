<?php
require_once "inc/gettext.php";
require_once "inc/links.php";
$title = _('FreeDict JSON/XML API'); require_once 'inc/head.php';
?>
<body>

<h1><?php echo _('FreeDict JSON/XML API') ?></h1>


<p><?php echo _('The FreeDict Project offers a statically updated API to query
information about dictionaries and to retrieve them. Furthermore, the API is
used by the web site to generate the download tables.
The documentation is in the <a href="https://github.com/freedict/fd-dictionaries/wiki/FreeDict-API">wiki</a>.') ?> <p>

<p><?php echo _('To access the data easily, eg. for use in a program as
<a href="http://stardict.sf.net/" target="_top">Stardict</a>, you can use this URL:') ?></p>

<p style="align: center"><a href="<?php echo fdict_url('freedict-database.xml') ?>">freedict-database.xml</a></p>

<? require_once 'inc/footer.php';
