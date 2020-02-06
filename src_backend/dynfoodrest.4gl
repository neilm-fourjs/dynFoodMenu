IMPORT security
IMPORT util
IMPORT FGL menuData
IMPORT FGL Users
IMPORT FGL debug
&include "../src/menus.inc"
DEFINE m_user Users
--------------------------------------------------------------------------------
#+ GET <server>/dynFoodRest/getToken/id/pwd
#+ result: A Record that contains uesr information
PUBLIC FUNCTION getToken(l_id CHAR(6) ATTRIBUTE(WSParam), l_pwd STRING ATTRIBUTE(WSParam)) ATTRIBUTES( 
		WSPath = "/getToken/{l_id}/{l_pwd}", 
		WSGet,
		WSDescription = "Validate User and get Token")
	RETURNS (userRecord ATTRIBUTES(WSMedia = 'application/json'))
	DEFINE l_rec userRecord = (
    user_id: "ERROR", 
		user_name: "Invalid User Id!" )

	IF l_pwd != C_APIPASS THEN
		CALL debug.output(SFMT("getToken: User:%1 API:%2 Invalid APIPASS",l_rec.user_id, l_pwd), FALSE)
		RETURN l_rec.*
	END IF
	IF m_user.get( l_id ) THEN
		LET m_user.currentUser.user_token = security.RandomGenerator.CreateUUIDString()
		LET m_user.currentUser.token_ts = CURRENT
		IF m_user.update() THEN
		END IF
		LET l_rec.* = m_user.currentUser.*
	END IF
	CALL debug.output(SFMT("getToken: %1 %2",l_rec.user_id, l_rec.user_token), FALSE)
	RETURN l_rec.*
END FUNCTION
--------------------------------------------------------------------------------
#+ GET <server>/dynFoodRest/getMenus
#+ result: A Record that contains an Array
PUBLIC FUNCTION getMenus() ATTRIBUTES( 
		WSPath = "/getMenus", 
		WSGet, 
		WSDescription = "Get list of Menus")
	RETURNS (menuList ATTRIBUTES(WSMedia = 'application/json'))
	DEFINE l_menu menuData
	IF NOT l_menu.getMenuListDB() THEN
	END IF
	RETURN l_menu.menuList.*
END FUNCTION
--------------------------------------------------------------------------------
#+ GET <server>/dynFoodRest/getMenu/<id>
#+ result: A menu array by ID
PUBLIC FUNCTION getMenu(l_menuName VARCHAR(6) ATTRIBUTE(WSParam)) ATTRIBUTES( 
		WSPath = "/getMenu/{l_menuName}", 
		WSGet, 
		WSDescription = "Get a Menu")
	RETURNS (MenuRecord ATTRIBUTES(WSMedia = 'application/json'))
	DEFINE l_menu menuData
	IF NOT l_menu.getMenuDB(l_menuName) THEN
		LET l_menu.menuData.menuName = "Invalid menuName!"
		LET l_menu.menuData.rows = 0
	END IF
	RETURN l_menu.menuData.*
END FUNCTION
--------------------------------------------------------------------------------
#+ POST <server>/dynFoodRest/placeOrder
#+ result: String
PUBLIC FUNCTION placeOrder(l_order orderRecord) ATTRIBUTES( 
		WSPath = "/placeOrder", 
		WSPost, 
		WSDescription = "Place an Order")
	RETURNS (INT,STRING ATTRIBUTES(WSMedia = 'application/json'))
	DEFINE l_json TEXT
	DEFINE l_fileName STRING

	DISPLAY "Order:",l_order.*
	LET l_fileName = "order_"||util.Datetime.format(CURRENT,"%Y%m%d%H%M_")||l_order.user_id||".json"
	CALL debug.output(SFMT("placeOrder User: %1 Items: %2 Saved: %3",l_order.user_id, l_order.rows, l_fileName), FALSE)
	LOCATE l_json IN MEMORY
	LET l_json = util.JSON.stringify(l_order)
	CALL l_json.writeFile(l_fileName)
-- TODO: validate that the token is valid.
	IF STATUS != 0 THEN
		RETURN 100,"Invalid Token!"
	END IF
--TODO: store order in DB
	IF STATUS != 0 THEN
		RETURN 101,"Failed to place order!"
	END IF
	RETURN 0,"Okay"
END FUNCTION
--------------------------------------------------------------------------------