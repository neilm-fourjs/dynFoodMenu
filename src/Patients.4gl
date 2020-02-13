
IMPORT util
IMPORT FGL db
&include "../src/menus.inc"

PUBLIC TYPE Patients RECORD
	wards DYNAMIC ARRAY OF wardRecord,
  list DYNAMIC ARRAY OF patientRecord,
	currentPatient patientRecord,
	errorMessage STRING
END RECORD
--------------------------------------------------------------------------------
--
FUNCTION (this Patients) select() RETURNS BOOLEAN
	IF this.wards.getLength() = 0 THEN CALL this.getWardsDB() END IF

	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
--
FUNCTION (this Patients) getWardsDB()
	DEFINE l_cnt SMALLINT
	IF NOT db.connect() THEN EXIT PROGRAM END IF
	SELECT COUNT(*) INTO l_cnt FROM wards
	IF l_cnt = 0 THEN
		CALL this.getWardsWS()
	END IF
	LET l_cnt = 0
	DECLARE ward_cur CURSOR FOR SELECT * FROM wards
	FOREACH ward_cur INTO this.wards[l_cnt+1].*
	END FOREACH
END FUNCTION
--------------------------------------------------------------------------------------------------------------
--
FUNCTION (this Patients) getWardsWS()

END FUNCTION