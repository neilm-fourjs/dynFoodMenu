
-- This service handles the login and issueing the security token.

IMPORT security
IMPORT util
IMPORT FGL Users
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
		description: "A RESTFUL backend for the dynFoodMenu mobile demo - Serving: Users",
    version: "1.0", 
    contact: ( name: "Neil J Martin", email:"neilm@4js.com") )

DEFINE m_user Users
DEFINE m_ts CHAR(19)
--------------------------------------------------------------------------------
#+ GET <server>/ws/r/dfm/users/getToken/id/pwd
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
#+ GET <server>/ws/r/dfm/users/checkUserID/id
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
#+ GET <server>/ws/r/dfm/users/getTime
#+ result: A menu array by ID
PUBLIC FUNCTION getTimeStamp() ATTRIBUTES( WSPath = "/getTimestamp", 
		WSGet, 
		WSDescription = "Get the server time")
	RETURNS (CHAR(19) ATTRIBUTES(WSMedia = 'application/json'))
	IF m_ts IS NULL THEN LET m_ts = CURRENT YEAR TO SECOND END IF
	RETURN m_ts
END FUNCTION
--------------------------------------------------------------------------------
#+ POST <server>/ws/r/dfm/users/placeOrder
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
