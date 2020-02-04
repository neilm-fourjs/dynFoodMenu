

CONSTANT C_WS_BACKEND="https://generodemos.dynu.net/g/ws/r/dynFoodRest"
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
		menu_id STRING,
		items DYNAMIC ARRAY OF menuItem,
		rows INTEGER
	END RECORD

PUBLIC TYPE orderRecord RECORD
		user_token STRING,
		user_id STRING,
		dte DATE,
		items DYNAMIC ARRAY OF RECORD
			item_id INTEGER,
			description STRING,
			qty SMALLINT,
			optional BOOLEAN
		END RECORD,
		rows SMALLINT
	END RECORD

PUBLIC TYPE userRecord RECORD
		user_id VARCHAR(6),
		user_name VARCHAR(30),
		user_pwd VARCHAR(60),
		user_token STRING,
		token_ts DATETIME YEAR TO MINUTE
	END RECORD