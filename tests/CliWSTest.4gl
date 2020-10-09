
IMPORT FGL libWSAuth
IMPORT FGL wsUsers
IMPORT FGL wsMenus
IMPORT FGL wsPatients

DEFINE m_user_id STRING
MAIN
	DEFINE l_stat INT
	DEFINE l_ret1 wsUsers.v1_getTokenResponseBodyType
	DEFINE l_ret2 wsMenus.v1_getMenusResponseBodyType
	DEFINE l_ret3 wsMenus.v1_getMenuResponseBodyType
	DEFINE l_ret4 wsPatients.v1_getWardsResponseBodyType
	DEFINE l_ts STRING

	# Initialize Secure Access
	IF NOT libWSAuth.init("ws_cfg.json") THEN
		DISPLAY "libWSAuth init failed."
		EXIT PROGRAM
	ELSE
		DISPLAY "userID: ",libWSAuth.user_id
	END IF

	LET wsUsers.Endpoint.Address.Uri = libWSAuth.serviceConfig.endPoint||"/users"
	LET wsMenus.Endpoint.Address.Uri = libWSAuth.serviceConfig.endPoint||"/menus"
	LET wsPatients.Endpoint.Address.Uri = libWSAuth.serviceConfig.endPoint||"/patients"

	CALL wsUsers.v1_getTimestamp() RETURNING l_stat, l_ts
	DISPLAY SFMT("getTimestamp Stat: %1 TS:%2",l_stat, l_ts)

	CALL wsUsers.v1_getToken("test","test") RETURNING l_stat, l_ret1.*
	DISPLAY SFMT("getToken User: %1 Token:%2",l_ret1.user_name,l_ret1.user_token)

	CALL wsMenus.v1_getMenus( NULL ) RETURNING l_stat, l_ret2.*
	IF l_stat != 0 THEN
		DISPLAY SFMT("getMenus: %1", l_stat)
	ELSE
		DISPLAY SFMT("getMenus Rows: %1",l_ret2.rows)
	END IF

	CALL wsMenus.v1_getMenu("menu1") RETURNING l_stat, l_ret3.*
	IF l_stat != 0 THEN
		DISPLAY SFMT("getMenu: %1", l_stat)
	ELSE
		DISPLAY SFMT("getMenu Rows: %1",l_ret3.rows)
	END IF

	CALL wsPatients.v1_getWards("dummytoken") RETURNING l_stat, l_ret4.*
	IF l_stat != 0 THEN
		DISPLAY SFMT("getWards: %1", l_stat)
	ELSE
		DISPLAY SFMT("getWards Rows: %1",l_ret4.list.getLength())
	END IF
END MAIN
