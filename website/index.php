<?php
 include 'inc/gettext.php';
 include 'inc/links.php';
 $langparam = $content_language ? "?l=$content_language" : "";
?>

<html>
<head>
 <meta NAME="Content-Language" CONTENT="<?php echo $content_language ?>">
 <META http-equiv="Content-Type" content="text/html;charset=utf-8">
 <link rel="stylesheet" type="text/css" href="<?php echo fdict_url('s.css') ?>">
 <link rel="alternate" type="application/rss+xml"
  href="http://sourceforge.net/export/rss2_projnews.php?group_id=1419&rss_fulltext=1"
  title="FreeDict Project News at SourceForge">
 <title>FreeDict</title>
</head>
 
<frameset COLS="225,*" border=0>
  <frame NAME="menu" SRC="<?php echo fdict_url("menu.php$langparam") ?>" SCROLLING="auto" MARGINHEIGHT=1 marginwidth=3>
  <frame NAME="main" SRC="<?php echo fdict_url("overview.php$langparam") ?>" SCROLLING="AUTO" MARGINHEIGHT="5" marginwidth=5>

  <!-- frame NAME="right" SCROLLING="AUTO" MARGINHEIGHT="5" marginwidth=5 NORESIZE
   SRC="http://sourceforge.net/export/projnews.php?group_id=1419&limit=5&flat=1&show_summaries=0" -->

  <noframes>
   <?php global $menu_nohead; $menu_nohead=1; include 'menu.php' ?>
  </noframes>
</frameset>
</html>
