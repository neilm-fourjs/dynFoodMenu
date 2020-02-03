
IMPORT FGL wsBackEnd
CONSTANT C_WS_BACKEND="https://generodemos.dynu.net/g/ws/r/dynFoodRest"

MAIN
	DEFINE l_stat INT
	DEFINE l_ret1 wsBackEnd.getTokenResponseBodyType
	DEFINE l_ret2 wsBackEnd.getMenusResponseBodyType

	LET wsBackEnd.Endpoint.Address.Uri = C_WS_BACKEND

	CALL wsBackEnd.getToken("test","test") RETURNING l_stat, l_ret1.*
	DISPLAY l_ret1.user_name,":",l_ret1.user_token

	CALL wsBackEnd.getMenus() RETURNING l_stat, l_ret2.*
	IF l_stat != 0 THEN
		DISPLAY SFMT("getMenus: %1", l_stat)
	ELSE
		DISPLAY l_ret2.rows
	END IF
END MAIN