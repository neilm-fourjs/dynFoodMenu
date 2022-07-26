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
	CALL test_v2()

END MAIN
--------------------------------------------------------------------------------------------------------------
FUNCTION test_v2()
	DEFINE l_stat INT
	DEFINE l_ts   STRING

	DISPLAY "Doing v2_getTimestamp ..."
	CALL wsUsers.v2_getTimestamp() RETURNING l_stat, l_ts
	IF l_stat != 0 THEN
		CASE STATUS
			WHEN -15553 -- TCP socket error
				IF INT_FLAG THEN
					DISPLAY "An interruption occurred."
				ELSE
					DISPLAY "TCP socket error: ", SQLCA.SQLERRM
				END IF
			OTHERWISE
				DISPLAY SFMT("Stat: %1 Status: %2 - %3", l_stat, STATUS, ERR_GET( STATUS ) )
		END CASE
		EXIT PROGRAM
	ELSE
		DISPLAY SFMT("v2_getTimestamp Stat: %1 TS: %2", l_stat, l_ts)
	END IF

	DISPLAY "Sleeping 605 seconds!"
	SLEEP 605
	DISPLAY "Doing v2_getTimestamp ..."
	CALL wsUsers.v2_getTimestamp() RETURNING l_stat, l_ts
	IF l_stat != 0 THEN
		CASE STATUS
			WHEN -15553 -- TCP socket error
				IF INT_FLAG THEN
					DISPLAY "An interruption occurred."
				ELSE
					DISPLAY "TCP socket error: ", SQLCA.SQLERRM
				END IF
			OTHERWISE
				DISPLAY SFMT("Stat: %1 Status: %2 - %3", l_stat, STATUS, ERR_GET( STATUS ) )
		END CASE
		EXIT PROGRAM
	ELSE
		DISPLAY SFMT("v2_getTimestamp Stat: %1 TS: %2", l_stat, l_ts)
	END IF

{
-- get my session token
	CALL wsUsers.v2_getUser("test", "test", NULL, NULL) RETURNING l_stat, l_ret1.*
	DISPLAY SFMT("v2_getUser Stat: %1 User: %2 Token: %3", l_stat, l_ret1.user_name, l_ret1.user_token)

	CALL wsMenus.v2_getMenus(NULL) RETURNING l_stat, l_ret2.*
	IF l_stat != 0 THEN
		DISPLAY SFMT("v2_getMenus: %1", l_stat)
	ELSE
		DISPLAY SFMT("v2_getMenus Rows: %1", l_ret2.rows)
	END IF

	CALL wsMenus.v2_getMenu("menu1") RETURNING l_stat, l_ret3.*
	IF l_stat != 0 THEN
		DISPLAY SFMT("v2_getMenu: %1", l_stat)
	ELSE
		DISPLAY SFMT("v2_getMenu Rows: %1", l_ret3.rows)
	END IF

	CALL wsPatients.v2_getWards("dummytoken") RETURNING l_stat, l_ret4.*
	IF l_stat != 0 THEN
		DISPLAY SFMT("getWards: %1", l_stat)
	ELSE
		DISPLAY SFMT("v2_getWards Rows: %1", l_ret4.list.getLength())
	END IF
}
END FUNCTION
