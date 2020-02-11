IMPORT util
IMPORT FGL db
&include "../src/menus.inc"

PUBLIC TYPE Users RECORD
  list DYNAMIC ARRAY OF userRecord,
	currentUser UserRecord,
	currentUserDetails userDetailsRecord,
	errorMessage STRING
END RECORD

FUNCTION (this Users) get(l_userId LIKE users.user_id) RETURNS BOOLEAN
	DEFINE x SMALLINT
	IF this.list.getLength() = 0 THEN CALL this.loadFromDB () END IF
	FOR x = 1 TO this.list.getLength()
		IF this.list[x].user_id = l_userId THEN
			LET this.currentUser.* = this.list[x].*
			DISPLAY "Found User:",l_userId
			SELECT * FROM userdetails WHERE user_id = l_userId
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
	IF STATUS != 0 THEN
		LET this.errorMessage = "1)"||SQLERRMESSAGE
		RETURN FALSE
	END IF
	INSERT INTO userdetails VALUES(this.currentUserDetails.*)
	IF STATUS != 0 THEN
		LET this.errorMessage = "2)"||SQLERRMESSAGE
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION (this Users) update() RETURNS BOOLEAN
	IF NOT db.connect() THEN EXIT PROGRAM END IF
	LET this.errorMessage = "User Update Okay."
	UPDATE users SET users.* = this.currentUser.* WHERE users.user_id = this.currentUser.user_id
	IF STATUS != 0 THEN
		LET this.errorMessage = "1)"||SQLERRMESSAGE
		RETURN FALSE
	END IF
	UPDATE userdetails SET userdetails.* = this.currentUserDetails.* WHERE userdetails.user_id = this.currentUser.user_id
	IF STATUS != 0 THEN
		LET this.errorMessage = "2)"||SQLERRMESSAGE
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION (this Users) delete(l_userId LIKE users.user_id) RETURNS BOOLEAN
	IF NOT db.connect() THEN EXIT PROGRAM END IF
	LET this.errorMessage = "User Deleted Okay."
	DELETE FROM users WHERE users.user_id = l_userId
	IF STATUS != 0 THEN
		LET this.errorMessage = "1)"||SQLERRMESSAGE
		RETURN FALSE
	END IF
	DELETE FROM userdetails WHERE userdetails.user_id = l_userId
	IF STATUS != 0 THEN
		LET this.errorMessage = "2)"||SQLERRMESSAGE
		RETURN FALSE
	END IF
	RETURN TRUE
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