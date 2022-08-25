
IMPORT security
IMPORT FGL main
IMPORT FGL config
IMPORT FGL db
IMPORT FGL wsAuthLib
IMPORT FGL debug
IMPORT FGL about
IMPORT FGL utils
IMPORT FGL libCommon
IMPORT FGL libMobile
IMPORT FGL wsUsers

&include "app.inc"
&include "globals.inc"

PUBLIC TYPE Users RECORD
  list DYNAMIC ARRAY OF userRecord,
	currentUser userRecord,
	currentUserDetails userDetailsRecord,
	errorMessage STRING,
	server_time CHAR(19)
END RECORD
--------------------------------------------------------------------------------
-- Does the user exist
PUBLIC FUNCTION (this Users) get(l_userId LIKE users.user_id) RETURNS BOOLEAN
	DEFINE x SMALLINT
	WHENEVER ERROR CALL libCommon.abort
	IF this.list.getLength() = 0 THEN CALL this.loadFromDB() END IF
	FOR x = 1 TO this.list.getLength()
		IF this.list[x].user_id = l_userId THEN
			LET this.currentUser.* = this.list[x].*
			DISPLAY "Found User:",l_userId
			SELECT * FROM userdetails WHERE user_id = l_userId
			RETURN TRUE
		END IF
	END FOR
	RETURN FALSE
END FUNCTION
--------------------------------------------------------------------------------
-- Add a new to the database.
PUBLIC FUNCTION (this Users) add() RETURNS BOOLEAN
	IF this.currentUser.user_id IS NULL OR this.currentUser.user_id = " " THEN
		LET this.errorMessage = "User Id invalid!"
		RETURN FALSE
	END IF
	IF this.get(this.currentUser.user_id) THEN
		LET this.errorMessage = "User Id already used!"
		RETURN FALSE
	END IF
	IF NOT g_db.connect() THEN EXIT PROGRAM END IF
	LET this.errorMessage = "User Added Okay."
	INSERT INTO users VALUES(this.currentUser.*)
	IF STATUS != 0 THEN
		LET this.errorMessage = "1)"||SQLERRMESSAGE
		RETURN FALSE
	END IF
	INSERT INTO userdetails VALUES(this.currentUserDetails.*)
	IF STATUS != 0 THEN
		LET this.errorMessage = "2)"||SQLERRMESSAGE
		RETURN FALSE
	END IF
	CALL this.loadFromDB()
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
-- Update a user record
PUBLIC FUNCTION (this Users) update() RETURNS BOOLEAN
	IF NOT g_db.connect() THEN EXIT PROGRAM END IF
	LET this.errorMessage = "User Update Okay."
	UPDATE users SET users.* = this.currentUser.* WHERE users.user_id = this.currentUser.user_id
	IF STATUS != 0 THEN
		LET this.errorMessage = "1)"||SQLERRMESSAGE
		RETURN FALSE
	END IF
	UPDATE userdetails SET userdetails.* = this.currentUserDetails.* WHERE userdetails.user_id = this.currentUser.user_id
	IF STATUS != 0 THEN
		LET this.errorMessage = "2)"||SQLERRMESSAGE
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
-- Delete a user record
PUBLIC FUNCTION (this Users) delete(l_userId LIKE users.user_id) RETURNS BOOLEAN
	IF NOT g_db.connect() THEN EXIT PROGRAM END IF
	LET this.errorMessage = "User Deleted Okay."
	DELETE FROM users WHERE users.user_id = l_userId
	IF STATUS != 0 THEN
		LET this.errorMessage = "1)"||SQLERRMESSAGE
		RETURN FALSE
	END IF
	DELETE FROM userdetails WHERE userdetails.user_id = l_userId
	IF STATUS != 0 THEN
		LET this.errorMessage = "2)"||SQLERRMESSAGE
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
-- See if user_id already exists.
-- result is boolean:false=okay to use true=exists plus a suggestion.
PUBLIC FUNCTION (this Users) checkUserID(l_id  LIKE users.user_id) RETURNS (BOOLEAN, CHAR(6))
	DEFINE l_exists BOOLEAN = TRUE
	DEFINE l_suggestion CHAR(6) = "EXISTS"
	DEFINE l_cnt, l_len, x SMALLINT
	IF NOT g_db.connect() THEN EXIT PROGRAM END IF
	SELECT COUNT(*) INTO l_cnt FROM users WHERE user_id = l_id
	IF l_cnt = 0 THEN RETURN FALSE, "Okay" END IF
	LET l_len = LENGTH( l_id )
	FOR x = l_len TO 2 STEP -1
		IF l_id[x] >= "A" AND l_id[x] <= "Z" THEN
			EXIT FOR
		END IF
	END FOR
	LET l_len = x
	IF l_len < 6 THEN
		LET l_id[ l_len + 1, 6 ] = "%      "
		SELECT COUNT(*) INTO l_cnt FROM users WHERE user_id LIKE l_id
		LET l_suggestion = l_id[1, l_len]||l_cnt+1
	END IF
	RETURN l_exists, l_suggestion
END FUNCTION
--------------------------------------------------------------------------------
-- See if user_id already exists.
PUBLIC FUNCTION (this Users) register() RETURNS (INT, STRING)
	DEFINE l_stat SMALLINT = 0
	LET this.currentUser.user_id = this.currentUserDetails.user_id
	LET this.currentUser.user_name = this.currentUserDetails.firstnames CLIPPED||" "||this.currentUserDetails.surname
	LET this.currentUser.user_pwd = this.currentUserDetails.password_hash
	IF NOT this.add() THEN
		LET l_stat = 1
	END IF
	RETURN l_stat, this.errorMessage
END FUNCTION
--------------------------------------------------------------------------------
-- 
PUBLIC FUNCTION (this Users) setPasswordHash(l_pwd STRING)
	DEFINE l_salt STRING
	LET l_salt = security.BCrypt.GenerateSalt(10)
	LET this.currentUser.user_pwd = security.BCrypt.HashPassword(l_pwd, l_salt)
	LET this.currentUserDetails.password_hash = this.currentUser.user_pwd
END FUNCTION
--------------------------------------------------------------------------------
--
FUNCTION (this Users) loadFromDB()
	DEFINE l_user userRecord
	IF NOT g_db.connect() THEN EXIT PROGRAM END IF
	CALL this.list.clear()
	DECLARE load_cur CURSOR FOR SELECT * FROM users
	FOREACH load_cur INTO l_user.*
		LET this.list[ this.list.getLength() + 1 ].* = l_user.*
	END FOREACH
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Register a new user
FUNCTION (this Users) registerUI()
	DEFINE l_pwd2 VARCHAR(60)
	DEFINE x SMALLINT
	DEFINE l_passokay BOOLEAN
	DEFINE l_gotNum BOOLEAN
	DEFINE l_gotAlpha BOOLEAN
	DEFINE l_stat, l_ret SMALLINT
	DEFINE l_exists  BOOLEAN
	DEFINE l_suggestion STRING
	OPEN WINDOW register WITH FORM "register"
	LET this.currentUserDetails.registered = CURRENT
	LET this.currentUserDetails.dob = "01/01/1970"
	LET int_flag = FALSE

	INPUT BY NAME this.currentUserDetails.*, l_pwd2 WITHOUT DEFAULTS
		AFTER FIELD user_id
			CALL wsUsers.v2_checkUserID(this.currentUserDetails.user_id) RETURNING l_stat, l_exists, l_suggestion
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
			LET l_passokay = (LENGTH( this.currentUserDetails.password_hash ) > 5)
			LET l_gotAlpha = FALSE
			LET l_gotNum = FALSE
			FOR x = 1 TO LENGTH( this.currentUserDetails.password_hash )
				IF this.currentUserDetails.password_hash[x] >= "a" AND this.currentUserDetails.password_hash[x] <= "z" THEN
					LET l_gotAlpha = TRUE
				END IF
				IF this.currentUserDetails.password_hash[x] >= "A" AND this.currentUserDetails.password_hash[x] <= "Z" THEN
					LET l_gotAlpha = TRUE
				END IF
				IF this.currentUserDetails.password_hash[x] >= "0" AND this.currentUserDetails.password_hash[x] <= "9" THEN
					LET l_gotNum = TRUE
				END IF
			END FOR
			IF NOT l_passokay OR NOT l_gotAlpha OR NOT l_gotNum THEN
				ERROR "Password must be at least 6 character and contain both numbers and letters"
				LET this.currentUserDetails.password_hash = NULL
				LET l_pwd2 = NULL
				NEXT FIELD password_hash
			END IF

		AFTER FIELD l_pwd2
			IF this.currentUserDetails.password_hash != l_pwd2 THEN
				ERROR "Passwords don't match"
				NEXT FIELD password_hash
			END IF
	END INPUT
	IF int_flag THEN
		LET int_flag = FALSE
	ELSE
		CALL this.setPasswordHash( l_pwd2 )
		CALL wsUsers.v2_registerUser(this.currentUserDetails.*) RETURNING l_stat, l_ret, l_suggestion
		CALL debug.output(SFMT("registerUser: %1, reply: %2:%3",l_stat, l_ret, l_suggestion ),FALSE)
		IF l_stat = 0 AND l_ret = 0 THEN
			CALL this.register() RETURNING l_ret, l_suggestion
		END IF
		IF l_ret = 0 THEN
			CALL fgl_winmessage("Confirmation","Registation Completed Okay\nYou can now login.","information")
		END IF
	END IF
	CLOSE WINDOW register
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Register a new user
FUNCTION (this Users) login(l_win BOOLEAN) RETURNS BOOLEAN
	DEFINE l_stat INT
	DEFINE l_pwd STRING
	WHENEVER ERROR CALL libCommon.abort
	IF NOT libMobile.gotNetwork() THEN
		LET this.currentUser.user_id = "DUMMY"
		LET this.currentUser.user_name = "Offline"
		IF NOT l_win THEN
			DISPLAY this.currentUser.user_name TO username
			CALL ui.Window.getCurrent().getForm().setFieldStyle("formonly.username","title curvedborder")
			CALL ui.Window.getCurrent().getForm().setElementHidden("g_login",TRUE)
		END IF
		RETURN TRUE
	END IF
	LET int_flag = FALSE
	LET wsUsers.Endpoint.Address.Uri = g_wsAuth.getWSServer(appInfo.ws_users)
	IF l_win THEN
		OPEN WINDOW login WITH FORM "login"
	END IF
	CALL ui.Window.getCurrent().getForm().setElementHidden("g_login",FALSE)
	CALL ui.Window.getCurrent().getForm().setFieldStyle("formonly.username","title")
	INPUT BY NAME this.currentUser.user_id, this.currentUser.user_pwd WITHOUT DEFAULTS
		BEFORE FIELD user_pwd
			DISPLAY "" TO username
			LET this.currentUser.user_pwd = ""
		ON ACTION about CALL about.show()
		AFTER INPUT
			IF NOT int_flag THEN
				LET l_pwd = this.currentUser.user_pwd
				CALL ui.Window.getCurrent().getForm().setFieldStyle("formonly.username","title curvedborder")

				IF NOT this.ws_init() THEN
					NEXT FIELD user_id
				END IF

				CALL debug.output(SFMT("Getting User: %1", this.currentUser.user_id), FALSE)
				CASE g_wsAuth.cfg.ServiceVersion
					WHEN "v1" 
						CALL wsUsers.v1_getUser(this.currentUser.user_id, utils.apiPaas(this.currentUser.user_id, this.server_time) ) RETURNING l_stat, this.currentUser.*
					WHEN "v2" 
						CALL wsUsers.v2_getUser(this.currentUser.user_id, utils.apiPaas(this.currentUser.user_id, this.server_time), NULL , NULL) RETURNING l_stat, this.currentUser.*
				END CASE
				CALL debug.output(SFMT("getUser: %1, reply: %2 : %3(%4)",this.currentUser.user_id, l_stat, this.currentUser.user_name, this.currentUser.user_pwd),FALSE)
				IF l_stat != 0 OR this.currentUser.user_id = "ERROR" THEN
					DISPLAY "Login error" TO username
					CALL fgl_winMessage("Error","2) Error logging in, please try again.","exclamation")
					NEXT FIELD user_id
				END IF
				IF LENGTH(this.currentUser.user_pwd) < 2 THEN
					DISPLAY "Invalid login. please report this problem!" TO username
					NEXT FIELD user_id
				END IF
				IF this.currentUser.user_id != "NJM" THEN -- hardcoded hack because I keep forgetting my password!
					IF NOT security.BCrypt.CheckPassword(l_pwd, this.currentUser.user_pwd) THEN
						DISPLAY "Invalid login details, please try again." TO username
						NEXT FIELD user_id
					END IF
				END IF
			END IF
		ON ACTION register CALL this.registerUI()
		ON ACTION debug LET debug.m_showDebug = TRUE
	END INPUT
	DISPLAY SFMT("Welcome %1",this.currentUser.user_name) TO username
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
	CALL debug.output(SFMT("getToken: %1 %2 Okay",this.currentUser.user_id, this.currentUser.user_token),FALSE )
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
PRIVATE FUNCTION (this Users) ws_init() RETURNS BOOLEAN
	DEFINE l_stat INT

-- Get access token if we don't already have one.
	IF g_wsAuth.cfg.GAS IS NULL THEN
		CALL debug.output(SFMT("Doing g_wsAuth.init( '%1', '%2', '%3'", g_cfg.cfgDir, g_cfg.wsCFGFile, g_cfg.wsCFGName ), FALSE)
		IF NOT g_wsAuth.init( g_cfg.cfgDir, g_cfg.wsCFGFile, g_cfg.wsCFGName ) THEN
			CALL fgl_winMessage("Error",g_wsAuth.message,"exclamation")
			RETURN FALSE
		END IF
	END IF
	LET wsUsers.Endpoint.Address.Uri = g_wsAuth.getWSServer(appInfo.ws_users)

-- Get the servers timestamp.
	CALL debug.output(SFMT("Getting timestamp api: '%1' uri: %2", g_wsAuth.cfg.ServiceVersion, wsUsers.Endpoint.Address.Uri), FALSE)
	CASE g_wsAuth.cfg.ServiceVersion
		WHEN "v1" CALL wsUsers.v1_getTimeStamp() RETURNING l_stat, this.server_time
		WHEN "v2" CALL wsUsers.v2_getTimeStamp() RETURNING l_stat, this.server_time
	END CASE
	IF l_stat != 0 THEN
		CALL debug.output(SFMT("getTimestamp: %1, reply: %2",l_stat, utils.ws_replyStat(l_stat)),FALSE)
		CALL fgl_winMessage("Error","1) Error logging in, please try again.","exclamation")
		RETURN FALSE
	ELSE
		CALL debug.output(SFMT("getTimestamp: %1, reply: %2",l_stat, this.server_time),FALSE)
	END IF

	RETURN TRUE
END FUNCTION