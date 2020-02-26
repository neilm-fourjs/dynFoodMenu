
IMPORT os

&include "menus.inc"

PUBLIC TYPE config RECORD
		dbDir STRING,
		logDir STRING,
		logFile STRING,
		errFile STRING,
		wsServer STRING
	END RECORD

FUNCTION (this config) init(l_dbDir STRING, l_logDir STRING, l_logfile STRING, l_wsServer STRING)
	LET this.dbDir = l_dbDir
	LET this.logDir =l_logDir
	LET this.logFile =l_logFile
	LET this.wsServer = l_wsServer
	IF this.dbDir IS NULL THEN LET this.dbDir = "." END IF
	IF this.logDir IS NULL THEN LET this.logDir = "." END IF
	IF this.logFile IS NULL THEN LET this.logFile = base.Application.getProgramName()||".log" END IF
	IF this.errFile IS NULL THEN LET this.errFile = base.Application.getProgramName()||".err" END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this config) setDefaults()
	IF this.dbDir IS NULL THEN LET this.dbDir = "." END IF
	IF this.logDir IS NULL THEN LET this.logDir = "." END IF
	IF this.logFile IS NULL THEN LET this.logFile = base.Application.getProgramName()||".log" END IF
	IF this.errFile IS NULL THEN LET this.errFile = base.Application.getProgramName()||".err" END IF
	IF this.wsServer IS NULL THEN LET this.wsServer = C_WSSERVER END IF
	IF this.wsServer.getCharAt(this.wsServer.getLength()) != "/" THEN
		LET this.wsServer = this.wsServer.append("/")
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this config) getLogFile() RETURNS STRING
	CALL this.setDefaults()
	RETURN os.Path.join(this.logDir,this.logFile)
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this config) getErrFile() RETURNS STRING
	CALL this.setDefaults()
	RETURN os.Path.join(this.logDir,this.errFile)
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this config) getWSServer(l_serviceMethod STRING) RETURNS STRING
	CALL this.setDefaults()
	RETURN this.wsServer||l_serviceMethod
END FUNCTION
--------------------------------------------------------------------------------------------------------------

