IMPORT FGL debug
IMPORT FGL wc_iconMenu
IMPORT FGL dynFoodMenu1
DEFINE myMenu wc_iconMenu.wc_iconMenu
MAIN
	DEFINE l_menuItem STRING = "."
	CALL ui.Interface.loadStyles(DOWNSHIFT(ui.Interface.getFrontEndName()))
	CALL debug.output("Started", FALSE)

-- Use a JSON file for the menu data
--        LET myMenu.fileName = "myMenu.js"
-- or
-- set the 4gl array for the menu data.
	CALL myMenu.addMenuItem("Breakfast", "breakfast.png", "menu1")
	CALL myMenu.addMenuItem("Lunch", "lunch.png", "menu2")
	CALL myMenu.addMenuItem("Dinner", "dinner.png", "menu3")
	CALL myMenu.addMenuItem("Close", "poweroff.png", "close")

	IF NOT myMenu.init(myMenu.fileName) THEN -- something wrong?
		EXIT PROGRAM
	END IF

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
