IMPORT util
IMPORT security
IMPORT FGL db
&include "../src/menus.inc"

PUBLIC TYPE Users RECORD
  list DYNAMIC ARRAY OF userRecord,
	currentUser UserRecord,
	currentUserDetails userDetailsRecord,
	errorMessage STRING
END RECORD
--------------------------------------------------------------------------------
--
PUBLIC FUNCTION (this Users) get(l_userId LIKE users.user_id) RETURNS BOOLEAN
	DEFINE x SMALLINT
	IF this.list.getLength() = 0 THEN CALL this.loadFromDB() END IF
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
--
PUBLIC FUNCTION (this Users) add() RETURNS BOOLEAN
	IF this.currentUser.user_id IS NULL OR this.currentUser.user_id = " " THEN
		LET this.errorMessage = "User Id invalid!"
		RETURN FALSE
	END IF
	IF this.get(this.currentUser.user_id) THEN
		LET this.errorMessage = "User Id already used!"
		RETURN FALSE
	END IF
	IF NOT db.connect() THEN EXIT PROGRAM END IF
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
	CALL this.loadFromDB()
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
--
PUBLIC FUNCTION (this Users) update() RETURNS BOOLEAN
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
--
PUBLIC FUNCTION (this Users) delete(l_userId LIKE users.user_id) RETURNS BOOLEAN
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
-- See if user_id already exists.
-- result is boolean:false=okay to use true=exists plus a suggestion.
PUBLIC FUNCTION (this Users) checkUserID(l_id  LIKE users.user_id) RETURNS (BOOLEAN, CHAR(6))
	DEFINE l_exists BOOLEAN = TRUE
	DEFINE l_suggestion CHAR(6) = "EXISTS"
	DEFINE l_cnt, l_len, x SMALLINT
	IF NOT db.connect() THEN EXIT PROGRAM END IF
	SELECT COUNT(*) INTO l_cnt FROM users WHERE user_id = l_id
	IF l_cnt = 0 THEN RETURN FALSE, "Okay" END IF
	LET l_len = LENGTH( l_id )
	FOR x = l_len TO 2 STEP -1
		IF l_id[x] >= "A" AND l_id[x] <= "Z" THEN
			EXIT FOR
		END IF
	END FOR
	LET l_len = x
	IF l_len < 6 THEN
		LET l_id[ l_len + 1, 6 ] = "%      "
		SELECT COUNT(*) INTO l_cnt FROM users WHERE user_id LIKE l_id
		LET l_suggestion = l_id[1, l_len]||l_cnt+1
	END IF
	RETURN l_exists, l_suggestion
END FUNCTION
--------------------------------------------------------------------------------
-- See if user_id already exists.
PUBLIC FUNCTION (this Users) register() RETURNS (INT, STRING)
	DEFINE l_stat SMALLINT = 0
	LET this.currentUser.user_id = this.currentUserDetails.user_id
	LET this.currentUser.user_name = this.currentUserDetails.firstnames CLIPPED||" "||this.currentUserDetails.surname
	LET this.currentUser.user_pwd = this.currentUserDetails.password_hash
	IF NOT this.add() THEN
		LET l_stat = 1
	END IF
	RETURN l_stat, this.errorMessage
END FUNCTION
--------------------------------------------------------------------------------
-- 
PUBLIC FUNCTION (this Users) setPasswordHash(l_pwd STRING)
	DEFINE l_salt STRING
	LET l_salt = security.BCrypt.GenerateSalt(10)
	LET this.currentUser.user_pwd = Security.BCrypt.HashPassword(l_pwd, l_salt)
	LET this.currentUserDetails.password_hash = this.currentUser.user_pwd
END FUNCTION
--------------------------------------------------------------------------------
--
FUNCTION (this Users) loadFromDB()
	DEFINE l_user userRecord
	IF NOT db.connect() THEN EXIT PROGRAM END IF
	CALL this.list.clear()
	DECLARE load_cur CURSOR FOR SELECT * FROM users
	FOREACH load_cur INTO l_user.*
		LET this.list[ this.list.getLength() + 1 ].* = l_user.*
	END FOREACH
END FUNCTION