<?php
require_once "inc/gettext.php";
require_once "inc/links.php";
$title = _('FreeDict-Editor'); require_once 'inc/head.php';
?>
<body>

<h1>FreeDict-Editor</h1>

<div style="float:right"><a href="http://xmlsoft.org/"><img
  src="<?php echo fdict_url('images/Libxml2-Logo-180x168.gif') ?>" alt="libxml2" border="0" hspace="10" /></a></div>

<p><?php printf(_("The %sdocumentation%s coming with this application includes the list
of features in the %sintroduction%s."), '<a href="editordoc.html">', '</a>',
'<a href="editordoc.html#freedict-editor-introduction">', '</a>') ?></p>

<p><?php printf(_("No release of the FreeDict-Editor has been made yet.
You can do an anonymous check out the <tt>freedict-editor</tt>
module from %sSVN%s and try compiling it yourself:"),
'<a href="http://sourceforge.net/scm/?type=svn&amp;group_id=1419">', '</a>') ?></p>

<blockquote cite="http://sourceforge.net/scm/?type=svn&amp;group_id=1419">
  <small><tt>svn co <a href="https://freedict.svn.sourceforge.net/svnroot/freedict/trunk/freedict-editor">https://freedict.svn.sourceforge.net/svnroot/freedict/trunk/freedict-editor</a> freedict-editor</tt></small>
</blockquote>

<p><?php printf(_("For the %srequirements%s, please also refer to the documentation."),
  '<a href="editordoc.html#freedict-editor-requirements">', '</a>') ?></p>

<p><?php printf(_("If you use %sDebian%s etch or unstable, you can add this to your %s (replace <i>etch</i> by <i>unstable</i> if you use unstable):"),
  '<a href="http://debian.org/">', '</a>', '<tt>/etc/apt/sources.list</tt>') ?></p>

<blockquote><small><tt>deb <a href="http://freedict.org/debian-repository">http://freedict.org/debian-repository</a> etch main<br />
deb-src <a href="http://freedict.org/debian-repository">http://freedict.org/debian-repository</a> etch main</tt></small></blockquote>

<? require_once 'inc/footer.php';
