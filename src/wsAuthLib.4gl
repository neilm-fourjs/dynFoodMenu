IMPORT util
IMPORT os
IMPORT FGL OAuthAPI

TYPE t_cfg RECORD
	name           STRING,
	GAS            STRING,
	ServiceName    STRING,
	ServiceVersion STRING,
	ClientID       STRING,
	SecretID       STRING,
	Scopes         STRING,
	idp            STRING,
	connTimeout    INTEGER
END RECORD

PUBLIC TYPE wsAuthLib RECORD
	cfgFileName      STRING,
	cfgName          STRING,
	cfgCur           SMALLINT,
	user_id          STRING,
	token            STRING,
	tokenExpire      INTEGER,
	endpoint         STRING,
	idpTokenEndpoint STRING,
	cfgJSON RECORD
		default STRING,
		cfgs    DYNAMIC ARRAY OF t_cfg
	END RECORD,
	cfg     t_cfg,
	message STRING
END RECORD

PUBLIC FUNCTION (this wsAuthLib) init(l_dir STRING, l_cfgFileName STRING, l_cfgName STRING) RETURNS BOOLEAN
	DEFINE l_stat       INT
	DEFINE l_cfg        TEXT
	DEFINE x            SMALLINT

-- check for and read the json configure for the web services
	IF this.cfgJSON.default IS NULL THEN
		LET this.cfgFileName = os.path.join(l_dir, l_cfgFileName)
		IF NOT os.path.exists(this.cfgFileName) THEN
			LET this.message = SFMT("Missing config file '%1' !", this.cfgFileName)
			RETURN FALSE
		END IF
		LET this.message = SFMT("Using '%1' for configuration", this.cfgFileName)
		IF fgl_getEnv("MYWSDEBUG") = "9" THEN
			DISPLAY this.message
		END IF
		LOCATE l_cfg IN FILE this.cfgFileName
		--CALL debug("init", "l_cfg", l_cfg)

		TRY
			CALL util.json.parse(l_cfg, this.cfgJSON)
		CATCH
			LET this.message =
					SFMT("Error parsing '%1'\n%2\nContent: %3", this.cfgFileName, ERR_GET(STATUS), NVL(l_cfg, "NULL!"))
			DISPLAY this.message
			RETURN FALSE
		END TRY
	END IF

	LET this.cfgCur  = 0
	LET this.cfgName = l_cfgName
	IF this.cfgName IS NULL OR this.cfgName.getLength() < 2 THEN
		LET this.cfgName = this.cfgJSON.default
	END IF
	FOR x = 1 TO this.cfgJSON.cfgs.getLength()
		IF this.cfgJSON.cfgs[x].name = this.cfgName THEN
			LET this.cfgCur = x
			LET this.cfg.* = this.cfgJSON.cfgs[x].*
		END IF
	END FOR
	IF this.cfgCur = 0 THEN
		LET this.message = SFMT("Invalid Config Name '%1'", this.cfgName)
		RETURN FALSE
	END IF

	CALL debug("init", "cfgName", this.cfgName)

-- Set the endpoint for the GAS
	LET this.endpoint = this.cfg.GAS || "/" || this.cfg.ServiceName || "/"
	CALL debug("init", "cfg.GAS", this.cfg.GAS)
	CALL debug("init", "cfg.ServiceName", this.cfg.ServiceName)
	CALL debug("init", "cfg.ServiceVersion", this.cfg.ServiceVersion)

	IF this.cfg.idp IS NULL THEN
		CALL debug("init", "NO IDP - not calling getAccessToken()", this.cfg.idp)
		RETURN TRUE
	END IF

-- Set the IDP for the GAS
	LET this.cfg.idp = this.cfg.GAS || "/" || this.cfg.idp

	CALL debug("init", "cfg.idp", this.cfg.idp)
	CALL debug("init", "cfg.connTimeout", this.cfg.connTimeout)
	CALL debug("init", "cfg.ClientID", this.cfg.ClientID)
	CALL debug("init", "cfg.Scopes", this.cfg.Scopes)

-- Retrieve access token using login credentials
	IF NOT this.getAccessToken() THEN
		RETURN FALSE
	END IF

-- Initialize OAuth access
	CALL OAuthAPI.InitService(this.cfg.connTimeout, this.Token) RETURNING l_stat
	LET this.message = "OAuthAPI.InitService " || IIF(l_stat, "Okay", "Failed!")
	DISPLAY SFMT("wsAuthLib.init: %1", this.message)

-- Is this actually useful to anyone ?
--	LET this.user_id = OAuthAPI.getIDSubject()

	RETURN l_stat
END FUNCTION
--------------------------------------------------------------------------------
PUBLIC FUNCTION (this wsAuthLib) getWSServer(l_serviceName STRING) RETURNS STRING
	RETURN this.endPoint || l_serviceName
END FUNCTION
--------------------------------------------------------------------------------
PRIVATE FUNCTION (this      wsAuthLib) getAccessToken() RETURNS BOOLEAN
	DEFINE l_metadata         OAuthAPI.OpenIDMetadataType
	DEFINE l_scopes_supported STRING
	DEFINE x                  SMALLINT

-- Retieve IdP info to get token endpoint for service access
	CALL debug("getAccessToken", "cfg.idp", this.cfg.idp)

	CALL OAuthAPI.FetchOpenIDMetadata(5, this.cfg.idp) RETURNING l_metadata.*
	IF l_metadata.issuer IS NULL THEN
		LET this.message = SFMT("Error : IDP unavailable: %1", this.cfg.idp)
		RETURN FALSE
	END IF

	IF fgl_getEnv("MYWSDEBUG") = "9" THEN
		FOR x = 1 TO l_metadata.scopes_supported.getLength()
			LET l_scopes_supported = l_scopes_supported.append(l_metadata.scopes_supported[x] || " ")
		END FOR
		CALL debug("getAccessToken", "l_metadata.token_endpoint", l_metadata.token_endpoint)
		CALL debug("getAccessToken", "l_scopes_supported", l_scopes_supported)
	END IF
	LET this.idpTokenEndpoint = l_metadata.token_endpoint

-- Get the access token using token endpoint and clientId/password
	CALL OAuthAPI.RetrieveServiceToken(
					5, l_metadata.token_endpoint, this.cfg.ClientId, this.cfg.SecretId, this.cfg.scopes)
			RETURNING this.token, this.tokenExpire
	IF this.token IS NULL THEN
		LET this.message =
				SFMT("Unable to retrieve token: %1 CliID: %2 Secid: %3 Scopes: %4 ",
						l_metadata.token_endpoint, this.cfg.ClientId, this.cfg.SecretId, this.cfg.scopes)
		RETURN FALSE
	ELSE
		DISPLAY "Token received."
	END IF
	CALL debug("getAccessToken", "token", this.token)
	CALL debug("getAccessToken", "tokenExpire", this.tokenExpire)

	RETURN TRUE
END FUNCTION

--------------------------------------------------------------------------------------------------------------

PRIVATE FUNCTION debug(l_func STRING, l_var STRING, l_val STRING)
	DEFINE x                    SMALLINT
	IF fgl_getEnv("MYWSDEBUG") = "9" THEN
		IF l_var = "token" AND l_val IS NOT NULL THEN
			LET x     = LENGTH(l_val)
			LET l_val = "Length = " || x || " Ends with: " || l_val.subString(x - 10, x)
		END IF
		DISPLAY SFMT("%1: wsAuthLib: %2 - %3 = %4", CURRENT, l_func, l_var, NVL(l_val, "NULL"))
	END IF
END FUNCTION
