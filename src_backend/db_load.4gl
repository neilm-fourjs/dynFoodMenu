IMPORT util
IMPORT FGL menuData

&include "menus.inc"
--------------------------------------------------------------------------------------------------------------
FUNCTION load_data()
	DEFINE l_data menuData
	DEFINE l_users DYNAMIC ARRAY OF userRecord
	DEFINE x,y SMALLINT
	DEFINE l_userJSON TEXT

	LOCATE l_userJSON IN MEMORY
	CALL l_userJSON.readFile("users.json")
	CALL util.JSON.parse(l_userJSON, l_users)
	FOR x = 1 TO l_users.getLength()
		DISPLAY "Insert:",l_users[x].user_name
		INSERT INTO users VALUES( l_users[x].* )
	END FOR

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