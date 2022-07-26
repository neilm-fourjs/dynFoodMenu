#+
#+ Generated from wsUsers
#+
IMPORT com
IMPORT xml
IMPORT util
IMPORT os
IMPORT FGL OAuthAPI

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

PUBLIC DEFINE Endpoint tGlobalEndpointType = (Address:(Uri: "http://neilm-predator/g/ws/r/dfmv2/users"))

# Error codes
PUBLIC CONSTANT C_SUCCESS = 0

# generated v2_registerUserRequestBodyType
PUBLIC TYPE v2_registerUserRequestBodyType RECORD
	user_id           STRING,
	salutation        STRING,
	firstnames        STRING,
	surname           STRING,
	email             STRING,
	dob               DATE,
	gender_preference STRING,
	password_hash     STRING,
	registered        DATETIME YEAR TO SECOND
END RECORD

# generated multipart v2_registerUserMultipartResponse
PUBLIC TYPE v2_registerUserMultipartResponse RECORD
	rv0 INTEGER,
	rv1 STRING
END RECORD

# generated v1_registerUserRequestBodyType
PUBLIC TYPE v1_registerUserRequestBodyType RECORD
	user_id           STRING,
	salutation        STRING,
	firstnames        STRING,
	surname           STRING,
	email             STRING,
	dob               DATE,
	gender_preference STRING,
	password_hash     STRING,
	registered        DATETIME YEAR TO SECOND
END RECORD

# generated multipart v1_registerUserMultipartResponse
PUBLIC TYPE v1_registerUserMultipartResponse RECORD
	rv0 INTEGER,
	rv1 STRING
END RECORD

# generated v2_getUserResponseBodyType
PUBLIC TYPE v2_getUserResponseBodyType RECORD
	user_id    STRING,
	user_name  STRING,
	user_pwd   STRING,
	user_token STRING,
	token_ts   DATETIME YEAR TO SECOND
END RECORD

# generated v1_getUserResponseBodyType
PUBLIC TYPE v1_getUserResponseBodyType RECORD
	user_id    STRING,
	user_name  STRING,
	user_pwd   STRING,
	user_token STRING,
	token_ts   DATETIME YEAR TO SECOND
END RECORD

# generated multipart v2_checkUserIDMultipartResponse
PUBLIC TYPE v2_checkUserIDMultipartResponse RECORD
	rv0 BOOLEAN,
	rv1 STRING
END RECORD

# generated multipart v1_checkUserIDMultipartResponse
PUBLIC TYPE v1_checkUserIDMultipartResponse RECORD
	rv0 BOOLEAN,
	rv1 STRING
END RECORD

################################################################################
# Operation /v2/registerUser
#
# VERB: POST
# ID:          v2_registerUser
# DESCRIPTION: Register a user
#
PUBLIC FUNCTION v2_registerUser(p_body v2_registerUserRequestBodyType)
		RETURNS(INTEGER, v2_registerUserMultipartResponse)
	DEFINE fullpath    base.StringBuffer
	DEFINE contentType STRING
	DEFINE req         com.HTTPRequest
	DEFINE resp        com.HTTPResponse
	DEFINE resp_body   v2_registerUserMultipartResponse
	DEFINE part        com.HttpPart
	DEFINE ind         INTEGER
	DEFINE xml_body    xml.DomDocument
	DEFINE xml_node    xml.DomNode
	DEFINE json_body   STRING
	DEFINE txt         STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/v2/registerUser")

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
			CALL req.setMethod("POST")
			CALL req.setHeader("Accept", "multipart/form-data")
			# Perform JSON request
			CALL req.setHeader("Content-Type", "application/json")
			LET json_body = util.JSON.stringify(p_body)
			CALL req.DoTextRequest(json_body)

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
				IF resp.getMultipartType() IS NOT NULL THEN
					# Parse Multipart response
					# Parse main part rv0 response
					# Parse TEXT response
					LET txt           = resp.getTextResponse()
					LET resp_body.rv0 = txt
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
# Operation /v2/getTimestamp
#
# VERB: GET
# ID:          v2_getTimeStamp
# DESCRIPTION: Get the server time
#
PUBLIC FUNCTION v2_getTimeStamp() RETURNS(INTEGER, STRING)
	DEFINE fullpath    base.StringBuffer
	DEFINE contentType STRING
	DEFINE req         com.HTTPRequest
	DEFINE resp        com.HTTPResponse
	DEFINE resp_body   STRING
	DEFINE json_body   STRING
	DEFINE txt         STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/v2/getTimestamp")

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
		DISPLAY SFMT("Resp: %1 %2", resp.getStatusCode(), resp.getStatusDescription())
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
# Operation /v1/registerUser
#
# VERB: POST
# ID:          v1_registerUser
# DESCRIPTION: Register a user
#
PUBLIC FUNCTION v1_registerUser(p_body v1_registerUserRequestBodyType)
		RETURNS(INTEGER, v1_registerUserMultipartResponse)
	DEFINE fullpath    base.StringBuffer
	DEFINE contentType STRING
	DEFINE req         com.HTTPRequest
	DEFINE resp        com.HTTPResponse
	DEFINE resp_body   v1_registerUserMultipartResponse
	DEFINE part        com.HttpPart
	DEFINE ind         INTEGER
	DEFINE xml_body    xml.DomDocument
	DEFINE xml_node    xml.DomNode
	DEFINE json_body   STRING
	DEFINE txt         STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/v1/registerUser")

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
			CALL req.setMethod("POST")
			CALL req.setHeader("Accept", "multipart/form-data")
			# Perform JSON request
			CALL req.setHeader("Content-Type", "application/json")
			LET json_body = util.JSON.stringify(p_body)
			CALL req.DoTextRequest(json_body)

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
				IF resp.getMultipartType() IS NOT NULL THEN
					# Parse Multipart response
					# Parse main part rv0 response
					# Parse TEXT response
					LET txt           = resp.getTextResponse()
					LET resp_body.rv0 = txt
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
# Operation /v1/getTimestamp
#
# VERB: GET
# ID:          v1_getTimeStamp
# DESCRIPTION: Get the server time
#
PUBLIC FUNCTION v1_getTimeStamp() RETURNS(INTEGER, STRING)
	DEFINE fullpath    base.StringBuffer
	DEFINE contentType STRING
	DEFINE req         com.HTTPRequest
	DEFINE resp        com.HTTPResponse
	DEFINE resp_body   STRING
	DEFINE json_body   STRING
	DEFINE txt         STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/v1/getTimestamp")

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
# Operation /v2/getUser/{l_id}/{l_pwd}
#
# VERB: GET
# ID:          v2_getUser
# DESCRIPTION: Validate User and get Token
#
PUBLIC FUNCTION v2_getUser(
		p_l_id STRING, p_l_pwd STRING, p_X_FourJs_Environment_Variable_REMOTE_ADDR STRING, p_X_VTM_client_id STRING)
		RETURNS(INTEGER, v2_getUserResponseBodyType)
	DEFINE fullpath    base.StringBuffer
	DEFINE contentType STRING
	DEFINE req         com.HTTPRequest
	DEFINE resp        com.HTTPResponse
	DEFINE resp_body   v2_getUserResponseBodyType
	DEFINE json_body   STRING
	DEFINE txt         STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/v2/getUser/{l_id}/{l_pwd}")
		CALL fullpath.replace("{l_id}", p_l_id, 1)
		CALL fullpath.replace("{l_pwd}", p_l_pwd, 1)

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
			IF p_X_FourJs_Environment_Variable_REMOTE_ADDR IS NOT NULL THEN
				CALL req.setHeader("X-FourJs-Environment-Variable-REMOTE_ADDR", p_X_FourJs_Environment_Variable_REMOTE_ADDR)
			END IF
			IF p_X_VTM_client_id IS NOT NULL THEN
				CALL req.setHeader("X-VTM-client-id", p_X_VTM_client_id)
			END IF
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
# Operation /v1/getUser/{l_id}/{l_pwd}
#
# VERB: GET
# ID:          v1_getUser
# DESCRIPTION: Validate User and get Token
#
PUBLIC FUNCTION v1_getUser(p_l_id STRING, p_l_pwd STRING) RETURNS(INTEGER, v1_getUserResponseBodyType)
	DEFINE fullpath                 base.StringBuffer
	DEFINE contentType              STRING
	DEFINE req                      com.HTTPRequest
	DEFINE resp                     com.HTTPResponse
	DEFINE resp_body                v1_getUserResponseBodyType
	DEFINE json_body                STRING
	DEFINE txt                      STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/v1/getUser/{l_id}/{l_pwd}")
		CALL fullpath.replace("{l_id}", p_l_id, 1)
		CALL fullpath.replace("{l_pwd}", p_l_pwd, 1)

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
# Operation /v2/checkUserID/{l_id}
#
# VERB: GET
# ID:          v2_checkUserID
# DESCRIPTION: Check UserID
#
PUBLIC FUNCTION v2_checkUserID(p_l_id STRING) RETURNS(INTEGER, v2_checkUserIDMultipartResponse)
	DEFINE fullpath                     base.StringBuffer
	DEFINE contentType                  STRING
	DEFINE req                          com.HTTPRequest
	DEFINE resp                         com.HTTPResponse
	DEFINE resp_body                    v2_checkUserIDMultipartResponse
	DEFINE part                         com.HttpPart
	DEFINE ind                          INTEGER
	DEFINE xml_body                     xml.DomDocument
	DEFINE xml_node                     xml.DomNode
	DEFINE json_body                    STRING
	DEFINE txt                          STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/v2/checkUserID/{l_id}")
		CALL fullpath.replace("{l_id}", p_l_id, 1)

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
			CALL req.setHeader("Accept", "multipart/form-data")
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
				IF resp.getMultipartType() IS NOT NULL THEN
					# Parse Multipart response
					# Parse main part rv0 response
					# Parse TEXT response
					LET txt = resp.getTextResponse()
					IF txt IS NULL THEN
						LET resp_body.rv0 = NULL
					ELSE
						IF txt.equalsIgnoreCase("true") THEN
							LET resp_body.rv0 = TRUE
						ELSE
							IF txt.equalsIgnoreCase("false") THEN
								LET resp_body.rv0 = FALSE
							ELSE
								LET resp_body.rv0 = txt
							END IF
						END IF
					END IF
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
# Operation /v1/checkUserID/{l_id}
#
# VERB: GET
# ID:          v1_checkUserID
# DESCRIPTION: Check UserID
#
PUBLIC FUNCTION v1_checkUserID(p_l_id STRING) RETURNS(INTEGER, v1_checkUserIDMultipartResponse)
	DEFINE fullpath                     base.StringBuffer
	DEFINE contentType                  STRING
	DEFINE req                          com.HTTPRequest
	DEFINE resp                         com.HTTPResponse
	DEFINE resp_body                    v1_checkUserIDMultipartResponse
	DEFINE part                         com.HttpPart
	DEFINE ind                          INTEGER
	DEFINE xml_body                     xml.DomDocument
	DEFINE xml_node                     xml.DomNode
	DEFINE json_body                    STRING
	DEFINE txt                          STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/v1/checkUserID/{l_id}")
		CALL fullpath.replace("{l_id}", p_l_id, 1)

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
			CALL req.setHeader("Accept", "multipart/form-data")
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
				IF resp.getMultipartType() IS NOT NULL THEN
					# Parse Multipart response
					# Parse main part rv0 response
					# Parse TEXT response
					LET txt = resp.getTextResponse()
					IF txt IS NULL THEN
						LET resp_body.rv0 = NULL
					ELSE
						IF txt.equalsIgnoreCase("true") THEN
							LET resp_body.rv0 = TRUE
						ELSE
							IF txt.equalsIgnoreCase("false") THEN
								LET resp_body.rv0 = FALSE
							ELSE
								LET resp_body.rv0 = txt
							END IF
						END IF
					END IF
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
