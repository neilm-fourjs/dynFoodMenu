IMPORT FGL debug
IMPORT FGL libCommon
IMPORT FGL libMobile
IMPORT FGL wc_iconMenu
IMPORT FGL dynFoodMenu
IMPORT FGL login
IMPORT FGL menuData
DEFINE myMenu wc_iconMenu.wc_iconMenu
DEFINE m_user login.userRecord
MAIN
	DEFINE l_menuItem STRING = "."
	DEFINE m_data menuData
	DEFINE x SMALLINT
	CALL libCommon.loadStyles()
	CALL debug.output("Started", FALSE)
	OPEN FORM login FROM "login"
	DISPLAY FORM login
{
	CALL myMenu.addMenuItem("Close", "poweroff.png", "close")
	IF NOT myMenu.init(NULL) THEN -- something wrong?
		EXIT PROGRAM
	END IF
	CALL myMenu.sendJSON()
}
	IF NOT m_user.login(FALSE) THEN
		CALL debug.output(SFMT("Invalid login %1 %2",m_user.user_id, m_user.user_name),FALSE)
		EXIT PROGRAM
	END IF
	CALL ui.Window.getCurrent().getForm().setFieldHidden("formonly.l_iconmenu",FALSE)
	IF NOT m_data.getMenuList() THEN
		CALL debug.output("Failed to get Menu list.",FALSE)
		EXIT PROGRAM
	END IF
	CALL ui.Window.getCurrent().getForm().setFieldHidden("formonly.l_iconmenu",FALSE)
-- set the 4gl array for the menu data.
	CALL myMenu.clear()
	FOR x = 1 TO m_data.menuList.rows
		CALL myMenu.addMenuItem( m_data.menuList.list[x].menuDesc, m_data.menuList.list[x].menuImage, m_data.menuList.list[x].menuName)
	END FOR
	CALL myMenu.addMenuItem("Close", "poweroff.png", "close")

	IF NOT myMenu.init(NULL) THEN -- something wrong?
		EXIT PROGRAM
	END IF
	LET dynFoodMenu.m_user_token =  m_user.user_token
	LET dynFoodMenu.m_user_id = m_user.user_id
	WHILE l_menuItem != "close"
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

	CALL debug.output("Finished", debug.m_showDebug)
END MAIN
