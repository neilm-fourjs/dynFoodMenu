IMPORT util
IMPORT FGL Patients
IMPORT FGL ws_lib
IMPORT FGL debug

&include "../src/menus.inc"

PUBLIC DEFINE serviceInfo RECORD ATTRIBUTE(WSInfo)
  title STRING,
  description STRING,
  termOfService STRING,
  contact RECORD
    name STRING,
    url STRING,
    email STRING
  END RECORD,
  version STRING
  END RECORD = (
    title: "dynFoodMenu", 
		description: "A RESTFUL backend for the dynFoodMenu mobile demo - Serving: Patients",
    version: "1.0", 
    contact: ( name: "Neil J Martin", email:"neilm@4js.com") )

--------------------------------------------------------------------------------
#+ GET <server>/ws/r/dfm/patients/getWards/<token>
#+ result: An array of wards
PUBLIC FUNCTION getWards(l_token STRING ATTRIBUTE(WSParam)) ATTRIBUTES( 
		WSPath = "/getWards/{l_token}",
		WSGet, 
		WSDescription = "Get wards")
	RETURNS (wardList ATTRIBUTES(WSMedia = 'application/json'))
	DEFINE l_patients Patients
	IF ws_lib.checkToken( l_token ) THEN
		LET l_patients.wards.messsage = "getting wards from db ..."
		CALL l_patients.getWardsDB()
	ELSE
		LET l_patients.wards.messsage = "Invalid Token."
	END IF
	RETURN l_patients.wards.*
END FUNCTION
--------------------------------------------------------------------------------
#+ GET <server>/ws/r/dfm/patients/getPatients/<token>/<id>
#+ result: A menu array by ID
PUBLIC FUNCTION getPatients(l_token STRING ATTRIBUTE(WSParam), l_ward SMALLINT ATTRIBUTE(WSParam)) ATTRIBUTES( 
		WSPath = "/getPatients/{l_token}/{l_ward}", 
		WSGet, 
		WSDescription = "Get patients for ward")
	RETURNS (patientList ATTRIBUTES(WSMedia = 'application/json'))
	DEFINE l_patients Patients
	IF ws_lib.checkToken( l_token ) THEN
		LET l_patients.patients.messsage = SFMT("getting patients for ward %1 from db ...", l_ward)
		CALL l_patients.getPatientsDB(l_ward)
	ELSE
		LET l_patients.patients.messsage = "Invalid Token."
	END IF
	RETURN l_patients.patients.*
END FUNCTION