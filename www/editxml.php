<?php

    if( ! $xml = simplexml_load_file('VLC-3.0.3.plist') )
    {
        echo 'unable to load XML file';
    }
    else
    {

      if(isset($_POST['submit'])) {
      $cat = $xml->xpath('/plist/dict/key[text()="catalogs"]/following-sibling::*[1]')[0];
      $cat->string[0]=$_POST['name'];
      $xml->asXML('VLC-3.0.3.plist');
      }

      echo 'XML file loaded successfully<br>';
      echo '-----------------------------------------------------------------<br>';
      print_r( $xml->xpath('/plist/dict/key[text()="catalogs"]/following-sibling::*[1]') );
      $cat = $xml->xpath('/plist/dict/key[text()="catalogs"]/following-sibling::*[1]');
      echo '<br>'.$cat[0]->string[0]; #testing
      echo '<br>'.$cat[0]->string[1]; # production
      echo '<br><br>';
      echo '<br><br>';


      echo '-----------------------------------------------------------------<br>';
      $i = 0;
      $cat = $xml->xpath('/plist/dict/key[text()="catalogs"]/following-sibling::*[1]')[0];
      foreach( $cat as $element)
          {
      echo 'CatalogsString '.$i.': '.($cat->string[$i]);
      echo '<br>-----------------------------------------------------------------<br>';
      $i++;
      }
      # $cat->string[0]='newElement'; # editiert ersten String

      $xml->asXML('VLC-3.0.3.plist');
    }
?>

<form method="post">
    <textarea name="name"><?php echo $cat->string[0] ?></textarea>
    <br>
    <input type="submit" name="submit" value="submit">
</form>
