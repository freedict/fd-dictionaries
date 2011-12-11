<?php
require_once 'inc/links.php';
require_once 'inc/gettext.php';

 global $menu_nohead;
 if(!isset($menu_nohead))
 { $title = _('Menu'); require_once 'inc/head.php'; }
?>
<body>
<table cellspacing="1" cellpadding="0" summary="<?php echo _('Menu') ?>">

<tr><td align="center"><img src="<?php echo fdict_url('images/freedict.gif') ?>" alt="FreeDict Logo" /></td></tr>

<tr><td class="menu"><?php
 global $XFreeDict;
 if(strstr($XFreeDict,'staticlinks')) { echo languagemenu(); }
 ?></td></tr>

<tr><td class="menu"><a href="<?php echo fdict_url('overview.php') ?>" target="main"><?php echo _('Overview') ?></a></td></tr>
<tr><td class="menu"><a href="<?php echo fdict_url('dataflow.php') ?>" target="main"><?php echo _('Data Flow') ?></a></td></tr>

<tr><td class="menuNObg" align="center"><?php echo _('Download databases') ?>:<br/>
 <table style="font-size: 9;" width="95%" cellspacing="1" summary="Choose Platform">
  <tr style="background-color:#eeeeee">
   <th><?php echo _('Platform') ?></th>
   <th><?php echo _('Application') ?></th>
  </tr>

  <tr style="background-color: #f0f0f0">
   <td><?php echo _('Windows &amp; Linux') ?></td>
   <td><a href="<?php echo fdict_url('flags-dict-tgz.php') ?>" target="main"><?php echo _('DICT servers (tgz)') ?></a></td>
  </tr>

  <tr style="background-color: #f0f0f0">
   <td><a href="<?php echo fdict_url('deb.php') ?>" target="main"><?php echo _('Debian Linux') ?></a></td>
   <td><?php echo _('dictd') ?></td>
  </tr>

  <tr style="background-color: #f0f0f0">
   <td><?php echo _('WinCE &amp; Palm') ?></td>
   <td>
<!--
    <a href="<?php echo fdict_url('flags-mobipocket.php') ?>" target="main">Mobipocket</a><br>
  -->
    <a href="<?php echo fdict_url('flags-evolutionary.php') ?>" target="main">Evolutionary Dictionary</a>
   </td>
  </tr>

  <tr style="background-color: #f0f0f0">
   <td>Zaurus/Qt</td>
   <td><a href="<?php echo fdict_url('flags-bedic.php') ?>" target="main">BEDic</a></td>
  </tr>

  <tr style="background-color: #f0f0f0"><td colspan="2" align="center">
   <a href="<?php echo fdict_url('list.php') ?>" target="main"><?php echo _('Detailed List') ?></a>
  </td></tr>

 </table>
</td></tr>


<tr><td class="menu">
 <a href="http://luetzschena-stahmeln.de/dictd/index.php?freedictonly"
  target="_top"><?php echo _('FreeDict Online Servers') ?></a>
</td></tr>

<tr><td class="menu">
 <a href="<?php echo fdict_url('editor.php') ?>" target="main">FreeDict-Editor</a>
</td></tr>

<tr><td class="menu">
 <a href="http://apps.sourceforge.net/mediawiki/freedict/index.php?title=FreeDict_HOWTO_-_TOC" target="_parent">HOWTO</a>
</td></tr>

<tr><td class="menu"><a href="http://sourceforge.net/projects/freedict/"
 target="_parent"><?php echo _('SourceForge Project Page') ?></a></td></tr>
<tr><td class="menu"><ul>
 <li><small><a href="http://sourceforge.net/scm/?type=svn&amp;group_id=1419"
  target="_parent">SVN</a><br /></small></li>
 <li><small><a href="http://sourceforge.net/mail/?group_id=1419"
  target="_parent"><?php echo _('Mailinglists') ?></a><br /></small></li>
 <li><small><a href="http://sourceforge.net/tracker/?group_id=1419&amp;atid=101419"
  target="_parent"><?php echo _('Bugs') ?></a><br /></small></li>
 <li><small><a href="http://apps.sourceforge.net/mediawiki/freedict/index.php?title=Main_Page"
  target="_parent"><?php echo _('Wiki') ?></a><br /></small></li>
</ul></td>
</tr>
<tr><td class="menu"><a href="<?php echo fdict_url('weblang.php') ?>" target="main"><?php echo _('Translate this Website') ?></a></td></tr>
<tr><td class="menu"><a href="<?php echo fdict_url('db-as-xml.php') ?>" target="main"><?php echo _('Database as XML') ?></a>
</td></tr>

<tr><td class="menuNObg" align="center">
 &copy; 2004-<?=date('Y')?> <?php echo _('FreeDict Project') ?>
</td></tr>
</table></body>
<?php
 if(!isset($menu_nohead))
 { echo '</html>'; }
?>
