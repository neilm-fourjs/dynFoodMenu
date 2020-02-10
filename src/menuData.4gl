-- Module for mananging the menu data
-- TODO: Get data from a web service
IMPORT util
IMPORT os
IMPORT FGL debug
IMPORT FGL wsBackEnd
IMPORT FGL db
IMPORT FGL libCommon
IMPORT FGL libMobile

&include "menus.inc"

PUBLIC TYPE menuData RECORD
	fileName STRING,
	menuList menuList,
	menuData menuRecord,
	ordered orderRecord
END RECORD
--------------------------------------------------------------------------------------------------------------
FUNCTION (this menuData) getMenu(l_menuName STRING) RETURNS BOOLEAN
	CALL debug.output(SFMT("Load %1",l_menuName), FALSE)
	LET this.menuData.menuName = l_menuName
	IF libMobile.gotNetwork() THEN
		IF NOT this.getMenuWS(l_menuName) THEN RETURN FALSE END IF
	ELSE
		IF NOT this.getMenuJSON(l_menuName) THEN RETURN FALSE END IF
	END IF
	CALL debug.output(SFMT("Loaded %1",this.fileName), FALSE)
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this menuData) getMenuList() RETURNS BOOLEAN
	CALL this.menulist.list.clear()
	IF libMobile.gotNetwork() THEN
		RETURN this.getMenuListWS()
	ELSE
		RETURN this.getMenuListJSON()
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- DB Code
FUNCTION (this menuData) getMenuListDB() RETURNS BOOLEAN
	IF this.menuList.rows = 0 THEN
		IF NOT db.connect() THEN EXIT PROGRAM END IF
		DECLARE l_cur1 CURSOR FOR SELECT * FROM menus
		LET this.menulist.rows = 0
		FOREACH l_cur1 INTO this.menulist.list[ this.menulist.rows + 1 ].*
			LET this.menulist.rows = this.menulist.rows + 1
		END FOREACH
		CALL this.menulist.list.deleteElement(this.menulist.rows+1)
	END IF
	CALL debug.output(SFMT("getMenuListDB: %1", this.menuList.rows),FALSE)
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this menuData) getMenuDB(l_menuName STRING) RETURNS BOOLEAN
	IF this.menuData.rows = 0 THEN
		IF NOT db.connect() THEN EXIT PROGRAM END IF
		DECLARE l_cur2 CURSOR FOR SELECT * FROM menuItems WHERE menuName = l_menuName
		LET this.menuData.rows = 0
		FOREACH l_cur2 INTO this.menuData.items[ this.menuData.rows + 1 ].*
			LET this.menuData.rows = this.menuData.rows + 1
		END FOREACH
		CALL this.menuData.items.deleteElement(this.menuData.rows+1)
	END IF
	CALL debug.output(SFMT("getMenuDB: %1 Items: %2", l_menuName, this.menuData.rows),FALSE)
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this menuData) placeOrderDB() RETURNS (INTEGER, STRING)
	DEFINE l_ord RECORD LIKE orders.*
	DEFINE x SMALLINT
	IF NOT db.connect() THEN RETURN 100, "No database connection1" END IF
-- Store order in DB
	LET l_ord.menu_id = this.ordered.menu_id
	LET l_ord.order_id = NULL
	LET l_ord.placed = this.ordered.placed
	LET l_ord.user_id = this.ordered.user_id
	LET l_ord.user_token = this.ordered.user_token
	INSERT INTO orders VALUES l_ord.*
	LET l_ord.order_id = SQLCA.sqlerrd[2] -- fetch serial
	IF STATUS != 0 THEN
		RETURN 101,"Failed to place order!"
	END IF
	FOR x = 1 TO this.ordered.rows
		LET this.ordered.items[x].order_id = l_ord.order_id
		INSERT INTO orderitems VALUES this.ordered.items[x].*
	END FOR
	IF STATUS != 0 THEN
		RETURN 102,"Failed to store order items!"
	END IF
	RETURN 0, SFMT("Your Order No is %1", l_ord.order_id)
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- JSON Code
FUNCTION (this menuData) getMenuListJSON() RETURNS BOOLEAN
	DEFINE l_json TEXT
	DEFINE l_fileName STRING = "menus.json"
	IF NOT os.path.exists(l_fileName) THEN
		LET l_fileName = "../etc/menus.json"		END IF
	LOCATE l_json IN FILE l_fileName -- Use Local Menu List
	CALL util.JSON.parse(l_json, this.menulist )
	LET this.menulist.rows = this.menulist.list.getLength()
	CALL debug.output(SFMT("getMenuListJSON: %1", this.menuList.rows),FALSE)
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this menuData) getMenuJSON(l_menuName STRING) RETURNS BOOLEAN
	DEFINE l_json TEXT
	CALL this.menuData.items.clear()
	CALL debug.output(SFMT("getMenuJSON: %1",l_menuName), FALSE)
-- get test data
	LET this.fileName = l_menuName||".json"
	IF NOT os.path.exists(this.fileName) THEN
		LET this.fileName = "../etc/"||l_menuName||".json"
	END IF
	LOCATE l_json IN FILE this.fileName
	IF l_json.getLength() < 2 THEN
		CALL output(SFMT("getMenuJSON: Failed to load Menu Data %1!",l_menuName), FALSE)
		ERROR SFMT("Failed to load Menu Data %1!",l_menuName)
		RETURN FALSE
	END IF
	CALL util.JSON.parse(l_json, this.menuData.items)
	LET this.menuData.rows = this.menuData.items.getLength()
	CALL this.calcLevels(l_menuName)
	CALL debug.output(SFMT("getMenuJSON: %1 Items: %2", l_menuName, this.menuData.rows),FALSE)
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- WS functions
--------------------------------------------------------------------------------------------------------------
FUNCTION (this menuData) getMenuListWS() RETURNS BOOLEAN
	DEFINE l_stat SMALLINT
	DEFINE l_json TEXT
	DEFINE l_fileName STRING = "menus.json"
	CALL libCommon.processing("Loading Menus ...",1)
	LET wsBackEnd.Endpoint.Address.Uri = C_WS_BACKEND
	CALL wsBackEnd.getMenus() RETURNING l_stat,this.menuList.*
	CALL libCommon.processing("Loading Menus ...",3)
	IF l_stat != 0 THEN
		CALL debug.output(SFMT("getMenuListWS: %1", l_stat),FALSE)
		RETURN FALSE
	END IF
	LOCATE l_json IN FILE l_fileName
	LET l_json = util.JSON.stringify(this.menulist) -- Save Menu List Locally
	CALL debug.output(SFMT("getMenuListWS: %1", this.menuList.rows),FALSE)
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this menuData) getMenuWS(l_menuName STRING) RETURNS BOOLEAN
	DEFINE l_stat INT
	LET wsBackEnd.Endpoint.Address.Uri = C_WS_BACKEND
	CALL libCommon.processing("Loading Menu ...",1)
	CALL wsBackEnd.getMenu(l_menuName) RETURNING l_stat, this.menuData.*
	CALL libCommon.processing("Loading Menu ...",3)
	IF l_stat != 0 THEN
		CALL debug.output(SFMT("getMenuWS: %1 Stat: %2", l_menuName, l_stat),FALSE)
		RETURN FALSE
	END IF
	CALL debug.output(SFMT("getMenuWS: %1 Rows: %2", l_menuName, this.menuData.rows),FALSE)
	IF this.menuData.rows = 0 THEN RETURN FALSE END IF
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this menuData) save()
	DEFINE l_stat INT
	DEFINE l_resp RECORD
		l_stat INT,
		l_msg STRING
	END RECORD
	LET wsBackEnd.Endpoint.Address.Uri = C_WS_BACKEND
	LET this.ordered.menu_id = this.menuData.menuName
	CALL libCommon.processing("Saving Order ...",1)
	CALL wsBackEnd.placeOrder(this.ordered.*) RETURNING l_stat, l_resp.*
	CALL libCommon.processing("Saved Order.",3)
	CALL debug.output(SFMT("save Stat: %1-%2:%3", l_stat,l_resp.l_stat,l_resp.l_msg),FALSE)
	IF l_stat = 0 THEN
		CALL fgl_winMessage("Order Confirmation",l_resp.l_msg,"information")
	ELSE
		CALL fgl_winMessage("Order Confirmation",SFMT("%1 : %2",l_resp.l_stat,l_resp.l_msg),"information")
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- util function
PRIVATE FUNCTION (this menuData ) calcLevels(l_menuName STRING)
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
		LET this.menuData.items[x].menuName = l_menuName
		LET this.menuData.items[x].level = l_levs[this.menuData.items[x].t_id].lev
	END FOR
END FUNCTION