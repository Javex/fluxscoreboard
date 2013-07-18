<?php

function calculate_hash($salt, $password)
{
	return hash('sha512', hash('sha512', $salt) . hash('sha512', $password));
}

function login($name, $password)
{
	global $conn;

	if (is_logged_in())
	{
		return false;
	}

	$result =
		mysql_query
		(
			"SELECT
				teams.tid,
				teams.name,
				teams.salt,
				teams.password
			FROM
				teams
			WHERE
				teams.name = '" . mysql_real_escape_string($name, $conn) . "'",
			$conn
		);

	if (mysql_num_rows($result) != 1)
	{
		return false;
	}

	$row = mysql_fetch_array($result);

	// Generate salted hash of password
	$hash = calculate_hash($row['salt'], $password);

	// Compare hash with the one in the database
	if ($hash !== $row['password'])
	{
		return false;
	}

	// Login successful
	session_regenerate_id();
	$_SESSION['login'] = true;
	$_SESSION['team_id'] = intval($row['tid']);
	$_SESSION['team_name'] = $row['name'];

	return true;
}

function logout()
{
	session_destroy();
	setcookie("PHPSESSID", NULL);

	return true;
}

function is_logged_in()
{
	return (isset($_SESSION["login"]) && ($_SESSION["login"] === true));
}

?>
