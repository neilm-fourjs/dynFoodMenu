-- Module for mananging the menu data
-- TODO: Get data from a web service
IMPORT util
IMPORT os
IMPORT FGL debug
IMPORT FGL config
IMPORT FGL wsAuthLib
IMPORT FGL db
--IMPORT FGL wsBackEnd
IMPORT FGL wsMenus
IMPORT FGL libCommon
IMPORT FGL libMobile

&include "menus.inc"
&include "globals.inc"

PUBLIC TYPE Menus RECORD
	fileName STRING,
	menuList menuList,
	menu menuRecord,
	ordered orderRecord
END RECORD
--------------------------------------------------------------------------------------------------------------
PUBLIC FUNCTION (this Menus) getMenu(l_menuName STRING) RETURNS BOOLEAN
	WHENEVER ERROR CALL libCommon.abort
	CALL debug.output(SFMT("Load %1",l_menuName), FALSE)
	LET this.menu.menuName = l_menuName
	IF libMobile.gotNetwork() THEN
		IF NOT this.getMenuWS(l_menuName) THEN RETURN FALSE END IF
	ELSE
		IF NOT this.getMenuJSON(l_menuName) THEN RETURN FALSE END IF
	END IF
	CALL debug.output(SFMT("Loaded %1",this.fileName), FALSE)
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
PUBLIC FUNCTION (this Menus) getMenuList() RETURNS BOOLEAN
	CALL this.menulist.list.clear()
	IF libMobile.gotNetwork() THEN
		RETURN this.getMenuListWS()
	ELSE
		RETURN this.getMenuListJSON()
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- DB Code
PUBLIC FUNCTION (this Menus) getMenuListDB() RETURNS BOOLEAN
	IF this.menuList.rows = 0 THEN
		IF NOT g_db.connect() THEN EXIT PROGRAM END IF
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
PUBLIC FUNCTION (this Menus) getMenuDB(l_menuName STRING) RETURNS BOOLEAN
	IF NOT g_db.connect() THEN EXIT PROGRAM END IF
	CALL this.menu.items.clear()
	DECLARE l_cur2 CURSOR FOR SELECT * FROM menuItems WHERE menuName = l_menuName
	LET this.menu.rows = 0
	FOREACH l_cur2 INTO this.menu.items[ this.menu.rows + 1 ].*
		LET this.menu.rows = this.menu.rows + 1
	END FOREACH
	CALL this.menu.items.deleteElement(this.menu.rows+1)
	CALL debug.output(SFMT("getMenuDB: %1 Items: %2", l_menuName, this.menu.rows),FALSE)
	IF this.menu.items.getLength() = 0 THEN
			LET this.menu.menuName = "Invalid Menu!"
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
PUBLIC FUNCTION (this Menus) placeOrderDB() RETURNS (INTEGER, STRING)
	DEFINE l_ord RECORD LIKE orders.*
	DEFINE x SMALLINT
	IF NOT g_db.connect() THEN RETURN 100, "No database connection1" END IF
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
PUBLIC FUNCTION (this Menus) getMenuListJSON() RETURNS BOOLEAN
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
PUBLIC FUNCTION (this Menus) getMenuJSON(l_menuName STRING) RETURNS BOOLEAN
	DEFINE l_json TEXT
	CALL this.menu.items.clear()
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
	CALL util.JSON.parse(l_json, this.menu.items)
	LET this.menu.rows = this.menu.items.getLength()
	CALL this.calcLevels(l_menuName)
	CALL debug.output(SFMT("getMenuJSON: %1 Items: %2", l_menuName, this.menu.rows),FALSE)
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- WS functions
--------------------------------------------------------------------------------------------------------------
FUNCTION (this Menus) getMenuListWS() RETURNS BOOLEAN
	DEFINE l_stat SMALLINT
	DEFINE l_json TEXT
	DEFINE l_fileName STRING = "menus.json"
	CALL libCommon.processing("Loading Menus ...",1)
	LET wsMenus.Endpoint.Address.Uri = g_wsAuth.getWSServer(C_WS_MENUS)
	CALL wsMenus.v2_getMenus() RETURNING l_stat,this.menuList.*
	CALL libCommon.processing("Loading Menus ...",3)
	IF l_stat != 0 THEN
		CALL debug.output(SFMT("getMenuListWS: %1 from %2", l_stat, wsMenus.Endpoint.Address.Uri),FALSE)
		RETURN FALSE
	END IF
	LOCATE l_json IN FILE l_fileName
	LET l_json = util.JSON.stringify(this.menulist) -- Save Menu List Locally
	CALL debug.output(SFMT("getMenuListWS: %1 from %2", this.menuList.rows, wsMenus.Endpoint.Address.Uri ),FALSE)
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this Menus) getMenuWS(l_menuName STRING) RETURNS BOOLEAN
	DEFINE l_stat INT
	LET wsMenus.Endpoint.Address.Uri = g_wsAuth.getWSServer(C_WS_MENUS)
	CALL libCommon.processing("Loading Menu ...",1)
	CALL wsMenus.v2_getMenu(l_menuName) RETURNING l_stat, this.menu.*
	CALL libCommon.processing("Loading Menu ...",3)
	IF l_stat != 0 THEN
		CALL debug.output(SFMT("getMenuWS: %1 Stat: %2", l_menuName, l_stat),FALSE)
		RETURN FALSE
	END IF
	CALL debug.output(SFMT("getMenuWS: %1 Rows: %2 from %3", l_menuName, this.menu.rows, wsMenus.Endpoint.Address.Uri),FALSE)
	IF this.menu.rows = 0 THEN RETURN FALSE END IF
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this Menus) save()
	DEFINE l_stat INT
	DEFINE l_resp RECORD
		l_stat INT,
		l_msg STRING
	END RECORD
	LET this.ordered.menu_id = this.menu.menuName
	CALL libCommon.processing("Saving Order ...",1)

	LET wsMenus.Endpoint.Address.Uri = g_wsAuth.getWSServer(C_WS_MENUS)
	CALL wsMenus.v2_placeOrder(this.ordered.*) RETURNING l_stat, l_resp.*
	CALL debug.output(SFMT("save Stat:%1:%2:%3 - from %4", l_stat,l_resp.l_stat,l_resp.l_msg, wsMenus.Endpoint.Address.Uri),FALSE)

	CALL libCommon.processing("Saved Order.",3)
	IF l_stat = 0 THEN
		CALL fgl_winMessage("Order Confirmation",l_resp.l_msg,"information")
	ELSE
		CALL fgl_winMessage("Order Confirmation",SFMT("%1 - %2 : %3", l_stat,l_resp.l_stat,l_resp.l_msg),"information")
	END IF

END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- util function
PRIVATE FUNCTION (this Menus ) calcLevels(l_menuName STRING)
	DEFINE x, y, l_id, l_pid, l_lev SMALLINT
	DEFINE l_levs DYNAMIC ARRAY OF RECORD
		pid SMALLINT,
		lev SMALLINT
	END RECORD
	DEFINE l_found BOOLEAN
	LET l_lev = 0
	FOR x = 1 TO this.menu.rows
		LET l_id = this.menu.items[x].t_id
		LET l_pid = this.menu.items[x].t_pid
		LET l_found = FALSE
		FOR y = 1 TO l_levs.getLength()
			IF l_levs[y].pid = l_pid THEN
				LET l_found = TRUE
				LET l_lev = l_levs[y].lev
			END IF
		END FOR
		IF NOT l_found THEN LET l_lev = l_lev + 1 END IF
		LET l_levs[l_id].pid = this.menu.items[x].t_pid
		LET l_levs[l_id].lev = l_lev
	END FOR
	FOR x = 1 TO this.menu.rows
		LET this.menu.items[x].menuName = l_menuName
		LET this.menu.items[x].level = l_levs[this.menu.items[x].t_id].lev
	END FOR
END FUNCTION