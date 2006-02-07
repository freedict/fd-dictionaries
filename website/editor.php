<?php
 include_once 'inc/gettext.php';
 include_once 'inc/links.php'
 ?>
<html>
<head>
 <title><?php echo _('FreeDict-Editor') ?></title>
 <META http-equiv="Content-Type" content="text/html;charset=utf-8">
 <link rel="stylesheet" type="text/css" href="<?php echo fdict_url('s.css') ?>">
</head>

<body>

<h1>FreeDict-Editor</h1>

<div style="float:right"><a href="http://xmlsoft.org/"><img align=center
  src="<?php echo fdict_url('images/Libxml2-Logo-180x168.gif') ?>" alt="libxml2" border=0 hspace=10></a></div>

<p><?php printf(_("The %sdocumentation%s coming with this application includes the list
of features in the %sintroduction%s."), '<a href="editordoc.html">', '</a>',
'<a href="editordoc.html#freedict-editor-introduction">', '</a>') ?></p>

<p><?php printf(_("No release of the FreeDict-Editor has been made yet.
You can do an anonymous check out the <tt>freedict-editor</tt>
module from %sCVS%s and try compiling it yourself:"),
'<a href="http://sourceforge.net/cvs/?group_id=1419">', '</a>') ?></p>

<blockquote><small><pre>cvs -d:pserver:anonymous@cvs.sourceforge.net:/cvsroot/freedict login
cvs -z3 -d:pserver:anonymous@cvs.sourceforge.net:/cvsroot/freedict co -P freedict-editor</pre></small></blockquote>

<p><?php printf(_("For the %srequirements%s, please also refer to the documentation."),
  '<a href="editordoc.html#freedict-editor-requirements">', '</a>') ?></p>
