<?php
#if(isset($_POST['submit'])) {
#$xml=simplexml_load_file('VLC-3.0.3.plist');
#$xml->xpath('/plist/dict/key[text()="category"]/following-sibling::*[1]')=$_POST['name'];
#$handle=fopen("VLC-3.0.3.plist","wb");
#fwrite($handle,$xml->asXML('3333.plist'));
#fclose($handle);
#}

$xml=simplexml_load_file('VLC-3.0.3.plist');
echo $xml->xpath('/plist/dict/key[text()="category"]');
$welcome=$xml->xpath('/plist/dict/key[text()="category"]/following-sibling::*[1]');

?>

<form method="post">
    <textarea name="name"><?php echo $welcome ?></textarea>
    <br>
    <input type="submit" name="submit" value="submit">
</form>
