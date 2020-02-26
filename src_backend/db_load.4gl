IMPORT util
IMPORT os
IMPORT FGL Menus

&include "menus.inc"

DEFINE m_JSONfile TEXT
--------------------------------------------------------------------------------------------------------------
FUNCTION load_data()
	DEFINE l_data Menus
	DEFINE l_users DYNAMIC ARRAY OF userRecord
	DEFINE l_userDetails DYNAMIC ARRAY OF userDetailsRecord
	DEFINE l_wards DYNAMIC ARRAY OF wardRecord
	DEFINE l_patients DYNAMIC ARRAY OF patientRecord
	DEFINE x,y SMALLINT

	IF loadJSON( "users.json" ) THEN
		CALL util.JSON.parse(m_JSONfile, l_users)
		FOR x = 1 TO l_users.getLength()
			DISPLAY "Insert User:",l_users[x].user_id
			INSERT INTO users VALUES( l_users[x].* )
		END FOR
	END IF

	IF loadJSON( "userDetails.json" ) THEN
		CALL util.JSON.parse(m_JSONfile, l_userDetails)
		FOR x = 1 TO l_userDetails.getLength()
			DISPLAY "Insert UserDetails:",l_userDetails[x].user_id
			INSERT INTO userDetails VALUES( l_userDetails[x].* )
		END FOR
	END IF

	IF loadJSON( "wards.json" ) THEN
		CALL util.JSON.parse(m_JSONfile, l_wards)
		FOR x = 1 TO l_wards.getLength()
			DISPLAY "Insert wards:",l_wards[x].ward_id
			INSERT INTO wards VALUES( l_wards[x].* )
		END FOR
	END IF

	IF loadJSON( "patients.json" ) THEN
		CALL util.JSON.parse(m_JSONfile, l_patients)
		FOR x = 1 TO l_patients.getLength()
			DISPLAY "Insert patients:",l_patients[x].id
			INSERT INTO patients VALUES( l_patients[x].* )
		END FOR
	END IF

	IF l_data.getMenuListJSON() THEN
		FOR x = 1 TO l_data.menuList.rows
			DISPLAY "Menu:",l_data.menuList.list[x].menuName,":",l_data.menuList.list[x].menuDesc
			INSERT INTO menus VALUES( l_data.menuList.list[x].* )
			IF l_data.getMenuJSON(l_data.menuList.list[x].menuName) THEN
				FOR y = 1 TO l_data.menu.rows
					INSERT INTO menuItems VALUES( l_data.menu.items[y].* )
				END FOR
			END IF
		END FOR
	END IF

END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION loadJSON(l_file STRING) RETURNS BOOLEAN
	IF os.path.exists( l_file ) THEN
		LOCATE m_JSONfile IN MEMORY
		CALL m_JSONfile.readFile(l_file)
		RETURN TRUE
	ELSE
		DISPLAY SFMT("Missing '%1'",l_file)
		RETURN FALSE
	END IF
END FUNCTION