
IMPORT security
MAIN
	DISPLAY setPasswordHash( ARG_VAL(1) )
END MAIN
--------------------------------------------------------------------------------------------------------------
FUNCTION setPasswordHash(l_pwd STRING)
	DEFINE l_salt STRING
	LET l_salt = security.BCrypt.GenerateSalt(10)
	RETURN security.BCrypt.HashPassword(l_pwd, l_salt)
END FUNCTION