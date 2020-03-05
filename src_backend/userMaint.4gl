IMPORT util
IMPORT security
IMPORT FGL about
IMPORT FGL libCommon
IMPORT FGL config
IMPORT FGL debug
IMPORT FGL Users
IMPORT FGL db
&include "menus.inc"
&include "globals.inc"

MAIN
	DEFINE l_salt STRING
	DEFINE l_user Users
	DEFINE l_tmpUser userRecord
	DEFINE l_config config

	IF NOT l_config.initConfigFile("dfm_backEnd.cfg") THEN
		CALL fgl_winMessage("Error", l_config.message,"exclamation")
		EXIT PROGRAM
	END IF

	CALL libCommon.loadStyles()
	OPEN FORM userMaint FROM "userMaint"
	DISPLAY FORM userMaint

	LET g_db.config = l_config
	CALL debug.output(l_config.message,FALSE)
	IF NOT g_db.connect() THEN
		CALL debug.output(g_db.message, FALSE)
		EXIT PROGRAM
	END IF

	CALL l_user.loadFromDB()
	DISPLAY ARRAY l_user.list TO arr.* ATTRIBUTES( ACCEPT=FALSE, CANCEL=FALSE )
		ON APPEND
			INPUT l_tmpUser.* FROM arr[ scr_line() ].*
				AFTER FIELD user_id
					IF l_user.get( l_tmpUser.user_id ) THEN
						ERROR SFMT("User Id already used: %1", l_user.currentUser.user_name)
						NEXT FIELD user_id
					END IF
				AFTER INPUT
					CALL l_user.setPasswordHash( l_tmpUser.user_pwd )
					LET l_user.list[ arr_curr() ].* = l_user.currentUser.*
					IF NOT l_user.add() THEN
						ERROR l_user.errorMessage
					ELSE
						MESSAGE l_user.errorMessage
					END IF
			END INPUT
		ON DELETE
			IF libCommon.confirm("Delete User ?") THEN
				IF NOT l_user.delete( l_user.list[ arr_curr() ].user_id ) THEN
					ERROR l_user.errorMessage
				ELSE
					MESSAGE l_user.errorMessage
				END IF
			ELSE
				LET int_flag = TRUE
			END IF
		ON UPDATE
			LET l_user.list[ arr_curr() ].user_pwd = ""
			INPUT l_user.list[ arr_curr() ].* FROM arr[ scr_line() ].* ATTRIBUTES(WITHOUT DEFAULTS)
				AFTER INPUT
					LET l_salt = security.BCrypt.GenerateSalt(10)
					LET l_user.currentUser.* = l_user.list[ arr_curr() ].*
					LET l_user.currentUser.user_pwd = Security.BCrypt.HashPassword(l_user.currentUser.user_pwd, l_salt)
					IF NOT l_user.update() THEN
						ERROR l_user.errorMessage
					ELSE
						MESSAGE l_user.errorMessage
					END IF
			END INPUT
		ON ACTION refresh
			CALL l_user.loadFromDB()
		ON ACTION about CALL about.show()
		ON ACTION close EXIT DISPLAY
		ON ACTION quit EXIT DISPLAY
	END DISPLAY
END MAIN