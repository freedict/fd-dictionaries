<?php
 include 'inc/gettext.php';
 include 'inc/links.php';
 $langparam = $content_language ? "?l=$content_language" : "";
?>
<!DOCTYPE html
     PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
 <meta name="Content-Language" content="<?php echo $content_language ?>" />
 <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
 <link rel="stylesheet" type="text/css" href="<?php echo fdict_url('s.css') ?>" />
 <link rel="alternate" type="application/rss+xml"
  href="http://sourceforge.net/export/rss2_projnews.php?group_id=1419&amp;rss_fulltext=1"
  title="FreeDict Project News at SourceForge" />
 <title>FreeDict</title>
</head>

<frameset cols="225,*">
  <frame name="menu" src="<?php echo fdict_url("menu.php$langparam") ?>" scrolling="auto" marginheight="1" marginwidth="3" />
  <frame name="main" src="<?php echo fdict_url("overview.php$langparam") ?>" scrolling="auto" marginheight="5" marginwidth="5" />


  <noframes>
   <?php global $menu_nohead; $menu_nohead=1; include 'menu.php' ?>
  </noframes>
</frameset>
</html>
