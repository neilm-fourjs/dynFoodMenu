IMPORT util
IMPORT security
IMPORT FGL about
IMPORT FGL libCommon
IMPORT FGL Users
&include "menus.inc"

MAIN
	DEFINE l_salt STRING
	DEFINE l_user Users
	DEFINE l_tmpUser userRecord

	CALL libCommon.loadStyles()
	OPEN FORM userMaint FROM "userMaint"
	DISPLAY FORM userMaint
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
					LET l_salt = security.BCrypt.GenerateSalt(10)
					LET l_user.currentUser.* = l_tmpUser.*
					LET l_user.currentUser.user_pwd = Security.BCrypt.HashPassword(l_user.currentUser.user_pwd, l_salt)
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
		ON ACTION about CALL about.show()
		ON ACTION close EXIT DISPLAY
		ON ACTION quit EXIT DISPLAY
	END DISPLAY
END MAIN