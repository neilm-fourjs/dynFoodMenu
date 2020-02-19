IMPORT util
IMPORT FGL Patients
IMPORT FGL utils
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

DEFINE m_patients Patients
--------------------------------------------------------------------------------
#+ GET <server>/dynFoodRest/getWards
#+ result: An array of wards
PUBLIC FUNCTION getWards() ATTRIBUTES( 
		WSPath = "/getWards",
		WSGet, 
		WSDescription = "Get wards")
	RETURNS (wardList ATTRIBUTES(WSMedia = 'application/json'))
	LET m_patients.wards.messsage = "getting wards from db ..."
	CALL m_patients.getWardsDB()
	RETURN m_patients.wards.*
END FUNCTION
--------------------------------------------------------------------------------
#+ GET <server>/dynFoodRest/getPatients/<id>
#+ result: A menu array by ID
PUBLIC FUNCTION getPatients(l_ward SMALLINT ATTRIBUTE(WSParam)) ATTRIBUTES( 
		WSPath = "/getPatients/{l_ward}", 
		WSGet, 
		WSDescription = "Get patients for ward")
	RETURNS (patientList ATTRIBUTES(WSMedia = 'application/json'))
	LET m_patients.wards.messsage = SFMT("getting patients for ward %1 from db ...", l_ward)
	CALL m_patients.getPatientsDB(l_ward)
	RETURN m_patients.patients.*
END FUNCTION