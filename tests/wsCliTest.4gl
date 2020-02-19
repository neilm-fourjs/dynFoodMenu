
IMPORT FGL wsUsers
IMPORT FGL wsMenus
IMPORT FGL wsPatients

MAIN
	DEFINE l_stat INT
	DEFINE l_ret1 wsUsers.getTokenResponseBodyType
	DEFINE l_ret2 wsMenus.getMenusResponseBodyType
	DEFINE l_ret3 wsMenus.getMenuResponseBodyType
	DEFINE l_ret4 wsPatients.getWardsResponseBodyType

	CALL wsUsers.getToken("test","test") RETURNING l_stat, l_ret1.*
	DISPLAY SFMT("getToken User: %1 Token:%2",l_ret1.user_name,l_ret1.user_token)

	CALL wsMenus.getMenus() RETURNING l_stat, l_ret2.*
	IF l_stat != 0 THEN
		DISPLAY SFMT("getMenus: %1", l_stat)
	ELSE
		DISPLAY SFMT("getMenus Rows: %1",l_ret2.rows)
	END IF

	CALL wsMenus.getMenu("menu1") RETURNING l_stat, l_ret3.*
	IF l_stat != 0 THEN
		DISPLAY SFMT("getMenu: %1", l_stat)
	ELSE
		DISPLAY SFMT("getMenu Rows: %1",l_ret3.rows)
	END IF

	CALL wsPatients.getWards("dummytoken") RETURNING l_stat, l_ret4.*
	IF l_stat != 0 THEN
		DISPLAY SFMT("getWards: %1", l_stat)
	ELSE
		DISPLAY SFMT("getWards Rows: %1",l_ret4.list.getLength())
	END IF
END MAIN