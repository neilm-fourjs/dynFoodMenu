IMPORT FGL debug
IMPORT FGL libCommon
IMPORT FGL libMobile
IMPORT FGL wc_iconMenu
IMPORT FGL dynFoodMenu
IMPORT FGL login
IMPORT FGL menuData
IMPORT FGL Patients
DEFINE myMenu wc_iconMenu.wc_iconMenu
DEFINE m_user login.userRecord
MAIN
	DEFINE l_menuItem STRING = "."
	DEFINE l_data menuData
	DEFINE l_patients Patients
	DEFINE x SMALLINT
	WHENEVER ERROR CALL libCommon.abort
	CALL libCommon.loadStyles()
	CALL debug.output(SFMT("Started FGLPROFILE=%1", fgl_getEnv("FGLPROFILE")), FALSE)
	OPEN FORM login FROM "login"
	DISPLAY FORM login

	IF NOT m_user.login(FALSE) THEN
		CALL debug.output(SFMT("Invalid login %1 %2",m_user.user_id, m_user.user_name),FALSE)
		CALL libCommon.exit_program()
	END IF
	CALL ui.Window.getCurrent().getForm().setFieldHidden("formonly.l_iconmenu",FALSE)
	IF NOT l_data.getMenuList() THEN
		CALL debug.output("Failed to get Menu list.",FALSE)
		CALL libCommon.exit_program()
	END IF
	CALL ui.Window.getCurrent().getForm().setFieldHidden("formonly.l_iconmenu",FALSE)
-- set the 4gl array for the menu data.
	CALL myMenu.clear()
	FOR x = 1 TO l_data.menuList.rows
		CALL myMenu.addMenuItem( l_data.menuList.list[x].menuDesc, l_data.menuList.list[x].menuImage, l_data.menuList.list[x].menuName)
	END FOR
	CALL myMenu.addMenuItem("Close", "poweroff.png", "close")

	IF NOT myMenu.init(NULL) THEN -- something wrong?
		CALL libCommon.exit_program()
	END IF
	LET dynFoodMenu.m_user_token =  m_user.user_token
	LET dynFoodMenu.m_user_id = m_user.user_id
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