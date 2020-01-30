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
		field STRING,
		option_id STRING,
		option_name STRING,
		hidden BOOLEAN
	END RECORD
PUBLIC TYPE condRecord RECORD
    cond RECORD
        menu_id STRING,
        type_id STRING,
        id FLOAT,
        name STRING
    END RECORD,
    d1_arr DYNAMIC ARRAY OF RECORD
        menu_id STRING,
        type_id STRING,
        cond_id FLOAT,
        item_id FLOAT
    END RECORD,
    d2_arr DYNAMIC ARRAY OF RECORD
        menu_id STRING,
        type_id STRING,
        cond_id FLOAT,
        item_id FLOAT
    END RECORD,
    d3_arr DYNAMIC ARRAY OF RECORD
        menu_id STRING,
        type_id STRING,
        cond_id FLOAT,
        item_id FLOAT
    END RECORD,
    d4_arr DYNAMIC ARRAY OF RECORD
        menu_id STRING,
        type_id STRING,
        cond_id FLOAT,
        item_id FLOAT
    END RECORD
	END RECORD
PUBLIC TYPE orderRecord RECORD
		id INTEGER,
		description STRING,
		qty SMALLINT,
		optional BOOLEAN
	END RECORD

PUBLIC TYPE menuData RECORD
	fileName STRING,
	menuTree DYNAMIC ARRAY OF menuRecord,
	menuConditions DYNAMIC ARRAY OF condRecord,
	ordered DYNAMIC ARRAY OF orderRecord
END RECORD
--------------------------------------------------------------------------------------------------------------
FUNCTION (this menuData ) load()
	CALL this.loadData()
	CALL this.loadConditions()
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this menuData ) save()
	DEFINE l_order STRING
--TODO: send the order
	LET l_order = util.JSON.stringify(this.ordered)
	DISPLAY "Save:", l_order
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this menuData ) loadData()
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
--------------------------------------------------------------------------------------------------------------
FUNCTION (this menuData ) loadConditions()
	DEFINE l_json TEXT
	IF os.path.exists("../etc/cond.json") THEN
		LET this.fileName = "../etc/cond.json"
	ELSE
		LET this.fileName = "cond.json"
	END IF
	TRY
		LOCATE l_json IN FILE this.fileName
	CATCH
		CALL fgl_winMessage("Error","Failed to load Menu Data!","exclamation")
		EXIT PROGRAM
	END TRY
	CALL util.JSON.parse(l_json, this.menuConditions)
END FUNCTION
