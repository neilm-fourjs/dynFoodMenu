-- Manages the Patients.

IMPORT FGL fgldialog
IMPORT FGL appInfo
IMPORT FGL debug
IMPORT FGL config
IMPORT FGL wsAuthLib
IMPORT FGL db
IMPORT FGL libCommon
IMPORT FGL about
--IMPORT FGL wsBackEnd
IMPORT FGL wsPatients

&include "app.inc"
&include "globals.inc"

DEFINE m_arr DYNAMIC ARRAY OF RECORD
	img    STRING,
	bed_no SMALLINT,
	fld1   STRING,
	fld2   STRING
END RECORD

PUBLIC TYPE Patients RECORD
	wards wardList, -- Record: list (array of wardRecord), current & message
	patients
			patientList, -- Record: list (array of patientRecord), ordered (array of patientOrderRecord) , current & message
	errorMessage STRING,
	token        STRING
END RECORD
--------------------------------------------------------------------------------
--
FUNCTION (this Patients) select() RETURNS BOOLEAN
	DEFINE x    SMALLINT
	DEFINE l_cb ui.ComboBox

	WHENEVER ERROR CALL libCommon.abort
	IF this.wards.list.getLength() = 0 THEN
		CALL this.getWards()
	END IF
	OPEN WINDOW p WITH FORM "patients"
	LET l_cb = ui.ComboBox.forName("formonly.ward_id")
	FOR x = 1 TO this.wards.list.getLength()
		CALL l_cb.addItem(this.wards.list[x].ward_id, this.wards.list[x].ward_name CLIPPED)
	END FOR
	IF this.patients.current.ward_id > 0 THEN
		CALL this.setScrArr()
	END IF
	MESSAGE ""
	LET int_flag = TRUE
	WHILE int_flag
		LET int_flag = FALSE
		DIALOG ATTRIBUTES(UNBUFFERED)
			INPUT BY NAME this.patients.current.ward_id ATTRIBUTES(WITHOUT DEFAULTS)
				ON CHANGE ward_id
					CALL this.getPatients(this.patients.current.ward_id)
					CALL this.setScrArr()
			END INPUT
			DISPLAY ARRAY m_arr TO arr.*
				ON ACTION selectrow
					LET this.patients.current.bed_no = m_arr[arr_curr()].bed_no
					CALL this.getPatient(this.patients.current.ward_id, this.patients.current.bed_no)
					DISPLAY BY NAME this.patients.current.name, this.patients.current.allergies
					DISPLAY IIF(this.patients.current.diabetic, "my-true", "my-false") TO dia
					DISPLAY IIF(this.patients.current.nilbymouth, "my-true", "my-false") TO nil
				ON ACTION test ATTRIBUTE(ROWBOUND)
					CALL fgl_winMessage("Test", SFMT("Test Row %1", arr_curr()), "exclamation")
			END DISPLAY
			ON ACTION accept
				ACCEPT DIALOG
			ON ACTION cancel
				CANCEL DIALOG
			ON ACTION about
				CALL about.show()
		END DIALOG
		IF int_flag THEN
			CLOSE WINDOW p
			RETURN FALSE
		END IF
		CALL debug.output(
				SFMT("Ward: %1 Bed: %2 Name: %3",
						this.patients.current.ward_id, this.patients.current.bed_no, this.patients.current.name),
				FALSE)

{	-- Confirm
		MENU
			ON ACTION accept EXIT MENU
			ON ACTION cancel LET int_flag = TRUE EXIT MENU
			ON ACTION close LET int_flag = TRUE EXIT MENU
		END MENU}
	END WHILE
	CLOSE WINDOW p

	IF int_flag THEN
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Get a list of the wards
FUNCTION (this Patients) setScrArr()
	DEFINE x SMALLINT
	CALL m_arr.clear()
	FOR x = 1 TO this.patients.list.getLength()
		LET m_arr[x].img = "fa-bed"
		IF this.patients.list[x].nilbymouth OR this.patients.list[x].diabetic
				OR LENGTH(this.patients.list[x].allergies) > 1 THEN
			LET m_arr[x].img = "fa-exclamation"
		END IF
		LET m_arr[x].bed_no = this.patients.list[x].bed_no
		LET m_arr[x].fld1   = SFMT("Bed #%1 Patient %2", this.patients.list[x].bed_no, this.patients.list[x].name)
		LET m_arr[x].fld2 =
				SFMT("Nil by mouth: %1 - Diabetic: %2 - %3",
						IIF(this.patients.list[x].nilbymouth, "YES", "NO"), IIF(this.patients.list[x].diabetic, "YES", "NO"),
						IIF(LENGTH(this.patients.list[x].allergies) > 1, "See below", "No Allergies"))
	END FOR
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Get a list of the wards
FUNCTION (this Patients) getWards()
	DEFINE l_cnt SMALLINT
	IF NOT g_db.connect() THEN
		EXIT PROGRAM
	END IF
	SELECT COUNT(*) INTO l_cnt FROM wards
	IF l_cnt = 0 THEN
		CALL this.getWardsWS()
	ELSE
		CALL this.getWardsDB()
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- get Patients for the ward
FUNCTION (this Patients) getPatients(l_ward INT)
	CALL debug.output(SFMT("getPatients: %1 Curr: %2", l_ward, this.patients.current.ward_id), FALSE)
	CALL this.patients.list.clear()
	CALL this.getPatientsDB(l_ward)
	IF this.patients.list.getLength() = 0 THEN
		CALL this.getPatientsWS(l_ward)
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- get Patient for the ward / bed.
FUNCTION (this Patients) getPatient(l_ward INT, l_bed SMALLINT)
	DEFINE x SMALLINT
	IF this.wards.current.ward_id != l_ward OR this.patients.list.getLength() = 0 THEN
		CALL this.getPatients(l_ward)
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
	IF NOT g_db.connect() THEN
		LET this.wards.message = "failed to connect to db!"
		EXIT PROGRAM
	END IF
	CALL this.wards.list.clear()
	DECLARE ward_cur CURSOR FOR SELECT * FROM wards
	FOREACH ward_cur INTO this.wards.list[l_cnt].*
		LET l_cnt = l_cnt + 1
	END FOREACH
	CALL this.wards.list.deleteElement(l_cnt)
	LET this.wards.message = SFMT("Found %1 Wards", this.wards.list.getLength())
	CALL debug.output(SFMT("getWardsDB: %1", this.wards.message), FALSE)
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Get a list of the Patients for the ward from the DB.
FUNCTION (this Patients) getPatientsDB(l_ward SMALLINT)
	DEFINE l_cnt     SMALLINT = 1
	DEFINE x         SMALLINT = 1
	DEFINE l_ordered patientOrderRecord
	IF NOT g_db.connect() THEN
		LET this.patients.message = "failed to connect to db!"
		EXIT PROGRAM
	END IF
	CALL this.patients.list.clear()
	DECLARE p_ordcur CURSOR FOR SELECT patient_id, menu_id, placed FROM orders WHERE patient_id = ?
	DECLARE p_cur CURSOR FOR SELECT * FROM patients WHERE ward_id = l_ward
	FOREACH p_cur INTO this.patients.list[l_cnt].*
		FOREACH p_ordcur USING this.patients.list[l_cnt].id INTO l_ordered.*
			LET this.patients.ordered[x].* = l_ordered.*
			LET x = x + 1
		END FOREACH
		LET l_cnt = l_cnt + 1
	END FOREACH
	CALL this.patients.list.deleteElement(l_cnt)
	LET this.patients.message = SFMT("Found %1 Patients in ward %2", this.patients.list.getLength(), l_ward)
	CALL debug.output(SFMT("getPatientsDB: %1 Ward: %2", this.patients.message, this.patients.current.ward_id), FALSE)
END FUNCTION

--------------------------------------------------------------------------------------------------------------
-- Get a list of the wards from the server.
FUNCTION (this Patients) getWardsWS()
	DEFINE l_stat SMALLINT
	LET wsPatients.Endpoint.Address.Uri = g_wsAuth.getWSServer(appInfo.appInfo.ws_patients)
	CALL wsPatients.v2_getWards(this.token) RETURNING l_stat, this.wards.*
	CALL debug.output(
			SFMT("getWardsWS: Stat=%1 %2 From: %3", l_stat, NVL(this.wards.message, "NULL"), wsPatients.Endpoint.Address.Uri),
			FALSE)
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Get a list of the patients for the ward from the server.
FUNCTION (this Patients) getPatientsWS(l_ward SMALLINT)
	DEFINE l_stat SMALLINT
	CALL this.patients.list.clear()
	IF l_ward IS NULL OR l_ward = 0 THEN
		CALL debug.output(SFMT("getPatientsWS: Ward: %1 - aborted", NVL(l_ward,"(null)")), FALSE)
		RETURN
	END IF
	LET wsPatients.Endpoint.Address.Uri = g_wsAuth.getWSServer(appInfo.appInfo.ws_patients)
	CALL wsPatients.v2_getPatients(this.token, l_ward) RETURNING l_stat, this.patients.*
	LET this.patients.current.ward_id = l_ward -- restore the current ward id!
	CALL debug.output(
			SFMT("getPatientsWS: Ward: %1 Stat: %2 Mess: %3 From: %4",
					l_ward, l_stat, NVL(this.patients.message, "NULL"), wsPatients.Endpoint.Address.Uri),
			FALSE)
END FUNCTION
