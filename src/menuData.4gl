-- Module for mananging the menu data
-- TODO: Get data from a web service
IMPORT util
IMPORT os
IMPORT FGL debug

PUBLIC TYPE menuRecord RECORD
		t_id INTEGER,
		t_pid INTEGER,
		id CHAR(6),
		type STRING,
		description STRING,
		conditional BOOLEAN,
		minval INTEGER,
		maxval INTEGER,
		field STRING,
		option_id STRING,
		option_name STRING,
		hidden BOOLEAN,
		level SMALLINT
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
	ordered DYNAMIC ARRAY OF orderRecord
END RECORD
--------------------------------------------------------------------------------------------------------------
FUNCTION (this menuData ) load(l_menuName STRING)
	CALL debug.output(SFMT("Load %1",l_menuName), FALSE)
	CALL this.loadData(l_menuName)
	CALL debug.output(SFMT("Loaded %1",this.fileName), FALSE)
	CALL this.calcLevels()
	CALL debug.output("Level calced", FALSE)
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this menuData ) save()
	DEFINE l_order STRING
--TODO: send the order
	LET l_order = util.JSON.stringify(this.ordered)
	DISPLAY "Save:", l_order
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this menuData ) loadData(l_menuName STRING)
	DEFINE l_json TEXT
-- get test data
	LET this.fileName = "../etc/"||l_menuName||".json"
	IF NOT os.path.exists(this.fileName) THEN
		LET this.fileName = l_menuName||".json"
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
FUNCTION (this menuData ) calcLevels()
	DEFINE x, y, l_id, l_pid, l_lev SMALLINT
	DEFINE l_levs DYNAMIC ARRAY OF RECORD
		pid SMALLINT,
		lev SMALLINT
	END RECORD
	DEFINE l_found BOOLEAN
	LET l_lev = 0
	FOR x = 1 TO this.menuTree.getLength() 
		LET l_id = this.menuTree[x].t_id
		LET l_pid = this.menuTree[x].t_pid
		LET l_found = FALSE
		FOR y = 1 TO l_levs.getLength()
			IF l_levs[y].pid = l_pid THEN
				LET l_found = TRUE
				LET l_lev = l_levs[y].lev
			END IF
		END FOR
		IF NOT l_found THEN LET l_lev = l_lev + 1 END IF
		LET l_levs[l_id].pid = this.menuTree[x].t_pid
		LET l_levs[l_id].lev = l_lev
	END FOR
	FOR x = 1 TO this.menuTree.getLength()
		LET this.menuTree[x].level = l_levs[this.menuTree[x].t_id].lev
{
		DISPLAY SFMT("%1 Type: %2 Id: %3 Pid: %4 Cond: %5 Desc: %6",
			(this.menuTree[x].level SPACES),
			this.menuTree[x].type.subString(1,4),
			this.menuTree[x].t_id,
			this.menuTree[x].t_pid,
			this.menuTree[x].conditional,
			this.menuTree[x].description)
}
	END FOR
END FUNCTION