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
	IF m_connected THEN RETURN TRUE END IF
	LET m_dbname = fgl_getResource("my.dbname")
	IF NOT os.path.exists(C_DBDIR) THEN
		IF NOT os.path.mkdir(C_DBDIR) THEN
			CALL debug.output(SFMT("Failed to make %1",C_DBDIR), FALSE)
			EXIT PROGRAM
		END IF
	END IF
	IF NOT os.path.exists(m_dbname) THEN
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
	CREATE TABLE dbver (
		dbver INTEGER
	)
	INSERT INTO dbver VALUES(1)

	CREATE TABLE users (
		user_id VARCHAR(6),
		user_name VARCHAR(30),
		user_pwd VARCHAR(60),
		user_token VARCHAR(60),
		token_ts DATETIME YEAR TO MINUTE
	)

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

	CREATE TABLE menus (
		menuName VARCHAR(6),
		menuDesc VARCHAR(30),
		menuImage VARCHAR(20)
	)

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

	CREATE TABLE orders (
		order_id SERIAL,
		user_token VARCHAR(60),
		user_id VARCHAR(6),
		menu_id VARCHAR(6),
		placed DATETIME YEAR TO SECOND
	)

	CREATE TABLE orderItems (
			order_id INTEGER,
			item_id INTEGER,
			description VARCHAR(30),
			qty SMALLINT,
			optional BOOLEAN
	)

	INSERT INTO dbver VALUES(1)
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION drop_tabs()
	CALL dropTab("users")
	CALL dropTab("menus")
	CALL dropTab("menuItems")
	CALL dropTab("orders")
	CALL dropTab("orderItems")
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION dropTab(l_tab STRING)
	TRY
		EXECUTE IMMEDIATE "drop table " || l_tab
		DISPLAY "Dropped " || l_tab
	CATCH
		CALL libCommon.error(
				SFMT("Failed to drop %1: %2 %3", l_tab, STATUS, SQLERRMESSAGE))
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
			DISPLAY "Fixing serial for ",l_tab,":", l_id
			LET l_sql = SFMT("SELECT setval('%1_%2_seq', %3)", l_tab, l_col, l_id)
			EXECUTE IMMEDIATE l_sql
		CATCH
			CALL libCommon.error(SFMT("DB Error %1:%2", STATUS, SQLERRMESSAGE))
		END TRY
	END IF
END FUNCTION
