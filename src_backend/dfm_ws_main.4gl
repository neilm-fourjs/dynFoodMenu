
-- This program registers the services.

IMPORT com

IMPORT FGL dfm_ws_menus
IMPORT FGL dfm_ws_users
IMPORT FGL dfm_ws_patients
IMPORT FGL ws_lib
IMPORT FGL debug
IMPORT FGL config
IMPORT FGL db

&include "menus.inc"
&include "globals.inc"

MAIN
	DEFINE l_config config
	IF NOT l_config.initConfigFile(NULL) THEN
		CALL fgl_winMessage("Error", l_config.message,"exclamation")
		EXIT PROGRAM
	END IF
	CALL debug.output(l_config.message,FALSE)
	LET g_db.config = l_config
	IF NOT g_db.connect() THEN
		EXIT PROGRAM
	END IF
  CALL debug.output(SFMT("%1 Server started",base.Application.getProgramName()),FALSE)
  CALL com.WebServiceEngine.RegisterRestService("dfm_ws_menus", "menus")
  CALL com.WebServiceEngine.RegisterRestService("dfm_ws_users", "users")
  CALL com.WebServiceEngine.RegisterRestService("dfm_ws_patients", "patients")
  CALL com.WebServiceEngine.Start()
  WHILE ws_lib.ws_ProcessServices_stat( com.WebServiceEngine.ProcessServices(-1) )
	END WHILE
  CALL debug.output(SFMT("%1 Server stopped",base.Application.getProgramName()),FALSE)
END MAIN