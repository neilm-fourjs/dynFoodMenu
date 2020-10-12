
IMPORT os
IMPORT FGL config

&define USEFILE
DEFINE m_debugText STRING = "Debug:\n"
DEFINE m_winOpen BOOLEAN = FALSE
PUBLIC DEFINE m_showDebug BOOLEAN = FALSE
DEFINE m_logFile STRING
--------------------------------------------------------------------------------------------------------------
FUNCTION clear()
	IF os.path.exists(m_logFile) THEN
		IF os.path.delete(m_logFile) THEN
		END IF
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION init_debug( l_logDir STRING, l_logFile STRING )
	DEFINE l_config config
	IF l_logDir IS NULL THEN
		IF l_config.initConfigFile(NULL) THEN
			LET l_logDir = l_config.logDir
			LET l_logFile = l_config.logFile
		END IF
	END IF
	IF l_logDir IS NULL THEN LET l_logDir = "." END IF
	IF l_logFile IS NULL THEN LET l_logFile = base.Application.getProgramName()||".log" END IF
	LET m_logFile = os.path.join(l_logDir,l_logFile)
	DISPLAY SFMT("debug log file is '%1'", m_logFile)
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION output(l_str STRING, l_wait BOOLEAN)
	DEFINE c base.Channel
	LET l_str = SFMT("%1:%2) %3", CURRENT, fgl_getPid(), l_str)
&ifdef USEFILE
	IF m_logFile IS NULL THEN CALL init_debug(NULL,NULL) END IF
	LET c = base.Channel.create()
	CALL c.openFile(m_logFile, "a+")
	CALL c.writeLine(l_str)
	CALL c.close()
&endif
	DISPLAY l_str
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
	IF m_logFile IS NULL THEN CALL init_debug(NULL,NULL) END IF
	CALL c.openFile(m_logFile, "r")
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
