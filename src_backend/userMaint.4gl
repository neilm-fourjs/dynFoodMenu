IMPORT util
IMPORT security
IMPORT FGL about
IMPORT FGL libCommon
&include "menus.inc"
DEFINE m_user userRecord
DEFINE m_users DYNAMIC ARRAY OF userRecord
MAIN
	DEFINE l_json TEXT
	DEFINE l_salt STRING
	CALL libCommon.loadStyles()
	OPEN FORM userMaint FROM "userMaint"
	DISPLAY FORM userMaint
	LOCATE l_json IN FILE "users.json"
	DISPLAY "JSON:",l_json
	CALL util.JSON.parse(l_json, m_users)
	DISPLAY ARRAY m_users TO arr.*
		ON APPEND
			INPUT m_user.* FROM arr[ scr_line() ].*
				AFTER INPUT
					LET l_salt = security.BCrypt.GenerateSalt(10)
					LET m_user.user_pwd = Security.BCrypt.HashPassword(m_user.user_pwd, l_salt)
					LET m_users[ arr_curr() ].* = m_user.*
			END INPUT
		ON UPDATE
			LET m_users[ arr_curr() ].user_pwd = ""
			INPUT m_users[ arr_curr() ].* FROM arr[ scr_line() ].* ATTRIBUTES(WITHOUT DEFAULTS)
				AFTER INPUT
					LET l_salt = security.BCrypt.GenerateSalt(10)
					LET m_users[ arr_curr() ].user_pwd = Security.BCrypt.HashPassword(m_user.user_pwd, l_salt)
			END INPUT
		ON ACTION about CALL about.show()
		ON ACTION close EXIT DISPLAY
	END DISPLAY
	LET l_json = util.JSON.stringify(m_users)
	DISPLAY "JSON:",l_json
END MAIN