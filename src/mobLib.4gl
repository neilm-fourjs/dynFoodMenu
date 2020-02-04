
FUNCTION gotNetwork() RETURNS BOOLEAN
	DEFINE l_netWork STRING
	IF base.Application.isMobile() THEN
		CALL ui.Interface.frontCall("mobile","connectivity", [], [l_netWork] )
		IF l_netWork = "NONE" THEN RETURN FALSE END IF
	END IF
	RETURN TRUE
END FUNCTION