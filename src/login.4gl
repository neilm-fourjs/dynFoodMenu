IMPORT util
IMPORT FGL debug
IMPORT FGL wsBackEnd

&include "menus.inc"

FUNCTION (this userRecord) login(l_network BOOLEAN) RETURNS BOOLEAN
	DEFINE l_stat INT
--TODO: login screen
	IF l_network THEN
		LET this.user_id = "NJM"
		LET this.user_pwd = "test"
		LET wsBackEnd.Endpoint.Address.Uri = C_WS_BACKEND
		CALL debug.output(SFMT("Getting token for: %1 from: %2 ", this.user_id, wsBackEnd.Endpoint.Address.Uri), FALSE)
		CALL wsBackEnd.getToken(this.user_id, this.user_pwd) RETURNING l_stat, this.*
		IF l_stat != 0 THEN
			CALL debug.output(SFMT("getToken: %1, reply: %2 : %3",this.user_id, l_stat, this.user_name),FALSE)
			RETURN FALSE
		END IF
	ELSE
		LET this.user_id = "DUMMY"
		LET this.user_name = "offline"
	END IF

	IF this.user_token IS NOT NULL THEN
		CALL debug.output(SFMT("getToken: %1 %2 Okay",this.user_id, this.user_token),FALSE )
		RETURN TRUE
	ELSE
		CALL debug.output(SFMT("getToken: %1 NULL Token!",this.user_id),FALSE )
		RETURN FALSE
	END IF
END FUNCTION