-- dynFoodMenu Demo
IMPORT FGL config
IMPORT FGL debug
IMPORT FGL libCommon
IMPORT FGL libMobile
IMPORT FGL wc_iconMenu
IMPORT FGL dynFoodMenu
IMPORT FGL Users
IMPORT FGL Menus
IMPORT FGL Patients
IMPORT FGL db
DEFINE myMenu wc_iconMenu.wc_iconMenu
&include "globals.inc"
MAIN
	DEFINE l_menuItem STRING = "."
	DEFINE l_user Users
	DEFINE l_menu Menus
	DEFINE l_patients Patients

	DEFINE x SMALLINT
	WHENEVER ERROR CALL libCommon.abort

	IF NOT g_cfg.initConfigFile(NULL) THEN
		CALL fgl_winMessage("Error", g_cfg.message,"exclamation")
		EXIT PROGRAM
	END IF
	CALL g_cfg.showCFG()
	CALL debug.output(g_cfg.message,FALSE)
	CALL STARTLOG( g_cfg.getLogFile() )
	CALL libCommon.loadStyles()
	CALL debug.output(SFMT("Started FGLPROFILE=%1", fgl_getEnv("FGLPROFILE")), FALSE)
	OPEN FORM login FROM "login"
	DISPLAY FORM login

	IF NOT l_user.login(FALSE) THEN
		CALL debug.output(SFMT("Invalid login %1 %2",l_user.currentUser.user_id, l_user.currentUser.user_name),FALSE)
		CALL libCommon.exit_program()
	END IF
	CALL ui.Window.getCurrent().getForm().setFieldHidden("formonly.l_iconmenu",FALSE)

	IF NOT l_menu.getMenuList() THEN
		CALL debug.output("Failed to get Menu list.",FALSE)
		CALL libCommon.exit_program()
	END IF
	CALL ui.Window.getCurrent().getForm().setFieldHidden("formonly.l_iconmenu",FALSE)
-- set the 4gl array for the menu data.
	CALL myMenu.clear()
	FOR x = 1 TO l_menu.menuList.rows
		CALL myMenu.addMenuItem( l_menu.menuList.list[x].menuDesc, l_menu.menuList.list[x].menuImage, l_menu.menuList.list[x].menuName)
	END FOR
	CALL myMenu.addMenuItem("Close", "poweroff.png", "close")

	IF NOT myMenu.init(NULL) THEN -- something wrong?
		CALL libCommon.exit_program()
	END IF
	LET dynFoodMenu.m_user_token =  l_user.currentUser.user_token
	LET dynFoodMenu.m_user_id = l_user.currentUser.user_id
	LET l_patients.token = l_user.currentUser.user_token
	WHILE TRUE
		IF NOT l_patients.select() THEN EXIT WHILE END IF
		DISPLAY SFMT("Ward: %1 Bed #%2 - %3", l_patients.wards.current.ward_name ,l_patients.patients.current.bed_no, l_patients.patients.current.name) TO username
		LET dynFoodMenu.m_patients = l_patients
		WHILE l_menuItem != "back"
			LET l_menuItem = myMenu.ui() -- show icon menu and wait for selection.
			CALL debug.output(SFMT("menu item %1 selected",l_menuItem), FALSE)
			CASE l_menuItem
				WHEN "close" EXIT WHILE
				WHEN "menu1" CALL dynFoodMenu.showMenu("menu1")
				WHEN "menu2" CALL dynFoodMenu.showMenu("menu2")
				WHEN "menu3" CALL dynFoodMenu.showMenu("menu3")
				WHEN "menu4" CALL dynFoodMenu.showMenu("menu4")
				WHEN "menu5" CALL dynFoodMenu.showMenu("menu5")
				OTHERWISE
					CALL fgl_winMessage("Info", SFMT("Menu item = '%1'", l_menuItem), "information")
			END CASE
		END WHILE
	END WHILE

	CALL libCommon.exit_program()
END MAIN