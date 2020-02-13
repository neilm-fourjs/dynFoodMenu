IMPORT os
IMPORT util
IMPORT FGL debug
IMPORT FGL libCommon
IMPORT FGL db

CONSTANT C_DBVER = 1
CONSTANT C_DBDIR = "../dfmd"

&include "menus.inc"

PUBLIC DEFINE m_dbname, m_dbdir STRING
PUBLIC DEFINE m_dbver SMALLINT
PUBLIC DEFINE m_dbtype STRING
PUBLIC DEFINE m_connected BOOLEAN = FALSE
--------------------------------------------------------------------------------------------------------------
FUNCTION connect() RETURNS BOOLEAN
	WHENEVER ERROR CALL libCommon.abort
	IF m_connected THEN RETURN TRUE END IF
	LET m_dbname = fgl_getResource("my.dbname")
	IF NOT base.Application.isMobile() THEN -- if not mobile use C_DBDIR
		IF NOT os.path.exists(C_DBDIR) THEN
			IF NOT os.path.mkdir(C_DBDIR) THEN
				CALL debug.output(SFMT("Failed to make %1",C_DBDIR), FALSE)
				EXIT PROGRAM
			END IF
		END IF
	END IF
	IF NOT os.path.exists(m_dbname) THEN
		CALL debug.output(SFMT("Creating %1",m_dbname),FALSE)
		CREATE DATABASE m_dbname
		CALL create()
	END IF

	CALL debug.output(SFMT("Connecting to %1",m_dbname),FALSE)
	TRY
		CONNECT TO m_dbname
		LET m_connected = TRUE
	CATCH
		CALL libCommon.error(SFMT("DB Connect failed %1", SQLERRMESSAGE))
		RETURN FALSE
	END TRY
	LET m_dbtype = fgl_getResource("dbi.default.driver")
	CALL check()
	CALL fix_serials("orders","order_id")
	CALL fix_serials("wards","ward_id")
	CALL fix_serials("patients","patient_id")
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION check()
	TRY
		SELECT * INTO m_dbver FROM dbver
	CATCH
	END TRY
	IF m_dbver IS NULL OR m_dbver = 0 THEN
		CALL create()
	END IF
	CALL debug.output(SFMT("DbVer: %1", m_dbver), FALSE)
	IF m_dbver < C_DBVER THEN
		IF NOT update() THEN
			EXIT PROGRAM
		END IF
		CALL debug.output(SFMT("DbVer: %1 Now", m_dbver), FALSE)
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION update()
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION create()
	CALL drop_tabs()
	CALL create_tabs()
	CALL debug.output("Attempting to run db_load.42r", FALSE)
	RUN "fglrun load_data.42r"
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION create_tabs()
	CALL debug.output("Create table: dbver", FALSE)
	CREATE TABLE dbver (
		dbver INTEGER
	)
	INSERT INTO dbver VALUES(1)

	CALL debug.output("Create table: users", FALSE)
	CREATE TABLE users (
		user_id VARCHAR(6),
		user_name VARCHAR(30),
		user_pwd VARCHAR(60),
		user_token VARCHAR(60),
		token_ts DATETIME YEAR TO MINUTE
	)

	CALL debug.output("Create table: userDetails", FALSE)
	CREATE TABLE userDetails (
		user_id VARCHAR(6),
		salutation VARCHAR(30),
		firstnames VARCHAR(30),
		surname VARCHAR(30),
		email VARCHAR(50),
		dob DATE,
		gender_preference CHAR(1),
		password_hash VARCHAR(60),
		registered DATETIME YEAR TO MINUTE
	)

	CALL debug.output("Create table: menus", FALSE)
	CREATE TABLE menus (
		menuName VARCHAR(6),
		menuDesc VARCHAR(30),
		menuImage VARCHAR(20)
	)

	CALL debug.output("Create table: menuItems", FALSE)
	CREATE TABLE menuItems (
		menuName VARCHAR(6),
		t_id INTEGER,
		t_pid INTEGER,
		id VARCHAR(6),
		type VARCHAR(10),
		description VARCHAR(30),
		conditional BOOLEAN,
		minval INTEGER,
		maxval INTEGER,
		field VARCHAR(25),
		option_id VARCHAR(6),
		option_name VARCHAR(30),
		hidden BOOLEAN,
		level SMALLINT
	)

	CALL debug.output("Create table: orders", FALSE)
	CREATE TABLE orders (
		order_id SERIAL,
		user_token VARCHAR(60),
		user_id VARCHAR(6),
		patients_id INTEGER,
		ward_id INTEGER,
		bed_no SMALLINT,
		menu_id VARCHAR(6),
		placed DATETIME YEAR TO SECOND
	)

	CALL debug.output("Create table: orderItems", FALSE)
	CREATE TABLE orderItems (
			order_id INTEGER,
			item_id INTEGER,
			description VARCHAR(30),
			qty SMALLINT,
			optional BOOLEAN
	)

	CALL debug.output("Create table: wards", FALSE)
	CREATE TABLE wards (
		ward_id INTEGER,
		ward_name VARCHAR(30)
	)

	CALL debug.output("Create table: patients", FALSE)
	CREATE TABLE patients (
		id SERIAL,
		name VARCHAR(40),
		dob DATE,
		gender_preference CHAR(1),
		ward_id INTEGER,
		bed_no SMALLINT,
		nilbymouth BOOLEAN,
		diabetic BOOLEAN,
		allergies VARCHAR(100)
	)

	INSERT INTO dbver VALUES(1)
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION drop_tabs()
	CALL dropTab("dbver")
	CALL dropTab("users")
	CALL dropTab("userDetails")
	CALL dropTab("menus")
	CALL dropTab("menuItems")
	CALL dropTab("orders")
	CALL dropTab("orderItems")
	CALL dropTab("wards")
	CALL dropTab("patients")
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION dropTab(l_tab STRING)
	TRY
		EXECUTE IMMEDIATE "drop table " || l_tab
		CALL debug.output(SFMT("Dropped %1",l_tab), FALSE)
	CATCH
		CALL libCommon.error(SFMT("Failed to drop %1: %2 %3", l_tab, STATUS, SQLERRMESSAGE))
	END TRY
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION fix_serials(l_tab STRING, l_col STRING)
	DEFINE l_id INTEGER
	DEFINE l_sql STRING
	IF m_dbtype = "dbmpgs" THEN
		TRY
			LET l_sql = SFMT("SELECT MAX(%1) FROM %2", l_col, l_tab)
			PREPARE l_pre FROM l_sql 
			EXECUTE l_pre INTO l_id
			SELECT MAX(pick_id) INTO l_id FROM pick_hist
			IF l_id IS NULL THEN
				LET l_id = 0
			END IF
			LET l_id = l_id + 1
			CALL debug.output(SFMT("Fixing serial for %1 : %2",l_tab, l_id), FALSE)
			LET l_sql = SFMT("SELECT setval('%1_%2_seq', %3)", l_tab, l_col, l_id)
			EXECUTE IMMEDIATE l_sql
		CATCH
			CALL libCommon.error(SFMT("DB Error %1:%2", STATUS, SQLERRMESSAGE))
		END TRY
	END IF
END FUNCTION
