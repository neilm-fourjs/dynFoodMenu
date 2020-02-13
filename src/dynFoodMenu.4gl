IMPORT FGL menuData
IMPORT FGL dynForm
IMPORT FGL debug
IMPORT FGL about
IMPORT FGL login
IMPORT FGL libMobile
IMPORT FGL Patients

DEFINE m_data menuData
DEFINE m_form dynForm
DEFINE m_dialog ui.Dialog
DEFINE m_user login.userRecord
PUBLIC DEFINE m_user_token STRING
PUBLIC DEFINE m_user_id STRING
PUBLIC DEFINE m_patients Patients
--------------------------------------------------------------------------------------------------------------
FUNCTION showMenu(l_menuName STRING)
	IF NOT m_data.getMenu(l_menuName) THEN RETURN END IF-- Load the menu data
	LET m_form.menuData = m_data.menuData -- give the ui library the menu data
	LET m_form.toolbar[1] = "submit"
	LET m_form.toolbar[2] = "cancel"
	LET m_form.toolbar[3] = "about"
--	LET m_form.toolbar[4] = "debug"
	CALL m_form.buildForm("Food Menu", "main", "icon32") -- create the form
	IF inpByName() THEN -- do the input
		CALL m_data.save()
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
	DEFINE l_order STRING = "Your Order is:\n"
	DEFINE l_desc STRING
	CALL debug.output("input_okay: Started", FALSE)
	IF NOT libMobile.gotNetwork() THEN
		CALL fgl_winMessage("Error","No connection!","exclamation")
		RETURN FALSE
	END IF
	IF m_user_id = "DUMMY" THEN
		IF NOT m_user.login(TRUE) OR m_user.user_id = "DUMMY" THEN
			CALL fgl_winMessage("Error","You are not logged in","exclamation")
			RETURN FALSE
		ELSE
			LET m_user_id = m_user.user_id
			LET m_user_token = m_user.user_token
		END IF
	END IF
	CALL m_data.ordered.items.clear()
	LET m_data.ordered.placed = CURRENT
	LET m_data.ordered.user_id = m_user_id
	LET m_data.ordered.user_token = m_user_token
	LET order_lines = 0
	FOR x = 1 TO m_data.menuData.rows
		IF m_data.menuData.items[x].field.getLength() > 2 THEN
			LET l_opt = 0
			LET l_val = m_dialog.getFieldValue(m_data.menuData.items[x].field)
			IF l_val > 0 THEN
				LET l_desc = m_data.menuData.items[x].description
				IF m_data.menuData.items[x].option_id.getLength()  > 2 THEN
					LET l_opt = m_dialog.getFieldValue(m_data.menuData.items[x].field||"o1")
					IF l_opt = 1 THEN
						LET l_desc = l_desc.append(" "||m_data.menuData.items[x].option_name)
					END IF
				END IF
				LET l_order = l_order.append(SFMT("%1 %2\n",l_val, l_desc))
				LET order_lines = order_lines + 1
				LET m_data.ordered.items[ order_lines ].item_id= m_data.menuData.items[x].t_id
				LET m_data.ordered.items[ order_lines ].description = l_desc
				LET m_data.ordered.items[ order_lines ].qty = l_val
				LET m_data.ordered.items[ order_lines ].optional = l_opt
			END IF
		END IF
	END FOR
	LET m_data.ordered.rows = order_lines
	IF order_lines > 0 THEN
		CALL debug.output("input_okay: Do confirm", FALSE)
		IF fgl_winQuestion("Confirm",l_order,"Yes","Yes|No","question",0) = "No" THEN
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
	FOR l_id = 1 TO m_data.menuData.rows
		IF m_data.menuData.items[l_id].field = l_fld THEN EXIT FOR END IF
	END FOR
	LET l_pid = m_data.menuData.items[l_id].t_pid
	LET l_cond = m_data.menuData.items[l_id].conditional
	CALL debug.output(SFMT("Validate Field: %1 = %2 Desc: %3 PID: %4 Cond: %5", l_fld, l_val, m_data.menuData.items[l_id].description, l_pid, l_cond), FALSE)

-- Clear items in same subgroup
	FOR x = 1 TO m_data.menuData.rows
		IF m_data.menuData.items[x].t_id = l_pid THEN
			LET l_pid_cond = m_data.menuData.items[x].conditional
			LET l_pid_pid = m_data.menuData.items[x].t_pid
			CALL debug.output(SFMT("%1) Parent: %2 Cond: %3 PIDPID: %4", m_data.menuData.items[x].level,m_data.menuData.items[x].description, l_pid_cond, l_pid_pid ), FALSE)
		END IF
		IF l_cond THEN
			IF m_data.menuData.items[x].t_pid = l_pid THEN
				IF x != l_id AND m_data.menuData.items[x].conditional THEN
					CALL debug.output(SFMT("CleanItem: %1 : %2",m_data.menuData.items[x].t_id, m_data.menuData.items[x].description), FALSE)
					CALL m_dialog.setFieldValue(m_data.menuData.items[x].field,0)
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
	FOR x = 1 TO m_data.menuData.rows
		IF m_data.menuData.items[x].t_id = l_pid_pid THEN
			LET l_pid_pid2 = m_data.menuData.items[x].t_pid
		END IF
		IF m_data.menuData.items[x].t_pid = l_pid_pid AND m_data.menuData.items[x].t_id != l_pid THEN
			CALL debug.output(SFMT("%1) Item: %2 Cond: %3", m_data.menuData.items[x].level, m_data.menuData.items[x].description,m_data.menuData.items[x].conditional), FALSE)
			IF m_data.menuData.items[x].conditional THEN
				LET l_g_pid = m_data.menuData.items[x].t_id
			END IF
		END IF
		IF m_data.menuData.items[x].t_pid = l_g_pid THEN
			CALL debug.output(SFMT("%1) Item: %2", m_data.menuData.items[x].level, m_data.menuData.items[x].description), FALSE)
			LET l_s_pid = m_data.menuData.items[x].t_id
		END IF
		IF m_data.menuData.items[x].t_pid = l_s_pid THEN
			IF m_data.menuData.items[x].field.getLength() > 1 AND m_data.menuData.items[x].t_pid != l_pid THEN
				CALL debug.output(SFMT("CleanItem: %1 : %2",m_data.menuData.items[x].t_id, m_data.menuData.items[x].description), FALSE)
				CALL m_dialog.setFieldValue(m_data.menuData.items[x].field,0)
			END IF
		END IF
	END FOR
	IF l_pid_pid2 > 1 THEN
		CALL clearOtherGroups(l_depth+1, l_pid, l_pid_pid2 )
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------