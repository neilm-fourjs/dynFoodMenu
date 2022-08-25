
IMPORT os
IMPORT FGL debug
IMPORT FGL config
IMPORT FGL libCommon
IMPORT FGL db

CONSTANT C_DBVER = 1

&include "app.inc"

PUBLIC TYPE db RECORD
	config config,
	dbver SMALLINT,
	dbtype STRING,
	connected BOOLEAN,
	message STRING
END RECORD
--------------------------------------------------------------------------------------------------------------
FUNCTION (this db) connect() RETURNS BOOLEAN
	WHENEVER ERROR CALL libCommon.abort
	IF NOT this.config.cfgDone THEN
		IF NOT this.config.initConfigFile(NULL) THEN
			LET this.message = "Init config failed"
			RETURN FALSE
		END IF
	END IF
	IF this.connected THEN
		LET this.message = "Already connected"
		RETURN TRUE
	END IF

	IF NOT base.Application.isMobile() THEN -- if not mobile use C_DBDIR
		IF NOT os.path.exists(this.config.dbdir) THEN
			IF NOT os.path.mkdir(this.config.dbdir) THEN
				CALL debug.output(SFMT("Failed to make %1",this.config.dbdir), FALSE)
				EXIT PROGRAM
			END IF
		END IF
		LET this.config.dbname = os.path.join( this.config.dbDir, this.config.dbName)
	END IF

	IF NOT os.path.exists(this.config.dbname) THEN
		CALL debug.output(SFMT("Creating %1",this.config.dbname),FALSE)
		CREATE DATABASE this.config.dbname
		CALL this.create()
	END IF

	CALL debug.output(SFMT("Connecting to %1",this.config.dbname),FALSE)
	TRY
		CONNECT TO this.config.dbname
		LET this.connected = TRUE
	CATCH
		CALL libCommon.error(SFMT("DB Connect failed %1", SQLERRMESSAGE))
		RETURN FALSE
	END TRY
	LET this.dbtype = fgl_getResource("dbi.default.driver")
	CALL this.check()
	CALL this.fix_serials("orders","order_id")
	CALL this.fix_serials("wards","ward_id")
	CALL this.fix_serials("patients","patient_id")
	LET this.message = "Connected"
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this db) check()
	TRY
		SELECT * INTO this.dbver FROM dbver
	CATCH
	END TRY
	IF this.dbver IS NULL OR this.dbver = 0 THEN
		CALL this.create()
	END IF
	CALL debug.output(SFMT("DbVer: %1", this.dbver), FALSE)
	IF this.dbver < C_DBVER THEN
		IF NOT this.update() THEN
			EXIT PROGRAM
		END IF
		CALL debug.output(SFMT("DbVer: %1 Now", this.dbver), FALSE)
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this db) fix_serials(l_tab STRING, l_col STRING)
	DEFINE l_id INTEGER
	DEFINE l_sql STRING
	IF this.dbtype = "dbmpgs" THEN
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
--------------------------------------------------------------------------------------------------------------
FUNCTION (this db) update() RETURNS BOOLEAN
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this db) create()
	CALL this.drop_tabs()
	CALL this.create_tabs()
	CALL debug.output("Attempting to run db_load.42r", FALSE)
	RUN "fglrun load_data.42r"
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this db) create_tabs()
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
		patient_id INTEGER,
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
FUNCTION (this db) drop_tabs()
	CALL this.dropTab("dbver")
	CALL this.dropTab("users")
	CALL this.dropTab("userDetails")
	CALL this.dropTab("menus")
	CALL this.dropTab("menuItems")
	CALL this.dropTab("orders")
	CALL this.dropTab("orderItems")
	CALL this.dropTab("wards")
	CALL this.dropTab("patients")
END FUNCTION
--------------------------------------------------------------------------------------------------------------
PRIVATE FUNCTION (this db) dropTab(l_tab STRING)
	TRY
		EXECUTE IMMEDIATE "drop table " || l_tab
		CALL debug.output(SFMT("Dropped %1",l_tab), FALSE)
	CATCH
		CALL libCommon.error(SFMT("Failed to drop %1: %2 %3", l_tab, STATUS, SQLERRMESSAGE))
	END TRY
END FUNCTION