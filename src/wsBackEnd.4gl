#+
#+ Generated from cli
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
		= (Address:(Uri: "http://pi3:8090/dynFoodRest"))

# Error codes
PUBLIC CONSTANT C_SUCCESS = 0

# generated placeOrderRequestBodyType
PUBLIC TYPE placeOrderRequestBodyType orderRecord

# generated multipart placeOrderMultipartResponse
PUBLIC TYPE placeOrderMultipartResponse RECORD
	rv0 INTEGER,
	rv1 STRING
END RECORD

# generated getMenusResponseBodyType
PUBLIC TYPE getMenusResponseBodyType RECORD
	list DYNAMIC ARRAY OF RECORD
		menuName STRING,
		menuDesc STRING,
		menuImage STRING
	END RECORD,
	rows INTEGER
END RECORD

# generated getTokenResponseBodyType
PUBLIC TYPE getTokenResponseBodyType RECORD
	user_id STRING,
	user_name STRING,
	user_pwd STRING,
	user_token STRING,
	token_ts DATETIME YEAR TO MINUTE
END RECORD

# generated getMenuResponseBodyType
PUBLIC TYPE getMenuResponseBodyType menuRecord

################################################################################
# Operation /placeOrder
#
# VERB: POST
# DESCRIPTION: Place an Order
#
PUBLIC FUNCTION placeOrder(p_body placeOrderRequestBodyType)
		RETURNS(INTEGER, placeOrderMultipartResponse)
	DEFINE fullpath base.StringBuffer
	DEFINE contentType STRING
	DEFINE req com.HTTPRequest
	DEFINE resp com.HTTPResponse
	DEFINE resp_body placeOrderMultipartResponse
	DEFINE part com.HttpPart
	DEFINE ind INTEGER
	DEFINE json_body STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/placeOrder")

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
# Operation /getMenus
#
# VERB: GET
# DESCRIPTION: Get list of Menus
#
PUBLIC FUNCTION getMenus() RETURNS(INTEGER, getMenusResponseBodyType)
	DEFINE fullpath base.StringBuffer
	DEFINE contentType STRING
	DEFINE req com.HTTPRequest
	DEFINE resp com.HTTPResponse
	DEFINE resp_body getMenusResponseBodyType
	DEFINE json_body STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/getMenus")

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
# Operation /getMenu/{l_id}
#
# VERB: GET
# DESCRIPTION: Get a Menu
#
PUBLIC FUNCTION getMenu(p_l_menuName STRING) RETURNS(INTEGER, getMenuResponseBodyType)
	DEFINE fullpath base.StringBuffer
	DEFINE contentType STRING
	DEFINE req com.HTTPRequest
	DEFINE resp com.HTTPResponse
	DEFINE resp_body getMenuResponseBodyType
	DEFINE json_body STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/getMenu/{l_menuName}")
		CALL fullpath.replace("{l_menuName}", p_l_menuName, 1)

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
