IMPORT com

IMPORT FGL dfm_ws_menus
IMPORT FGL ws_lib
IMPORT FGL debug

MAIN
  CALL debug.output(SFMT("%1 Server started",base.Application.getProgramName()),FALSE)
  CALL com.WebServiceEngine.RegisterRestService("dfm_ws_menus", "menus")
  CALL com.WebServiceEngine.Start()
  WHILE ws_lib.ws_ProcessServices_stat( com.WebServiceEngine.ProcessServices(-1) )
	END WHILE
  CALL debug.output(SFMT("%1 Server stopped",base.Application.getProgramName()),FALSE)
END MAIN