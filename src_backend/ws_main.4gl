IMPORT com

IMPORT FGL dynfoodrest
IMPORT FGL debug

PUBLIC DEFINE serviceInfo RECORD ATTRIBUTE(WSInfo)
  title STRING,
  description STRING,
  termOfService STRING,
  contact RECORD
    name STRING,
    url STRING,
    email STRING
  END RECORD,
  version STRING
  END RECORD = (
    title: "dynFoodMenu", 
		description: "A RESTFUL backend for the dynFoodMenu mobile demo",
    version: "1.0", 
    contact: ( name: "Neil J Martin", email:"neilm@4js.com") )

MAIN
  DEFINE ret INTEGER

  CALL com.WebServiceEngine.RegisterRestService("dynfoodrest", "dynFoodRest")
  CALL debug.output("Server started",FALSE)
  CALL com.WebServiceEngine.Start()
  WHILE TRUE
    LET ret = com.WebServiceEngine.ProcessServices(-1)
    CASE ret
      WHEN 0
        CALL debug.output("Request processed.",FALSE)
      WHEN -1
        CALL debug.output("Timeout reached.",FALSE)
      WHEN -2
        CALL debug.output("Disconnected from application server.",FALSE)
        EXIT PROGRAM # The Application server has closed the connection
      WHEN -3
        CALL debug.output("Client Connection lost.",FALSE)
      WHEN -4
        CALL debug.output("Server interrupted with Ctrl-C.",FALSE)
      WHEN -5
        CALL debug.output(SFMT("BadHTTPHeader: %1",SQLCA.SQLERRM),  FALSE)
      WHEN -9
        CALL debug.output("Unsupported operation.",FALSE)
      WHEN -10
        CALL debug.output("Internal server error.",FALSE)
      WHEN -23
        CALL debug.output("Deserialization error.",FALSE)
      WHEN -35
        CALL debug.output("No such REST operation found.",FALSE)
      WHEN -36
        CALL debug.output("Missing REST parameter.",FALSE)
      OTHERWISE
        CALL debug.output("Unexpected server error " || ret || ".",FALSE)
        EXIT WHILE
    END CASE
    IF int_flag != 0 THEN
      LET int_flag = 0
      EXIT WHILE
    END IF
  END WHILE
  CALL debug.output("Server stopped",FALSE)
END MAIN