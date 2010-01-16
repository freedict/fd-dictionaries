<?php
include "inc/gettext.php";
include "inc/links.php";
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
 <title><?php echo _('Database as XML') ?> - FreeDict</title>
 <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
 <link rel="stylesheet" type="text/css" href="<?php echo fdict_url('s.css') ?>" />
</head>

<body>

<h1><?php echo _('Database as XML') ?></h1>


<p><?php echo _('The Download Tables are generated from an XML file.
To access that data easily, eg. for use in a program as
<a href="http://stardict.sf.net/" target="_top">Stardict</a>, you can use this URL:') ?></p>

<p style="align: center"><a href="<?php echo fdict_url('freedict-database.xml') ?>">freedict-database.xml</a></p>

<? require 'inc/footer.php';
