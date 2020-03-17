
IMPORT FGL debug

DEFINE m_host STRING

FUNCTION ws_ProcessServices_stat( l_stat INT ) RETURNS BOOLEAN
	CASE l_stat
		WHEN 0
			CALL debug.output("Request processed.",FALSE)
		WHEN -1
			CALL debug.output("Timeout reached.",FALSE)
		WHEN -2
			CALL debug.output("Disconnected from application server.",FALSE)
			RETURN FALSE
		WHEN -3
			CALL debug.output("Client Connection lost.",FALSE)
		WHEN -4
			CALL debug.output("Server interrupted with Ctrl-C.",FALSE)
		WHEN -5
			CALL debug.output(SFMT("BadHTTPHeader: %1",SQLCA.SQLERRM),  FALSE)
		WHEN -9
			CALL debug.output("Unsupported operation.",FALSE)
		WHEN -10
			CALL debug.output("Internal server error.",FALSE)
		WHEN -23
			CALL debug.output("Deserialization error.",FALSE)
		WHEN -35
			CALL debug.output("No such REST operation found.",FALSE)
		WHEN -36
			CALL debug.output("Missing REST parameter.",FALSE)
		OTHERWISE
			CALL debug.output("Unexpected server error " || l_stat || ".",FALSE)
			RETURN FALSE
	END CASE
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION getHostName()
	DEFINE c base.Channel
	DEFINE l_host STRING
	IF m_host.getLength() > 1 THEN RETURN m_host END IF
	LET l_host = fgl_getEnv("HOSTNAME")
	IF l_host.getLength() < 2 THEN
		LET c = base.Channel.create()
		CALL c.openPipe("hostname -f","r")
		LET l_host = c.readLine()
		CALL c.close()
	END IF
	IF l_host.getLength() < 2 THEN LET l_host = "Unknown!" END IF
	LET m_host = l_host
	RETURN l_host
END FUNCTION
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
FUNCTION checkToken( l_token STRING ) RETURNS BOOLEAN
	IF l_token.getLength() < 10 THEN RETURN FALSE END IF
--TODO: actually check the token
	RETURN TRUE
END FUNCTION