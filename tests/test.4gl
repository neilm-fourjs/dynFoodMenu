MAIN
	OPEN FORM f FROM "generated"
	DISPLAY FORM f
	MENU
		ON ACTION close EXIT MENU
		ON ACTION quit EXIT MENU
		ON ACTION dump
			CALL ui.window.getCurrent().getNode().getFirstChild().writeXml("dump.xml")
	END MENU
END MAIN
