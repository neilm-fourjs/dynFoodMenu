&include "menus.inc"
--------------------------------------------------------------------------------------------------------------
-- 2020-02-10 15:52:22
-- 1234567890123456789
FUNCTION  apiPaas(l_usr STRING, l_ts CHAR(19)) RETURNS STRING
	DEFINE l_ret STRING
	DEFINE l_char CHAR(50)
	LET l_char = C_APIPASS
	LET l_char[16, 15+l_usr.getLength()] = l_usr
	LET l_char[22,23] = l_ts[3,4] -- year
	LET l_char[24,25] = l_ts[15,16] -- min
	LET l_char[26,27] = l_ts[6,7] -- month
	LET l_char[28,29] = l_ts[12,13] -- hours
	LET l_char[30,31] = l_ts[9,10] -- day
	LET l_char[32,33] = l_ts[18,19] -- seconds
	LET l_ret = l_char CLIPPED
	DISPLAY "APIPass:", l_ret
	RETURN l_ret
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION ws_replyStat( l_stat INT ) RETURNS STRING
	DEFINE l_reply STRING
	CASE l_stat
		WHEN 200
			LET l_reply = "Success"
		WHEN 403
			LET l_reply = "Forbidden"
		OTHERWISE
			LET l_reply = SFMT("Unexpected reply status: %1 ",l_stat)
	END CASE
	RETURN l_reply
END FUNCTION