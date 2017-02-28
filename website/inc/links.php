<?php
 // options for this website
 // the only used option presently is 'staticlinks'
 // for generating links fit for generating the
 // php-less version of the freedict website
 global $XFreeDict;
 $XFreeDict = '';

 $headers = apache_request_headers();
 if(isset($headers['X-FreeDict']))
  $XFreeDict = $headers['X-FreeDict'];

 //echo "XFreeDict: $XFreeDict<br>";

 // adapts internal urls of the freedict website
 // to whether the php-less version is generated
 function fdict_url($url)
 {
  $splitted = preg_split('/\?/', $url, 2);
  $path = $splitted[0];
  $query = array_key_exists(1, $splitted) ? $splitted[1] : NULL;

  // split url
  $parts = pathinfo($path);

  // no dot for current dir
  if($parts["dirname"]=='.') $parts["dirname"] = '';
  // strip extension from basename
  if(strlen($parts["extension"]))
   $parts["basename"] = substr($parts["basename"], 0,
    -1-strlen($parts["extension"]));

  global $XFreeDict;
  if(strstr($XFreeDict,'staticlinks'))
  {

   // no php in this version
   if($parts["extension"]=='php') $parts["extension"] = 'html';

   // images are one level up
   if(strncmp($parts["dirname"], 'images', 6) == 0)
    $parts["dirname"] = '../' . $parts["dirname"];

   // so are stylesheets, xml files, and pot files
   if($parts["extension"]=='css' ||
      $parts["extension"]=='xml' ||
      $parts["extension"]=='pot')
    $parts["dirname"] = '..' . $parts["dirname"];

   $url = (strlen($parts["dirname"]) ? ($parts["dirname"] . '/') : '') .
          $parts["basename"] .
	  '.' . $parts["extension"];
  }
  else
  {
   $url = (strlen($parts["dirname"]) ? ($parts["dirname"] . '/') : '') .
   $parts["basename"];

   if($parts["extension"]=='svgz' ||
      $parts["extension"]=='png')
    $url .= '.' . $parts["extension"];

   if($query) $url .= "?$query";

  }

  return $url;
 }

?>
