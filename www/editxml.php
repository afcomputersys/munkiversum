<?php
# 3 Catalogs möglich: new, testing, production

$PlistFile = 'VLC-3.0.3.plist';

    if( ! $xml = simplexml_load_file($PlistFile) )
    {
        echo 'unable to load XML file';
    }
    else
    {
      if(isset($_POST['submit'])) {
      # Entfernt den Inhalt des Catalogs-Array
      unset($xml->xpath('/plist/dict/key[text()="catalogs"]/following-sibling::*[1]')[0]->string);
      $cat = $xml->xpath('/plist/dict/key[text()="catalogs"]/following-sibling::*[1]')[0];
        $a = 0;
        if(isset($_POST['new'])) {
          $cat->string[$a]=$_POST['new']; $a++;}
        if(isset($_POST['testing'])) {
          $cat->string[$a]=$_POST['testing']; $a++;}
        if(isset($_POST['production'])) {
          $cat->string[$a]=$_POST['production']; $a++;}
        $xml->asXML($PlistFile); #speichert das File zurück
      }

      echo 'XML file loaded successfully<br>';
      echo '-----------------------------------------------------------------<br>';
      $cat = $xml->xpath('/plist/dict/key[text()="catalogs"]/following-sibling::*[1]')[0];
      print_r( $cat );
      echo '<br>-----------------------------------------------------------------<br>';
      echo '<br><br>';


      $i = 0;
      $cat = $xml->xpath('/plist/dict/key[text()="catalogs"]/following-sibling::*[1]')[0];
      # echo '<br>'.$cat[0]->string[0]; # testing
      # echo '<br>'.$cat[0]->string[1]; # production
      echo '-----------------------------------------------------------------<br>';
      foreach( $cat as $element)
      {
      echo 'CatalogsString '.$i.': '.($cat->string[$i]);
      echo '<br>-----------------------------------------------------------------<br>';
      $i++;
      }
      # $cat->string[0]='newElement'; # editiert ersten String
      $displayname = $xml->xpath('/plist/dict/key[text()="display_name"]/following-sibling::*[1]')[0];
    }
?>



<form method="post">
    <?php echo 'DisplayName: '.$displayname.'<br>';?>
    <input type="checkbox" name="new" value="new" <?php if (stripos(json_encode($cat),'new') !== false) {echo "checked";}?>> new<br>
    <input type="checkbox" name="testing" value="testing" <?php if (stripos(json_encode($cat),'testing') !== false) {echo "checked";}?>> testing<br>
    <input type="checkbox" name="production" value="production" <?php if (stripos(json_encode($cat),'production') !== false) {echo "checked";}?>> production<br>
    <br>
    <input type="submit" name="submit" value="submit">
</form>
