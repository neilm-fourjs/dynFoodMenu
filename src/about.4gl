
&include "menus.inc"
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
	OPEN WINDOW about WITH FORM "about"
	DISPLAY BY NAME l_about
	MENU
		ON ACTION close EXIT MENU
	END MENU
	CLOSE WINDOW about
END FUNCTION