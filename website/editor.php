<?php
require_once "inc/gettext.php";
require_once "inc/links.php";
$title = _('FreeDict-Editor'); require_once 'inc/head.php';
?>
<body>

<h1>FreeDict-Editor</h1>

<div style="float:right"><a href="http://xmlsoft.org/"><img
  src="<?php echo fdict_url('images/Libxml2-Logo-180x168.gif') ?>" alt="libxml2" border="0" hspace="10" /></a></div>

<p style="color: red"><?php echo _("FreeDict-Editor is unmaintained!")?></p>

<p><?php printf(_("The %sdocumentation%s coming with this application includes the list
of features in the %sintroduction%s."), '<a href="editordoc.html">', '</a>',
'<a href="editordoc.html#freedict-editor-introduction">', '</a>') ?></p>

<p><?php printf(_("No release of the FreeDict-Editor has been made yet.
You can checkout the <tt>freedict-editor</tt>
directory from %sgit%s and try compiling it yourself:"),
'<a href="https://github.com/freedict/fd-dictionaries/tree/master/freedict-editor" target="_parent">', '</a>') ?></p>

<blockquote><pre>
git clone --depth=1 --no-checkout https://github.com/freedict/fd-dictionaries.git &amp;&amp; \
cd fd-dictionaries &amp;&amp; \
git --work-tree=`pwd` checkout HEAD -- freedict-editor
</pre></blockquote>

<p><?php printf(_("For the %srequirements%s, please also refer to the documentation."),
  '<a href="editordoc.html#freedict-editor-requirements">', '</a>') ?></p>

<p><?php printf(_("If you use %sDebian%s unstable, you can add this to your %s:"),
  '<a href="http://debian.org/" target="_parent">', '</a>', '<tt>/etc/apt/sources.list</tt>') ?></p>

<blockquote><small><tt>deb <a href="http://freedict.org/debian-repository">http://freedict.org/debian-repository</a> unstable main<br />
deb-src <a href="http://freedict.org/debian-repository">http://freedict.org/debian-repository</a> unstable main</tt></small></blockquote>

<? require_once 'inc/footer.php';
