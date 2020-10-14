
IMPORT FGL wsAuthLib

DEFINE m_user_id STRING
MAIN
	DEFINE l_stat INT
	DEFINE l_cfgFileName, l_tokenFileName STRING
	DEFINE l_tok TEXT
	DEFINE wsAuth wsAuthLib

	LET l_cfgFileName = IIF(NUM_ARGS()>0, ARG_VAL(1), "ws_cfg.json")
	LET l_tokenFileName = IIF(NUM_ARGS()>1, ARG_VAL(2), "dfm.tok")

	# Initialize Secure Access
	IF NOT wsAuth.init(".",l_cfgFileName,"localv2") THEN
		DISPLAY "libWSAuth init failed."
		EXIT PROGRAM
	END IF

	LOCATE l_tok IN FILE l_tokenFileName
	LET l_tok = wsAuth.token

END MAIN
