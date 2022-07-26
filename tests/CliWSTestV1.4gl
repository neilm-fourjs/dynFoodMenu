IMPORT FGL wsAuthLib

IMPORT FGL wsUsers
IMPORT FGL wsMenus
IMPORT FGL wsPatients

MAIN
	DEFINE l_cfgFileName, l_cfgName STRING
	DEFINE wsAuth                   wsAuthLib

-- Initialize Secure Access
	LET l_cfgFileName = "ws_cfg.json"
	LET l_cfgName     = IIF(NUM_ARGS() > 0, ARG_VAL(1), "localv2")
	IF NOT wsAuth.init(".", l_cfgFileName, l_cfgName) THEN
		DISPLAY wsAuth.message
		EXIT PROGRAM
	END IF

-- Setup my specific service end points
	LET wsUsers.Endpoint.Address.Uri    = wsAuth.endPoint || "users"
	LET wsMenus.Endpoint.Address.Uri    = wsAuth.endPoint || "menus"
	LET wsPatients.Endpoint.Address.Uri = wsAuth.endPoint || "patients"
	DISPLAY "Users Endpoint: ", wsUsers.Endpoint.Address.Uri

-- Do test calls
	CALL test_v1()

END MAIN
--------------------------------------------------------------------------------------------------------------
FUNCTION test_v1()
	DEFINE l_stat INT
	DEFINE l_ret1 wsUsers.userRecord
{	DEFINE l_ret2 wsMenus.v1_getMenusResponseBodyType
	DEFINE l_ret3 wsMenus.v1_getMenuResponseBodyType
	DEFINE l_ret4 wsPatients.v1_getWardsResponseBodyType}
	DEFINE l_ts   STRING

	CALL wsUsers.v1_getTimeStamp() RETURNING l_stat, l_ts
	DISPLAY SFMT("v1_getTimestamp Stat: %1 TS: %2", l_stat, l_ts)

-- get my session token
	CALL wsUsers.v1_getUser("test", "test") RETURNING l_stat, l_ret1.*
	DISPLAY SFMT("v1_getUser Stat: %1 User: %2 Token: %3", l_stat, l_ret1.user_name, l_ret1.user_token)
{
	CALL wsMenus.v1_getMenus() RETURNING l_stat, l_ret2.*
	IF l_stat != 0 THEN
		DISPLAY SFMT("v1_getMenus: %1", l_stat)
	ELSE
		DISPLAY SFMT("v1_getMenus Rows: %1", l_ret2.rows)
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
}
END FUNCTION
--------------------------------------------------------------------------------------------------------------
