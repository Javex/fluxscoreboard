<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="content-type" content="text/html; charset=utf-8" />
		<meta http-equiv="X-UA-Compatible" content="IE=Edge" />
		<title>Hack.lu CTF 2012</title>
		<link href="favicon.ico" rel="icon" type="image/x-icon" />
		<link rel="stylesheet" type="text/css" href="css/blue/style.css" />
		<link rel="stylesheet" type="text/css" href="css/hacklu.css" />
		<!--[if IE]>
			<link rel="stylesheet" type="text/css" href="css/iefix.css" />
		<![endif]-->
		<script type="text/javascript" src="js/jquery-1.8.2.min.js"></script>
		<script type="text/javascript" src="js/jquery.metadata.js"></script>
		<script type="text/javascript" src="js/jquery.tablesorter.min.js"></script>
		<script type="text/javascript" src="js/hacklu.js"></script>

	</head>
	<body>
		<div id="cursorfix"></div>
		<div id="naviheader"></div>
		<ul id="navi">

<?php 
	if(isset($_SESSION['login']) && $_SESSION['login'])
	{
		echo '<li><a href="index.php">Announcements</a></li>';
		echo '<li><a href="scoreboard.php">Scoreboard</a></li>';
		echo '<li><a href="challenges.php">Challenges</a></li>';
		echo '<li><a href="submit.php">Submit</a></li>';
		echo '<li><a href="index.php?action=logout">Logout (' . htmlentities($_SESSION['team_name'], ENT_QUOTES, 'utf-8') . ')</a></li>';
	}
	else	
	{
		echo '<li><a href="index.php">Login</a></li>';	
		echo '<li><a href="scoreboard.php">Scoreboard</a></li>';	
		echo '<li><a href="http://2012.hack.lu/index.php/CaptureTheFlag">Help</a></li>';
	}
?>

		</ul>
		<div class="clear"></div>

		<div id="content">
