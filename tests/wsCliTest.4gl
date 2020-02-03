
IMPORT FGL wsBackEnd
CONSTANT C_WS_BACKEND="https://generodemos.dynu.net/g/ws/r/dynFoodRest"

MAIN
	DEFINE l_stat INT
	DEFINE l_ret1 wsBackEnd.getTokenResponseBodyType
	DEFINE l_ret2 wsBackEnd.getMenusResponseBodyType
	DEFINE l_ret3 wsBackEnd.getMenuResponseBodyType

	LET wsBackEnd.Endpoint.Address.Uri = C_WS_BACKEND

	CALL wsBackEnd.getToken("test","test") RETURNING l_stat, l_ret1.*
	DISPLAY SFMT("getToken User: %1 Token:%2",l_ret1.user_name,l_ret1.user_token)

	CALL wsBackEnd.getMenus() RETURNING l_stat, l_ret2.*
	IF l_stat != 0 THEN
		DISPLAY SFMT("getMenus: %1", l_stat)
	ELSE
		DISPLAY SFMT("getMenus Rows: %1",l_ret2.rows)
	END IF

	CALL wsBackEnd.getMenu("menu1") RETURNING l_stat, l_ret3.*
	IF l_stat != 0 THEN
		DISPLAY SFMT("getMenu: %1", l_stat)
	ELSE
		DISPLAY SFMT("getMenu Rows: %1",l_ret3.rows)
	END IF
END MAIN