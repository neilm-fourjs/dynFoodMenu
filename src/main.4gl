IMPORT FGL debug
IMPORT FGL wc_iconMenu
IMPORT FGL dynFoodMenu1
IMPORT FGL login
IMPORT FGL menuData
DEFINE myMenu wc_iconMenu.wc_iconMenu
DEFINE m_user login.userRecord
MAIN
	DEFINE l_menuItem STRING = "."
	DEFINE m_data menuData
	DEFINE x SMALLINT
	CALL ui.Interface.loadStyles(DOWNSHIFT(ui.Interface.getFrontEndName()))
	CALL debug.output("Started", FALSE)

	IF NOT m_user.login() THEN
		EXIT PROGRAM
	END IF
	IF NOT m_data.getMenuList() THEN
		EXIT PROGRAM
	END IF
-- Use a JSON file for the menu data
--        LET myMenu.fileName = "myMenu.js"
-- or
-- set the 4gl array for the menu data.

	FOR x = 1 TO m_data.menuList.rows
		CALL myMenu.addMenuItem( m_data.menuList.list[x].menuDesc, m_data.menuList.list[x].menuImage, m_data.menuList.list[x].menuName)
	END FOR
	CALL myMenu.addMenuItem("Close", "poweroff.png", "close")

	IF NOT myMenu.init(myMenu.fileName) THEN -- something wrong?
		EXIT PROGRAM
	END IF
	LET dynFoodMenu1.m_user_token =  m_user.user_token
	LET dynFoodMenu1.m_user_id = m_user.user_id
	WHILE l_menuItem != "close"
		LET l_menuItem = myMenu.ui() -- show icon menu and wait for selection.
		CALL debug.output(SFMT("menu item %1 selected",l_menuItem), FALSE)
		CASE l_menuItem
			WHEN "close" EXIT WHILE
			WHEN "menu1" CALL dynFoodMenu1.showMenu("menu1")
			WHEN "menu2" CALL dynFoodMenu1.showMenu("menu2")
			WHEN "menu3" CALL dynFoodMenu1.showMenu("menu3")
			WHEN "menu4" CALL dynFoodMenu1.showMenu("menu4")
			WHEN "menu5" CALL dynFoodMenu1.showMenu("menu5")
			OTHERWISE
				CALL fgl_winMessage("Info", SFMT("Menu item = '%1'", l_menuItem), "information")
		END CASE
	END WHILE

	CALL debug.output("Finished", debug.m_showDebug)
END MAIN
