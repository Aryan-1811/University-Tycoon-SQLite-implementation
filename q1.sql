INSERT INTO Dice (Player_ID, Roll_No, Roll_Value) VALUES
	((SELECT Player_ID FROM Players WHERE Name='Gareth'),1,4);

UPDATE Players
SET "Location" = (
    SELECT MIN(Location_ID)
    FROM Location
    WHERE "Order" = (
        (SELECT "Order" FROM Location WHERE location_id = "Location") + 4)
		% (SELECT MAX("Order") FROM Location)  -- loop around if necessary
)
WHERE Name = 'Gareth';