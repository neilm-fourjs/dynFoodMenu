IMPORT FGL Menus
IMPORT FGL dynForm
IMPORT FGL debug
IMPORT FGL about
IMPORT FGL libMobile
IMPORT FGL libCommon
IMPORT FGL Users
IMPORT FGL Patients

DEFINE m_menu Menus
DEFINE m_form dynForm
DEFINE m_dialog ui.Dialog
DEFINE m_user Users
PUBLIC DEFINE m_user_token STRING
PUBLIC DEFINE m_user_id STRING
PUBLIC DEFINE m_patients Patients
--------------------------------------------------------------------------------------------------------------
FUNCTION showMenu(l_menuName STRING)
	WHENEVER ERROR CALL libCommon.abort
	IF NOT m_menu.getMenu(l_menuName) THEN RETURN END IF-- Load the menu data
	LET m_form.menu = m_menu.menu -- give the ui library the menu data
	LET m_form.toolbar[1] = "submit"
	LET m_form.toolbar[2] = "cancel"
	LET m_form.toolbar[3] = "about"
--	LET m_form.toolbar[4] = "debug"
	CALL m_form.buildForm("Food Menu", "main", "icon32") -- create the form
	IF inpByName() THEN -- do the input
		CALL m_menu.save()
	END IF
	CALL m_form.close()
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Do the screen record INPUT.
FUNCTION inpByName() RETURNS (BOOLEAN)
	DEFINE l_event STRING
	DEFINE x SMALLINT
	DEFINE l_accept BOOLEAN = FALSE
	CALL debug.output("inp: Start", FALSE)
	LET m_dialog = ui.Dialog.createInputByName( m_form.inpFields )
	CALL m_dialog.addTrigger("ON ACTION close")
	FOR x = 1 TO m_form.toolbar.getLength() -- add actions from tool to dialog
		CALL m_dialog.addTrigger("ON ACTION "||m_form.toolbar[x])
	END FOR
	FOR x = 1 TO m_form.inpFields.getLength() -- set all fields to 0
		CALL m_dialog.setFieldValue(m_form.inpFields[x].l_fldName,0)
	END FOR
	CALL debug.output("inp: Built", FALSE)
	WHILE TRUE
		LET l_event = m_dialog.nextEvent()
		IF l_event.subString(1,10) = "ON CHANGE " THEN
			--MESSAGE SFMT("Field %1 changed.", l_event.subString(11,l_event.getLength()))
			CALL validate( )
			CONTINUE WHILE
		END IF
		CASE l_event
			WHEN "ON ACTION close" EXIT WHILE
			WHEN "ON ACTION cancel" EXIT WHILE
			WHEN "ON ACTION about" CALL about.show()
--			WHEN "ON ACTION debug" LET debug.m_showDebug = TRUE
			WHEN "ON ACTION submit"
				IF input_okay() THEN
					LET l_accept = TRUE
					EXIT WHILE
				END IF
			OTHERWISE
				--MESSAGE "Event:",l_event
		END CASE
	END WHILE
	CALL m_dialog.close()
	CALL debug.output(SFMT("inp: Finished Accept %1",IIF(l_accept,"True","False")), FALSE)
	RETURN l_accept
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Show order details and confirm okay
FUNCTION input_okay() RETURNS BOOLEAN
	DEFINE x, order_lines SMALLINT
	DEFINE l_val, l_opt SMALLINT
	DEFINE l_order STRING
	DEFINE l_desc STRING
	CALL debug.output("input_okay: Started", FALSE)
	IF NOT libMobile.gotNetwork() THEN
		CALL fgl_winMessage("Error","No connection!","exclamation")
		RETURN FALSE
	END IF
	IF m_user_id = "DUMMY" THEN
		IF NOT m_user.login(TRUE) OR m_user.currentUser.user_id = "DUMMY" THEN
			CALL fgl_winMessage("Error","You are not logged in","exclamation")
			RETURN FALSE
		ELSE
			LET m_user_id = m_user.currentUser.user_id
			LET m_user_token = m_user.currentUser.user_token
		END IF
	END IF
	CALL m_menu.ordered.items.clear()
	LET m_menu.ordered.placed = CURRENT
	LET m_menu.ordered.user_id = m_user_id
	LET m_menu.ordered.user_token = m_user_token
	LET m_menu.ordered.bed_no = m_patients.patients.current.bed_no
	LET m_menu.ordered.ward_id = m_patients.patients.current.ward_id
	LET m_menu.ordered.patient_id = m_patients.patients.current.id
	LET l_order = SFMT("Ward: %1\nBed: %2\nPatient: %3\n\n", m_patients.wards.current.ward_name, m_menu.ordered.bed_no,m_patients.patients.current.name) 
	LET order_lines = 0
	FOR x = 1 TO m_menu.menu.rows
		IF m_menu.menu.items[x].field.getLength() > 2 THEN
			LET l_opt = 0
			LET l_val = m_dialog.getFieldValue(m_menu.menu.items[x].field)
			IF l_val > 0 THEN
				LET l_desc = m_menu.menu.items[x].description
				IF m_menu.menu.items[x].option_id.getLength()  > 2 THEN
					LET l_opt = m_dialog.getFieldValue(m_menu.menu.items[x].field||"o1")
					IF l_opt = 1 THEN
						LET l_desc = l_desc.append(" "||m_menu.menu.items[x].option_name)
					END IF
				END IF
				LET l_order = l_order.append(SFMT("%1 %2\n",l_val, l_desc))
				LET order_lines = order_lines + 1
				LET m_menu.ordered.items[ order_lines ].item_id= m_menu.menu.items[x].t_id
				LET m_menu.ordered.items[ order_lines ].description = l_desc
				LET m_menu.ordered.items[ order_lines ].qty = l_val
				LET m_menu.ordered.items[ order_lines ].optional = l_opt
			END IF
		END IF
	END FOR
	LET m_menu.ordered.rows = order_lines
	IF order_lines > 0 THEN
		CALL debug.output("input_okay: Do confirm", FALSE)
		IF fgl_winQuestion("Confirm Order For",l_order,"Yes","Yes|No","question",0) = "No" THEN
			CALL debug.output("input_okay: Confirmed - No", FALSE)
			RETURN FALSE
		END IF
	ELSE
		ERROR "Empty order ignored!"
		RETURN FALSE
	END IF
	CALL debug.output("input_okay: Confirmed- Yes", FALSE)
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION validate()
	DEFINE l_fld, l_val STRING
	DEFINE x, l_id, l_pid, l_pid_pid SMALLINT
	DEFINE l_cond, l_pid_cond BOOLEAN
	LET l_fld = m_dialog.getCurrentItem()
	LET l_val = m_dialog.getFieldValue(l_fld)
	FOR l_id = 1 TO m_menu.menu.rows
		IF m_menu.menu.items[l_id].field = l_fld THEN EXIT FOR END IF
	END FOR
	LET l_pid = m_menu.menu.items[l_id].t_pid
	LET l_cond = m_menu.menu.items[l_id].conditional
	CALL debug.output(SFMT("Validate Field: %1 = %2 Desc: %3 PID: %4 Cond: %5", l_fld, l_val, m_menu.menu.items[l_id].description, l_pid, l_cond), FALSE)

-- Clear items in same subgroup
	FOR x = 1 TO m_menu.menu.rows
		IF m_menu.menu.items[x].t_id = l_pid THEN
			LET l_pid_cond = m_menu.menu.items[x].conditional
			LET l_pid_pid = m_menu.menu.items[x].t_pid
			CALL debug.output(SFMT("%1) Parent: %2 Cond: %3 PIDPID: %4", m_menu.menu.items[x].level,m_menu.menu.items[x].description, l_pid_cond, l_pid_pid ), FALSE)
		END IF
		IF l_cond THEN
			IF m_menu.menu.items[x].t_pid = l_pid THEN
				IF x != l_id AND m_menu.menu.items[x].conditional THEN
					CALL debug.output(SFMT("CleanItem: %1 : %2",m_menu.menu.items[x].t_id, m_menu.menu.items[x].description), FALSE)
					CALL m_dialog.setFieldValue(m_menu.menu.items[x].field,0)
				END IF 
			END IF
		END IF
	END FOR
	IF NOT l_pid_cond THEN RETURN END IF
	CALL clearOtherGroups(1, l_pid, l_pid_pid)

END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION clearOtherGroups(l_depth SMALLINT, l_pid SMALLINT, l_pid_pid SMALLINT)
	DEFINE x, l_s_pid, l_pid_pid2, l_g_pid SMALLINT
	CALL debug.output(SFMT("Checking Parent Items: %1 Depth: %2", l_pid_pid,l_depth), FALSE)
-- Clear items in conditional groups
	FOR x = 1 TO m_menu.menu.rows
		IF m_menu.menu.items[x].t_id = l_pid_pid THEN
			LET l_pid_pid2 = m_menu.menu.items[x].t_pid
		END IF
		IF m_menu.menu.items[x].t_pid = l_pid_pid AND m_menu.menu.items[x].t_id != l_pid THEN
			CALL debug.output(SFMT("%1) Item: %2 Cond: %3", m_menu.menu.items[x].level, m_menu.menu.items[x].description,m_menu.menu.items[x].conditional), FALSE)
			IF m_menu.menu.items[x].conditional THEN
				LET l_g_pid = m_menu.menu.items[x].t_id
			END IF
		END IF
		IF m_menu.menu.items[x].t_pid = l_g_pid THEN
			CALL debug.output(SFMT("%1) Item: %2", m_menu.menu.items[x].level, m_menu.menu.items[x].description), FALSE)
			LET l_s_pid = m_menu.menu.items[x].t_id
		END IF
		IF m_menu.menu.items[x].t_pid = l_s_pid THEN
			IF m_menu.menu.items[x].field.getLength() > 1 AND m_menu.menu.items[x].t_pid != l_pid THEN
				CALL debug.output(SFMT("CleanItem: %1 : %2",m_menu.menu.items[x].t_id, m_menu.menu.items[x].description), FALSE)
				CALL m_dialog.setFieldValue(m_menu.menu.items[x].field,0)
			END IF
		END IF
	END FOR
	IF l_pid_pid2 > 1 THEN
		CALL clearOtherGroups(l_depth+1, l_pid, l_pid_pid2 )
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------