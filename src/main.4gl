IMPORT FGL debug
IMPORT FGL wc_iconMenu
IMPORT FGL dynFoodMenu1
IMPORT FGL login
IMPORT FGL menuData
DEFINE myMenu wc_iconMenu.wc_iconMenu
DEFINE m_user login.userRecord
DEFINE m_fe STRING
DEFINE m_netWork BOOLEAN = TRUE
MAIN
	DEFINE l_menuItem STRING = "."
	DEFINE m_data menuData
	DEFINE x SMALLINT
	DEFINE l_netWork STRING
	LET m_fe = DOWNSHIFT(ui.Interface.getFrontEndName())
	CALL ui.Interface.loadStyles(m_fe)
	CALL debug.output("Started", FALSE)

	IF base.Application.isMobile() THEN
		CALL ui.Interface.frontCall("mobile","connectivity", [], [l_netWork] )
	END IF

	IF m_netWork = "NONE" THEN LET m_netWork = FALSE END IF

	IF NOT m_user.login(m_netWork) THEN
		CALL debug.output(SFMT("Invalid login %1 %2",m_user.user_id, m_user.user_name),FALSE)
		EXIT PROGRAM
	END IF
	IF NOT m_data.getMenuList(m_netWork) THEN
		CALL debug.output("Failed to get Menu list.",FALSE)
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
			WHEN "menu1" CALL dynFoodMenu1.showMenu("menu1", m_netWork)
			WHEN "menu2" CALL dynFoodMenu1.showMenu("menu2", m_netWork)
			WHEN "menu3" CALL dynFoodMenu1.showMenu("menu3", m_netWork)
			WHEN "menu4" CALL dynFoodMenu1.showMenu("menu4", m_netWork)
			WHEN "menu5" CALL dynFoodMenu1.showMenu("menu5", m_netWork)
			OTHERWISE
				CALL fgl_winMessage("Info", SFMT("Menu item = '%1'", l_menuItem), "information")
		END CASE
	END WHILE

	CALL debug.output("Finished", debug.m_showDebug)
END MAIN
