
IMPORT FGL config
IMPORT FGL db
&include "menus.inc"
&include "globals.inc"
FUNCTION show()
	DEFINE l_ver STRING
	DEFINE l_about STRING
	LET l_ver = SFMT("%1 %2", ui.Interface.getFrontEndName(), ui.Interface.getFrontEndVersion() )
	LET l_ver = l_ver.append(" UR:"||ui.Interface.getUniversalClientVersion() )
	LET l_about = SFMT("Program: %1 Version: %2", base.Application.getProgramName(), C_APPVER )
	LET l_about = l_about.append( SFMT("\nClient Version: %1", l_ver) )
	LET l_about = l_about.append( SFMT("\nFGLIMAGEPATH=%1", fgl_getEnv("FGLIMAGEPATH")) )
	LET l_about = l_about.append( SFMT("\nGBC_USER_DIR=%1", fgl_getEnv("GBC_USER_DIR")) )
	LET l_about = l_about.append( SFMT("\nGBC_USER=%1", fgl_getEnv("GBC_USER")) )
	LET l_about = l_about.append( SFMT("\nFGLGBCDIR=%1", fgl_getEnv("FGLGBCDIR")) )
	LET l_about = l_about.append( SFMT("\nCFG File=%1", g_cfg.cfgFile) )
	LET l_about = l_about.append( SFMT("\ndbDir=%1", g_cfg.dbDir) )
	LET l_about = l_about.append( SFMT("\ndbName=%1", g_cfg.dbName) )
	LET l_about = l_about.append( SFMT("\nlogDir=%1", g_cfg.logDir) )
	LET l_about = l_about.append( SFMT("\nlogFile=%1", g_cfg.logFile) )
	LET l_about = l_about.append( SFMT("\nWS Server=%1", g_cfg.wsServer) )
	OPEN WINDOW about WITH FORM "about"
	DISPLAY BY NAME l_about
	MENU
		ON ACTION close EXIT MENU
	END MENU
	CLOSE WINDOW about
END FUNCTION