<?php
 include 'inc/links.php';
 include 'inc/gettext.php'
?>
<html>
<head>
 <title><?php echo _('Data Flow') ?> - FreeDict</title>
 <META http-equiv="Content-Type" content="text/html;charset=utf-8">
 <link rel="stylesheet" type="text/css" href="<?php echo fdict_url('s.css') ?>">
</head>

<body>

<h1><?php echo _('Data Flow') ?></h1>

<a href="<?php echo fdict_url('images/dataflow.png') ?>" target="_top"><img
 src="<?php echo fdict_url('images/dataflow.png') ?>" width="100%" style="background-color: white"
border=0 alt="<?php printf("%2.0f", filesize('images/dataflow.png')/1024)
 ?> kB"></a>

[<a href="<?php echo fdict_url('images/dataflow.svgz') ?>" type="image/svg+xml">SVG Version</a>,
<?php printf("%2.0f", filesize('images/dataflow.svgz')/1024) ?> kB,
<?php echo _('possibly plugin needed, eg.') ?> 
<a href="http://www.adobe.com/svg/viewer/install/main.html"
target="_parent"><?php echo _("Adbobe's") ?></a>]

</body>
</html>
