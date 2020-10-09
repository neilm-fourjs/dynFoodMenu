
IMPORT os
IMPORT util

&include "menus.inc"

-- directories to search for the json config file
DEFINE m_loc DYNAMIC ARRAY OF STRING = [ 
        "/storage/emulated/0/download",
        "/sdcard/Download",
        "/storage/sdcard0/download",
        "/mnt/sdcard/download",
        "../cfg",
        "../etcBackEnd",
        "." ]

PUBLIC TYPE config RECORD
		cfgDone BOOLEAN,
		cfgDir STRING,
		cfgFileName STRING,
		cfgFile STRING,
		dbDir STRING,
		dbName STRING,
		logDir STRING,
		logFile STRING,
		errFile STRING,
		wsServer STRING,
		wsVersion STRING,
		ClientID STRING,
		SecretID STRING,
		message STRING
	END RECORD

FUNCTION (this config) initConfigFile(l_fileName STRING) RETURNS BOOLEAN
	DEFINE x SMALLINT
	DEFINE l_fileDir, l_file STRING
	DEFINE l_json TEXT
	IF l_fileName IS NULL THEN LET l_fileName = base.Application.getProgramName()||".cfg" END IF
	FOR x = 1 TO m_loc.getLength()
		LET l_file = os.Path.join(m_loc[x], l_fileName)
	--	DISPLAY "Check for :",l_file
		IF os.Path.exists( l_file ) THEN
			LET l_fileDir = m_loc[x]
			EXIT FOR
		END IF
	END FOR
	IF l_fileDir IS NULL THEN
		LET this.message = SFMT("Failed to find config file: %1", l_FileName)
		RETURN FALSE
	END IF
	LOCATE l_json IN MEMORY
	CALL l_json.readFile( l_file )
	CALL util.JSON.parse( l_json, this)
	LET this.cfgDir = l_fileDir
	LET this.cfgFileName = l_fileName
	LET this.cfgFile = l_file
	CALL this.setDefaults()
	LET this.cfgDone = TRUE
	LET this.message = SFMT("Using config file: %1", l_file)
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this config) init(l_dbDir STRING, l_dbName STRING, l_logDir STRING, l_logfile STRING, l_wsServer STRING, l_wsVersion STRING)
	LET this.dbDir = l_dbDir
	LET this.dbName = l_dbName
	LET this.logDir =l_logDir
	LET this.logFile =l_logFile
	LET this.wsServer = l_wsServer
	LET this.wsVersion = l_wsVersion
	CALL this.setDefaults()
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this config) showCFG()
	DISPLAY "CFG:",util.JSON.stringify(this)
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Set anything not set in the config file to sane defaults
FUNCTION (this config) setDefaults()
	IF this.dbDir IS NULL THEN LET this.dbDir = "." END IF
	IF this.dbName IS NULL THEN LET this.dbName = fgl_getResource("my.dbname") END IF
	IF this.logDir IS NULL THEN LET this.logDir = "." END IF
	IF this.logFile IS NULL THEN LET this.logFile = base.Application.getProgramName()||".log" END IF
	IF this.errFile IS NULL THEN LET this.errFile = base.Application.getProgramName()||".err" END IF
	IF this.wsServer IS NULL THEN LET this.wsServer = C_WSSERVER END IF
	IF this.wsVersion IS NULL THEN LET this.wsVersion = C_DEFWSVER END IF
	IF this.wsServer.getCharAt(this.wsServer.getLength()) != "/" THEN
		LET this.wsServer = this.wsServer.append("/")
	END IF
	IF NOT os.path.exists(this.logDir) THEN
		IF NOT os.path.mkdir(this.logDir) THEN
			LET this.message = SFMT("Failed to create logDir '%1'!", this.logDir)
		END IF
	END IF
	LET this.cfgDone = TRUE
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
	RETURN this.wsServer||l_serviceMethod||"/"||this.wsVersion
END FUNCTION
--------------------------------------------------------------------------------------------------------------