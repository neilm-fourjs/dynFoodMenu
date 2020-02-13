
IMPORT FGL db
IMPORT FGL db_load
MAIN

	IF NOT db.connect() THEN EXIT PROGRAM END IF
	IF ARG_VAL(1) = "DROP" THEN
		CALL db.drop_tabs()
		CALL db.create_tabs()
	ELSE
		CALL db_load.load_data()
	END IF

END MAIN
