IMPORT FGL config
IMPORT FGL db
IMPORT FGL db_load
MAIN
	DEFINE l_db db
	DEFINE l_config config
	IF NOT l_config.initConfigFile("dfm_ws.cfg") THEN
		EXIT PROGRAM 1
	END IF
	LET l_db.config = l_config
	IF NOT l_db.connect() THEN EXIT PROGRAM END IF
	IF ARG_VAL(1) = "RECREATE" OR ARG_VAL(1) = "RELOAD" THEN
		CALL l_db.drop_tabs()
		CALL l_db.create_tabs()
		IF ARG_VAL(1) = "RELOAD" THEN	CALL db_load.load_data() END IF
	ELSE
		CALL db_load.load_data()
	END IF
END MAIN
