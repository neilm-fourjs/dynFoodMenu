
IMPORT util
IMPORT FGL db
IMPORT FGL debug
IMPORT FGL libCommon
IMPORT FGL wsBackEnd
&include "../src/menus.inc"

PUBLIC TYPE Patients RECORD
	wards wardList,
	patients patientList,
	errorMessage STRING
END RECORD
--------------------------------------------------------------------------------
--
FUNCTION (this Patients) select() RETURNS BOOLEAN
	DEFINE x SMALLINT
	DEFINE l_cb ui.ComboBox
	WHENEVER ERROR CALL libCommon.abort
	IF this.wards.list.getLength() = 0 THEN CALL this.getWards() END IF
	OPEN WINDOW p WITH FORM "patients"
	LET l_cb = ui.ComboBox.forName("formonly.ward_id")
	FOR x = 1 TO this.wards.list.getLength()
		CALL l_cb.addItem(x, this.wards.list[x].ward_name CLIPPED)
	END FOR
	LET int_flag = TRUE
	WHILE int_flag
		LET int_flag = FALSE
		INPUT BY NAME this.patients.current.ward_id,  this.patients.current.bed_no WITHOUT DEFAULTS
		IF int_flag THEN
			CLOSE WINDOW p
			RETURN FALSE
		END IF
		DISPLAY IIF( this.patients.current.diabetic, "my-true","my-false" ) TO dia
		DISPLAY IIF( this.patients.current.nilbymouth, "my-true","my-false" ) TO nil

		CALL this.getPatient( this.patients.current.ward_id, this.patients.current.bed_no )
		CALL debug.output(SFMT("Ward: %1 Bed: %2 Name: %3", this.patients.current.ward_id, this.patients.current.bed_no, this.patients.current.name ), FALSE)
		DISPLAY BY NAME this.patients.current.name, this.patients.current.allergies

	-- Confirm
		MENU
			ON ACTION accept EXIT MENU
			ON ACTION cancel LET int_flag = TRUE EXIT MENU
			ON ACTION close LET int_flag = TRUE EXIT MENU
		END MENU
	END WHILE
	CLOSE WINDOW p

	IF int_flag THEN RETURN FALSE END IF
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Get a list of the wards
FUNCTION (this Patients) getWards()
	DEFINE l_cnt SMALLINT
	IF NOT db.connect() THEN EXIT PROGRAM END IF
	SELECT COUNT(*) INTO l_cnt FROM wards
	IF l_cnt = 0 THEN
		CALL this.getWardsWS()
	ELSE
		CALL this.getWardsDB()
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- get Patient for the ward / bed.
FUNCTION (this Patients) getPatient(l_ward INT, l_bed SMALLINT)
	DEFINE x SMALLINT
	IF this.wards.current.ward_id != l_ward OR this.patients.list.getLength() = 0 THEN
		CALL this.patients.list.clear()
		CALL this.getPatientsWS(l_ward)
	-- set current ward
		FOR x = 1 TO this.wards.list.getLength()
			IF this.wards.list[x].ward_id = l_ward THEN
				LET this.wards.current.* = this.wards.list[x].*
			END IF
		END FOR
	END IF

-- set current patient
	FOR x = 1 TO this.patients.list.getLength()
		IF l_bed = this.patients.list[x].bed_no THEN
			LET this.patients.current.* = this.patients.list[x].*
		END IF
	END FOR
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Get a list of the wards from the DB.
FUNCTION (this Patients) getWardsDB()
	DEFINE l_cnt SMALLINT = 1
	IF NOT db.connect() THEN 
		LET this.wards.messsage = "failed to connect to db!"
		EXIT PROGRAM
	END IF
	CALL this.wards.list.clear()
	DECLARE ward_cur CURSOR FOR SELECT * FROM wards
	FOREACH ward_cur INTO this.wards.list[l_cnt].*
		LET l_cnt = l_cnt + 1
	END FOREACH
	CALL this.wards.list.deleteElement(l_cnt)
	LET this.wards.messsage = SFMT("Found %1 Wards",  this.wards.list.getLength())
	CALL debug.output(SFMT("getWardsDB: %1", this.wards.messsage), FALSE)
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Get a list of the wards from the DB.
FUNCTION (this Patients) getPatientsDB(l_ward SMALLINT)
	DEFINE l_cnt SMALLINT = 1
	IF NOT db.connect() THEN
		LET this.patients.messsage = "failed to connect to db!"
		EXIT PROGRAM
	END IF
	CALL this.patients.list.clear()
	DECLARE p_cur CURSOR FOR SELECT * FROM patients WHERE ward_id = l_ward
	FOREACH p_cur INTO this.patients.list[l_cnt].*
		LET l_cnt = l_cnt + 1
	END FOREACH
	CALL this.patients.list.deleteElement(l_cnt)
	LET this.patients.messsage = SFMT("Found %1 Patients in ward %2",  this.patients.list.getLength(), l_ward)
	CALL debug.output(SFMT("getPatientsDB: %1", this.patients.messsage), FALSE)
END FUNCTION

--------------------------------------------------------------------------------------------------------------
-- Get a list of the wards from the server.
FUNCTION (this Patients) getWardsWS()
	DEFINE l_stat SMALLINT
	CALL wsBackEnd.getWards() RETURNING l_stat, this.wards.*
	CALL debug.output(SFMT("getWardsWS: %1 %2", l_stat, NVL(this.wards.messsage,"NULL")), FALSE)
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Get a list of the patients for the ward from the server.
FUNCTION (this Patients) getPatientsWS(l_ward SMALLINT)
	DEFINE l_stat SMALLINT
	CALL wsBackEnd.getPatients(l_ward) RETURNING l_stat, this.patients.*
	CALL debug.output(SFMT("getPatientsWS: %1 %2", l_stat, NVL(this.patients.messsage,"NULL")), FALSE)
END FUNCTION