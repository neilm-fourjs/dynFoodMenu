IMPORT util
IMPORT os
IMPORT FGL OAuthAPI

PUBLIC DEFINE serviceConfig RECORD
	GAS              STRING,
	endPoint         STRING,
	ClientID         STRING,
	SecretID         STRING,
	scopes           STRING,
	idp              STRING,
	idpTokenEndpoint STRING,
	connectionExpire INTEGER,
	token            STRING,
	tokenExpire      INTEGER
END RECORD

PUBLIC DEFINE user_id STRING

FUNCTION init(l_cfgFileName STRING) RETURNS BOOLEAN
	DEFINE l_stat             INT
	DEFINE l_cfg              TEXT

-- check for and read the json configure for the web services
	IF NOT os.path.exists(l_cfgFileName) THEN
		DISPLAY SFMT("Missing config file '%1' !", l_cfgFileName)
		EXIT PROGRAM 1
	END IF
	DISPLAY SFMT("Using '%1' for configuration", l_cfgFileName)
	LOCATE l_cfg IN FILE l_cfgFileName
	CALL util.json.parse(l_cfg, serviceConfig)

-- Set the endpoint for the GAS
	LET serviceConfig.endPoint = serviceConfig.GAS || "/ws/r/" || serviceConfig.endPoint
-- Set the IDP for the GAS
	LET serviceConfig.idp = serviceConfig.GAS || serviceConfig.idp

	IF fgl_getEnv("MYWSDEBUG") = "9" THEN
		DISPLAY SFMT("libWSAuth.init: GAS: %1", serviceConfig.GAS)
		DISPLAY SFMT("libWSAuth.init: Endpoint: %1", serviceConfig.endPoint)
		DISPLAY SFMT("libWSAuth.init: IDP: %1", serviceConfig.idp)
		DISPLAY SFMT("libWSAuth.init: ClientID: %1, SecretID: %2", serviceConfig.ClientID, serviceConfig.SecretID)
		DISPLAY SFMT("libWSAuth.init: Scopes: %1", serviceConfig.scopes)
	END IF

-- Retrieve access token using login credentials
	CALL getAccessToken()

-- Initialize OAuth access
	CALL OAuthAPI.InitService(serviceConfig.connectionExpire, serviceConfig.Token) RETURNING l_stat

-- Is this actually useful to anyone ?
	LET user_id = OAuthAPI.getIDSubject()

	RETURN l_stat
END FUNCTION
--------------------------------------------------------------------------------
PRIVATE FUNCTION getAccessToken()
	DEFINE l_metadata         OAuthAPI.OpenIDMetadataType
	DEFINE l_scopes_supported STRING
	DEFINE x                  SMALLINT

-- Retieve IdP info to get token endpoint for service access
	IF fgl_getEnv("MYWSDEBUG") = "9" THEN
		DISPLAY SFMT("libWSAuth.getAccessToken: Service IDP: %1", serviceConfig.idp)
	END IF
	CALL OAuthAPI.FetchOpenIDMetadata(5, serviceConfig.idp) RETURNING l_metadata.*
	IF l_metadata.issuer IS NULL THEN
		DISPLAY SFMT("Error : IDP unavailable: %1", serviceConfig.idp)
		EXIT PROGRAM 1
	END IF

	IF fgl_getEnv("MYWSDEBUG") = "9" THEN
		FOR x = 1 TO l_metadata.scopes_supported.getLength()
			LET l_scopes_supported = l_scopes_supported.append(l_metadata.scopes_supported[x] || " ")
		END FOR
		DISPLAY SFMT("libWSAuth.getAccessToken: Token Endpoint: %1", l_metadata.token_endpoint)
		DISPLAY SFMT("libWSAuth.getAccessToken: Scopes Support: %1", l_scopes_supported)
	END IF

-- Get the access token using token endpoint and clientId/password
	CALL OAuthAPI.RetrieveServiceToken(
					5, l_metadata.token_endpoint, serviceConfig.ClientId, serviceConfig.SecretId, serviceConfig.scopes)
			RETURNING serviceConfig.token, serviceConfig.tokenExpire
	IF serviceConfig.token IS NULL THEN
		DISPLAY SFMT("Unable to retrieve token: %1 CliID: %2 Secid: %3 Scopes: %4 ",
				l_metadata.token_endpoint, serviceConfig.ClientId, serviceConfig.SecretId, serviceConfig.scopes)
		EXIT PROGRAM 1
	END IF
	IF fgl_getEnv("MYWSDEBUG") = "9" THEN
		DISPLAY SFMT("libWSAuth.getAccessToken: Token: %1", serviceConfig.token)
		DISPLAY SFMT("libWSAuth.getAccessToken: Token Expires in %1 seconds", serviceConfig.tokenExpire)
	END IF

END FUNCTION
