-- Function handling the backend web service.
IMPORT util
&include "menus.inc"
FUNCTION getToken(l_usr STRING, l_pwd STRING)
	DEFINE l_user userRecord
--TODO: generate client functions from service
	LET l_user.user_id = l_usr
	LET l_user.user_pwd = l_pwd
	LET l_user.user_name = "Neil J Martin"
	LET l_user.user_token = "token"
	RETURN util.JSON.stringify(l_user)
END FUNCTION