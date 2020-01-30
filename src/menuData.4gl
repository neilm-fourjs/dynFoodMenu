-- Module for mananging the menu data
-- TODO: Get data from a web service
IMPORT util
IMPORT os
PUBLIC TYPE menuRecord RECORD
	t_id INTEGER,
	t_pid INTEGER,
	id CHAR(6),
	type CHAR(20),
	description STRING,
	visible BOOLEAN,
	minval INTEGER,
	maxval INTEGER,
	field CHAR(50),
	option_id CHAR(6),
	option_name STRING,
	hidden BOOLEAN
END RECORD

PUBLIC TYPE menuData RECORD
	fileName STRING,
	menuTree DYNAMIC ARRAY OF menuRecord
END RECORD
--------------------------------------------------------------------------------------------------------------
FUNCTION (this menuData ) load()
	DEFINE l_json TEXT
-- get test data
	IF os.path.exists("../etc/data.json") THEN
		LET this.fileName = "../etc/data.json"
	ELSE
		LET this.fileName = "data.json"
	END IF
	TRY
		LOCATE l_json IN FILE this.fileName
	CATCH
		CALL fgl_winMessage("Error","Failed to load Menu Data!","exclamation")
		EXIT PROGRAM
	END TRY
	CALL util.JSON.parse(l_json, this.menuTree)
END FUNCTION
