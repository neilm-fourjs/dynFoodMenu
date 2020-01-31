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
	CALL myMenu.addMenuItem("Breakfast", "breakfast.png", "MEN1")
	CALL myMenu.addMenuItem("Close", "poweroff.png", "close")

	IF NOT myMenu.init(myMenu.fileName) THEN -- something wrong?
		EXIT PROGRAM
	END IF

	WHILE l_menuItem != "close"
		LET l_menuItem = myMenu.ui() -- show icon menu and wait for selection.
		CASE l_menuItem
			WHEN "close" EXIT WHILE
			WHEN "MEN1" CALL dynFoodMenu1.showMenu("MEN1")
			OTHERWISE
				CALL fgl_winMessage("Info", SFMT("Menu item = '%1'", l_menuItem), "information")
		END CASE
	END WHILE

	CALL debug.output("Finished", debug.m_showDebug)
END MAIN
