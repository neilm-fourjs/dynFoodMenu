IMPORT FGL menuData
IMPORT FGL dynForm

DEFINE m_data menuData
DEFINE m_form dynForm
MAIN
	CALL ui.Interface.loadStyles( DOWNSHIFT( ui.Interface.getFrontEndName()) )
	CURRENT WINDOW IS SCREEN
	CALL m_data.load() -- Load the menu data
	LET m_form.treeData = m_data.menuTree -- give the ui library the menu data
	CALL m_form.buildForm("Dynamic Menu Demo", "main2") -- create the form
	CALL inp() -- do the input
END MAIN
--------------------------------------------------------------------------------------------------------------
-- Do the screen record INPUT.
FUNCTION inp() RETURNS ()
	DEFINE d ui.Dialog
	DEFINE l_event STRING
	DEFINE x SMALLINT
	LET d = ui.Dialog.createInputByName( m_form.inpFields )
	CALL d.addTrigger("ON ACTION close")
	CALL d.addTrigger("ON ACTION quit")
	FOR x = 1 TO m_form.inpFields.getLength()
		CALL d.setFieldValue(m_form.inpFields[x].l_fldName,0)
	END FOR
	WHILE TRUE
		LET l_event = d.nextEvent()
		IF l_event.subString(1,10) = "ON CHANGE " THEN
			MESSAGE SFMT("Field %1 changed.", l_event.subString(11,l_event.getLength()))
			CONTINUE WHILE
		END IF
		CASE l_event
			WHEN "ON ACTION close" EXIT WHILE
			WHEN "ON ACTION quit" EXIT WHILE
			OTHERWISE
				MESSAGE "Event:",l_event
		END CASE
	END WHILE
END FUNCTION