CREATE TABLE "Tokens" (
	"Token_ID"	INTEGER NOT NULL,
	"Name"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("Token_ID" AUTOINCREMENT)
);

CREATE TABLE "Location" (
	"Location_ID"	INTEGER NOT NULL,
	"Name"	TEXT NOT NULL UNIQUE,
	"Type"	TEXT NOT NULL,
	"Order"	INTEGER NOT NULL,
	PRIMARY KEY("Location_ID" AUTOINCREMENT)
);

CREATE TABLE "Players" (
	"Player_ID"	INTEGER NOT NULL,
	"Name"	TEXT NOT NULL,
	"Token"	INTEGER NOT NULL UNIQUE,
	"Credits"	INTEGER NOT NULL DEFAULT 100,
	"Location"	INTEGER NOT NULL,
	"Intermediate_Location"	INTEGER DEFAULT NULL,
	PRIMARY KEY("Player_ID" AUTOINCREMENT),
	FOREIGN KEY("Intermediate_Location") REFERENCES "Location"("Location_ID"),
	FOREIGN KEY("Location") REFERENCES "Location"("Location_ID"),
	FOREIGN KEY("Token") REFERENCES "Tokens"("Token_ID")
);

CREATE TABLE "Colour" (
	"Colour_ID"	INTEGER NOT NULL,
	"Name"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("Colour_ID" AUTOINCREMENT)
);

CREATE TABLE "Buildings" (
	"Building_Id"	INTEGER NOT NULL,
	"Location_ID"	INTEGER NOT NULL UNIQUE,
	"Tuition_Fee"	INTEGER NOT NULL,
	"Cost"	INTEGER NOT NULL GENERATED ALWAYS AS ("Tuition_Fee" * 2) STORED,
	"Owner"	INTEGER DEFAULT NULL,
	"Colour"	INTEGER NOT NULL,
	PRIMARY KEY("Building_Id" AUTOINCREMENT),
	FOREIGN KEY("Colour") REFERENCES "Colour"("Colour_ID"),
	FOREIGN KEY("Location_ID") REFERENCES "Location"("Location_ID"),
	FOREIGN KEY("Owner") REFERENCES "Players"("Player_ID")
);

CREATE TABLE "Specials" (
	"Location_ID"	INTEGER NOT NULL,
	"Description"	TEXT NOT NULL,
	"Action_Type"	TEXT CHECK(Action_Type IN ('fine', 'award', 'share')),
	"Action_Amount"	INTEGER,
	PRIMARY KEY("Location_ID"),
	FOREIGN KEY("Location_ID") REFERENCES "Location"("Location_ID")
);

CREATE TABLE "Dice" (
	"ID"	INTEGER NOT NULL,
	"Player_ID"	INTEGER NOT NULL,
	"Roll_No"	INTEGER,
	"Roll_Value"	INTEGER,
	PRIMARY KEY("ID" AUTOINCREMENT),
	FOREIGN KEY("Player_ID") REFERENCES "Players"("Player_ID")
);

CREATE TABLE "GameStatus" (
	"Game_Round"	INTEGER DEFAULT 1,
	"Moves_In_Round"	INTEGER DEFAULT 0
);

CREATE TABLE "AuditTrail" (
	"Log_ID"	INTEGER NOT NULL,
	"Player"	INTEGER NOT NULL,
	"Location"	INTEGER NOT NULL,
	"Credit_Balance"	INTEGER NOT NULL,
	"Game_Round"	INTEGER NOT NULL,
	PRIMARY KEY("Log_ID" AUTOINCREMENT),
	FOREIGN KEY("Player") REFERENCES "Players"("Player_ID")
);

CREATE TRIGGER after_passing_welcome_week
AFTER UPDATE OF "Location" ON Players
FOR EACH ROW
WHEN NEW."Location" = (SELECT Location_ID FROM Location WHERE Name = 'Welcome Week') 
     OR (OLD."Location" > NEW."Location" AND NEW."Location" != (SELECT Location_ID FROM Location WHERE Name = 'Suspension'))
BEGIN
    UPDATE Players 
    SET Credits = Credits + 100
    WHERE Player_ID = NEW.Player_ID;
END;

CREATE TRIGGER after_building_landing
AFTER UPDATE OF "Location" ON Players
FOR EACH ROW
WHEN (SELECT Type FROM Location WHERE Location_ID = NEW."Location") = 'Building'
BEGIN
    UPDATE Players
    SET Credits = CASE
        WHEN (SELECT Owner FROM Buildings WHERE Location_ID = NEW."Location") IS NULL
             AND NEW.Credits >= (SELECT Cost FROM Buildings WHERE Location_ID = NEW."Location")
        THEN Credits - (SELECT Cost FROM Buildings WHERE Location_ID = NEW."Location")
        WHEN (SELECT Owner FROM Buildings WHERE Location_ID = NEW."Location") != NEW.Player_ID
             AND (SELECT COUNT(*) FROM Buildings
                  WHERE Owner = (SELECT Owner FROM Buildings WHERE Location_ID = NEW."Location")
                  AND "Colour" = (SELECT "Colour" FROM Buildings WHERE Location_ID = NEW."Location")) 
             = (SELECT COUNT(*) FROM Buildings WHERE "Colour" = (SELECT "Colour" FROM Buildings WHERE Location_ID = NEW."Location"))
        THEN Credits - (SELECT Tuition_Fee * 2 FROM Buildings WHERE Location_ID = NEW."Location")
        WHEN (SELECT Owner FROM Buildings WHERE Location_ID = NEW."Location") != NEW.Player_ID
			AND (SELECT COUNT(*) FROM Buildings
				WHERE Owner = (SELECT Owner FROM Buildings WHERE Location_ID = NEW."Location")
					AND "Colour" = (SELECT "Colour" FROM Buildings WHERE Location_ID = NEW."Location")) 
				<(SELECT COUNT(*) FROM Buildings WHERE "Colour" = (SELECT "Colour" FROM Buildings WHERE Location_ID = NEW."Location"))
		THEN Credits - (SELECT Tuition_Fee FROM Buildings WHERE Location_ID = NEW."Location")
		ELSE Credits
    END
    WHERE Player_ID = NEW.Player_ID;
    -- Update the owner's credits if applicable
    UPDATE Players
    SET Credits = CASE
		WHEN(SELECT COUNT(*) FROM Buildings
			WHERE Owner = (SELECT Owner FROM Buildings WHERE Location_ID = NEW."Location")
				AND "Colour" = (SELECT "Colour" FROM Buildings WHERE Location_ID = NEW."Location")) 
            = (SELECT COUNT(*) FROM Buildings WHERE "Colour" = (SELECT "Colour" FROM Buildings WHERE Location_ID = NEW."Location"))
		THEN Credits + (SELECT Tuition_Fee*2 FROM Buildings WHERE Location_ID = NEW."Location")
		WHEN (SELECT COUNT(*) FROM Buildings
			WHERE Owner = (SELECT Owner FROM Buildings WHERE Location_ID = NEW."Location")
				AND "Colour" = (SELECT "Colour" FROM Buildings WHERE Location_ID = NEW."Location")) 
			<(SELECT COUNT(*) FROM Buildings WHERE "Colour" = (SELECT "Colour" FROM Buildings WHERE Location_ID = NEW."Location"))
		THEN Credits + (SELECT Tuition_Fee FROM Buildings WHERE Location_ID = NEW."Location")
		ELSE Credits
	END
    WHERE Player_ID = (SELECT Owner FROM Buildings WHERE Location_ID = NEW."Location")
		AND Player_ID != NEW.Player_ID;
	
	UPDATE Buildings
	SET Owner = CASE
		WHEN (SELECT Owner FROM Buildings WHERE Location_ID = NEW."Location") IS NULL
             AND NEW.Credits >= (SELECT Cost FROM Buildings WHERE Location_ID = NEW."Location")
		THEN NEW.Player_ID
		ELSE Owner
	END
	WHERE Location_ID = NEW."Location";
END;

CREATE TRIGGER after_youre_suspended
AFTER UPDATE OF "Location" ON Players
FOR EACH ROW
WHEN NEW."Location" = (SELECT Location_ID FROM Location WHERE Name = 'Your''e Suspended')
BEGIN
	UPDATE Players 
	SET "Location" = (SELECT Location_ID FROM Location WHERE Name = 'Suspension') 
	WHERE Player_ID = NEW.Player_ID;
END;

CREATE TRIGGER after_suspension_check
AFTER UPDATE OF "Location" ON Players
FOR EACH ROW
WHEN NEW."Location" = (SELECT Location_ID FROM Location WHERE Name = 'Suspension')
BEGIN
    UPDATE Players
    SET "Location" = (SELECT Location_ID FROM Location WHERE Name = 'Visitor')
    WHERE Player_ID = NEW.Player_ID
      AND (SELECT Roll_Value FROM Dice WHERE Player_ID = NEW.Player_ID ORDER BY "ID" DESC LIMIT 1) = 6;
END;

CREATE TRIGGER after_landing_on_special_location
AFTER UPDATE OF "Location" ON Players
FOR EACH ROW
WHEN (SELECT Type FROM Location WHERE Location_ID = NEW."Location") IN ('Hearing', 'RAG')
BEGIN
    -- Update credits based on the action type from the Specials table
    UPDATE Players
    SET Credits = CASE
        WHEN (SELECT Action_Type FROM Specials WHERE Location_ID = NEW."Location") = 'fine'
            THEN Credits - (SELECT Action_Amount FROM Specials WHERE Location_ID = NEW."Location")
        WHEN (SELECT Action_Type FROM Specials WHERE Location_ID = NEW."Location") = 'award'
            THEN Credits + (SELECT Action_Amount FROM Specials WHERE Location_ID = NEW."Location")
        WHEN (SELECT Action_Type FROM Specials WHERE Location_ID = NEW."Location") = 'share'
            THEN Credits - ((SELECT Action_Amount FROM Specials WHERE Location_ID = NEW."Location") * 
                            ((SELECT COUNT(*) FROM Players) - 1))
        ELSE Credits
    END
    WHERE Player_ID = NEW.Player_ID;

    -- Handle the 'share' action by distributing the action amount to other players
    UPDATE Players
    SET Credits = Credits + (SELECT Action_Amount FROM Specials WHERE Location_ID = NEW."Location")
    WHERE Player_ID != NEW.Player_ID
      AND (SELECT Action_Type FROM Specials WHERE Location_ID = NEW."Location") = 'share';
END;

CREATE TRIGGER update_game_round
AFTER UPDATE OF "Location" ON Players
FOR EACH ROW
BEGIN
    UPDATE GameStatus 
    SET Moves_In_Round = Moves_In_Round + 1;

    -- Check if all players have moved
    UPDATE GameStatus
    SET Moves_In_Round = 0, Game_Round = Game_Round + 1
	WHERE Moves_In_Round > (SELECT COUNT(*) FROM Players);
	INSERT INTO AuditTrail (Player, "Location", Credit_Balance, Game_Round)
    VALUES (NEW.Player_ID, NEW."Location", NEW.Credits, (SELECT Game_Round FROM GameStatus));
END;


