
FUNCTION show()
	DEFINE l_ver STRING
	LET l_ver = SFMT("%1 %2", ui.Interface.getFrontEndName(), ui.Interface.getFrontEndVersion() )
	LET l_ver = l_ver.append(" UR:"||ui.Interface.getUniversalClientVersion() )
	CALL fgl_winMessage("Client Version", l_ver, "information")
END FUNCTION