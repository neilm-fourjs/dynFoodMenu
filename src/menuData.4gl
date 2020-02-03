-- Module for mananging the menu data
-- TODO: Get data from a web service
IMPORT util
IMPORT os
IMPORT FGL debug

&include "menus.inc"

PUBLIC TYPE menuData RECORD
	fileName STRING,
	menuData menuRecord,
	ordered orderRecord
END RECORD
--------------------------------------------------------------------------------------------------------------
FUNCTION (this menuData ) load(l_menuName STRING) RETURNS BOOLEAN
	CALL debug.output(SFMT("Load %1",l_menuName), FALSE)
	IF NOT this.loadData(l_menuName) THEN RETURN FALSE END IF
	CALL debug.output(SFMT("Loaded %1",this.fileName), FALSE)
	CALL this.calcLevels()
	CALL debug.output("Levels calced", FALSE)
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this menuData ) save()
	DEFINE l_order STRING
--TODO: send the order
	LET l_order = util.JSON.stringify(this.ordered)
	DISPLAY "Save:", l_order
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this menuData ) loadData(l_menuName STRING) RETURNS BOOLEAN
	DEFINE l_json TEXT
-- get test data
	LET this.fileName = "../etc/"||l_menuName||".json"
	IF NOT os.path.exists(this.fileName) THEN
		LET this.fileName = l_menuName||".json"
	END IF
	LOCATE l_json IN FILE this.fileName
	IF l_json.getLength() < 2 THEN
		CALL fgl_winMessage("Error","Failed to load Menu Data!","exclamation")
		RETURN FALSE
	END IF
	CALL util.JSON.parse(l_json, this.menuData.items)
	LET this.menuData.rows = this.menuData.items.getLength()
	RETURN TRUE
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
	FOR x = 1 TO this.menuData.rows
		LET l_id = this.menuData.items[x].t_id
		LET l_pid = this.menuData.items[x].t_pid
		LET l_found = FALSE
		FOR y = 1 TO l_levs.getLength()
			IF l_levs[y].pid = l_pid THEN
				LET l_found = TRUE
				LET l_lev = l_levs[y].lev
			END IF
		END FOR
		IF NOT l_found THEN LET l_lev = l_lev + 1 END IF
		LET l_levs[l_id].pid = this.menuData.items[x].t_pid
		LET l_levs[l_id].lev = l_lev
	END FOR
	FOR x = 1 TO this.menuData.rows
		LET this.menuData.items[x].level = l_levs[this.menuData.items[x].t_id].lev
{
		DISPLAY SFMT("%1 Type: %2 Id: %3 Pid: %4 Cond: %5 Desc: %6",
			(this.menuData.items[x].level SPACES),
			this.menuData.items[x].type.subString(1,4),
			this.menuData.items[x].t_id,
			this.menuData.items[x].t_pid,
			this.menuData.items[x].conditional,
			this.menuData.items[x].description)
}
	END FOR
END FUNCTION