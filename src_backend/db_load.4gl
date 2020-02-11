IMPORT util
IMPORT os
IMPORT FGL menuData

&include "menus.inc"
--------------------------------------------------------------------------------------------------------------
FUNCTION load_data()
	DEFINE l_data menuData
	DEFINE l_users DYNAMIC ARRAY OF userRecord
	DEFINE l_userDetails DYNAMIC ARRAY OF userDetailsRecord
	DEFINE x,y SMALLINT
	DEFINE l_userJSON TEXT

	IF os.path.exists( "users.json" ) THEN
		LOCATE l_userJSON IN MEMORY
		CALL l_userJSON.readFile("users.json")
		CALL util.JSON.parse(l_userJSON, l_users)
		FOR x = 1 TO l_users.getLength()
			DISPLAY "Insert User:",l_users[x].user_id
			INSERT INTO users VALUES( l_users[x].* )
		END FOR
	ELSE
		DISPLAY "Missing 'users.json'"
	END IF

	IF os.path.exists( "userDetails.json" ) THEN
		LOCATE l_userJSON IN MEMORY
		CALL l_userJSON.readFile("userDetails.json")
		CALL util.JSON.parse(l_userJSON, l_userDetails)
		FOR x = 1 TO l_userDetails.getLength()
			DISPLAY "Insert UserDetails:",l_userDetails[x].user_id
			INSERT INTO userDetails VALUES( l_userDetails[x].* )
		END FOR
	ELSE
		DISPLAY "Missing 'usersDetails.json'"
	END IF

	IF l_data.getMenuListJSON() THEN
		FOR x = 1 TO l_data.menuList.rows
			DISPLAY "Menu:",l_data.menuList.list[x].menuName,":",l_data.menuList.list[x].menuDesc
			INSERT INTO menus VALUES( l_data.menuList.list[x].* )
			IF l_data.getMenuJSON(l_data.menuList.list[x].menuName) THEN
				FOR y = 1 TO l_data.menuData.rows
					INSERT INTO menuItems VALUES( l_data.menuData.items[y].* )
				END FOR
			END IF
		END FOR
	END IF

END FUNCTION