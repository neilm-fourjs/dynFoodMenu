-- This service provides the menus, menu items and ability to place an order.
-- http://localhost/g/ws/r/dfm/menus?openapi.json

IMPORT com
IMPORT FGL Menus
IMPORT FGL ws_lib
IMPORT FGL debug

&include "../src/app.inc"

PUBLIC DEFINE serviceInfo RECORD ATTRIBUTE(WSInfo)
	title         STRING,
	description   STRING,
	termOfService STRING,
	contact RECORD
		name  STRING,
		url   STRING,
		email STRING
	END RECORD,
	version STRING,
	modules DYNAMIC ARRAY OF STRING
END RECORD =
		(title: "dynFoodMenu", description: "A RESTFUL backend for the dynFoodMenu mobile demo - Serving: Menus",
				version: "v2", contact:(name: "Neil J Martin", email: "neilm@4js.com"), modules:["One", "Two", "Three"])
PRIVATE DEFINE Context DICTIONARY ATTRIBUTE(WSContext) OF STRING

PUBLIC DEFINE menuError RECORD ATTRIBUTE(WSError = "Menu Error")
	host    STRING,
	status  SMALLINT,
	message STRING
END RECORD

DEFINE m_menu Menus
--------------------------------------------------------------------------------
#+ GET <server>/ws/r/dfm/menus/v1/getMenu
#+ result: A Record that contains an Array
PUBLIC FUNCTION v1_getMenus() ATTRIBUTES(WSPath = "/v1/getMenu", WSGet, WSDescription = "Get list of Menus")
		RETURNS(menuList ATTRIBUTES(WSMedia = 'application/json'))
	DEFINE l_menu Menus
	CALL ws_lib.auditLog(CURRENT, "v1_getMenus", "getMenus")
	IF NOT l_menu.getMenuListDB() THEN
		LET l_menu.menuList.rows = 0
	END IF
	RETURN l_menu.menuList.*
END FUNCTION
--------------------------------------------------------------------------------
#+ GET <server>/ws/r/dfm/menus/v1/getMenu/<id>
#+ result: A menu array by ID
PUBLIC FUNCTION v1_getMenu(l_menuName VARCHAR(6) ATTRIBUTE(WSParam))
		ATTRIBUTES(WSPath = "/v1/getMenu/{l_menuName}", WSGet, WSDescription = "Get a Menu")
		RETURNS(MenuRecord ATTRIBUTES(WSMedia = 'application/json'))
	IF NOT m_menu.getMenuDB(l_menuName) THEN
		LET m_menu.menu.menuName = "Invalid menuName!"
		LET m_menu.menu.rows     = 0
	END IF
	RETURN m_menu.menu.*
END FUNCTION
--------------------------------------------------------------------------------
#+ POST <server>/ws/r/dfm/menus/v1/placeOrder
#+ result: String
PUBLIC FUNCTION v1_placeOrder(l_order orderRecord)
		ATTRIBUTES(WSPath = "/v1/placeOrder", WSPost, WSDescription = "Place an Order")
		RETURNS(INT, STRING ATTRIBUTES(WSMedia = 'application/json'))
	DEFINE l_stat INTEGER
	DEFINE l_ret  STRING
	CALL debug.output(SFMT("v1_placeOrder User: %1 Items: %2", l_order.user_id, l_order.rows), FALSE)
	IF NOT ws_lib.checkToken(l_order.user_token) THEN
		RETURN 100, "Invalid Token!"
	END IF
-- Store order in DB
	LET m_menu.ordered = l_order
	CALL m_menu.placeOrderDB() RETURNING l_stat, l_ret
	RETURN l_stat, l_ret
END FUNCTION
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- V2 functions
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
#+ GET <server>/ws/r/dfm/menus/v2/getMenu
#+ result: A Record that contains an Array
PUBLIC FUNCTION v2_getMenus(
		l_cli_ip STRING ATTRIBUTES(WSHeader, WSOptional, WSName = "X-FourJs-Environment-Variable-REMOTE_ADDR"))
		ATTRIBUTES(WSPath = "/v2/getMenu", WSGet,
&ifdef USE_SCOPES
  WSScope = "dfm.get",
&endif
				WSDescription = "Get list of Menus")
		RETURNS(menuList ATTRIBUTES(WSMedia = 'application/json'))
	DEFINE l_menu Menus
	CALL ws_lib.auditLog(CURRENT, "v2_getMenus", l_cli_ip)
	IF NOT l_menu.getMenuListDB() THEN
		LET l_menu.menuList.rows = 0
	END IF
	RETURN l_menu.menuList.*
END FUNCTION
--------------------------------------------------------------------------------
#+ GET <server>/ws/r/dfm/menus/v2/getMenu/<id>
#+ result: A menu array by ID
PUBLIC FUNCTION v2_getMenu(l_menuName VARCHAR(6) ATTRIBUTE(WSParam))
		ATTRIBUTES(WSPath = "/v2/getMenu/{l_menuName}", WSGet,
&ifdef USE_SCOPES
  WSScope = "dfm.get",
&endif
				WSDescription = "Get a Menu", WSThrows = "400:@menuError")
		RETURNS(MenuRecord ATTRIBUTES(WSMedia = 'application/json'))
	IF NOT m_menu.getMenuDB(l_menuName) THEN
		LET m_menu.menu.menuName = "Invalid menuName!"
		LET m_menu.menu.rows     = 0
		CALL setMenuError(100, "Invalid menuName!")
	END IF
	RETURN m_menu.menu.*
END FUNCTION
--------------------------------------------------------------------------------
#+ POST <server>/ws/r/dfm/menus/v2/placeOrder
#+ result: String
PUBLIC FUNCTION v2_placeOrder(l_order orderRecord)
		ATTRIBUTES(WSPath = "/v2/placeOrder", WSPost,
&ifdef USE_SCOPES
  WSScope = "dfm.post",
&endif
				WSDescription = "Place an Order")
		RETURNS(INT, STRING ATTRIBUTES(WSMedia = 'application/json'))
	DEFINE l_stat INTEGER
	DEFINE l_ret  STRING
	CALL debug.output(SFMT("v2_placeOrder User: %1 Items: %2", l_order.user_id, l_order.rows), FALSE)
	IF NOT ws_lib.checkToken(l_order.user_token) THEN
		RETURN 100, "Invalid Token!"
	END IF
-- Store order in DB
	LET m_menu.ordered = l_order
	CALL m_menu.placeOrderDB() RETURNING l_stat, l_ret
	RETURN l_stat, l_ret
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION setMenuError(l_stat SMALLINT, l_msg STRING)
	LET menuError.host    = fgl_getEnv("HOST")
	LET menuError.status  = l_stat
	LET menuError.message = l_msg
	CALL com.WebServiceEngine.SetRestError(400, menuError)
END FUNCTION
--------------------------------------------------------------------------------
