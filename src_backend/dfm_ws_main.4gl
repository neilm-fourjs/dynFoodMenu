-- This program registers the services.

IMPORT com
IMPORT FGL fgldialog
IMPORT FGL dfm_ws_menus
IMPORT FGL dfm_ws_users
IMPORT FGL dfm_ws_patients
IMPORT FGL ws_lib
IMPORT FGL wsAuthLib
IMPORT FGL debug
IMPORT FGL config
IMPORT FGL db

&include "app.inc"
&include "globals.inc"

MAIN
	DEFINE l_config config
	IF NOT l_config.initConfigFile(NULL) THEN
		CALL fgldialog.fgl_winMessage("Error", l_config.message, "exclamation")
		EXIT PROGRAM
	END IF
	RUN "env | sort > /tmp/dfm_ws" || fgl_getPID() || ".env"
	RUN "date >> /tmp/dfm_ws" || fgl_getPID() || ".env"

	CALL debug.output(l_config.message, FALSE)
	LET g_db.config = l_config
	IF NOT g_db.connect() THEN
		EXIT PROGRAM
	END IF
	CALL debug.output(SFMT("%1 Server started", base.Application.getProgramName()), FALSE)
	CALL debug.output("Register dfm_ws_menus", FALSE)
	CALL com.WebServiceEngine.RegisterRestService("dfm_ws_menus", "menus")
	CALL debug.output("Register dfm_ws_users", FALSE)
	CALL com.WebServiceEngine.RegisterRestService("dfm_ws_users", "users")
	CALL debug.output("Register dfm_ws_patients", FALSE)
	CALL com.WebServiceEngine.RegisterRestService("dfm_ws_patients", "patients")
	CALL debug.output("Start Engine", FALSE)
	CALL com.WebServiceEngine.Start()
	CALL debug.output("Start ProcessServices Loop", FALSE)
	WHILE ws_lib.ws_ProcessServices_stat(com.WebServiceEngine.ProcessServices(-1))
	END WHILE
	CALL debug.output(SFMT("%1 Server stopped", base.Application.getProgramName()), FALSE)
END MAIN
