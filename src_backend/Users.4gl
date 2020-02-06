IMPORT util
IMPORT FGL db
&include "../src/menus.inc"

PUBLIC TYPE Users RECORD
  list DYNAMIC ARRAY OF userRecord,
	currentUser UserRecord,
	errorMessage STRING
END RECORD

FUNCTION (this Users) get(l_userId LIKE users.user_id) RETURNS BOOLEAN
	DEFINE x SMALLINT
	IF this.list.getLength() = 0 THEN CALL this.loadFromDB () END IF
	FOR x = 1 TO this.list.getLength()
		IF this.list[x].user_id = l_userId THEN
			LET this.currentUser.* = this.list[x].*
			DISPLAY "Found User:",l_userId
			RETURN TRUE
		END IF
	END FOR
	RETURN FALSE
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION (this Users) add() RETURNS BOOLEAN
	IF NOT db.connect() THEN EXIT PROGRAM END IF
	IF this.currentUser.user_id IS NULL OR this.currentUser.user_id = " " THEN
		LET this.errorMessage = "User Id invalid!"
		RETURN FALSE
	END IF
	LET this.errorMessage = "User Added Okay."
	INSERT INTO users VALUES(this.currentUser.*)
	IF STATUS = 0 THEN RETURN TRUE END IF
	LET this.errorMessage = SQLERRMESSAGE
	RETURN FALSE
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION (this Users) update() RETURNS BOOLEAN
	IF NOT db.connect() THEN EXIT PROGRAM END IF
	LET this.errorMessage = "User Update Okay."
	UPDATE users SET users.* = this.currentUser.* WHERE users.user_id = this.currentUser.user_id
	IF STATUS = 0 THEN RETURN TRUE END IF
	LET this.errorMessage = SQLERRMESSAGE
	RETURN FALSE
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION (this Users) delete(l_userId LIKE users.user_id) RETURNS BOOLEAN
	IF NOT db.connect() THEN EXIT PROGRAM END IF
	LET this.errorMessage = "User Deleted Okay."
	DELETE FROM users WHERE users.user_id = l_userId
	IF STATUS = 0 THEN RETURN TRUE END IF
	LET this.errorMessage = SQLERRMESSAGE
	RETURN FALSE
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION (this Users) loadFromDB()
	DEFINE l_user userRecord
	IF NOT db.connect() THEN EXIT PROGRAM END IF
	DECLARE load_cur CURSOR FOR SELECT * FROM users
	FOREACH load_cur INTO l_user.*
		LET this.list[ this.list.getLength() + 1 ].* = l_user.*
	END FOREACH
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION (this Users) loadFromJSON()
	DEFINE l_userJSON TEXT
	LOCATE l_userJSON IN MEMORY
	CALL l_userJSON.readFile("users.json")
	CALL util.JSON.parse(l_userJSON, this.list)
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION (this Users) saveToJSON()
	DEFINE l_userJSON TEXT
	LET l_userJSON = util.JSON.stringify(this.list)
	CALL l_userJSON.writeFile("users.json")
END FUNCTION
--------------------------------------------------------------------------------