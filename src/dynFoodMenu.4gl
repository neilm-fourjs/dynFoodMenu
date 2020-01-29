IMPORT util
IMPORT os
TYPE t_rec RECORD
	t_id INTEGER,
	t_pid INTEGER,
	id CHAR(6),
	type CHAR(20),
	description STRING,
	visible BOOLEAN,
	minval INTEGER,
	maxval INTEGER,
	field CHAR(50),
	option_id CHAR(6),
	option_name STRING,
	hidden BOOLEAN
END RECORD
DEFINE m_tree DYNAMIC ARRAY OF t_rec
DEFINE m_inp DYNAMIC ARRAY OF RECORD
		l_fldName STRING,
		l_fldType STRING
	END RECORD
DEFINE m_flds SMALLINT
CONSTANT C_WIDTH=20
MAIN
	DEFINE l_json TEXT
	DEFINE l_f ui.Form
-- get test data
	IF os.path.exists("../etc/data.json") THEN
		LOCATE l_json IN FILE "../etc/data.json"
	ELSE
		LOCATE l_json IN FILE "data.json"
	END IF
	CALL util.JSON.parse(l_json, m_tree)
	CALL ui.Interface.loadStyles( DOWNSHIFT( ui.Interface.getFrontEndName()) )
-- build the form
	CALL ui.Interface.setText("Menu")
	CURRENT WINDOW IS SCREEN
	LET l_f = ui.Window.getCurrent().createForm("Menu")
	CALL buildForm( l_f.getNode(), "Dynamic Menu Demo", "main2" )
	CALL inp()
END MAIN
--------------------------------------------------------------------------------------------------------------
-- Do the screen record INPUT.
FUNCTION inp() RETURNS ()
	DEFINE d ui.Dialog
	DEFINE l_event STRING
	DEFINE x SMALLINT
	LET d = ui.Dialog.createInputByName( m_inp )
	CALL d.addTrigger("ON ACTION close")
	CALL d.addTrigger("ON ACTION quit")
	FOR x = 1 TO m_inp.getLength()
		CALL d.setFieldValue(m_inp[x].l_fldName,0)
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
--------------------------------------------------------------------------------------------------------------
-- Generate the screen form and recordView.
FUNCTION buildForm( l_n om.DomNode, l_titl STRING, l_styl STRING ) RETURNS ()
	DEFINE l_w, l_vb, l_grid, l_group, l_sgroup, l_cont om.DomNode
	DEFINE l_fldnam, l_desc STRING
	DEFINE x,y SMALLINT
	LET l_w = l_n.getParent()
	CALL l_w.setAttribute("text",l_titl)
	CALL l_w.setAttribute("style",l_styl)
	CALL l_n.setAttribute("text",l_titl)
	CALL l_n.setAttribute("style",l_styl)
	LET l_vb = l_n.createChild("VBox")
	LET l_grid = l_vb.createChild("Grid")
	CALL l_grid.setAttribute("gridWidth",C_WIDTH+6)
	CALL l_grid.setAttribute("width",C_WIDTH+6)
	CALL m_inp.clear()
	LET m_flds = 0
	FOR x = 1 TO m_tree.getLength()
		LET l_fldnam = m_tree[x].field CLIPPED
		LET l_desc = m_tree[x].description CLIPPED
		DISPLAY  m_tree[x].type[1,2],":",l_fldnam,":",IIF(m_tree[x].hidden,"T","F"),":",l_desc,":",IIF(l_sgroup IS NULL,"G","SG")
		IF m_tree[x].hidden THEN CONTINUE FOR END IF
		CASE m_tree[x].type
			WHEN "Type"
				CALL addField(x, 0, l_grid, "",l_desc ,"Label", C_WIDTH)
			WHEN "Group"
				LET l_group = addGroup(x, l_vb, l_desc,C_WIDTH+4)
				LET l_cont = l_group
			WHEN "Subgroup"
				IF m_tree[x].visible THEN
					IF l_group.getTagName() = "Group" THEN
						LET l_group = l_group.createChild("VBox")
					END IF
					LET l_sgroup = addGroup(x, l_group, l_desc,C_WIDTH+2)
					LET l_cont = l_sgroup
				END IF
			WHEN "Item"
				IF l_cont.getTagName() = "Group" THEN
					LET l_cont = l_cont.createChild("Grid")
				END IF
				IF m_tree[x].maxval = 1 THEN
					CALL addField(x, 0, l_cont, l_fldnam, l_desc,"CheckBox", C_WIDTH)
				ELSE
					CALL addField(x, 0, l_cont, l_fldnam, l_desc,"SpinEdit", 3)
					CALL addField(x, 4, l_cont, "", l_desc,"Label", C_WIDTH)
				END IF
				IF m_tree[x].option_name IS NOT NULL THEN
					CALL addField(x, 15,l_cont, l_fldnam||"o1", m_tree[x].option_name,"CheckBox", C_WIDTH)
				END IF
		END CASE
	END FOR
-- Create screen record
	LET l_grid = l_n.createChild("RecordView")
	CALL l_grid.setAttribute("tabName","formonly")
	FOR x = 1 TO m_inp.getLength()
		LET l_group = l_grid.createChild("Link")
		LET y = m_inp[x].l_fldName.getIndexOf(".",1)
		CALL l_group.setAttribute("colName",m_inp[x].l_fldName.subString(y+1,m_inp[x].l_fldName.getLength()))
		CALL l_group.setAttribute("fieldIdRef",x)
	END FOR
	CALL ui.Interface.refresh()
	CALL l_n.writeXml("generated.42f") -- for debug only!
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION addGroup(x SMALLINT, l_n om.DomNode, l_desc STRING, l_width SMALLINT) RETURNS (om.DomNode)
	DEFINE l_group om.DomNode
	DEFINE l_nam STRING
	LET l_group = l_n.createChild("Group")
	CALL l_group.setAttribute("gridWidth", l_width)
	CALL l_group.setAttribute("width", l_width)
	LET l_nam = SFMT("%1_%2_%3",DOWNSHIFT(m_tree[x].id CLIPPED), m_tree[x].t_pid, m_tree[x].t_id )
	CALL l_group.setAttribute("name",  l_nam)
	CALL l_group.setAttribute("text", l_desc)
	CALL l_group.setAttribute("posY", x)
	CALL l_group.setAttribute("posX", 0)
	RETURN l_group
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION addField(x SMALLINT, y SMALLINT, l_n om.DomNode, l_nam STRING, l_desc STRING, l_wdg STRING, l_width SMALLINT) RETURNS ()
	DEFINE l_ff, l_w om.DomNode
	DEFINE z SMALLINT
	DEFINE l_typ STRING
	IF l_nam IS NOT NULL THEN
		LET l_ff = l_n.createChild("FormField")
		LET z = l_nam.getIndexOf(".",1)
		CALL l_ff.setAttribute("name", l_nam)
		CALL l_ff.setAttribute("colName",l_nam.subString(z+1, l_nam.getLength()))
		CASE l_wdg
			WHEN "CheckBox" LET l_typ = "BOOLEAN"
			WHEN "SpinEdit" LET l_typ = "SMALLINT"
		END CASE
		LET m_flds = m_flds + 1
		LET m_inp[ m_flds ].l_fldName = l_nam
		LET m_inp[ m_flds ].l_fldType = l_typ
		CALL l_ff.setAttribute("varType", l_typ)
		CALL l_ff.setAttribute("notNull",1)
		CALL l_ff.setAttribute("required",1)
		CALL l_ff.setAttribute("defaultValue",0)
		CALL l_ff.setAttribute("value",0)
		CALL l_ff.setAttribute("fieldId", m_flds)
		LET l_w = l_ff.createChild(l_wdg)
	ELSE
		LET l_w = l_n.createChild(l_wdg)
	END IF
	CALL l_w.setAttribute("posY", x)
	CALL l_w.setAttribute("posX", y)
	IF l_width > l_desc.getLength() AND l_desc.getLength() > 1 THEN LET l_width = l_desc.getLength() END IF
	CALL l_w.setAttribute("width",l_width)
	CALL l_w.setAttribute("gridWidth",l_width)
	CALL l_w.setAttribute("text", l_desc)
	IF l_wdg = "SpinEdit" THEN
		CALL l_w.setAttribute("valueMin",0)
		CALL l_w.setAttribute("valueMax",m_tree[x].maxval)
	END IF
END FUNCTION