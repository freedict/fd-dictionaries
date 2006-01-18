<?php
include "inc/data.php";
include "inc/langcodes.php";
include "inc/gettext.php";
include "inc/links.php";
?>
<html>
<head>
 <title><?php echo _('Download / List View') ?> - FreeDict</title>
 <META http-equiv="Content-Type" content="text/html;charset=utf-8">
 <link rel="stylesheet" type="text/css" href="<?php echo fdict_url('s.css') ?>">
</head>

<body>

<h1><?php echo _('Detailed Dictionary Overview') ?></h1>

<table summary="Detailed Dictionary Overview">
 <tr bgcolor="#eeeeee">
  <th rowspan=2><?php echo _('Language &amp; Project') ?></th>
  <th rowspan=2><?php echo _('Maintainer') ?></th>
  <th rowspan=2><?php echo _('Headwords') ?></th>
  <th rowspan=2><?php echo _('Version') ?></th>
  <th rowspan=2><?php echo _('Last Changed') ?></th>
  <th rowspan=2><?php echo _('Status') ?></th>
  <th colspan=8><?php echo _('Version for / Size in MB') ?></th>
 </tr>
 <tr bgcolor="#dddddd">
  <th>dictd (tgz)</th>
  <th>dictd (bz2)</th>
  <th><small>evolutionary</small></th>
  <!-- th><small>mobi- pocket</small></th -->
  <th>zbedic</th>
  <th>StarDict</th>
  <th>rpm</th>
  <th>TEI XML</th>
  <th>src</th>
 </tr>

<?php

function cmp($a, $b)
{
  $na = $a->get_attribute('name');
  $nb = $b->get_attribute('name');
  if($na == $nb) return 0;
  return ($na < $nb) ? -1 : 1;
}

$ds = ($have_php5) ?
 $freedict_database->getElementsByTagName('dictionary') :
 $fddb_docel->get_elements_by_tagname('dictionary');

usort ($ds, "cmp");
foreach($ds as $d)
{
  list($l1, $l2) = split('-', $d->$get_attr('name'));

  $status = $d->$get_attr('status');  
  echo '<tr bgcolor="'. status2color($status) .'">';

  echo '<td>';
  $source = $d->$get_attr('sourceURL');
  if($source) echo '<a href="'. $source .'" target="_top">';
  echo _(langcode2english($l1)) .' -&gt; '. _(langcode2english($l2));
  if($source) echo '</a>';
  echo '</td>';
  
  $maintainer = $d->$get_attr('maintainerName');
  if($maintainer=='') $maintainer='-';
  echo '<td>'. $maintainer .'</td>';
  echo '<td align=right>'. $d->$get_attr('headwords') .'</td>';
  echo '<td>'. $d->$get_attr('edition') .'</td>';
  echo '<td>'. $d->$get_attr('date') .'</td>';
  echo '<td><small>'. $status .'</small></td>';

  foreach(array('dict-tgz', 'dict-tbz2', 'evolutionary', 'bedic', 'stardict', 'rpm', 'tei', 'src') as $platform)
  {
    linkcell($d, find_release($d, $platform), $platform);
  }

  echo '</tr>';
}

?>

</table>
<?php include 'inc/legend.php' ?>
