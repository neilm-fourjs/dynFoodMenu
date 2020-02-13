
IMPORT util
IMPORT FGL db
IMPORT FGL debug
&include "../src/menus.inc"

PUBLIC TYPE Patients RECORD
	wards DYNAMIC ARRAY OF wardRecord,
	currentWard SMALLINT,
	list DYNAMIC ARRAY OF patientRecord,
	currentPatient patientRecord,
	errorMessage STRING
END RECORD
--------------------------------------------------------------------------------
--
FUNCTION (this Patients) select() RETURNS BOOLEAN
	DEFINE x SMALLINT
	DEFINE l_cb ui.ComboBox
	IF this.wards.getLength() = 0 THEN CALL this.getWardsDB() END IF
	OPEN WINDOW p WITH FORM "patients"
	LET l_cb = ui.ComboBox.forName("formonly.ward_id")
	FOR x = 1 TO this.wards.getLength()
		CALL l_cb.addItem(x, this.wards[x].ward_name CLIPPED)
	END FOR
	LET int_flag = FALSE
	INPUT BY NAME this.currentPatient.ward_id,  this.currentPatient.bed_no

	CALL this.getPatient( this.currentPatient.ward_id, this.currentPatient.bed_no )

	CALL debug.output(SFMT("Ward: %1 Bed: %2 Name: %3", this.currentPatient.ward_id, this.currentPatient.bed_no, this.currentPatient.name ), FALSE)
	DISPLAY BY NAME this.currentPatient.name, this.currentPatient.allergies

	MENU
		ON ACTION close EXIT MENU
		ON ACTION cancel LET int_flag = TRUE EXIT MENU
		ON ACTION accept EXIT MENU
	END MENU

	CLOSE WINDOW p

	IF int_flag THEN RETURN FALSE END IF
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Get a list of the wards from the DB.
FUNCTION (this Patients) getWardsDB()
	DEFINE l_cnt SMALLINT
	IF NOT db.connect() THEN EXIT PROGRAM END IF
	SELECT COUNT(*) INTO l_cnt FROM wards
	IF l_cnt = 0 THEN
		CALL this.getWardsWS()
	END IF
	LET l_cnt = 1
	CALL this.wards.clear()
	DECLARE ward_cur CURSOR FOR SELECT * FROM wards
	FOREACH ward_cur INTO this.wards[l_cnt].*
		LET l_cnt = l_cnt + 1
	END FOREACH
	CALL this.wards.deleteElement(l_cnt)
	CALL debug.output(SFMT("Wards: %1", this.wards.getLength()), FALSE)
END FUNCTION
--------------------------------------------------------------------------------------------------------------
--
FUNCTION (this Patients) getPatient(l_ward INT, l_bed SMALLINT)
	DEFINE x SMALLINT
	IF this.currentWard != l_ward THEN
		CALL this.list.clear()
		LET this.currentWard = l_ward
-- fetch patient list for ward
-- TODO:
	END IF

-- set current patient
	FOR x = 1 TO this.list.getLength()
		IF l_bed = this.list[x].bed_no THEN
			LET this.currentPatient.* = this.list[x].*
		END IF
	END FOR

END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Get a list of the wards from the server.
FUNCTION (this Patients) getWardsWS()

END FUNCTION