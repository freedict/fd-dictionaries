<?php
 include 'inc/gettext.php';
 include 'inc/links.php';
 $langparam = $content_language ? "?l=$content_language" : "";
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html>
<head>
 <meta NAME="Content-Language" CONTENT="<?php echo $content_language ?>">
 <META http-equiv="Content-Type" content="text/html;charset=utf-8">
 <link rel="stylesheet" type="text/css" href="<?php echo fdict_url('s.css') ?>">
 <link rel="alternate" type="application/rss+xml"
  href="http://sourceforge.net/export/rss2_projnews.php?group_id=1419&amp;rss_fulltext=1"
  title="FreeDict Project News at SourceForge">
 <title>FreeDict</title>
</head>
 
<frameset COLS="225,*" border=0>
  <frame NAME="menu" SRC="<?php echo fdict_url("menu.php$langparam") ?>" SCROLLING="auto" MARGINHEIGHT=1 marginwidth=3>
  <frame NAME="main" SRC="<?php echo fdict_url("overview.php$langparam") ?>" SCROLLING="AUTO" MARGINHEIGHT="5" marginwidth=5>

  <!-- frame NAME="right" SCROLLING="AUTO" MARGINHEIGHT="5" marginwidth=5 NORESIZE
   SRC="http://sourceforge.net/export/projnews.php?group_id=1419&amp;limit=5&amp;flat=1&amp;show_summaries=0" -->

  <noframes>
   <?php global $menu_nohead; $menu_nohead=1; include 'menu.php' ?>
  </noframes>
</frameset>
</html>
