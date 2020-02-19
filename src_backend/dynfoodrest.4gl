IMPORT security
IMPORT util
IMPORT FGL menuData
IMPORT FGL Users
IMPORT FGL Patients
IMPORT FGL utils
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
		description: "A RESTFUL backend for the dynFoodMenu mobile demo",
    version: "1.0", 
    contact: ( name: "Neil J Martin", email:"neilm@4js.com") )

DEFINE m_user Users
DEFINE m_patients Patients
DEFINE m_ts CHAR(19)
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
	IF m_ts IS NULL THEN LET m_ts = CURRENT YEAR TO SECOND END IF
	IF l_pwd != utils.apiPaas(l_id CLIPPED, m_ts) THEN
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
#+ GET <server>/dynFoodRest/checkUserID/id
#+ result is boolean:false=okay to use true=exists plus a suggestion.
PUBLIC FUNCTION checkUserID(l_id CHAR(6) ATTRIBUTE(WSParam)) ATTRIBUTES( 
		WSPath = "/checkUserID/{l_id}", 
		WSGet,
		WSDescription = "Check UserID")
	RETURNS (BOOLEAN, CHAR(6) ATTRIBUTES(WSMedia = 'application/json'))
	DEFINE l_exists BOOLEAN
	DEFINE l_suggestion CHAR(6)
	CALL m_user.checkUserID( l_id ) RETURNING l_exists, l_suggestion
	RETURN l_exists, l_suggestion
END FUNCTION
--------------------------------------------------------------------------------
#+ GET <server>/dynFoodRest/getTime
#+ result: A menu array by ID
PUBLIC FUNCTION getTimeStamp() ATTRIBUTES( WSPath = "/getTimestamp", 
		WSGet, 
		WSDescription = "Get the server time")
	RETURNS (CHAR(19) ATTRIBUTES(WSMedia = 'application/json'))
	IF m_ts IS NULL THEN LET m_ts = CURRENT YEAR TO SECOND END IF
	RETURN m_ts
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
#+ GET <server>/dynFoodRest/getWards
#+ result: An array of wards
PUBLIC FUNCTION getWards() ATTRIBUTES( 
		WSPath = "/getWards",
		WSGet, 
		WSDescription = "Get wards")
	RETURNS (wardList ATTRIBUTES(WSMedia = 'application/json'))
	LET m_patients.wards.messsage = "getting wards from db ..."
	CALL m_patients.getWardsDB()
	RETURN m_patients.wards.*
END FUNCTION
--------------------------------------------------------------------------------
#+ GET <server>/dynFoodRest/getPatients/<id>
#+ result: A menu array by ID
PUBLIC FUNCTION getPatients(l_ward SMALLINT ATTRIBUTE(WSParam)) ATTRIBUTES( 
		WSPath = "/getPatients/{l_ward}", 
		WSGet, 
		WSDescription = "Get patients for ward")
	RETURNS (patientList ATTRIBUTES(WSMedia = 'application/json'))
	LET m_patients.wards.messsage = SFMT("getting patients for ward %1 from db ...", l_ward)
	CALL m_patients.getPatientsDB(l_ward)
	RETURN m_patients.patients.*
END FUNCTION
--------------------------------------------------------------------------------
#+ POST <server>/dynFoodRest/placeOrder
#+ result: String
PUBLIC FUNCTION registerUser(l_userDets userDetailsRecord) ATTRIBUTES( 
		WSPath = "/registerUser", 
		WSPost, 
		WSDescription = "Register a user")
	RETURNS (INT, STRING ATTRIBUTES(WSMedia = 'application/json'))
	DEFINE l_stat INTEGER
	DEFINE l_ret STRING
	LET m_user.currentUserDetails.* = l_userDets.*
	CALL m_user.register() RETURNING l_stat, l_ret
	RETURN l_stat, l_ret
END FUNCTION
--------------------------------------------------------------------------------
#+ POST <server>/dynFoodRest/placeOrder
#+ result: String
PUBLIC FUNCTION placeOrder(l_order orderRecord) ATTRIBUTES( 
		WSPath = "/placeOrder", 
		WSPost, 
		WSDescription = "Place an Order")
	RETURNS (INT, STRING ATTRIBUTES(WSMedia = 'application/json'))
	DEFINE l_json TEXT
	DEFINE l_fileName STRING
	DEFINE l_stat INTEGER
	DEFINE l_ret STRING
	DEFINE l_menu menuData
	LET l_fileName = "order_"||util.Datetime.format(CURRENT,"%Y%m%d%H%M_")||l_order.user_id||".json"
	CALL debug.output(SFMT("placeOrder User: %1 Items: %2 Saved: %3",l_order.user_id, l_order.rows, l_fileName), FALSE)
	LOCATE l_json IN MEMORY
	LET l_json = util.JSON.stringify(l_order)
	CALL l_json.writeFile(l_fileName)
-- TODO: validate that the token is valid.
	IF STATUS != 0 THEN
		RETURN 100,"Invalid Token!"
	END IF
-- Store order in DB
	LET l_menu.ordered = l_order
	CALL l_menu.placeOrderDB() RETURNING l_stat, l_ret
	RETURN l_stat, l_ret
END FUNCTION
--------------------------------------------------------------------------------