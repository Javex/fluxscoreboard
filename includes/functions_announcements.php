<?php

function insertAnnouncement($message)
{
	global $conn;

	if(empty($message) || !is_string($message))
		return "<span class=\"error\">Error: Wrong data.</span>";
		
	$message = mysql_real_escape_string($message);
		
	mysql_query("INSERT INTO news VALUES ('', CURRENT_TIMESTAMP(), '$message')", $conn);
	
	if(mysql_insert_id($conn))
		return '<span class="success">Announcement with ID '.mysql_insert_id($conn).' was successfully added.</span>';
	else	
		return "<span class=\"error\">Error: Could not insert new announcement.</span>";
}

function deleteAnnouncement($id)
{
	global $conn;

	if(empty($id) || !is_numeric($id))
		return "<span class=\"error\">Error: Wrong data.</span>";
	
	$id = (int)$id;
	
	mysql_query("DELETE FROM news WHERE id = $id", $conn);
	
	if(mysql_affected_rows($conn) == 1)
		return '<span class="success">Announcement with ID '.$id.' was successfully deleted.</span>';
	else	
		return "<span class=\"error\">Error: Could not delete announcement ID $id.</span>";
}

function get_announcements()
{
	global $conn;
	$news = array();

	$result =
		mysql_query
		(
			"SELECT
				news.id,
				news.timestamp,
				news.message
			FROM
				news
			ORDER BY
				news.timestamp DESC",
			$conn
		);

	if (mysql_num_rows($result) > 0)
	{
		while ($row = mysql_fetch_assoc($result))
		{
			$news[] = $row;
		}
	}

	return $news;
}

?>
