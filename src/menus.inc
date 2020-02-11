
SCHEMA dynfooddemo

CONSTANT C_APPVER="1.0"
CONSTANT C_WS_BACKEND="https://generodemos.dynu.net/g/ws/r/dyn/dynFoodRest"
CONSTANT C_APIPASS="dynFoodMenuDemofqqGQg43ppgjcaqz"

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
		placed DATETIME YEAR TO SECOND,
		menu_id STRING,
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