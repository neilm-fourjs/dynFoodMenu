IMPORT util
IMPORT security
IMPORT FGL debug
IMPORT FGL about
IMPORT FGL utils
IMPORT FGL libMobile
IMPORT FGL wsBackEnd
IMPORT FGL Users

&include "menus.inc"

DEFINE m_users Users
DEFINE m_server_time CHAR(19)

FUNCTION (this userRecord) login(l_win BOOLEAN) RETURNS BOOLEAN
	DEFINE l_stat INT
	DEFINE l_pwd STRING

	IF NOT libMobile.gotNetwork() THEN
		LET this.user_id = "DUMMY"
		LET this.user_name = "Offline"
		IF NOT l_win THEN
			DISPLAY this.user_name TO username
			CALL ui.Window.getCurrent().getForm().setFieldStyle("formonly.username","title curvedborder")
			CALL ui.Window.getCurrent().getForm().setElementHidden("g_login",TRUE)
		END IF
		RETURN TRUE
	END IF
	LET int_flag = FALSE
	LET wsBackEnd.Endpoint.Address.Uri = C_WS_BACKEND
	IF l_win THEN
		OPEN WINDOW login WITH FORM "login"
	END IF
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
				CALL wsBackEnd.getTimestamp() RETURNING l_stat, m_server_time
				CALL debug.output(SFMT("getTimestamp: %1, reply: %2",l_stat, m_server_time),FALSE)
				IF l_stat != 0 THEN
					DISPLAY "Login error" TO username
					CALL fgl_winMessage("Error","1) Error logging in, please try again.","exclamation")
					NEXT FIELD user_id
				END IF
				CALL wsBackEnd.getToken(this.user_id, utils.apiPaas(this.user_id, m_server_time) ) RETURNING l_stat, this.*
				CALL debug.output(SFMT("getToken: %1, reply: %2 : %3(%4)",this.user_id, l_stat, this.user_name, this.user_pwd),FALSE)
				IF l_stat != 0 OR this.user_id = "ERROR" THEN
					DISPLAY "Login error" TO username
					CALL fgl_winMessage("Error","2) Error logging in, please try again.","exclamation")
					NEXT FIELD user_id
				END IF
				IF LENGTH(this.user_pwd) < 2 THEN
					DISPLAY "Invalid login. please report this problem!" TO username
					NEXT FIELD user_id
				END IF
				IF NOT security.BCrypt.CheckPassword(l_pwd, this.user_pwd) THEN
					DISPLAY "Invalid login details, please try again." TO username
					NEXT FIELD user_id
				END IF
			END IF
		ON ACTION register
			CALL register()
	END INPUT
	DISPLAY SFMT("Welcome %1",this.user_name) TO username
	IF NOT l_win THEN
		CALL ui.Window.getCurrent().getForm().setElementHidden("g_login",TRUE)
	ELSE
		CLOSE WINDOW login
	END IF
	IF int_flag THEN
		CALL debug.output("Login Cancelled", FALSE)
		LET int_flag = FALSE
		RETURN FALSE
	END IF
	CALL debug.output(SFMT("getToken: %1 %2 Okay",this.user_id, this.user_token),FALSE )
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION register()
	DEFINE l_pwd2 VARCHAR(60)
	DEFINE x SMALLINT
	DEFINE l_passokay BOOLEAN
	DEFINE l_gotNum BOOLEAN
	DEFINE l_gotAlpha BOOLEAN
	DEFINE l_stat, l_ret SMALLINT
	DEFINE l_exists  BOOLEAN
	DEFINE l_suggestion STRING
	OPEN WINDOW register WITH FORM "register"
	LET m_users.currentUserDetails.registered = CURRENT
	LET m_users.currentUserDetails.dob = "01/01/1970"
	LET int_flag = FALSE
	INPUT BY NAME m_users.currentUserDetails.*, l_pwd2 WITHOUT DEFAULTS
		AFTER FIELD user_id
			CALL wsBackEnd.checkUserID(m_users.currentUserDetails.user_id) RETURNING l_stat, l_exists, l_suggestion
			CALL debug.output(SFMT("checkUserID: %1, reply: %2:%3",l_stat, l_exists, l_suggestion ),FALSE)
			IF l_exists THEN
				IF l_suggestion != "EXISTS" THEN
					MESSAGE "User ID not available, consider: ",l_suggestion
				ELSE
					MESSAGE "User ID not available."
				END IF
				NEXT FIELD user_id
			END IF
		AFTER FIELD password_hash
			LET l_passokay = (LENGTH( m_users.currentUserDetails.password_hash ) > 5)
			LET l_gotAlpha = FALSE
			LET l_gotNum = FALSE
			FOR x = 1 TO LENGTH( m_users.currentUserDetails.password_hash )
				IF m_users.currentUserDetails.password_hash[x] >= "a" AND m_users.currentUserDetails.password_hash[x] <= "z" THEN
					LET l_gotAlpha = TRUE
				END IF
				IF m_users.currentUserDetails.password_hash[x] >= "A" AND m_users.currentUserDetails.password_hash[x] <= "Z" THEN
					LET l_gotAlpha = TRUE
				END IF
				IF m_users.currentUserDetails.password_hash[x] >= "0" AND m_users.currentUserDetails.password_hash[x] <= "9" THEN
					LET l_gotNum = TRUE
				END IF
			END FOR
			IF NOT l_passokay OR NOT l_gotAlpha OR NOT l_gotNum THEN
				ERROR "Password must be at least 6 character and contain both numbers and letters"
				LET m_users.currentUserDetails.password_hash = NULL
				LET l_pwd2 = NULL
				NEXT FIELD password_hash
			END IF

		AFTER FIELD l_pwd2
			IF m_users.currentUserDetails.password_hash != l_pwd2 THEN
				ERROR "Passwords don't match"
				NEXT FIELD password_hash
			END IF
	END INPUT
	IF int_flag THEN
		LET int_flag = FALSE
	ELSE
		CALL m_users.setPasswordHash( l_pwd2 )
		CALL wsBackEnd.registerUser(m_users.currentUserDetails.*) RETURNING l_stat, l_ret, l_suggestion
		CALL debug.output(SFMT("registerUser: %1, reply: %2:%3",l_stat, l_ret, l_suggestion ),FALSE)
		IF l_stat = 0 AND l_ret = 0 THEN
			CALL m_users.register() RETURNING l_ret, l_suggestion
		END IF
		IF l_ret = 0 THEN
			CALL fgl_winMessage("Confirmation","Registation Completed Okay\nYou can now login.","information")
		END IF
	END IF
	CLOSE WINDOW register
END FUNCTION