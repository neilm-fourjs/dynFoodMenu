#+
#+ Generated from wsPatients
#+
IMPORT com
IMPORT xml
IMPORT util
IMPORT os

&include "../src/menus.inc"

#+
#+ Global Endpoint user-defined type definition
#+
TYPE tGlobalEndpointType RECORD # Rest Endpoint
	Address RECORD # Address
		Uri STRING # URI
	END RECORD,
	Binding RECORD # Binding
		Version STRING, # HTTP Version (1.0 or 1.1)
		ConnectionTimeout INTEGER, # Connection timeout
		ReadWriteTimeout INTEGER, # Read write timeout
		CompressRequest STRING # Compression (gzip or deflate)
	END RECORD
END RECORD

PUBLIC DEFINE Endpoint tGlobalEndpointType
		= (Address:(Uri: "https://generodemos.dynu.net/z/ws/r/dfm/patients"))

# Error codes
PUBLIC CONSTANT C_SUCCESS = 0

# generated getPatientsResponseBodyType
PUBLIC TYPE getPatientsResponseBodyType patientList
{RECORD
	list DYNAMIC ARRAY OF RECORD
		id INTEGER,
		name STRING,
		dob DATE,
		gender_preference STRING,
		ward_id INTEGER,
		bed_no INTEGER,
		nilbymouth BOOLEAN,
		diabetic BOOLEAN,
		allergies STRING
	END RECORD,
	current RECORD
		id INTEGER,
		name STRING,
		dob DATE,
		gender_preference STRING,
		ward_id INTEGER,
		bed_no INTEGER,
		nilbymouth BOOLEAN,
		diabetic BOOLEAN,
		allergies STRING
	END RECORD,
	ordered DYNAMIC ARRAY OF RECORD
		patient_id INTEGER,
		menu_id STRING,
		placed DATETIME YEAR TO SECOND
	END RECORD,
	messsage STRING
END RECORD}

# generated getWardsResponseBodyType
PUBLIC TYPE getWardsResponseBodyType wardList
{RECORD
	list DYNAMIC ARRAY OF RECORD
		ward_id INTEGER,
		ward_name STRING
	END RECORD,
	current RECORD
		ward_id INTEGER,
		ward_name STRING
	END RECORD,
	messsage STRING
END RECORD}

################################################################################
# Operation /getPatients/{l_token}/{l_ward}
#
# VERB: GET
# DESCRIPTION: Get patients for ward
#
PUBLIC FUNCTION getPatients(p_l_token STRING, p_l_ward INTEGER)
		RETURNS(INTEGER, getPatientsResponseBodyType)
	DEFINE fullpath base.StringBuffer
	DEFINE contentType STRING
	DEFINE req com.HTTPRequest
	DEFINE resp com.HTTPResponse
	DEFINE resp_body getPatientsResponseBodyType
	DEFINE json_body STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/getPatients/{l_token}/{l_ward}")
		CALL fullpath.replace("{l_token}", p_l_token, 1)
		CALL fullpath.replace("{l_ward}", p_l_ward, 1)

		# Create request and configure it
		LET req =
				com.HTTPRequest.Create(
						SFMT("%1%2", Endpoint.Address.Uri, fullpath.toString()))
		IF Endpoint.Binding.Version IS NOT NULL THEN
			CALL req.setVersion(Endpoint.Binding.Version)
		END IF
		IF Endpoint.Binding.ConnectionTimeout <> 0 THEN
			CALL req.setConnectionTimeout(Endpoint.Binding.ConnectionTimeout)
		END IF
		IF Endpoint.Binding.ReadWriteTimeout <> 0 THEN
			CALL req.setTimeout(Endpoint.Binding.ReadWriteTimeout)
		END IF
		IF Endpoint.Binding.CompressRequest IS NOT NULL THEN
			CALL req.setHeader("Content-Encoding", Endpoint.Binding.CompressRequest)
		END IF

		# Perform request
		CALL req.setMethod("GET")
		CALL req.setHeader("Accept", "application/json")
		CALL req.DoRequest()

		# Retrieve response
		LET resp = req.getResponse()
		# Process response
		INITIALIZE resp_body TO NULL
		LET contentType = resp.getHeader("Content-Type")
		CASE resp.getStatusCode()

			WHEN 200 #Success
				IF contentType MATCHES "*application/json*" THEN
					# Parse JSON response
					LET json_body = resp.getTextResponse()
					CALL util.JSON.parse(json_body, resp_body)
					RETURN C_SUCCESS, resp_body.*
				END IF
				RETURN -1, resp_body.*

			OTHERWISE
				RETURN resp.getStatusCode(), resp_body.*
		END CASE
	CATCH
		RETURN -1, resp_body.*
	END TRY
END FUNCTION
################################################################################

################################################################################
# Operation /getWards/{l_token}
#
# VERB: GET
# DESCRIPTION: Get wards
#
PUBLIC FUNCTION getWards(p_l_token STRING)
		RETURNS(INTEGER, getWardsResponseBodyType)
	DEFINE fullpath base.StringBuffer
	DEFINE contentType STRING
	DEFINE req com.HTTPRequest
	DEFINE resp com.HTTPResponse
	DEFINE resp_body getWardsResponseBodyType
	DEFINE json_body STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/getWards/{l_token}")
		CALL fullpath.replace("{l_token}", p_l_token, 1)

		# Create request and configure it
		LET req =
				com.HTTPRequest.Create(
						SFMT("%1%2", Endpoint.Address.Uri, fullpath.toString()))
		IF Endpoint.Binding.Version IS NOT NULL THEN
			CALL req.setVersion(Endpoint.Binding.Version)
		END IF
		IF Endpoint.Binding.ConnectionTimeout <> 0 THEN
			CALL req.setConnectionTimeout(Endpoint.Binding.ConnectionTimeout)
		END IF
		IF Endpoint.Binding.ReadWriteTimeout <> 0 THEN
			CALL req.setTimeout(Endpoint.Binding.ReadWriteTimeout)
		END IF
		IF Endpoint.Binding.CompressRequest IS NOT NULL THEN
			CALL req.setHeader("Content-Encoding", Endpoint.Binding.CompressRequest)
		END IF

		# Perform request
		CALL req.setMethod("GET")
		CALL req.setHeader("Accept", "application/json")
		CALL req.DoRequest()

		# Retrieve response
		LET resp = req.getResponse()
		# Process response
		INITIALIZE resp_body TO NULL
		LET contentType = resp.getHeader("Content-Type")
		CASE resp.getStatusCode()

			WHEN 200 #Success
				IF contentType MATCHES "*application/json*" THEN
					# Parse JSON response
					LET json_body = resp.getTextResponse()
					CALL util.JSON.parse(json_body, resp_body)
					RETURN C_SUCCESS, resp_body.*
				END IF
				RETURN -1, resp_body.*

			OTHERWISE
				RETURN resp.getStatusCode(), resp_body.*
		END CASE
	CATCH
		RETURN -1, resp_body.*
	END TRY
END FUNCTION
################################################################################
