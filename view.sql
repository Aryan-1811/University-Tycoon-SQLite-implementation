CREATE VIEW leaderboard AS
SELECT 
    Players.Name AS name,
    
    -- Convert the current location to snake_case
    LOWER(REPLACE(Location.Name, ' ', '_')) AS "location",
    
    -- Display the player's credit balance
    Players.Credits AS credits,
    
    -- List of unique buildings owned by the player in snake_case, ordered clockwise
    (SELECT GROUP_CONCAT(LOWER(REPLACE(loc.Name, ' ', '_')) ORDER BY loc.Location_ID ASC, ' , ')
     FROM Buildings b
     JOIN Location loc ON b.Location_ID = loc.Location_ID
     WHERE b.Owner = Players.Player_ID) AS "buildings"

FROM 
    Players
JOIN 
    Location ON Players."Location" = Location.Location_ID

-- Order by net worth in descending order
ORDER BY 
    Credits DESC;

