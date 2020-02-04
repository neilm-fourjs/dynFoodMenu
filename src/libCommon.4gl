
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