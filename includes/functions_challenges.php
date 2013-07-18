<?php

function get_challenges()
{
	global $conn;
	$challenges = array();

	$result =
		mysql_query
		(
			"SELECT
				challenges.cid,
				challenges.title,
				challenges.points,
				challenges.status,
				challenges.manual,
				(
					SELECT
						COUNT(submissions.challid)
					FROM
						submissions
					WHERE
						submissions.challid = challenges.cid
				) AS solved
			FROM
				challenges
			ORDER BY
				challenges.cid",
			$conn
		);

	if (mysql_num_rows($result) > 0)
	{
		while ($row = mysql_fetch_assoc($result))
		{
			$challenges[] = $row;
		}
	}

	return $challenges;
}

function get_challenge($cid)
{
	global $conn;
	$challenges = array();

	$result =
		mysql_query
		(
			"SELECT
				challenges.cid,
				challenges.title,
				challenges.text,
				challenges.points,
				challenges.status,
				challenges.manual
			FROM
				challenges
			WHERE
				challenges.cid = '" . mysql_real_escape_string($cid, $conn) . "'
				AND challenges.status = 1
			LIMIT
				1",
			$conn
		);

	if (mysql_num_rows($result) === 1)
	{
		return mysql_fetch_assoc($result);
	}

	// Unknown challenge or offline
	return false;
}

function get_solved_challenges()
{
	global $conn;
	$challenges = array();

	if (is_logged_in())
	{
		$result =
			mysql_query
			(
				"SELECT
					submissions.challid
				FROM
					submissions
				WHERE
					submissions.teamid = '" . mysql_real_escape_string($_SESSION['team_id'], $conn) . "'",
				$conn
			);

		if (mysql_num_rows($result) > 0)
		{
			while ($row = mysql_fetch_assoc($result))
			{
				$challenges[$row['challid']] = true;
			}
		}
	}

	return $challenges;
}

function check_submission($cid, $solution)
{
	global $conn;

	if(DISABLE_SUBMISSION)
		return 'Error: Submission is disabled at the moment.';
	
	if(empty($cid))
		return 'Error: Challenge ID is empty.';
	
	if(empty($solution))
		return 'Error: solution is empty.';
		
	if(!is_numeric($cid) || !is_string($solution))
		return 'Error: No hacking.';
		
	$cid = (int)$cid;	
	$teamid = (int)$_SESSION['team_id'];
	$solution = mysql_real_escape_string(trim($solution), $conn);
	$cid = mysql_real_escape_string($cid);
	
	$correctcheck = mysql_query("SELECT points, status, manual FROM challenges WHERE cid = '$cid' AND solution = '$solution'", $conn);
	
	if(mysql_num_rows($correctcheck) <= 0)
		return 'Error: Wrong solution.';
	
	$info = mysql_fetch_array($correctcheck);
	
	if($info['status'] == 0)
		return 'Error: This challenge has been taken offline.';
		
	if($info['manual'] == 1)
		return 'Error: Credits for this challenge will be awarded manually.';	
	
	$points = $info['points'];
	
	$doublecheck = mysql_query("SELECT teamid FROM submissions WHERE challid = '$cid'", $conn);
	
	$solvers = 0;
		
	while ($row = mysql_fetch_array($doublecheck)) 
	{
		if($teamid == $row['teamid'])
			return 'Error: Already solved.';
		else
			$solvers++;
	}	
		
	if($solvers == 0)
	{
		$message = 'Congratulations: You solved this challenge as first!';
		$bonus = 3;
	}	
	else if($solvers == 1)
	{
		$message = 'Congratulations: You solved this challenge as second!';
		$bonus = 2;
	}	
	else if($solvers == 2)
	{
		$message = 'Congratulations: You solved this challenge as third!';
		$bonus = 1;
	}
	else
	{
		$message = 'Congratulations!';
		$bonus = 0;
	}	
	
	$insert = mysql_query("INSERT INTO submissions VALUES ('', '$teamid', '$cid', CURRENT_TIMESTAMP(), $bonus)", $conn);
	
	if(mysql_insert_id($conn))
	{
		$points = $points+$bonus;
		return $message . " Credits: " . $points;
	}	
	else	
		return 'Error: Submit function broken. Contact hacklu@fluxfingers.net!';  
}

function insertChallenge($title, $text, $solution, $points)
{
	global $conn;
	
	if(empty($title) || !is_string($title)
	|| empty($text) || !is_string($text)
	|| (!empty($solution) && !is_string($solution))
	|| (!empty($points) && !is_numeric($points)))
		return "<span class=\"error\">Error: Wrong data.</span>";
		
	if(empty($solution) || empty($points))
		$manual = 1;
	else
		$manual = 0;	
		
	$title = mysql_real_escape_string($title, $conn);
	$text = mysql_real_escape_string($text, $conn);
	$solution = mysql_real_escape_string($solution, $conn);
	$points = (int)$points;
	
	mysql_query("INSERT INTO challenges VALUES ('', '$title', '$text', '$solution', $points, 0, $manual)", $conn);
	
	if(mysql_insert_id($conn))
		return '<span class="success">Challenge with ID '.mysql_insert_id($conn).' was successfully added.</span>';
	else	
		return "<span class=\"error\">Error: Could not insert new challenge.</span>";
}

function updateChallenge($cid, $title, $text, $solution, $points)
{
	global $conn;

	if(empty($cid) || !is_numeric($cid)
	|| empty($title) || !is_string($title)
	|| empty($text) || !is_string($text)
	|| (!empty($solution) && !is_string($solution))
	|| (!empty($points) && !is_numeric($points)))
		return "<span class=\"error\">Error: Wrong data.</span>";
	
	if(empty($solution) || empty($points))
		$manual = 1;
	else
		$manual = 0;
	
	$cid = (int)$cid;
	$title = mysql_real_escape_string($title, $conn);
	$text = mysql_real_escape_string($text, $conn);
	$solution = mysql_real_escape_string($solution, $conn);
	$points = (int)$points;

	mysql_query("UPDATE challenges SET title = '$title', text = '$text', solution = '$solution', points = $points, manual = $manual WHERE cid = $cid", $conn);

	if(mysql_affected_rows($conn) == 1)
		return "<span class=\"success\">Challenge with ID $cid was successfully updated.</span>";
	else	
		return "<span class=\"error\">Error: Could not update challenge ID $cid.</span>";
}

function deleteChallenge($cid)
{
	global $conn;

	if(empty($cid) || !is_numeric($cid))
		return "<span class=\"error\">Error: Wrong data.</span>";
	
	$cid = (int)$cid;
	
	$delete = mysql_query("DELETE FROM submissions WHERE challid = $cid", $conn);
	
	if($delete)
	{
		mysql_query("DELETE FROM challenges WHERE cid = $cid", $conn);
		
		if(mysql_affected_rows($conn) == 1)
			return "<span class=\"success\">Challenge with ID $cid was successfully deleted from challenges and submissions.</span>";
		else	
			return "<span class=\"error\">Error: Could not delete challenge ID $cid.</span>";
	}
	else
	{
		return "<span class=\"error\">Error: Could not delete submissions for challenge ID $cid. Challenge ID $cid not deleted.</span>";
	}
}

function statusChallenge($cid, $status)
{
	global $conn;

	if(empty($cid) || !is_numeric($cid)
	|| !is_numeric($status) || $status > 1 || $status < 0 )
		return "<span class=\"error\">Error: Wrong data.</span>";
		
	$cid = (int)$cid;
	$status = (int)$status;
	$offon = ($status == 1) ? 'online' : 'offline';
	
	mysql_query("UPDATE challenges SET status = $status WHERE cid = $cid", $conn);
	
	if(mysql_affected_rows($conn) == 1)
		return "<span class=\"success\">Challenge with ID $cid is now $offon.</span>";
	else	
		return "<span class=\"error\">Error: Could not put challenge ID $cid $offon.</span>";
}

function insertSubmission($teamid, $challid, $bonus)
{
	global $conn;

	if(empty($teamid) || !is_numeric($teamid)
	|| empty($challid) || !is_numeric($challid))
		return "<span class=\"error\">Error: Wrong data.</span>";
		
	$teamid = (int)$teamid;
	$challid = (int)$challid;
	$bonus = (int)$bonus;
	
	$teamcheck = mysql_query("SELECT name FROM teams WHERE tid = $teamid");
	
	if(mysql_num_rows($teamcheck) <= 0)
		return "<span class=\"error\">Error: team id $teamid does not exist.</span>";
		
	$challengecheck = mysql_query("SELECT title FROM challenges WHERE cid = $challid");
	
	if(mysql_num_rows($challengecheck) <= 0)
		return "<span class=\"error\">Error: challenge id $challid does not exist.</span>";	
	
	mysql_query("INSERT INTO submissions VALUES ('', $teamid, $challid, CURRENT_TIMESTAMP(), $bonus)", $conn);
	
	if(mysql_insert_id($conn))
		return '<span class="success">Submission with ID '.mysql_insert_id($conn).' was successfully added.</span>';
	else	
		return "<span class=\"error\">Error: Could not insert new submission.</span>";
}

function updateSubmission($sid, $teamid, $challid, $timestamp, $bonus)
{
	global $conn;

	if(empty($sid) || !is_numeric($sid)
	|| empty($teamid) || !is_numeric($teamid)
	|| empty($challid) || !is_numeric($challid)
	|| empty($timestamp) || !is_string($timestamp))
		return "<span class=\"error\">Error: Wrong data.</span>";
	
	$sid = (int)$sid;
	$teamid = (int)$teamid;
	$challid = (int)$challid;
	$timestamp = mysql_real_escape_string($timestamp, $conn);
	$bonus = (int)$bonus;

	$teamcheck = mysql_query("SELECT name FROM teams WHERE tid = $teamid");
	
	if(mysql_num_rows($teamcheck) <= 0)
		return "<span class=\"error\">Error: team id $teamid does not exist.</span>";
		
	$challengecheck = mysql_query("SELECT title FROM challenges WHERE cid = $challid");
	
	if(mysql_num_rows($challengecheck) <= 0)
		return "<span class=\"error\">Error: challenge id $challid does not exist.</span>";
	
	mysql_query("UPDATE submissions SET teamid = $teamid, challid = $challid, timestamp = '$timestamp', bonus = $bonus WHERE sid = $sid", $conn);
	
	if(mysql_affected_rows($conn) == 1)
		return '<span class="success">Submission with ID '.$sid.' was successfully updated.</span>';
	else	
		return "<span class=\"error\">Error: Could not update submission ID $sid.</span>";
}

function deleteSubmission($sid)
{
	global $conn;

	if(empty($sid) || !is_numeric($sid))
		return "<span class=\"error\">Error: Wrong data.</span>";
	
	$sid = (int)$sid;
	
	mysql_query("DELETE FROM submissions WHERE sid = $sid", $conn);
	
	if(mysql_affected_rows($conn) == 1)
		return '<span class="success">Submission with ID '.$sid.' was successfully deleted.</span>';
	else	
		return "<span class=\"error\">Error: Could not delete submission ID $sid.</span>";
}

?>
