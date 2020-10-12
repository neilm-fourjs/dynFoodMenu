#+
#+ Generated from wsMenus
#+
IMPORT com
IMPORT xml
IMPORT util
IMPORT os
IMPORT FGL OAuthAPI
&include "menus.inc"

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

PUBLIC DEFINE Endpoint tGlobalEndpointType = (Address:(Uri: "http://neilm-predator/g/ws/r/dfmv2/menus"))

# Error codes
PUBLIC CONSTANT C_SUCCESS   = 0
PUBLIC CONSTANT C_MENUERROR = 1001

# generated v2_placeOrderRequestBodyType
PUBLIC TYPE v2_placeOrderRequestBodyType orderRecord
{RECORD
	order_id   INTEGER,
	user_token STRING,
	user_id    STRING,
	patient_id INTEGER,
	ward_id    INTEGER,
	bed_no     INTEGER,
	menu_id    STRING,
	placed     DATETIME YEAR TO SECOND,
	items DYNAMIC ARRAY OF RECORD
		order_id    INTEGER,
		item_id     INTEGER,
		description STRING,
		qty         INTEGER,
		optional    BOOLEAN
	END RECORD,
	rows INTEGER
END RECORD}

# generated multipart v2_placeOrderMultipartResponse
PUBLIC TYPE v2_placeOrderMultipartResponse RECORD
	rv0 INTEGER,
	rv1 STRING
END RECORD

# generated v2_getMenusResponseBodyType
PUBLIC TYPE v2_getMenusResponseBodyType menuList
{RECORD
	list DYNAMIC ARRAY OF RECORD
		menuName  STRING,
		menuDesc  STRING,
		menuImage STRING
	END RECORD,
	rows INTEGER
END RECORD}

# generated v1_placeOrderRequestBodyType
PUBLIC TYPE v1_placeOrderRequestBodyType orderRecord
{ RECORD
	order_id   INTEGER,
	user_token STRING,
	user_id    STRING,
	patient_id INTEGER,
	ward_id    INTEGER,
	bed_no     INTEGER,
	menu_id    STRING,
	placed     DATETIME YEAR TO SECOND,
	items DYNAMIC ARRAY OF RECORD
		order_id    INTEGER,
		item_id     INTEGER,
		description STRING,
		qty         INTEGER,
		optional    BOOLEAN
	END RECORD,
	rows INTEGER
END RECORD }

# generated multipart v1_placeOrderMultipartResponse
PUBLIC TYPE v1_placeOrderMultipartResponse RECORD
	rv0 INTEGER,
	rv1 STRING
END RECORD

# generated v1_getMenusResponseBodyType
PUBLIC TYPE v1_getMenusResponseBodyType RECORD
	list DYNAMIC ARRAY OF RECORD
		menuName  STRING,
		menuDesc  STRING,
		menuImage STRING
	END RECORD,
	rows INTEGER
END RECORD

# generated v2_getMenuResponseBodyType
PUBLIC TYPE v2_getMenuResponseBodyType menuRecord
{RECORD
	menuName STRING,
	items DYNAMIC ARRAY OF RECORD
		menuName    STRING,
		t_id        INTEGER,
		t_pid       INTEGER,
		id          STRING,
		type        STRING,
		description STRING,
		conditional BOOLEAN,
		minval      INTEGER,
		maxval      INTEGER,
		field       STRING,
		option_id   STRING,
		option_name STRING,
		hidden      BOOLEAN,
		level       INTEGER
	END RECORD,
	rows INTEGER
END RECORD}

# generated menuErrorErrorType
PUBLIC TYPE menuErrorErrorType RECORD
	host    STRING,
	status  INTEGER,
	message STRING
END RECORD

# generated v1_getMenuResponseBodyType
PUBLIC TYPE v1_getMenuResponseBodyType RECORD
	menuName STRING,
	items DYNAMIC ARRAY OF RECORD
		menuName    STRING,
		t_id        INTEGER,
		t_pid       INTEGER,
		id          STRING,
		type        STRING,
		description STRING,
		conditional BOOLEAN,
		minval      INTEGER,
		maxval      INTEGER,
		field       STRING,
		option_id   STRING,
		option_name STRING,
		hidden      BOOLEAN,
		level       INTEGER
	END RECORD,
	rows INTEGER
END RECORD

PUBLIC # Menu Error
		DEFINE menuError menuErrorErrorType

################################################################################
# Operation /v2/placeOrder
#
# VERB: POST
# ID:          v2_placeOrder
# DESCRIPTION: Place an Order
#
PUBLIC FUNCTION v2_placeOrder(p_body v2_placeOrderRequestBodyType) RETURNS(INTEGER, v2_placeOrderMultipartResponse)
	DEFINE fullpath                    base.StringBuffer
	DEFINE contentType                 STRING
	DEFINE req                         com.HTTPRequest
	DEFINE resp                        com.HTTPResponse
	DEFINE resp_body                   v2_placeOrderMultipartResponse
	DEFINE part                        com.HttpPart
	DEFINE ind                         INTEGER
	DEFINE xml_body                    xml.DomDocument
	DEFINE xml_node                    xml.DomNode
	DEFINE json_body                   STRING
	DEFINE txt                         STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/v2/placeOrder")

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
# Operation /v2/getMenu
#
# VERB: GET
# ID:          v2_getMenus
# DESCRIPTION: Get list of Menus
#
PUBLIC FUNCTION v2_getMenus()
		RETURNS(INTEGER, v2_getMenusResponseBodyType)
	DEFINE fullpath    base.StringBuffer
	DEFINE contentType STRING
	DEFINE req         com.HTTPRequest
	DEFINE resp        com.HTTPResponse
	DEFINE resp_body   v2_getMenusResponseBodyType
	DEFINE json_body   STRING
	DEFINE txt         STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/v2/getMenu")

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
# Operation /v1/placeOrder
#
# VERB: POST
# ID:          v1_placeOrder
# DESCRIPTION: Place an Order
#
PUBLIC FUNCTION v1_placeOrder(p_body v1_placeOrderRequestBodyType) RETURNS(INTEGER, v1_placeOrderMultipartResponse)
	DEFINE fullpath                    base.StringBuffer
	DEFINE contentType                 STRING
	DEFINE req                         com.HTTPRequest
	DEFINE resp                        com.HTTPResponse
	DEFINE resp_body                   v1_placeOrderMultipartResponse
	DEFINE part                        com.HttpPart
	DEFINE ind                         INTEGER
	DEFINE xml_body                    xml.DomDocument
	DEFINE xml_node                    xml.DomNode
	DEFINE json_body                   STRING
	DEFINE txt                         STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/v1/placeOrder")

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
# Operation /v1/getMenu
#
# VERB: GET
# ID:          v1_getMenus
# DESCRIPTION: Get list of Menus
#
PUBLIC FUNCTION v1_getMenus(p_X_FourJs_Environment_Variable_REMOTE_ADDR STRING)
		RETURNS(INTEGER, v1_getMenusResponseBodyType)
	DEFINE fullpath    base.StringBuffer
	DEFINE contentType STRING
	DEFINE req         com.HTTPRequest
	DEFINE resp        com.HTTPResponse
	DEFINE resp_body   v1_getMenusResponseBodyType
	DEFINE json_body   STRING
	DEFINE txt         STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/v1/getMenu")

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
# Operation /v2/getMenu/{l_menuName}
#
# VERB: GET
# ID:          v2_getMenu
# DESCRIPTION: Get a Menu
#
PUBLIC FUNCTION v2_getMenu(p_l_menuName STRING) RETURNS(INTEGER, v2_getMenuResponseBodyType)
	DEFINE fullpath                       base.StringBuffer
	DEFINE contentType                    STRING
	DEFINE req                            com.HTTPRequest
	DEFINE resp                           com.HTTPResponse
	DEFINE resp_body                      v2_getMenuResponseBodyType
	DEFINE json_body                      STRING
	DEFINE txt                            STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/v2/getMenu/{l_menuName}")
		CALL fullpath.replace("{l_menuName}", p_l_menuName, 1)

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

			WHEN 400 #Menu Error
				IF contentType MATCHES "*application/json*" THEN
					# Parse JSON response
					LET json_body = resp.getTextResponse()
					CALL util.JSON.parse(json_body, menuError)
					RETURN C_MENUERROR, resp_body.*
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
# Operation /v1/getMenu/{l_menuName}
#
# VERB: GET
# ID:          v1_getMenu
# DESCRIPTION: Get a Menu
#
PUBLIC FUNCTION v1_getMenu(p_l_menuName STRING) RETURNS(INTEGER, v1_getMenuResponseBodyType)
	DEFINE fullpath                       base.StringBuffer
	DEFINE contentType                    STRING
	DEFINE req                            com.HTTPRequest
	DEFINE resp                           com.HTTPResponse
	DEFINE resp_body                      v1_getMenuResponseBodyType
	DEFINE json_body                      STRING
	DEFINE txt                            STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.Create()
		CALL fullpath.append("/v1/getMenu/{l_menuName}")
		CALL fullpath.replace("{l_menuName}", p_l_menuName, 1)

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
