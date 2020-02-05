IMPORT util
IMPORT security
IMPORT FGL debug
IMPORT FGL about
IMPORT FGL mobLib
IMPORT FGL wsBackEnd

&include "menus.inc"

FUNCTION (this userRecord) login() RETURNS BOOLEAN
	DEFINE l_network BOOLEAN
	DEFINE l_stat INT
	DEFINE l_pwd STRING
	LET l_netWork = mobLib.gotNetwork()
	IF NOT l_network THEN
		LET this.user_id = "DUMMY"
		LET this.user_name = "offline"
		RETURN TRUE
	END IF
	LET int_flag = FALSE
	LET wsBackEnd.Endpoint.Address.Uri = C_WS_BACKEND
	OPEN WINDOW login WITH FORM "login"
	INPUT BY NAME this.user_id, this.user_pwd
		ON ACTION about CALL about.show()
		AFTER INPUT
			IF NOT int_flag THEN
				CALL debug.output(SFMT("Getting token for: %1 from: %2 ", this.user_id, wsBackEnd.Endpoint.Address.Uri), FALSE)
				LET l_pwd = this.user_pwd
				CALL wsBackEnd.getToken(this.user_id, C_APIPASS) RETURNING l_stat, this.*
				IF l_stat != 0 THEN
					CALL debug.output(SFMT("getToken: %1, reply: %2 : %3",this.user_id, l_stat, this.user_name),FALSE)
					CALL fgl_winMessage("Error","Error logging in, please try again.","exclamation")
					NEXT FIELD user_id
				END IF
				IF security.BCrypt.CheckPassword(l_pwd, this.user_pwd) THEN
					CALL fgl_winMessage("Error","Invalid login details, please try again.","exclamation")
					NEXT FIELD user_id
				END IF
			END IF
	END INPUT
	CLOSE WINDOW login
	IF int_flag THEN LET int_flag = FALSE RETURN FALSE END IF
	CALL debug.output(SFMT("getToken: %1 %2 Okay",this.user_id, this.user_token),FALSE )
	RETURN TRUE
END FUNCTION