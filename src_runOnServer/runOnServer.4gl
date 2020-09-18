IMPORT os

CONSTANT C_DEFAULT_URL = "https://generodemos.dynu.net/z/ua/r/dynFoodMenu"
DEFINE m_isMobile BOOLEAN = FALSE
MAIN
	DEFINE l_url STRING
	DEFINE l_res STRING
	DEFINE l_cli STRING

	LET l_cli = ui.interface.getFrontEndName()
	DISPLAY "Client:", l_cli
	IF l_cli.subString(1,2) = "GM" THEN
		LET m_isMobile = TRUE
	END IF
	IF m_isMobile THEN
		CALL ui.Interface.frontCall("mobile","connectivity",[],l_res)
		DISPLAY "connectivity res:", l_res
		IF l_res = "NONE" THEN
			CALL fgl_winMessage("Error", "No network detected, check your wifi settings", "exclamation")
			EXIT PROGRAM
		END IF
	END IF

	LET l_url = getURL()
	TRY
		CALL ui.interface.frontcall("mobile", "runOnServer", [l_url], [l_res])
	CATCH
		CALL fgl_winMessage("Error", SFMT("Run on Server failed:%1\n", err_get(STATUS)), "exclamation")
		DISPLAY "runOnServer Res:",l_res
		CALL ui.Interface.frontCAll("standard","launchUrl", [l_url], [l_res])
		DISPLAY "launchUrl Res:",l_res
	END TRY
	CALL fgl_winMessage("Done", "Done", "exclamation")
END MAIN
--------------------------------------------------------------------------------------------------------------
FUNCTION getURL()
	DEFINE l_path, l_cfg, l_url STRING
	DEFINE c base.Channel
	DEFINE x SMALLINT
	DEFINE l_result STRING

-- Get Permission for reading/writing the config file.
	CALL ui.Interface.frontCall("android", "askForPermission", ["android.permission.READ_EXTERNAL_STORAGE"], [l_result])
	CALL ui.Interface.frontCall("android", "askForPermission", ["android.permission.WRITE_EXTERNAL_STORAGE"], [l_result])
	CALL ui.Interface.frontCall("android", "askForPermission", ["android.permission.MANAGE_EXTERNAL_STORAGE"], [l_result])

	CASE -- find the Downloads folder.
		WHEN os.path.exists("/storage/emulated/Download")
			LET l_path = "/storage/emulated/Download"
		WHEN os.path.exists("/storage/sdcard0/download")
			LET l_path = "/storage/sdcard0/download"
		WHEN os.path.exists("/sdcard/Download")
			LET l_path = "/sdcard/Download"
	END CASE
	IF l_path IS NULL THEN
		CALL fgl_winMessage("Error", "Can't find the Download folder", "exclamation")
		EXIT PROGRAM
	END IF

	LET l_path = os.path.join(l_path, "runOnServer.cfg")
	IF NOT os.path.exists(l_path) THEN
		CALL fgl_winMessage("Error", "Can't find the runOsServer.cfg", "exclamation")
		LET l_url = C_DEFAULT_URL
		{PROMPT "Enter URL:" FOR l_url
		IF l_url IS NULL THEN
			EXIT PROGRAM
		END IF}
		TRY
			LET c = base.Channel.create()
			CALL c.openFile(l_path, "w")
			CALL c.writeLine(l_url)
			CALL c.close()
		CATCH
			CALL fgl_winMessage("Error", SFMT("Failed to save %1", l_path), "exclamation")
		END TRY
		RETURN l_url
	END IF

	LET c = base.Channel.create()
	CALL c.openFile(l_path, "r")
	LET l_cfg = c.readLine()
	CALL c.close()

	IF l_cfg MATCHES "*<IP>*" THEN
		LET x = l_cfg.getIndexOf("<", 1)
		IF x > 0 THEN
			LET l_url = l_cfg.subString(1, x - 1)
			LET l_url = l_url.append("10.2.1.183")
			LET x = l_cfg.getIndexOf(">", 1)
			LET l_url = l_url.append(l_cfg.subString(x + 1, l_cfg.getLength()))
		END IF
	ELSE
		LET l_url = l_cfg
	END IF
	DISPLAY "URL: ", l_url
--	CALL fgl_winMessage("Application", SFMT("URL: %1", l_url), "information")

	RETURN l_url
END FUNCTION