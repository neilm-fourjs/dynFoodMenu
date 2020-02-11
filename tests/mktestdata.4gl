
IMPORT security
IMPORT util
IMPORT FGL db

&include "menus.inc"

DEFINE l_users DYNAMIC ARRAY OF userRecord
DEFINE l_userDetails DYNAMIC ARRAY OF userDetailsRecord
MAIN
	DEFINE x SMALLINT = 1
	DEFINE l_json TEXT

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