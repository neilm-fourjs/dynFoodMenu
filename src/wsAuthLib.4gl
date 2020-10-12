IMPORT util
IMPORT os
IMPORT FGL OAuthAPI

PUBLIC TYPE wsAuthLib RECORD
	cfgFileName      STRING,
	user_id          STRING,
	connectionExpire INTEGER,
	token            STRING,
	tokenExpire      INTEGER,
	cfg RECORD
		GAS              STRING,
		endPoint         STRING,
		ClientID         STRING,
		SecretID         STRING,
		scopes           STRING,
		idp              STRING,
		idpTokenEndpoint STRING
	END RECORD
END RECORD

PUBLIC FUNCTION (this wsAuthLib) init(l_cfgFileName STRING) RETURNS BOOLEAN
	DEFINE l_stat       INT
	DEFINE l_cfg        TEXT

-- check for and read the json configure for the web services
	IF NOT os.path.exists(l_cfgFileName) THEN
		DISPLAY SFMT("Missing config file '%1' !", l_cfgFileName)
		EXIT PROGRAM 1
	END IF
	DISPLAY SFMT("Using '%1' for configuration", l_cfgFileName)
	LOCATE l_cfg IN FILE l_cfgFileName
	CALL util.json.parse(l_cfg, this.cfg)

-- Set the endpoint for the GAS
	LET this.cfg.endPoint = this.cfg.GAS || "/ws/r/" || this.cfg.endPoint
-- Set the IDP for the GAS
	LET this.cfg.idp = this.cfg.GAS || this.cfg.idp

	IF fgl_getEnv("MYWSDEBUG") = "9" THEN
		DISPLAY SFMT("wsAuthLib.init: GAS: %1", this.cfg.GAS)
		DISPLAY SFMT("wsAuthLib.init: Endpoint: %1", this.cfg.endPoint)
		DISPLAY SFMT("wsAuthLib.init: IDP: %1", this.cfg.idp)
		DISPLAY SFMT("wsAuthLib.init: ClientID: %1, SecretID: %2", this.cfg.ClientID, this.cfg.SecretID)
		DISPLAY SFMT("wsAuthLib.init: Scopes: %1", this.cfg.scopes)
	END IF

-- Retrieve access token using login credentials
	CALL this.getAccessToken()

-- Initialize OAuth access
	CALL OAuthAPI.InitService(this.connectionExpire, this.Token) RETURNING l_stat

-- Is this actually useful to anyone ?
	LET this.user_id = OAuthAPI.getIDSubject()

	RETURN l_stat
END FUNCTION
--------------------------------------------------------------------------------
PRIVATE FUNCTION (this      wsAuthLib) getAccessToken()
	DEFINE l_metadata         OAuthAPI.OpenIDMetadataType
	DEFINE l_scopes_supported STRING
	DEFINE x                  SMALLINT

-- Retieve IdP info to get token endpoint for service access
	IF fgl_getEnv("MYWSDEBUG") = "9" THEN
		DISPLAY SFMT("wsAuthLib.getAccessToken: Service IDP: %1", this.cfg.idp)
	END IF
	CALL OAuthAPI.FetchOpenIDMetadata(5, this.cfg.idp) RETURNING l_metadata.*
	IF l_metadata.issuer IS NULL THEN
		DISPLAY SFMT("Error : IDP unavailable: %1", this.cfg.idp)
		EXIT PROGRAM 1
	END IF

	IF fgl_getEnv("MYWSDEBUG") = "9" THEN
		FOR x = 1 TO l_metadata.scopes_supported.getLength()
			LET l_scopes_supported = l_scopes_supported.append(l_metadata.scopes_supported[x] || " ")
		END FOR
		DISPLAY SFMT("wsAuthLib.getAccessToken: Token Endpoint: %1", l_metadata.token_endpoint)
		DISPLAY SFMT("wsAuthLib.getAccessToken: Scopes Support: %1", l_scopes_supported)
	END IF

-- Get the access token using token endpoint and clientId/password
	CALL OAuthAPI.RetrieveServiceToken(
					5, l_metadata.token_endpoint, this.cfg.ClientId, this.cfg.SecretId, this.cfg.scopes)
			RETURNING this.token, this.tokenExpire
	IF this.token IS NULL THEN
		DISPLAY SFMT("Unable to retrieve token: %1 CliID: %2 Secid: %3 Scopes: %4 ",
				l_metadata.token_endpoint, this.cfg.ClientId, this.cfg.SecretId, this.cfg.scopes)
		EXIT PROGRAM 1
	ELSE
		DISPLAY "Token received."
	END IF
	IF fgl_getEnv("MYWSDEBUG") = "9" THEN
		DISPLAY SFMT("wsAuthLib.getAccessToken: Token: %1", this.token)
		DISPLAY SFMT("wsAuthLib.getAccessToken: Token Expires in %1 seconds", this.tokenExpire)
	END IF

END FUNCTION
