<?php

function register_team($teamname, $password, $password_repeat, $email, $location)
{
	global $conn;

	if (empty($teamname))
	{
		return "Empty teamnames are not allowed. Please try again.";
	}

	if (empty($password))
	{
		return "Empty passwords are not allowed. Please try again.";
	}

	if ($password !== $password_repeat)
	{
		return "Your passwords do not match. Please try again.";
	}

	if (strlen( $password ) < 4)
	{
		return "Come on, your password should be longer. Try again.";
	}

	if (!filter_var($email, FILTER_VALIDATE_EMAIL))
	{
		return "Your email is not valid. Please try again.";
	}

	$result =
		mysql_query
		(
			"SELECT
				states.id
			FROM
				states
			WHERE
				states.id = '" . mysql_real_escape_string($location, $conn) . "'",
			$conn
		);

	if (mysql_num_rows($result) == 0)
	{
		return "This location does not exist.";
	}

	$result =
		mysql_query
		(
			"SELECT
				teams.tid
			FROM
				teams
			WHERE
				teams.name = '" . mysql_real_escape_string($teamname, $conn) . "'",
			$conn
		);

	if (mysql_num_rows($result) > 0)
	{
		return "This teamname is already taken.";
	}

	$result =
		mysql_query
		(
			"SELECT
				teams.tid
			FROM
				teams
			WHERE
				teams.email = '" . mysql_real_escape_string($email, $conn) . "'",
			$conn
		);

	if (mysql_num_rows($result) > 0)
	{
		return "This email is already taken.";
	}

	$salt = uniqid();
	$hash = calculate_hash($salt, $password);

	$result =
		mysql_query
		(
			"INSERT INTO
				teams
				(
					name,
					password,
					salt,
					email,
					state
				)
			VALUES
			(
				'" . mysql_real_escape_string($teamname, $conn) . "',
				'" . mysql_real_escape_string($hash, $conn) . "',
				'" . mysql_real_escape_string($salt, $conn) . "',
				'" . mysql_real_escape_string($email, $conn) . "',
				'" . mysql_real_escape_string($location, $conn) . "'
			)",
			$conn
		);
}

function get_states()
{
	global $conn;
	$states = array();

	$result =
		mysql_query
		(
			"SELECT
				states.id,
				states.name
			FROM
				states
			ORDER BY
				states.id ASC",
			$conn
		);

	if (mysql_num_rows($result) > 0)
	{
		while ($row = mysql_fetch_assoc($result))
		{
			$states[] = $row;
		}
	}

	return $states;
}

function update_team($tid, $teamname, $password, $email, $location)
{
	global $conn;

	if (empty($teamname))
	{
		return "Empty teamnames are not allowed. Please try again.";
	}

	$result =
		mysql_query
		(
			"SELECT
				states.id
			FROM
				states
			WHERE
				states.id = '" . mysql_real_escape_string($location, $conn) . "'",
			$conn
		);

	if (mysql_num_rows($result) == 0)
	{
		return "This location does not exist.";
	}

	if(empty($password))
	{
		$result =
			mysql_query
			(
				"UPDATE
					teams
				SET
					name = '" . mysql_real_escape_string($teamname, $conn) . "',
					email = '" . mysql_real_escape_string($email, $conn) . "',
					state = '" . mysql_real_escape_string($location, $conn) . "'
				WHERE
					tid = '" . mysql_real_escape_string($tid, $conn) . "'",
				$conn
			);	
	}
	else
	{
		$salt = uniqid();
		$hash = calculate_hash($salt, $password);

		$result =
			mysql_query
			(
				"UPDATE
					teams
				SET
					name = '" . mysql_real_escape_string($teamname, $conn) . "',
					password = '" . mysql_real_escape_string($hash, $conn) . "',
					salt = '" . mysql_real_escape_string($salt, $conn) . "',
					email = '" . mysql_real_escape_string($email, $conn) . "',
					state = '" . mysql_real_escape_string($location, $conn) . "'
				WHERE
					tid = '" . mysql_real_escape_string($tid, $conn) . "'",
				$conn
			);
	}
}

function delete_team($tid)
{
	global $conn;

	if (empty($tid) || !is_numeric($tid))
	{
		return "Error: Wrong data.";
	}
	
	mysql_query
	(
		"DELETE FROM
			teams
		WHERE
			tid = '" . mysql_real_escape_string($tid, $conn) . "'",
		$conn
	);
	
	if (mysql_affected_rows($conn) == 1)
	{
		return 'Team with ID ' . $tid . ' was successfully deleted.';
	}
	else
	{
		return "Error: Could not delete team ID " . htmlspecialchars($tid);
	}
}

function get_teams()
{
	global $conn;
	$teams = array();

	$result =
		mysql_query
		(
			"SELECT
				teams.tid,
				teams.local,
				teams.name AS teamname,
				(
					SELECT
						GROUP_CONCAT( CONCAT( submissions.challid, ':', submissions.bonus ) )
					FROM
						challenges, submissions
					WHERE
						submissions.teamid = teams.tid
						AND submissions.challid = challenges.cid
						AND challenges.status = 1
				) AS solved,
				(
					SELECT
						COALESCE( SUM( challenges.points ), 0 ) + COALESCE( SUM( submissions.bonus ), 0 )
					FROM
						challenges, submissions
					WHERE
						submissions.teamid = teams.tid
						AND submissions.challid = challenges.cid
						AND challenges.status = 1
				) AS score,
				states.name AS state
			FROM
				teams
			JOIN
				states
			ON
				teams.state = states.id

			ORDER BY
				score DESC,
				teamname ASC",
			$conn
		);

	if (mysql_num_rows($result) > 0)
	{
		$current['rank'] = 1;
		$current['score'] = -1;

		while ($row = mysql_fetch_assoc($result))
		{
			// Determine the rank of the team
			if ($current['score'] < 0)
			{
				$current['score'] = $row['score'];
			}

			if ($row['score'] < $current['score'])
			{
				$current['score'] = $row['score'];
				$current['rank']++;
			}

			$row['rank'] = $current['rank'];

			// Save the solved challenges in a format that is easy to use (cid -> bonus)
			$solved = array();
			$tmp_solved1 = explode(',', $row['solved']);

			foreach($tmp_solved1 as $tmp_solved2)
			{
				// Skip when empty
				if (empty($tmp_solved2))
				{
					continue;
				}

				$tmp_solved3 = explode(':', $tmp_solved2);

				if ($tmp_solved3 !== false)
				{
					$solved[$tmp_solved3[0]] = $tmp_solved3[1];
				}
			}

			$row['solved'] = $solved;

			// Append data to output array
			$teams[] = $row;
		}
	}

	return $teams;
}

function get_team($tid)
{
	global $conn;

	$result =
		mysql_query
		(
			"SELECT
				teams.tid,
				teams.name AS teamname,
				teams.email,
				teams.state,
				teams.local
			FROM
				teams
			WHERE
				teams.tid = '" . mysql_real_escape_string($tid, $conn) . "'",
			$conn
		);

	if (mysql_num_rows($result) === 1)
	{
		return mysql_fetch_assoc($result);
	}
	else
	{
		exit('unknown team');
	}
}

?>
