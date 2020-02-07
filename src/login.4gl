IMPORT util
IMPORT security
IMPORT FGL debug
IMPORT FGL about
IMPORT FGL libMobile
IMPORT FGL wsBackEnd

&include "menus.inc"

FUNCTION (this userRecord) login() RETURNS BOOLEAN
	DEFINE l_network BOOLEAN
	DEFINE l_stat INT
	DEFINE l_pwd STRING
	LET l_netWork = libMobile.gotNetwork()
	IF NOT l_network THEN
		LET this.user_id = "DUMMY"
		LET this.user_name = "Offline"
		DISPLAY this.user_name TO username
		CALL ui.Window.getCurrent().getForm().setFieldStyle("formonly.username","title curvedborder")
		RETURN TRUE
	END IF
	LET int_flag = FALSE
	LET wsBackEnd.Endpoint.Address.Uri = C_WS_BACKEND
	--OPEN WINDOW login WITH FORM "login"
	CALL ui.Window.getCurrent().getForm().setElementHidden("g_login",FALSE)
	CALL ui.Window.getCurrent().getForm().setFieldStyle("formonly.username","title")
	INPUT BY NAME this.user_id, this.user_pwd WITHOUT DEFAULTS
		BEFORE FIELD user_pwd
			DISPLAY "" TO username
			LET this.user_pwd = ""
		ON ACTION about CALL about.show()
		AFTER INPUT
			IF NOT int_flag THEN
				CALL debug.output(SFMT("Getting token for: %1 from: %2 ", this.user_id, wsBackEnd.Endpoint.Address.Uri), FALSE)
				LET l_pwd = this.user_pwd
				CALL ui.Window.getCurrent().getForm().setFieldStyle("formonly.username","title curvedborder")
				CALL wsBackEnd.getToken(this.user_id, C_APIPASS) RETURNING l_stat, this.*
				CALL debug.output(SFMT("getToken: %1, reply: %2 : %3(%4)",this.user_id, l_stat, this.user_name, this.user_pwd),FALSE)
				IF l_stat != 0 OR this.user_id = "ERROR" THEN
					DISPLAY "Login error" TO username
					CALL fgl_winMessage("Error","Error logging in, please try again.","exclamation")
					NEXT FIELD user_id
				END IF
				IF NOT security.BCrypt.CheckPassword(l_pwd, this.user_pwd) THEN
					DISPLAY "Invalid login details, please try again." TO username
					NEXT FIELD user_id
				END IF
			END IF
	END INPUT
	DISPLAY SFMT("Welcome %1",this.user_name) TO username
	CALL ui.Window.getCurrent().getForm().setElementHidden("g_login",TRUE)
--	CLOSE WINDOW login
	IF int_flag THEN LET int_flag = FALSE RETURN FALSE END IF
	CALL debug.output(SFMT("getToken: %1 %2 Okay",this.user_id, this.user_token),FALSE )
	RETURN TRUE
END FUNCTION