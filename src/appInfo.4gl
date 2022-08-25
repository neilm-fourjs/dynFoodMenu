
PUBLIC DEFINE appInfo RECORD
		version STRING,
		cfgFile STRING,
		cfgName STRING,
		ws_users STRING,
		ws_menus STRING,
		ws_patients STRING,
		apiPass STRING
	END RECORD = ( 
		version: "1,1", 
		cfgFile: "ws_cfg.json",
		cfgName: "localv2",
		ws_users: "users",
		ws_menus: "menus",
		ws_patients: "patients",
		apiPass: "dynFoodMenuDemofqqGQg43ppgjcaqz"
		)

FUNCTION getAppInfo()
-- Dummy
END FUNCTION