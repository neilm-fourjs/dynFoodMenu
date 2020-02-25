
IMPORT FGL db
IMPORT FGL db_load
MAIN

	IF NOT db.connect() THEN EXIT PROGRAM END IF
	IF ARG_VAL(1) = "DROP" OR ARG_VAL(1) = "RELOAD" THEN
		CALL db.drop_tabs()
		CALL db.create_tabs()
		IF ARG_VAL(1) = "RELOAD" THEN	CALL db_load.load_data() END IF
	ELSE
		CALL db_load.load_data()
	END IF

END MAIN
