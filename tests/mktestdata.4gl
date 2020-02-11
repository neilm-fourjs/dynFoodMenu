
IMPORT security
IMPORT util
IMPORT FGL db
IMPORT FGL Users
&include "menus.inc"
DEFINE m_users Users
DEFINE l_users DYNAMIC ARRAY OF userRecord
DEFINE l_userDetails DYNAMIC ARRAY OF userDetailsRecord
MAIN
	DEFINE x SMALLINT = 1
	DEFINE l_json TEXT

	CALL testCheck("NJM")
	CALL testCheck("NJM1")
	CALL testCheck("NJM01")
	CALL testCheck("NJM001")
	CALL testCheck("NJM007")

	LET l_users[x].user_id = "NJM"
	LET l_users[x].user_name = "Neil Martin"
	LET l_users[x].user_pwd = doPassword("12neilm")
	LET l_userDetails[x].user_id = l_users[x].user_id
	LET l_userDetails[x].password_hash = l_users[x].user_pwd
	LET l_userDetails[x].registered = CURRENT
	LET l_userDetails[x].gender_preference = "M"
	LET l_userDetails[x].email = "neilm@4js.com"
	LET l_userDetails[x].salutation = "Mr"
	LET l_userDetails[x].firstnames = "Neil"
	LET l_userDetails[x].surname = "Martin"
	LET x = x + 1
	LET l_users[x].user_id = "RH"
	LET l_users[x].user_name = "Ryan Hamlin"
	LET l_users[x].user_pwd = doPassword("12ryanh")
	LET l_userDetails[x].user_id = l_users[x].user_id
	LET l_userDetails[x].password_hash = l_users[x].user_pwd
	LET l_userDetails[x].registered = CURRENT
	LET l_userDetails[x].gender_preference = "M"
	LET l_userDetails[x].email = "ryanh@4js.com"
	LET l_userDetails[x].salutation = "Mr"
	LET l_userDetails[x].firstnames = "Ryan"
	LET l_userDetails[x].surname = "Hamlin"

	LOCATE l_json IN FILE "../etcBackEnd/users.json"
	LET l_json = util.JSON.stringify(l_users)
	LOCATE l_json IN FILE "../etcBackEnd/userDetails.json"
	LET l_json = util.JSON.stringify(l_userDetails)
END MAIN
--------------------------------------------------------------------------------------------------------------
FUNCTION doPassword( l_pwd STRING )
	DEFINE l_salt STRING
	LET l_salt = security.BCrypt.GenerateSalt(10)
	RETURN Security.BCrypt.HashPassword(l_pwd, l_salt)
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION testCheck(l_id CHAR(6))
	DEFINE l_exists BOOLEAN
	DEFINE l_suggestion CHAR(6)
	CALL m_users.checkUserID(l_id) RETURNING l_exists, l_suggestion
	DISPLAY l_id, " Exists:",l_exists, " Suggestion:",l_suggestion
END FUNCTION