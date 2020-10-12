
IMPORT FGL wsAuthLib

IMPORT FGL wsUsers
IMPORT FGL wsMenus
IMPORT FGL wsPatients

MAIN
	DEFINE l_cfgFileName STRING
	DEFINE wsAuth wsAuthLib

-- Initialize Secure Access
  LET l_cfgFileName = IIF(NUM_ARGS()>0, ARG_VAL(1), "ws_cfg.json")
	IF NOT wsAuth.init(".", l_cfgFileName, NULL) THEN
		DISPLAY wsAuth.message
		EXIT PROGRAM
	ELSE
		DISPLAY "userID: ", wsAuth.user_id
	END IF

-- Setup my specific service end points
	LET wsUsers.Endpoint.Address.Uri    = wsAuth.endPoint || "users"
	LET wsMenus.Endpoint.Address.Uri    = wsAuth.endPoint || "menus"
	LET wsPatients.Endpoint.Address.Uri = wsAuth.endPoint || "patients"
	DISPLAY "Users Endpoint: ",wsUsers.Endpoint.Address.Uri

-- Do test calls
	CASE wsAuth.cfg.ServiceVersion
		WHEN "v1" CALL test_v1()
		WHEN "v2" CALL test_v2()
	END CASE

END MAIN
--------------------------------------------------------------------------------------------------------------
FUNCTION test_v1()
	DEFINE l_stat INT
	DEFINE l_ret1 wsUsers.v1_getTokenResponseBodyType
	DEFINE l_ret2 wsMenus.v1_getMenusResponseBodyType
	DEFINE l_ret3 wsMenus.v1_getMenuResponseBodyType
	DEFINE l_ret4 wsPatients.v1_getWardsResponseBodyType
	DEFINE l_ts   STRING

	CALL wsUsers.v1_getTimestamp() RETURNING l_stat, l_ts
	DISPLAY SFMT("getTimestamp Stat: %1 TS:%2", l_stat, l_ts)

	CALL wsUsers.v1_getToken("test", "test") RETURNING l_stat, l_ret1.*
	DISPLAY SFMT("getToken User: %1 Token:%2", l_ret1.user_name, l_ret1.user_token)

	CALL wsMenus.v1_getMenus(NULL) RETURNING l_stat, l_ret2.*
	IF l_stat != 0 THEN
		DISPLAY SFMT("getMenus: %1", l_stat)
	ELSE
		DISPLAY SFMT("getMenus Rows: %1", l_ret2.rows)
	END IF

	CALL wsMenus.v1_getMenu("menu1") RETURNING l_stat, l_ret3.*
	IF l_stat != 0 THEN
		DISPLAY SFMT("getMenu: %1", l_stat)
	ELSE
		DISPLAY SFMT("getMenu Rows: %1", l_ret3.rows)
	END IF

	CALL wsPatients.v1_getWards("dummytoken") RETURNING l_stat, l_ret4.*
	IF l_stat != 0 THEN
		DISPLAY SFMT("getWards: %1", l_stat)
	ELSE
		DISPLAY SFMT("getWards Rows: %1", l_ret4.list.getLength())
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION test_v2()
	DEFINE l_stat INT
	DEFINE l_ret1 wsUsers.v1_getTokenResponseBodyType
	DEFINE l_ret2 wsMenus.v1_getMenusResponseBodyType
	DEFINE l_ret3 wsMenus.v1_getMenuResponseBodyType
	DEFINE l_ret4 wsPatients.v1_getWardsResponseBodyType
	DEFINE l_ts   STRING

	CALL wsUsers.v2_getTimestamp() RETURNING l_stat, l_ts
	DISPLAY SFMT("getTimestamp Stat: %1 TS:%2", l_stat, l_ts)

	CALL wsUsers.v2_getToken("test", "test") RETURNING l_stat, l_ret1.*
	DISPLAY SFMT("getToken User: %1 Token:%2", l_ret1.user_name, l_ret1.user_token)

	CALL wsMenus.v2_getMenus(NULL) RETURNING l_stat, l_ret2.*
	IF l_stat != 0 THEN
		DISPLAY SFMT("getMenus: %1", l_stat)
	ELSE
		DISPLAY SFMT("getMenus Rows: %1", l_ret2.rows)
	END IF

	CALL wsMenus.v2_getMenu("menu1") RETURNING l_stat, l_ret3.*
	IF l_stat != 0 THEN
		DISPLAY SFMT("getMenu: %1", l_stat)
	ELSE
		DISPLAY SFMT("getMenu Rows: %1", l_ret3.rows)
	END IF

	CALL wsPatients.v2_getWards("dummytoken") RETURNING l_stat, l_ret4.*
	IF l_stat != 0 THEN
		DISPLAY SFMT("getWards: %1", l_stat)
	ELSE
		DISPLAY SFMT("getWards Rows: %1", l_ret4.list.getLength())
	END IF
END FUNCTION
