-- This service provides the list of Wards and Patients.

IMPORT FGL Patients
IMPORT FGL ws_lib
IMPORT FGL debug

&include "../src/app.inc"

PUBLIC DEFINE serviceInfo RECORD ATTRIBUTE(WSInfo)
	title         STRING,
	description   STRING,
	termOfService STRING,
	contact RECORD
		name  STRING,
		url   STRING,
		email STRING
	END RECORD,
	version STRING
END RECORD =
		(title: "dynFoodMenu", description: "A RESTFUL backend for the dynFoodMenu mobile demo - Serving: Patients",
				version: "v2", contact:(name: "Neil J Martin", email: "neilm@4js.com"))
PRIVATE DEFINE Context DICTIONARY ATTRIBUTE(WSContext) OF STRING
DEFINE m_patients      Patients
--------------------------------------------------------------------------------
#+ GET <server>/ws/r/dfm/patients/v1/getWards/<token>
#+ result: An array of wards
PUBLIC FUNCTION v1_getWards(l_token STRING ATTRIBUTE(WSParam))
		ATTRIBUTES(WSPath = "/v1/getWards/{l_token}", WSGet, WSDescription = "Get wards")
		RETURNS(wardList ATTRIBUTES(WSMedia = 'application/json'))

	IF ws_lib.checkToken(l_token) THEN
		LET m_patients.wards.message = "getting wards from db ..."
		CALL m_patients.getWardsDB()
	ELSE
		LET m_patients.wards.message = "Invalid Token."
	END IF
	RETURN m_patients.wards.*
END FUNCTION
--------------------------------------------------------------------------------
#+ GET <server>/ws/r/dfm/patients/v1/getPatients/<token>/<id>
#+ result: A menu array by ID
PUBLIC FUNCTION v1_getPatients(l_token STRING ATTRIBUTE(WSParam), l_ward SMALLINT ATTRIBUTE(WSParam))
		ATTRIBUTES(WSPath = "/v1/getPatients/{l_token}/{l_ward}", WSGet, WSDescription = "Get patients for ward")
		RETURNS(patientList ATTRIBUTES(WSMedia = 'application/json'))

	IF ws_lib.checkToken(l_token) THEN
		LET m_patients.patients.message = SFMT("getting patients for ward %1 from db ...", l_ward)
		CALL m_patients.getPatientsDB(l_ward)
	ELSE
		LET m_patients.patients.message = "Invalid Token."
	END IF
	RETURN m_patients.patients.*
END FUNCTION
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- V2 functions
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
#+ GET <server>/ws/r/dfm/patients/v2/getWards/<token>
#+ result: An array of wards
PUBLIC FUNCTION v2_getWards(l_token STRING ATTRIBUTE(WSParam))
		ATTRIBUTES(WSPath = "/v2/getWards/{l_token}", WSGet,
&ifdef USE_SCOPES
  WSScope = "dfm.get",
&endif
				WSDescription = "Get wards")
		RETURNS(wardList ATTRIBUTES(WSMedia = 'application/json'))

	IF ws_lib.checkToken(l_token) THEN
		LET m_patients.wards.message = "getting wards from db ..."
		CALL m_patients.getWardsDB()
	ELSE
		LET m_patients.wards.message = "Invalid Token."
	END IF
	RETURN m_patients.wards.*
END FUNCTION
--------------------------------------------------------------------------------
#+ GET <server>/ws/r/dfm/patients/v2/getPatients/<token>/<id>
#+ result: A menu array by ID
PUBLIC FUNCTION v2_getPatients(l_token STRING ATTRIBUTE(WSParam), l_ward SMALLINT ATTRIBUTE(WSParam))
		ATTRIBUTES(WSPath = "/v2/getPatients/{l_token}/{l_ward}", WSGet,
&ifdef USE_SCOPES
  WSScope = "dfm.get",
&endif
				WSDescription = "Get patients for ward")
		RETURNS(patientList ATTRIBUTES(WSMedia = 'application/json'))

	IF ws_lib.checkToken(l_token) THEN
		LET m_patients.patients.message = SFMT("getting patients for ward %1 from db ...", l_ward)
		CALL m_patients.getPatientsDB(l_ward)
	ELSE
		LET m_patients.patients.message = "Invalid Token."
	END IF
	RETURN m_patients.patients.*
END FUNCTION
