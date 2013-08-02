<?php

require_once('manager.php');

if (isset($_POST['name']) && isset($_POST['password']) && is_string($_POST['name']) && is_string($_POST['password']))
{ // Login
	if (login($_POST['name'], $_POST['password']))
	{
		header("Location: index.php");
	}
	else
	{
		header("Location: index.php?loginfailed=1");
	}

	exit;
}
else if (isset($_GET['action']) && is_string($_GET['action']) && $_GET['action'] === 'logout')
{ // Logout
	if (logout())
	{
		header("Location: index.php");
	}

	exit;
}

include('html/header.php');

if (!is_logged_in())
{ // Login form
	include('html/login.php');
}
else
{ // Announcements
	include('html/announcements.php');
}

include('html/footer.php');

?>
