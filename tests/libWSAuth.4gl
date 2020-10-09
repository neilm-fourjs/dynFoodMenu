
IMPORT util
IMPORT os
IMPORT FGL OAuthAPI

PUBLIC DEFINE serviceConfig RECORD
	GAS STRING,
	endPoint STRING,
	ClientID STRING,
	SecretID STRING,
	scopes           STRING,
	idp              STRING,
	idpTokenEndpoint STRING,
	connectionExpire INTEGER,
	token            STRING,
	tokenExpire      INTEGER
	END RECORD

PUBLIC DEFINE user_id STRING

FUNCTION init(l_cfgFileName STRING) RETURNS BOOLEAN
	DEFINE l_stat INT
	DEFINE l_cfg TEXT
	IF NOT os.path.exists( l_cfgFileName ) THEN
		DISPLAY SFMT("Missing config file '%1' !", l_cfgFileName)
		EXIT PROGRAM 1
	END IF
	DISPLAY SFMT("Using '%1' for configuration", l_cfgFileName)
	LOCATE l_cfg IN FILE l_cfgFileName
	CALL util.json.parse( l_cfg, serviceConfig )
	
	LET serviceConfig.endPoint = serviceConfig.GAS||"/ws/r/"||serviceConfig.endPoint
	LET serviceConfig.idp = serviceConfig.GAS||serviceConfig.idp
	DISPLAY SFMT("Endpoint: %1 ClientID: %2, SecretID: %3 IDP: %4", serviceConfig.endPoint, serviceConfig.ClientID, serviceConfig.SecretID, serviceConfig.idp )

	# Retrieve access token using login credentials
	CALL getAccessToken()

	# Initialize OAuth access
	CALL OAuthAPI.InitService(serviceConfig.connectionExpire, serviceConfig.Token) RETURNING l_stat
	DISPLAY SFMT("OAuthAPI.InitService Stat: %1", l_stat)

	LET user_id = OAuthAPI.getIDSubject()

	RETURN l_stat
END FUNCTION
--------------------------------------------------------------------------------
PRIVATE FUNCTION getAccessToken()
	DEFINE l_metadata OAuthAPI.OpenIDMetadataType

	# Retieve IdP info to get token endpoint for service access
	CALL OAuthAPI.FetchOpenIDMetadata(5, serviceConfig.idp) RETURNING l_metadata.*
	IF l_metadata.issuer IS NULL THEN
		DISPLAY SFMT("Error : IDP unavailable: %1", serviceConfig.idp)
		EXIT PROGRAM 1
	END IF

	# Get the access token using token endpoint and clientId/password
	CALL OAuthAPI.RetrieveServiceToken( 5, l_metadata.token_endpoint, serviceConfig.ClientId, serviceConfig.SecretId, serviceConfig.scopes )
			RETURNING serviceConfig.token, serviceConfig.tokenExpire
	IF serviceConfig.token IS NULL THEN
		DISPLAY SFMT("Unable to retrieve token: %1 CliID: %2 Secid: %3 Scopes: %4 ", l_metadata.token_endpoint, serviceConfig.ClientId, serviceConfig.SecretId, serviceConfig.scopes)
		EXIT PROGRAM 1
	ELSE
		DISPLAY SFMT("Token expires in %1 seconds", serviceConfig.tokenExpire)
	END IF
--	DISPLAY SFMT("Token: %1", serviceConfig.token)

END FUNCTION
