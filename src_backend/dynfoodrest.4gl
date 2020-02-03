IMPORT security
IMPORT FGL menuData
&include "../src/menus.inc"
--------------------------------------------------------------------------------
#+ GET <server>/dynFoodRest/getToken/id/pwd
#+ result: A Record that contains uesr information
PUBLIC FUNCTION getToken(l_id CHAR(6) ATTRIBUTE(WSParam), l_pwd STRING ATTRIBUTE(WSParam)) ATTRIBUTES( 
		WSPath = "/getToken/{l_id}/{l_pwd}", 
		WSGet,
		WSDescription = "Validate User and get Token")
	RETURNS (userRecord ATTRIBUTES(WSMedia = 'application/json,application/xml'))
	DEFINE l_rec userRecord

--TODO: validate the password
	LET l_rec.user_id = l_id
	LET l_rec.user_pwd = l_pwd
	LET l_rec.user_name = "Neil J Martin"
	LET l_rec.user_token = security.RandomGenerator.CreateUUIDString()

	RETURN l_rec.*
END FUNCTION
--------------------------------------------------------------------------------
#+ GET <server>/dynFoodRest/getMenus
#+ result: A Record that contains an Array
PUBLIC FUNCTION getMenus() ATTRIBUTES( 
		WSPath = "/getMenus", 
		WSGet, 
		WSDescription = "Get list of Menus")
	RETURNS (menuList ATTRIBUTES(WSMedia = 'application/json,application/xml'))
	DEFINE l_rec menuList
{
	DEFINE l_in RECORD
		menuName VARCHAR(6),
		menuDesc VARCHAR(30)
	END RECORD
	DECLARE l_cur1 CURSOR FOR SELECT id,description FROM menus
		WHERE type = "Menu"
	FOREACH l_cur1 INTO l_in.*
		LET l_rec.list[l_rec.rows].menuName = l_in.menuName
		LET l_rec.list[l_rec.rows].menuDesc = l_in.menuDesc
	END FOREACH
}
	LET l_rec.list[1].menuName = "menu1"
	LET l_rec.list[1].menuDesc = "Breakfast"
	LET l_rec.list[1].menuImage = "breakfast.png"
	LET l_rec.list[2].menuName = "menu2"
	LET l_rec.list[2].menuDesc = "Lunch"
	LET l_rec.list[2].menuImage = "lunch.png"
	LET l_rec.rows = 2

	LET l_rec.rows = l_rec.list.getLength()
	RETURN l_rec.*
END FUNCTION
--------------------------------------------------------------------------------
#+ GET <server>/dynFoodRest/getMenu/<id>
#+ result: A menu array by ID
PUBLIC FUNCTION getMenu(l_id VARCHAR(6) ATTRIBUTE(WSParam)) ATTRIBUTES( 
		WSPath = "/getMenu/{l_id}", 
		WSGet, 
		WSDescription = "Get a Menu")
	RETURNS (MenuRecord ATTRIBUTES(WSMedia = 'application/json,application/xml'))
	DEFINE l_menu menuData
	IF NOT l_menu.load(l_id) THEN
		LET l_menu.menuData.description = "Invalid MenuID!"
		LET l_menu.menuData.rows = 0
		RETURN l_menu.menuData.*
	END IF
{
	DECLARE l_cur2 CURSOR FOR SELECT * FROM menus
		WHERE menu_name = l_id
	LET l_menu.rows = 1
	FOREACH l_cur2 INTO l_menu.items[l_menu.rows].*
		LET l_menu.rows = l_menu.rows + 1
	END FOREACH
}

	RETURN l_menu.menuData.*
END FUNCTION
--------------------------------------------------------------------------------
#+ POST <server>/dynFoodRest/placeOrder
#+ result: String
PUBLIC FUNCTION placeOrder(l_order orderRecord) ATTRIBUTES( 
		WSPath = "/addMenu/", 
		WSPost, 
		WSDescription = "Place an Order")
	RETURNS (INT,STRING ATTRIBUTES(WSMedia = 'application/json,application/xml'))

	DISPLAY l_order.*

-- TODO: validate that the token is valid.
	IF STATUS != 0 THEN
		RETURN 100,"Invalid Token!"
	END IF
--TODO: store order
	IF STATUS != 0 THEN
		RETURN 101,"Failed to place order!"
	END IF
	RETURN 0,"Okay"
END FUNCTION
--------------------------------------------------------------------------------