
IMPORT FGL appInfo
IMPORT FGL config
IMPORT FGL db
IMPORT FGL wsAuthLib
&include "app.inc"
&include "globals.inc"
FUNCTION show()
	DEFINE l_ver   STRING
	DEFINE l_about STRING
	LET l_ver   = SFMT("%1 %2", ui.Interface.getFrontEndName(), ui.Interface.getFrontEndVersion())
	LET l_ver   = l_ver.append(" UR:" || NVL(ui.Interface.getUniversalClientVersion(), "NULL"))
	LET l_about = SFMT("Program: %1 Version: %2", base.Application.getProgramName(), appInfo.appInfo.version)
	LET l_about = l_about.append(SFMT("\nClient Version: %1", l_ver))
	LET l_about = l_about.append(SFMT("\nRendering: %1", fgl_getresource("gui.rendering")))
	LET l_about = l_about.append(SFMT("\nFGLIMAGEPATH=%1", fgl_getenv("FGLIMAGEPATH")))
	LET l_about = l_about.append(SFMT("\nGBC_USER_DIR=%1", fgl_getenv("GBC_USER_DIR")))
	LET l_about = l_about.append(SFMT("\nGBC_USER=%1", fgl_getenv("GBC_USER")))
	LET l_about = l_about.append(SFMT("\nFGLGBCDIR=%1", fgl_getenv("FGLGBCDIR")))
	LET l_about = l_about.append(SFMT("\nCFG File=%1", g_cfg.cfgFile))
	LET l_about = l_about.append(SFMT("\ndbDir=%1", g_cfg.dbDir))
	LET l_about = l_about.append(SFMT("\ndbName=%1", g_cfg.dbName))
	LET l_about = l_about.append(SFMT("\nlogDir=%1", g_cfg.logDir))
	LET l_about = l_about.append(SFMT("\nlogFile=%1", g_cfg.logFile))
	LET l_about = l_about.append(SFMT("\nWS CFGFile=%1", g_wsAuth.cfgFileName))
	LET l_about = l_about.append(SFMT("\nWS CFGName=%1", g_wsAuth.cfgName))
	LET l_about = l_about.append(SFMT("\nWS CFG GAS=%1", g_wsAuth.cfg.GAS))
	LET l_about = l_about.append(SFMT("\nWS CFG Service=%1", g_wsAuth.cfg.ServiceName))
	LET l_about = l_about.append(SFMT("\nWS CFG Version=%1", g_wsAuth.cfg.ServiceVersion))
	LET l_about = l_about.append(SFMT("\nWS CFG Endpoint=%1", g_wsAuth.endpoint))
	OPEN WINDOW about WITH FORM "about"
	DISPLAY BY NAME l_about
	MENU
		BEFORE MENU
			IF ui.Interface.getFrontEndName() != "GMA" THEN
				CALL DIALOG.setActionHidden("gmaabout", TRUE)
			END IF
		ON ACTION gmaabout
			CALL ui.Interface.frontCall("Android", "showAbout", [], [])
		ON ACTION close
			EXIT MENU
	END MENU
	CLOSE WINDOW about
END FUNCTION
