<?php

//error_reporting(0);

$Host     = '192.168.1.30';
$User     = 'hacklu';
$Password = 'ovWOikP8pQhIdU1FaO76';
$Database = 'hacklu';

$conn = mysql_connect($Host, $User, $Password) or die('Error: Can not connect to database. Scoreboard broken. Contact hacklu@fluxfingers.net!');
mysql_select_db($Database, $conn) or die('Error: Can not open database. Scoreboard broken. Contact hacklu@fluxfingers.net!');
mysql_set_charset('utf8', $conn); 


$Password = false;
	
?>
