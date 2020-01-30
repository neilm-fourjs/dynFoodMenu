IMPORT FGL menuData
IMPORT FGL dynForm

DEFINE m_data menuData
DEFINE m_form dynForm
DEFINE m_dialog ui.Dialog
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
	DEFINE l_event STRING
	DEFINE x SMALLINT
	LET m_dialog = ui.Dialog.createInputByName( m_form.inpFields )
	CALL m_dialog.addTrigger("ON ACTION close")
	CALL m_dialog.addTrigger("ON ACTION quit")
	FOR x = 1 TO m_form.inpFields.getLength()
		CALL m_dialog.setFieldValue(m_form.inpFields[x].l_fldName,0)
	END FOR
	WHILE TRUE
		LET l_event = m_dialog.nextEvent()
		IF l_event.subString(1,10) = "ON CHANGE " THEN
			MESSAGE SFMT("Field %1 changed.", l_event.subString(11,l_event.getLength()))
			CALL validate( )
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
--------------------------------------------------------------------------------------------------------------
FUNCTION validate()
	DEFINE l_fld, l_val STRING
	DEFINE l_id, l_c_id, l_d_no, l_i_id SMALLINT
	LET l_fld = m_dialog.getCurrentItem()
	LET l_val = m_dialog.getFieldValue(l_fld)
	FOR l_id = 1 TO m_data.menuTree.getLength()
		IF m_data.menuTree[l_id].field = l_fld THEN EXIT FOR END IF
	END FOR
	DISPLAY SFMT("Field: %1 = %2 Desc: %3", l_fld, l_val, m_data.menuTree[l_id].description)
	LET l_i_id = m_data.menuTree[l_id].t_id
	FOR l_c_id = 1 TO m_data.menuConditions.getLength()
		LET l_d_no = checkCondition( l_c_id, l_i_id )
		IF l_d_no > 0 THEN
			DISPLAY m_data.menuConditions[l_c_id].cond.name
			CALL clearItems( l_c_id, 1, l_i_id )
			CALL clearItems( l_c_id, 2, l_i_id )
			CALL clearItems( l_c_id, 3, l_i_id )
			CALL clearItems( l_c_id, 4, l_i_id )
			--EXIT FOR
		END IF
	END FOR
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION checkCondition( l_c_id SMALLINT, l_i_id SMALLINT) RETURNS SMALLINT
	DEFINE l_d_id SMALLINT
	FOR l_d_id = 1 TO m_data.menuConditions[l_c_id].d1_arr.getLength()
		IF m_data.menuConditions[l_c_id].d1_arr[l_d_id].item_id = l_i_id THEN
			RETURN 1
		END IF
	END FOR
	FOR l_d_id = 1 TO m_data.menuConditions[l_c_id].d2_arr.getLength()
		IF m_data.menuConditions[l_c_id].d2_arr[l_d_id].item_id = l_i_id THEN
			RETURN 2
		END IF
	END FOR
	FOR l_d_id = 1 TO m_data.menuConditions[l_c_id].d3_arr.getLength()
		IF m_data.menuConditions[l_c_id].d3_arr[l_d_id].item_id = l_i_id THEN
			RETURN 3
		END IF
	END FOR
	FOR l_d_id = 1 TO m_data.menuConditions[l_c_id].d4_arr.getLength()
		IF m_data.menuConditions[l_c_id].d4_arr[l_d_id].item_id = l_i_id THEN
			RETURN 4
		END IF
	END FOR
	RETURN 0
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION clearItems( l_c_id SMALLINT, l_d_no SMALLINT, l_i_id SMALLINT )
	DEFINE x SMALLINT
	DISPLAY "CleanItems - Cond:",l_c_id," except:",l_i_id
	CASE l_d_no
		WHEN 1
			FOR x = 1 TO m_data.menuConditions[l_c_id].d1_arr.getLength()
				IF  m_data.menuConditions[l_c_id].d1_arr[x].item_id != l_i_id THEN
					CALL clearItem( m_data.menuConditions[l_c_id].d1_arr[x].item_id )
				END IF
			END FOR
		WHEN 2
			FOR x = 1 TO m_data.menuConditions[l_c_id].d2_arr.getLength()
				IF  m_data.menuConditions[l_c_id].d2_arr[x].item_id != l_i_id THEN
					CALL clearItem( m_data.menuConditions[l_c_id].d2_arr[x].item_id )
				END IF
			END FOR
		WHEN 3
			FOR x = 1 TO m_data.menuConditions[l_c_id].d3_arr.getLength()
				IF  m_data.menuConditions[l_c_id].d3_arr[x].item_id != l_i_id THEN
					CALL clearItem( m_data.menuConditions[l_c_id].d3_arr[x].item_id )
				END IF
			END FOR
		WHEN 4
			FOR x = 1 TO m_data.menuConditions[l_c_id].d4_arr.getLength()
				IF  m_data.menuConditions[l_c_id].d4_arr[x].item_id != l_i_id THEN
					CALL clearItem( m_data.menuConditions[l_c_id].d4_arr[x].item_id )
				END IF
			END FOR
	END CASE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION clearItem( l_id SMALLINT )
	DEFINE x SMALLINT
	DEFINE l_found BOOLEAN = FALSE
	FOR x = 1 TO m_data.menuTree.getLength()
		IF m_data.menuTree[x].t_id = l_id THEN
			LET l_found = TRUE
			DISPLAY "CleanItem:",l_id, ":",m_data.menuTree[x].description
			CALL m_dialog.setFieldValue(m_data.menuTree[x].field,0)
		END IF
	END FOR
	IF NOT l_found THEN
		DISPLAY "CleanItem:",l_id, " not found!"
	END IF
END FUNCTION
