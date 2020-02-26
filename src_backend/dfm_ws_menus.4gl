
IMPORT util
IMPORT FGL Menus
IMPORT FGL ws_lib
IMPORT FGL debug

&include "../src/menus.inc"

PUBLIC DEFINE serviceInfo RECORD ATTRIBUTE(WSInfo)
  title STRING,
  description STRING,
  termOfService STRING,
  contact RECORD
    name STRING,
    url STRING,
    email STRING
  END RECORD,
  version STRING
  END RECORD = (
    title: "dynFoodMenu", 
		description: "A RESTFUL backend for the dynFoodMenu mobile demo - Serving: Menus",
    version: "1.0", 
    contact: ( name: "Neil J Martin", email:"neilm@4js.com") )

--------------------------------------------------------------------------------
#+ GET <server>/ws/r/dfm/menus/getMenus
#+ result: A Record that contains an Array
PUBLIC FUNCTION getMenus() ATTRIBUTES( 
		WSPath = "/getMenus", 
		WSGet, 
		WSDescription = "Get list of Menus")
	RETURNS (menuList ATTRIBUTES(WSMedia = 'application/json'))
	DEFINE l_menu Menus
	IF NOT l_menu.getMenuListDB() THEN
	END IF
	RETURN l_menu.menuList.*
END FUNCTION
--------------------------------------------------------------------------------
#+ GET <server>/ws/r/dfm/menus/getMenu/<id>
#+ result: A menu array by ID
PUBLIC FUNCTION getMenu(l_menuName VARCHAR(6) ATTRIBUTE(WSParam)) ATTRIBUTES( 
		WSPath = "/getMenu/{l_menuName}", 
		WSGet, 
		WSDescription = "Get a Menu")
	RETURNS (MenuRecord ATTRIBUTES(WSMedia = 'application/json'))
	DEFINE l_menu Menus
	IF NOT l_menu.getMenuDB(l_menuName) THEN
		LET l_menu.menu.menuName = "Invalid menuName!"
		LET l_menu.menu.rows = 0
	END IF
	RETURN l_menu.menu.*
END FUNCTION
--------------------------------------------------------------------------------
#+ POST <server>/ws/r/dfm/menus/placeOrder
#+ result: String
PUBLIC FUNCTION placeOrder(l_order orderRecord) ATTRIBUTES( 
		WSPath = "/placeOrder", 
		WSPost, 
		WSDescription = "Place an Order")
	RETURNS (INT, STRING ATTRIBUTES(WSMedia = 'application/json'))
	DEFINE l_stat INTEGER
	DEFINE l_ret STRING
	DEFINE l_menu Menus
	CALL debug.output(SFMT("placeOrder User: %1 Items: %2",l_order.user_id, l_order.rows), FALSE)
	IF NOT ws_lib.checkToken( l_order.user_token ) THEN
		RETURN 100,"Invalid Token!"
	END IF
-- Store order in DB
	LET l_menu.ordered = l_order
	CALL l_menu.placeOrderDB() RETURNING l_stat, l_ret
	RETURN l_stat, l_ret
END FUNCTION
--------------------------------------------------------------------------------
