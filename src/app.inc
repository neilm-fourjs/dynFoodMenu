
SCHEMA dynfooddemo

PUBLIC TYPE menuList RECORD
		list DYNAMIC ARRAY OF RECORD
			menuName STRING,
			menuDesc STRING,
			menuImage STRING
		END RECORD,
		rows INTEGER
	END RECORD

PUBLIC TYPE menuItem RECORD
		menuName VARCHAR(6),
		t_id INTEGER,
		t_pid INTEGER,
		id STRING,
		type STRING,
		description STRING,
		conditional BOOLEAN,
		minval INTEGER,
		maxval INTEGER,
		field STRING,
		option_id STRING,
		option_name STRING,
		hidden BOOLEAN,
		level SMALLINT
	END RECORD

PUBLIC TYPE menuRecord RECORD
		menuName STRING,
		items DYNAMIC ARRAY OF menuItem,
		rows INTEGER
	END RECORD

PUBLIC TYPE orderItemsRecord RECORD
			order_id INTEGER,
			item_id INTEGER,
			description STRING,
			qty SMALLINT,
			optional BOOLEAN
		END RECORD

PUBLIC TYPE orderRecord RECORD
		order_id INTEGER,
		user_token STRING,
		user_id STRING,
		patient_id INTEGER,
		ward_id INTEGER,
		bed_no SMALLINT,
		menu_id STRING,
		placed DATETIME YEAR TO SECOND,
		items DYNAMIC ARRAY OF orderItemsRecord,
		rows SMALLINT
	END RECORD

PUBLIC TYPE userRecord RECORD
		user_id VARCHAR(6),
		user_name VARCHAR(30),
		user_pwd VARCHAR(60),
		user_token STRING,
		token_ts DATETIME YEAR TO MINUTE
	END RECORD

PUBLIC TYPE userDetailsRecord RECORD
		user_id VARCHAR(6),
		salutation VARCHAR(30),
		firstnames VARCHAR(30),
		surname VARCHAR(30),
		email VARCHAR(50),
		dob DATE,
		gender_preference CHAR(1),
		password_hash VARCHAR(60),
		registered DATETIME YEAR TO MINUTE
	END RECORD

PUBLIC TYPE wardRecord RECORD
		ward_id INTEGER,
		ward_name VARCHAR(30)
	END RECORD

PUBLIC TYPE wardList RECORD
		list DYNAMIC ARRAY OF wardRecord,
		current wardRecord,
		message STRING
	END RECORD

PUBLIC TYPE patientRecord RECORD
		id INTEGER,
		name VARCHAR(40),
		dob DATE,
		gender_preference CHAR(1),
		ward_id INTEGER,
		bed_no SMALLINT,
		nilbymouth BOOLEAN,
		diabetic BOOLEAN,
		allergies VARCHAR(100)
	END RECORD

PUBLIC TYPE patientOrderRecord RECORD
		patient_id INTEGER,
		menu_id STRING,
		placed DATETIME YEAR TO SECOND
	END RECORD

PUBLIC TYPE patientList RECORD
		list DYNAMIC ARRAY OF patientRecord,
		current patientRecord,
		ordered DYNAMIC ARRAY OF patientOrderRecord,
		message STRING
	END RECORD
