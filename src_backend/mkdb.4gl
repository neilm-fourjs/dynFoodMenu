
IMPORT FGL db
IMPORT FGL db_load
MAIN
	IF NOT db.connect() THEN EXIT PROGRAM END IF
	CALL db_load.load_data()
END MAIN
