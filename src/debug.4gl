IMPORT os
DEFINE m_debugText STRING = "Debug:\n"
DEFINE m_winOpen BOOLEAN = FALSE
--------------------------------------------------------------------------------------------------------------
FUNCTION clear()
	IF os.path.exists("debug.log") THEN
		IF os.path.delete("debug.log") THEN
		END IF
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION output(l_str STRING, l_wait BOOLEAN)
	DEFINE c base.Channel
	LET c = base.Channel.create()
	CALL c.openFile("debug.log", "a+")
	LET l_str = SFMT("%1) %2", CURRENT, l_str)
	DISPLAY l_str
	CALL c.writeLine(l_str)
	CALL c.close()
	IF l_wait THEN
		CALL showDebug(l_str, l_wait)
	ELSE
		LET m_debugText = m_debugText.append(l_str || "\n")
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION showWinDebug()
	IF NOT m_winOpen THEN
		OPEN WINDOW debug WITH FORM "debug"
		LET m_winOpen = TRUE
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION closeWinDebug()
	IF m_winOpen THEN
		CLOSE WINDOW debug
		LET m_winOpen = FALSE
		CALL ui.interface.refresh()
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION showDebug(l_str STRING, l_wait STRING)
	CALL showWinDebug()
	LET m_debugText = m_debugText.append(l_str || "\n")
	DISPLAY m_debugText TO debugtext
	IF l_wait THEN
		MENU
			ON ACTION close
				EXIT MENU
		END MENU
	END IF
	CALL closeWinDebug()
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION showFile()
	DEFINE c base.Channel
	DEFINE l_str STRING
	LET c = base.Channel.create()
	CALL c.openFile("debug.log", "r")
	LET l_str = "Debug:\n"
	WHILE NOT c.isEof()
		LET l_str = l_str.append(c.readLine() || "\n")
	END WHILE
	CALL c.close()
	CALL showWinDebug()
	DISPLAY l_str TO debugtext
	MENU
		ON ACTION close
			EXIT MENU
	END MENU
	CALL closeWinDebug()
END FUNCTION
