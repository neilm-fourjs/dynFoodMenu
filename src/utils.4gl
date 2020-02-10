&include "menus.inc"
--------------------------------------------------------------------------------------------------------------
FUNCTION  apiPaas(l_usr STRING, l_tim CHAR(10)) RETURNS STRING
	DEFINE l_ret STRING
	DEFINE l_char CHAR(50)
	DEFINE l_dte CHAR(10)
	LET l_dte = TODAY
	LET l_char = C_APIPASS
	LET l_char[16, 15+l_usr.getLength()] = l_usr
	LET l_char[22,23] = l_tim[4,5]
	LET l_char[24,25] = l_dte[1,2]
	LET l_char[26,27] = l_dte[4,5]
	LET l_char[28,29] = l_tim[1,2]
	LET l_char[30,31] = l_dte[9,10]
	LET l_ret = l_char CLIPPED
	DISPLAY "APIPass:", l_ret
	RETURN l_ret
END FUNCTION