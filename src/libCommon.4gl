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