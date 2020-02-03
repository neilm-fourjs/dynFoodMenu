
PUBLIC TYPE menuList RECORD
		list DYNAMIC ARRAY OF RECORD
			menuName STRING,
			menuDesc STRING,
			menuImage STRING
		END RECORD,
		rows SMALLINT
	END RECORD

PUBLIC TYPE menuItem RECORD
		t_id INTEGER,
		t_pid INTEGER,
		id VARCHAR(6),
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
		description STRING,
		image STRING,
		items DYNAMIC ARRAY OF menuItem,
		rows SMALLINT
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
		user_pwd VARCHAR(20),
		user_name VARCHAR(30),
		user_token STRING
	END RECORD