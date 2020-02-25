
IMPORT security
IMPORT util
IMPORT FGL db
IMPORT FGL Users

&include "menus.inc"

DEFINE m_users Users
DEFINE m_men DYNAMIC ARRAY OF STRING = 
 [ "Fred","George","Michael", "Jim", "Harry", "Matthew", "Henry", "Neil", 
   "Ryan", "Vincent", "Andrew", "Dean", "Kent", "Tim", "John", "Philip" ]
DEFINE m_women DYNAMIC ARRAY OF STRING = 
 [ "Linda","Sara","Sue", "Lucy", "Ann", "Tracey", "Michelle", "Megan", 
   "Debby", "June", "Jane", "Joni", "Gillan", "Amy", "Angelina", "Vicky" ]
MAIN
	DEFINE l_users DYNAMIC ARRAY OF userRecord
	DEFINE l_userDetails DYNAMIC ARRAY OF userDetailsRecord
	DEFINE l_wards DYNAMIC ARRAY OF wardRecord
	DEFINE l_patients DYNAMIC ARRAY OF patientRecord
	DEFINE x SMALLINT = 1
	DEFINE y, p SMALLINT
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

	FOR x = 1 TO 4
		LET l_wards[x].ward_id = x
		CASE x
			WHEN 1 LET l_wards[x].ward_name = "Mars"
			WHEN 2 LET l_wards[x].ward_name = "Jupiter"
			WHEN 3 LET l_wards[x].ward_name = "Saturn"
			WHEN 4 LET l_wards[x].ward_name = "Venus"
		END CASE
	END FOR
	LOCATE l_json IN FILE "../etcBackEnd/wards.json"
	LET l_json = util.JSON.stringify(l_wards)

	LET p = 1
	FOR y = 1 TO l_wards.getLength()
		FOR x = 1 TO 8
			LET l_patients[p].id = p
			LET l_patients[p].ward_id = y
			LET l_patients[p].bed_no = x
			LET l_patients[p].diabetic = FALSE
			LET l_patients[p].nilbymouth = FALSE
			CASE util.Math.rand(15) 
				WHEN 10 LET l_patients[p].diabetic = TRUE
				WHEN 11 LET l_patients[p].nilbymouth = TRUE
				WHEN 1 LET l_patients[p].allergies = "Lactose"
				WHEN 2 LET l_patients[p].allergies = "Gluten"
				WHEN 3 LET l_patients[p].allergies = "Nuts"
			END CASE
			CASE y
				WHEN 1 LET l_patients[p].gender_preference = "M"
				WHEN 2 LET l_patients[p].gender_preference = "F"
				WHEN 3 LET l_patients[p].gender_preference = "M"
				WHEN 4 LET l_patients[p].gender_preference = "F"
			END CASE
			LET l_patients[p].name = genName(l_patients[p].gender_preference)
			LET p = p + 1
		END FOR
	END FOR
	LOCATE l_json IN FILE "../etcBackEnd/patients.json"
	LET l_json = util.JSON.stringify(l_patients)
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
--------------------------------------------------------------------------------------------------------------
FUNCTION genName(l_gen CHAR(1)) RETURNS STRING
	DEFINE l_nam STRING
	IF l_gen = "M" THEN
		LET l_nam = m_men[ 1 ]
		CALL m_men.deleteElement(1)
	ELSE
		LET l_nam = m_women[ 1 ]
		CALL m_women.deleteElement(1)
	END IF
	RETURN l_nam
END FUNCTION
