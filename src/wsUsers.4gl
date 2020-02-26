#+
#+ Generated from wsUsers
#+
IMPORT com
IMPORT xml
IMPORT util
IMPORT os

&include "menus.inc"
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
		= (Address:(Uri: "https://generodemos.dynu.net/z/ws/r/dfm/users"))

# Error codes
PUBLIC CONSTANT C_SUCCESS = 0

# generated registerUserRequestBodyType
PUBLIC TYPE registerUserRequestBodyType RECORD
	user_id STRING,
	salutation STRING,
	firstnames STRING,
	surname STRING,
	email STRING,
	dob DATE,
	gender_preference STRING,
	password_hash STRING,
	registered DATETIME YEAR TO SECOND
END RECORD

# generated multipart registerUserMultipartResponse
PUBLIC TYPE registerUserMultipartResponse RECORD
	rv0 INTEGER,
	rv1 STRING
END RECORD

# generated getTokenResponseBodyType
PUBLIC TYPE getTokenResponseBodyType userRecord
{ RECORD
	user_id STRING,
	user_name STRING,
	user_pwd STRING,
	user_token STRING,
	token_ts DATETIME YEAR TO SECOND
END RECORD}

# generated multipart checkUserIDMultipartResponse
PUBLIC TYPE checkUserIDMultipartResponse RECORD
	rv0 BOOLEAN,
	rv1 STRING
END RECORD

################################################################################
# Operation /registerUser
#
# VERB: POST
# DESCRIPTION: Register a user
#
PUBLIC FUNCTION registerUser(p_body registerUserRequestBodyType)
		RETURNS(INTEGER, registerUserMultipartResponse)
	DEFINE fullpath base.StringBuffer
	DEFINE contentType STRING
	DEFINE req com.HTTPRequest
	DEFINE resp com.HTTPResponse
	DEFINE resp_body registerUserMultipartResponse
	DEFINE part com.HttpPart
	DEFINE ind INTEGER
	DEFINE xml_body xml.DomDocument
	DEFINE xml_node xml.DomNode
	DEFINE json_body STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/registerUser")

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
		CALL req.setMethod("POST")
		CALL req.setHeader("Accept", "multipart/form-data")
		# Perform JSON request
		CALL req.setHeader("Content-Type", "application/json")
		LET json_body = util.JSON.stringify(p_body)
		CALL req.DoTextRequest(json_body)

		# Retrieve response
		LET resp = req.getResponse()
		# Process response
		INITIALIZE resp_body TO NULL
		LET contentType = resp.getHeader("Content-Type")
		CASE resp.getStatusCode()

			WHEN 200 #Success
				IF resp.getMultipartType() IS NOT NULL THEN
					# Parse Multipart response
					# Parse main part rv0 response
					# Parse TEXT response
					LET resp_body.rv0 = resp.getTextResponse()
					FOR ind = 1 TO resp.getPartCount()
						LET part = resp.getPart(ind)
						# Parse rv1 response
						# Parse JSON response
						LET json_body = part.getContentAsString()
						CALL util.JSON.parse(json_body, resp_body.rv1)
					END FOR
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
# Operation /getTimestamp
#
# VERB: GET
# DESCRIPTION: Get the server time
#
PUBLIC FUNCTION getTimeStamp() RETURNS(INTEGER, STRING)
	DEFINE fullpath base.StringBuffer
	DEFINE contentType STRING
	DEFINE req com.HTTPRequest
	DEFINE resp com.HTTPResponse
	DEFINE resp_body STRING
	DEFINE json_body STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/getTimestamp")

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
					RETURN C_SUCCESS, resp_body
				END IF
				RETURN -1, resp_body

			OTHERWISE
				RETURN resp.getStatusCode(), resp_body
		END CASE
	CATCH
		RETURN -1, resp_body
	END TRY
END FUNCTION
################################################################################

################################################################################
# Operation /getToken/{l_id}/{l_pwd}
#
# VERB: GET
# DESCRIPTION: Validate User and get Token
#
PUBLIC FUNCTION getToken(p_l_id STRING, p_l_pwd STRING)
		RETURNS(INTEGER, getTokenResponseBodyType)
	DEFINE fullpath base.StringBuffer
	DEFINE contentType STRING
	DEFINE req com.HTTPRequest
	DEFINE resp com.HTTPResponse
	DEFINE resp_body getTokenResponseBodyType
	DEFINE json_body STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/getToken/{l_id}/{l_pwd}")
		CALL fullpath.replace("{l_id}", p_l_id, 1)
		CALL fullpath.replace("{l_pwd}", p_l_pwd, 1)

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
# Operation /checkUserID/{l_id}
#
# VERB: GET
# DESCRIPTION: Check UserID
#
PUBLIC FUNCTION checkUserID(p_l_id STRING)
		RETURNS(INTEGER, checkUserIDMultipartResponse)
	DEFINE fullpath base.StringBuffer
	DEFINE contentType STRING
	DEFINE req com.HTTPRequest
	DEFINE resp com.HTTPResponse
	DEFINE resp_body checkUserIDMultipartResponse
	DEFINE part com.HttpPart
	DEFINE ind INTEGER
	DEFINE xml_body xml.DomDocument
	DEFINE xml_node xml.DomNode
	DEFINE json_body STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/checkUserID/{l_id}")
		CALL fullpath.replace("{l_id}", p_l_id, 1)

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
		CALL req.setHeader("Accept", "multipart/form-data")
		CALL req.DoRequest()

		# Retrieve response
		LET resp = req.getResponse()
		# Process response
		INITIALIZE resp_body TO NULL
		LET contentType = resp.getHeader("Content-Type")
		CASE resp.getStatusCode()

			WHEN 200 #Success
				IF resp.getMultipartType() IS NOT NULL THEN
					# Parse Multipart response
					# Parse main part rv0 response
					# Parse TEXT response
					LET resp_body.rv0 = resp.getTextResponse()
					FOR ind = 1 TO resp.getPartCount()
						LET part = resp.getPart(ind)
						# Parse rv1 response
						# Parse JSON response
						LET json_body = part.getContentAsString()
						CALL util.JSON.parse(json_body, resp_body.rv1)
					END FOR
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
