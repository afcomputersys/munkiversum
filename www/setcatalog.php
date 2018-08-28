<html>
 <head>
  <title>PHP Test</title>
 </head>
 <body>

 <?php
### read
  $xml=simplexml_load_file('VLC-3.0.3.plist');
  # $cat=$xml->dict[0]->key[3];
  $cat=$xml->xpath('/plist/dict/key[text()="category"]/following-sibling::*[1]'); #https://stackoverflow.com/questions/35343505/can-you-use-simplexml-in-php-to-parse-plist-files

## write (direct without read)
  #$xml->xpath('/plist/dict/key[text()="category"]/following-sibling::*[1])') = 'Neuer Wert'; #http://www.nusphere.com/kb/phpmanual/ref.simplexml.htm?
  echo $xml->asXML('222.plist');
  echo '<p>Hello World</p>';
  var_dump($cat);
  echo '<br><br>';
  echo $cat[0];
  echo (string) "Wert: ".$cat[0];
 ?>

 </body>
</html>
