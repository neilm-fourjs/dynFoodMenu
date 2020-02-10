
IMPORT FGL utils
DEFINE m_rec RECORD
	t1g1sg1ch1 BOOLEAN,
	t1g1sg1ch2 BOOLEAN,
	t1g1sg1ch2o1 BOOLEAN,
	t1g2sg1sp1 SMALLINT,
	t1g2sg1sp2 SMALLINT,
	t1g2sg2ch1 BOOLEAN,
	t1g2sg3ch1 BOOLEAN,
	t1g2sg3ch1o1 BOOLEAN,
	t1g2sg3ch2 BOOLEAN,
	t1g2sg3ch2o1 BOOLEAN,
	t1g3sg1ch1 BOOLEAN,
	t1g3sg1ch1o1 BOOLEAN,
	t1g3sg1ch2 BOOLEAN,
	t1g3sg1ch3 BOOLEAN,
	t1g3sg1ch4 BOOLEAN,
	t1g4sg1ch1 BOOLEAN,
	t1g5sg1ch1 BOOLEAN,
	t1g5sg1ch1o1 BOOLEAN,
	t1g5sg1ch2 BOOLEAN,
	t1g5sg1ch2o1 BOOLEAN,
	t1g5sg1ch3 BOOLEAN,
	t1g5sg1ch3o1 BOOLEAN,
	t1g5sg1ch4 BOOLEAN,
	t1g5sg1sp5 SMALLINT,
	t1g5sg1sp6 SMALLINT,
	t1g5sg1sp7 SMALLINT
END RECORD

MAIN
	DEFINE l_tim CHAR(10)
	LET l_tim = TIME
	OPEN FORM f FROM "generated"
	DISPLAY FORM f
	DISPLAY utils.apiPaas("NJM", l_tim)
	MENU
		ON ACTION inp CALL inp()
		ON ACTION dyninp CALL dyninp()
		ON ACTION close EXIT MENU
		ON ACTION quit EXIT MENU
	END MENU
END MAIN
--------------------------------------------------------------------------------------------------------------
FUNCTION inp()
	INPUT BY NAME m_rec.*
		ON ACTION close EXIT INPUT
		ON ACTION quit EXIT INPUT
		ON ACTION dump
			CALL ui.window.getCurrent().getNode().getFirstChild().writeXml("dump.xml")
		BEFORE INPUT
	CALL DIALOG.getForm().setElementStyle("mylabel","dim")
	END INPUT
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION dyninp()
	DEFINE l_dialog ui.Dialog
	DEFINE l_event STRING
	DEFINE l_inpFields DYNAMIC ARRAY OF RECORD
		fldname STRING,
		fldtype STRING
	END RECORD
	DEFINE x SMALLINT = 1
	LET l_inpFields[x].fldName = "formonly.t1g1sg1ch1"
	LET l_inpFields[x].fldType = "BOOLEAN" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g1sg1ch2"
	LET l_inpFields[x].fldType = "BOOLEAN" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g1sg1ch2o1"
	LET l_inpFields[x].fldType = "BOOLEAN" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g2sg1sp1"
	LET l_inpFields[x].fldType = "SMALLINT" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g2sg1sp2"
	LET l_inpFields[x].fldType = "SMALLINT" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g2sg2ch1"
	LET l_inpFields[x].fldType = "BOOLEAN" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g2sg3ch1"
	LET l_inpFields[x].fldType = "BOOLEAN" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g2sg3ch1o1"
	LET l_inpFields[x].fldType = "BOOLEAN" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g2sg3ch2"
	LET l_inpFields[x].fldType = "BOOLEAN" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g2sg3ch2o1"
	LET l_inpFields[x].fldType = "BOOLEAN" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g3sg1ch1"
	LET l_inpFields[x].fldType = "BOOLEAN" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g3sg1ch1o1"
	LET l_inpFields[x].fldType = "BOOLEAN" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g3sg1ch2"
	LET l_inpFields[x].fldType = "BOOLEAN" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g3sg1ch3"
	LET l_inpFields[x].fldType = "BOOLEAN" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g3sg1ch4"
	LET l_inpFields[x].fldType = "BOOLEAN" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g4sg1ch1"
	LET l_inpFields[x].fldType = "BOOLEAN" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g5sg1ch1"
	LET l_inpFields[x].fldType = "BOOLEAN" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g5sg1ch1o1"
	LET l_inpFields[x].fldType = "BOOLEAN" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g5sg1ch2"
	LET l_inpFields[x].fldType = "BOOLEAN" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g5sg1ch2o1"
	LET l_inpFields[x].fldType = "BOOLEAN" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g5sg1ch3"
	LET l_inpFields[x].fldType = "BOOLEAN" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g5sg1ch3o1"
	LET l_inpFields[x].fldType = "BOOLEAN" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g5sg1ch4"
	LET l_inpFields[x].fldType = "BOOLEAN" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g5sg1sp5"
	LET l_inpFields[x].fldType = "SMALLINT" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g5sg1sp6"
	LET l_inpFields[x].fldType = "SMALLINT" LET x = x + 1
	LET l_inpFields[x].fldName = "formonly.t1g5sg1sp7"
	LET l_inpFields[x].fldType = "SMALLINT" LET x = x + 1

	LET l_dialog = ui.Dialog.createInputByName( l_inpFields )
	CALL l_dialog.addTrigger("ON ACTION close")
	CALL l_dialog.addTrigger("ON ACTION quit")
	WHILE TRUE
		LET l_event = l_dialog.nextEvent()
		CASE l_event
			WHEN "ON ACTION close" EXIT WHILE
			WHEN "ON ACTION quit" EXIT WHILE
			OTHERWISE
				MESSAGE "Event:",l_event
		END CASE
	END WHILE
END FUNCTION
--------------------------------------------------------------------------------------------------------------

