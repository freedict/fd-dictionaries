<?php
  global $SKIP_SETLOCALE;
  $SKIP_SETLOCALE = true;
  include 'inc/gettext.php';

  global $content_language;

  // let the GET parameter override the Accept-Language header
  if($_GET['l']) $content_language=$_GET['l'];

  header("Location: $content_language");
?>
