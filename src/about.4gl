
&include "menus.inc"
FUNCTION show()
	DEFINE l_ver STRING
	LET l_ver = SFMT("%1 %2", ui.Interface.getFrontEndName(), ui.Interface.getFrontEndVersion() )
	LET l_ver = l_ver.append(" UR:"||ui.Interface.getUniversalClientVersion() )
	CALL fgl_winMessage(SFMT("About %1",base.Application.getProgramName()),SFMT("Application Version: %1\nClient Version: %2", C_APPVER, l_ver), "information")
END FUNCTION