IMPORT util
IMPORT FGL backEnd

&include "menus.inc"

FUNCTION (this userRecord) login() RETURNS BOOLEAN
	DEFINE l_reply STRING
	LET this.user_id = "NJM"
--TODO: login screen
	LET l_reply = backEnd.getToken(this.user_id, this.user_pwd)
	CALL util.JSON.parse(l_reply, this)
	IF this.user_token IS NOT NULL THEN
		RETURN TRUE
	ELSE
		RETURN FALSE
	END IF
END FUNCTION