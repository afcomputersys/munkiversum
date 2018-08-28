<?php
# 3 Catalogs möglich: new, testing, production (könnte auch allgemein programmiert wreden)

$directory = 'pkgsinfo';
$scanned_directory = array_diff(scandir($directory), array('..', '.'));
foreach ($scanned_directory as $value) {
    $PlistFile = $value;
    $PlistFileShorten = preg_replace("/[^A-Za-z0-9]/", "", $PlistFile);
    if(!$xml=simplexml_load_file($directory.'/'.$PlistFile)) {
      echo 'unable to load XML file: '.$PlistFile; }
    else {
      $displayname = $xml->xpath('/plist/dict/key[text()="display_name"]/following-sibling::*[1]')[0];
      $version = $xml->xpath('/plist/dict/key[text()="version"]/following-sibling::*[1]')[0];
      if(isset($_POST['submit'.$PlistFileShorten])) {
        # Entfernt den Inhalt des Catalogs-Array
        unset($xml->xpath('/plist/dict/key[text()="catalogs"]/following-sibling::*[1]')[0]->string);
        $cat = $xml->xpath('/plist/dict/key[text()="catalogs"]/following-sibling::*[1]')[0];
        # macht Strings der ausgewählten Checkboxen am richtigen Ort mit der korrekten Nummerierung
        $a = 0;
        if(isset($_POST['new'])) {
          $cat->string[$a]=$_POST['new']; $a++; }
        if(isset($_POST['testing'])) {
          $cat->string[$a]=$_POST['testing']; $a++; }
        if(isset($_POST['production'])) {
          $cat->string[$a]=$_POST['production']; $a++; }
        #speichert das File zurück
        $xml->asXML($directory.'/'.$PlistFile); }
      else {
        $cat = $xml->xpath('/plist/dict/key[text()="catalogs"]/following-sibling::*[1]')[0]; }
    }
?>

<form method="post">
<table style="width: 100%">
  <tr>
    <td style="width: 20%">
    </td>
    <td style="width: 40%">
      <?php echo $displayname.' '.$version;?>
    </td>
    <td style="width: 40%">
      <input type="checkbox" name="new" value="new" <?php if (stripos(json_encode($cat),'new') !== false) {echo "checked";}?>> new ---
      <input type="checkbox" name="testing" value="testing" <?php if (stripos(json_encode($cat),'testing') !== false) {echo "checked";}?>> testing ---
      <input type="checkbox" name="production" value="production" <?php if (stripos(json_encode($cat),'production') !== false) {echo "checked";}?>> production ---
      <input type="submit" name="<?php echo 'submit'.$PlistFileShorten; ?>" value="submit"> <?php if(isset($_POST['submit'.$PlistFileShorten])) { echo '<font color="green">Kataloge aktualisiert</font>';}?>
    </td>
    <hr>
  </tr>
</table>
</form>

<?php
}
?>
