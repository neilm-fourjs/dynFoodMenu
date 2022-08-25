#+
#+ Generated from wsPatients
#+
IMPORT com
IMPORT util
IMPORT FGL OAuthAPI
&include "app.inc"

#+
#+ Global Endpoint user-defined type definition
#+
TYPE tGlobalEndpointType RECORD # Rest Endpoint
	Address RECORD                # Address
		Uri STRING                  # URI
	END RECORD,
	Binding RECORD               # Binding
		Version           STRING,  # HTTP Version (1.0 or 1.1)
		ConnectionTimeout INTEGER, # Connection timeout
		ReadWriteTimeout  INTEGER, # Read write timeout
		CompressRequest   STRING   # Compression (gzip or deflate)
	END RECORD
END RECORD

PUBLIC DEFINE Endpoint tGlobalEndpointType = (Address:(Uri: "http://neilm-predator/g/ws/r/dfmv2/patients"))

# Error codes
PUBLIC CONSTANT C_SUCCESS = 0

# generated v2_getPatientsResponseBodyType
PUBLIC TYPE v2_getPatientsResponseBodyType patientList
{ RECORD
		id                INTEGER,
		name              STRING,
		dob               DATE,
		gender_preference STRING,
		ward_id           INTEGER,
		bed_no            INTEGER,
		nilbymouth        BOOLEAN,
		diabetic          BOOLEAN,
		allergies         STRING
	END RECORD
	current RECORD
		id                INTEGER,
		name              STRING,
		dob               DATE,
		gender_preference STRING,
		ward_id           INTEGER,
		bed_no            INTEGER,
		nilbymouth        BOOLEAN,
		diabetic          BOOLEAN,
		allergies         STRING
	END RECORD,
	ordered DYNAMIC ARRAY OF RECORD
		patient_id INTEGER,
		menu_id    STRING,
		placed     DATETIME YEAR TO SECOND
	END RECORD,
	message STRING
END RECORD}

# generated v1_getPatientsResponseBodyType
PUBLIC TYPE v1_getPatientsResponseBodyType RECORD
	list DYNAMIC ARRAY OF RECORD
		id                INTEGER,
		name              STRING,
		dob               DATE,
		gender_preference STRING,
		ward_id           INTEGER,
		bed_no            INTEGER,
		nilbymouth        BOOLEAN,
		diabetic          BOOLEAN,
		allergies         STRING
	END RECORD,
	current RECORD
		id                INTEGER,
		name              STRING,
		dob               DATE,
		gender_preference STRING,
		ward_id           INTEGER,
		bed_no            INTEGER,
		nilbymouth        BOOLEAN,
		diabetic          BOOLEAN,
		allergies         STRING
	END RECORD,
	ordered DYNAMIC ARRAY OF RECORD
		patient_id INTEGER,
		menu_id    STRING,
		placed     DATETIME YEAR TO SECOND
	END RECORD,
	message STRING
END RECORD

# generated v2_getWardsResponseBodyType
PUBLIC TYPE v2_getWardsResponseBodyType wardList
{ RECORD
	list DYNAMIC ARRAY OF RECORD
		ward_id   INTEGER,
		ward_name STRING
	END RECORD,
	current RECORD
		ward_id   INTEGER,
		ward_name STRING
	END RECORD,
	message STRING
END RECORD}

# generated v1_getWardsResponseBodyType
PUBLIC TYPE v1_getWardsResponseBodyType RECORD
	list DYNAMIC ARRAY OF RECORD
		ward_id   INTEGER,
		ward_name STRING
	END RECORD,
	current RECORD
		ward_id   INTEGER,
		ward_name STRING
	END RECORD,
	message STRING
END RECORD

################################################################################
# Operation /v2/getPatients/{l_token}/{l_ward}
#
# VERB: GET
# ID:          v2_getPatients
# DESCRIPTION: Get patients for ward
#
PUBLIC FUNCTION v2_getPatients(p_l_token STRING, p_l_ward INTEGER) RETURNS(INTEGER, v2_getPatientsResponseBodyType)
	DEFINE fullpath                        base.StringBuffer
	DEFINE contentType                     STRING
	DEFINE req                             com.HTTPRequest
	DEFINE resp                            com.HTTPResponse
	DEFINE resp_body                       v2_getPatientsResponseBodyType
	DEFINE json_body                       STRING
	DEFINE txt                             STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/v2/getPatients/{l_token}/{l_ward}")
		CALL fullpath.replace("{l_token}", p_l_token, 1)
		CALL fullpath.replace("{l_ward}", p_l_ward, 1)

		WHILE TRUE
			# Create oauth request and configure it
			LET req = OAuthAPI.CreateHTTPAuthorizationRequest(SFMT("%1%2", Endpoint.Address.Uri, fullpath.toString()))
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
			# Retry if access token has expired
			IF NOT OAuthAPI.RetryHTTPRequest(resp) THEN
				EXIT WHILE
			END IF
		END WHILE
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
# Operation /v1/getPatients/{l_token}/{l_ward}
#
# VERB: GET
# ID:          v1_getPatients
# DESCRIPTION: Get patients for ward
#
PUBLIC FUNCTION v1_getPatients(p_l_token STRING, p_l_ward INTEGER) RETURNS(INTEGER, v1_getPatientsResponseBodyType)
	DEFINE fullpath                        base.StringBuffer
	DEFINE contentType                     STRING
	DEFINE req                             com.HTTPRequest
	DEFINE resp                            com.HTTPResponse
	DEFINE resp_body                       v1_getPatientsResponseBodyType
	DEFINE json_body                       STRING
	DEFINE txt                             STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/v1/getPatients/{l_token}/{l_ward}")
		CALL fullpath.replace("{l_token}", p_l_token, 1)
		CALL fullpath.replace("{l_ward}", p_l_ward, 1)

		WHILE TRUE
			# Create oauth request and configure it
			LET req = OAuthAPI.CreateHTTPAuthorizationRequest(SFMT("%1%2", Endpoint.Address.Uri, fullpath.toString()))
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
			# Retry if access token has expired
			IF NOT OAuthAPI.RetryHTTPRequest(resp) THEN
				EXIT WHILE
			END IF
		END WHILE
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
# Operation /v2/getWards/{l_token}
#
# VERB: GET
# ID:          v2_getWards
# DESCRIPTION: Get wards
#
PUBLIC FUNCTION v2_getWards(p_l_token STRING) RETURNS(INTEGER, v2_getWardsResponseBodyType)
	DEFINE fullpath                     base.StringBuffer
	DEFINE contentType                  STRING
	DEFINE req                          com.HTTPRequest
	DEFINE resp                         com.HTTPResponse
	DEFINE resp_body                    v2_getWardsResponseBodyType
	DEFINE json_body                    STRING
	DEFINE txt                          STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/v2/getWards/{l_token}")
		CALL fullpath.replace("{l_token}", p_l_token, 1)

		WHILE TRUE
			# Create oauth request and configure it
			LET req = OAuthAPI.CreateHTTPAuthorizationRequest(SFMT("%1%2", Endpoint.Address.Uri, fullpath.toString()))
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
			# Retry if access token has expired
			IF NOT OAuthAPI.RetryHTTPRequest(resp) THEN
				EXIT WHILE
			END IF
		END WHILE
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
# Operation /v1/getWards/{l_token}
#
# VERB: GET
# ID:          v1_getWards
# DESCRIPTION: Get wards
#
PUBLIC FUNCTION v1_getWards(p_l_token STRING) RETURNS(INTEGER, v1_getWardsResponseBodyType)
	DEFINE fullpath                     base.StringBuffer
	DEFINE contentType                  STRING
	DEFINE req                          com.HTTPRequest
	DEFINE resp                         com.HTTPResponse
	DEFINE resp_body                    v1_getWardsResponseBodyType
	DEFINE json_body                    STRING
	DEFINE txt                          STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/v1/getWards/{l_token}")
		CALL fullpath.replace("{l_token}", p_l_token, 1)

		WHILE TRUE
			# Create oauth request and configure it
			LET req = OAuthAPI.CreateHTTPAuthorizationRequest(SFMT("%1%2", Endpoint.Address.Uri, fullpath.toString()))
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
			# Retry if access token has expired
			IF NOT OAuthAPI.RetryHTTPRequest(resp) THEN
				EXIT WHILE
			END IF
		END WHILE
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
