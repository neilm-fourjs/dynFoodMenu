IMPORT FGL debug
--------------------------------------------------------------------------------------------------------------
-- Load the style file based on the client:
-- gm.4st for Mobile ( GMA / GMI native )
-- gd.4st for GDC ( native )
-- gb.4st for GBC and Universal Rendering
FUNCTION loadStyles()
	DEFINE l_fe CHAR(2)
	DEFINE l_uaName STRING
	LET l_fe = DOWNSHIFT(ui.Interface.getFrontEndName())
	LET l_uaName = ui.Interface.getUniversalClientName()
	IF l_uaName.getLength() > 1 THEN LET l_fe = "gb" END IF -- switch GBC
	CALL debug.output(SFMT("Loaded styles from %1.4st",l_fe),FALSE)
	CALL ui.Interface.loadStyles(l_fe)
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION processing(l_str STRING, l_mode SMALLINT)
	IF l_mode = 1 THEN
		OPEN WINDOW processing WITH FORM "processing"
	END IF
	DISPLAY l_str TO msg
	IF l_mode = 3 THEN
		CLOSE WINDOW processing
	END IF
	CALL ui.Interface.refresh()
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION error(l_str STRING)
	--CALL fgl_winMessage("Error", l_str, "exclamation")
	CALL debug.output(SFMT("Error: %1",l_str), FALSE)
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION confirm(l_str STRING) RETURNS BOOLEAN
	IF fgl_winQuestion("Confirm",l_str,"Yes","Yes|No","question",1) = "Yes" THEN
		RETURN TRUE
	ELSE
		RETURN FALSE
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION abort()
	LET debug.m_showDebug = TRUE
	CALL debug.output(SFMT("Abort Status:%1\n%2", STATUS, SQLERRMESSAGE), TRUE)
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION exit_program()
	CALL debug.output("Finished", debug.m_showDebug)
	EXIT PROGRAM
END FUNCTION