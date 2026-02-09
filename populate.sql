-- Insert Tokens
INSERT INTO Tokens (Name) 
VALUES 
('Mortarboard'), ('Book'), ('Certificate'), ('Gown'), ('Laptop'), ('Pen');

-- Insert Locations
INSERT INTO Location (Name, Type, "Order") VALUES 
    ('Welcome Week', 'Corner', 1),
    ('Kilburn', 'Building', 2),
    ('IT', 'Building', 3),
    ('Hearing 1', 'Hearing', 4),
    ('Uni Place', 'Building', 5),
	('AMBS', 'Building', 6),
    ('RAG 1', 'RAG', 7),
    ('Visitor', 'Corner', 8),
	('Suspension', 'Corner', 8),
	('Crawford', 'Building', 9),
	('Sugden', 'Building', 10),
	('Ali G', 'Corner', 11),
	('Shopping Precinct', 'Building', 12),
	('MECD', 'Building', 13),
	('RAG 2', 'RAG', 14),
	('Library', 'Building', 15),
	('Sam Alex', 'Building', 16),
	('Hearing 2', 'Hearing', 17),
	('Your''e Suspended', 'Corner', 18),
	('Museum', 'Building', 19),
	('Whitworth Hall', 'Building', 20);

-- Insert Players
INSERT INTO Players (Name, Token, Credits, "Location") 
VALUES 
    ('Gareth', (SELECT Token_ID FROM Tokens WHERE Name = 'Certificate'), 345, (SELECT Location_ID FROM Location WHERE Name = 'Museum')),
    ('Uli', (SELECT Token_ID FROM Tokens WHERE Name = 'Mortarboard'), 590, (SELECT Location_ID FROM Location WHERE Name = 'Kilburn')),
    ('Pradyumn', (SELECT Token_ID FROM Tokens WHERE Name = 'Book'), 465, (SELECT Location_ID FROM Location WHERE Name = 'AMBS')),
    ('Ruth', (SELECT Token_ID FROM Tokens WHERE Name = 'Pen'), 360, (SELECT Location_ID FROM Location WHERE Name = 'Hearing 1'));
	
INSERT INTO Colour (Name) 
VALUES
('Green'), ('Orange'), ('Blue'), ('Brown'), ('Grey'), ('Black');
	
-- Insert Buildings
INSERT INTO Buildings (Location_ID, Tuition_Fee, Owner, "Colour")
VALUES
((SELECT Location_ID FROM Location WHERE Name = 'Kilburn'), 15, 
(SELECT Player_ID FROM Players WHERE Name = 'Ruth'), 
(SELECT Colour_ID FROM Colour WHERE Name = 'Green')),
((SELECT Location_ID FROM Location WHERE Name = 'IT'), 15,
(SELECT Player_ID FROM Players WHERE Name = 'Gareth'), 
(SELECT Colour_ID FROM Colour WHERE Name = 'Green')),
((SELECT Location_ID FROM Location WHERE Name = 'Uni Place'), 25,
(SELECT Player_ID FROM Players WHERE Name = 'Gareth'), 
(SELECT Colour_ID FROM Colour WHERE Name = 'Orange')),
((SELECT Location_ID FROM Location WHERE Name = 'AMBS'), 25,
(SELECT Player_ID FROM Players WHERE Name = 'Uli'), 
(SELECT Colour_ID FROM Colour WHERE Name = 'Orange')),
((SELECT Location_ID FROM Location WHERE Name = 'Crawford'), 30, 
(SELECT Player_ID FROM Players WHERE Name = 'Pradyumn'), 
(SELECT Colour_ID FROM Colour WHERE Name = 'Blue')),
((SELECT Location_ID FROM Location WHERE Name = 'Sugden'), 30,
(SELECT Player_ID FROM Players WHERE Name = 'Gareth'), 
(SELECT Colour_ID FROM Colour WHERE Name = 'Blue')),
((SELECT Location_ID FROM Location WHERE Name = 'Shopping Precinct'), 35, NULL, 
(SELECT Colour_ID FROM Colour WHERE Name = 'Brown')),
((SELECT Location_ID FROM Location WHERE Name = 'MECD'), 35, 
(SELECT Player_ID FROM Players WHERE Name = 'Uli'), 
(SELECT Colour_ID FROM Colour WHERE Name = 'Brown')),
((SELECT Location_ID FROM Location WHERE Name = 'Library'), 40,
(SELECT Player_ID FROM Players WHERE Name = 'Pradyumn'), 
(SELECT Colour_ID FROM Colour WHERE Name = 'Grey')),
((SELECT Location_ID FROM Location WHERE Name = 'Sam Alex'), 40, NULL, 
(SELECT Colour_ID FROM Colour WHERE Name = 'Grey')),
((SELECT Location_ID FROM Location WHERE Name = 'Museum'), 50,
(SELECT Player_ID FROM Players WHERE Name = 'Pradyumn'), 
(SELECT Colour_ID FROM Colour WHERE Name = 'Black')),
((SELECT Location_ID FROM Location WHERE Name = 'Whitworth Hall'), 50,
(SELECT Player_ID FROM Players WHERE Name = 'Ruth'), 
(SELECT Colour_ID FROM Colour WHERE Name = 'Black'));

-- Insert Specials
INSERT INTO Specials (Location_ID, Description, Action_Type, Action_Amount) VALUES 
    ((SELECT Location_ID FROM Location WHERE Name = 'Welcome Week'), 'You''ve landed on/passed Welcome Week. Awarded 100cr.', 'award', 100),
    ((SELECT Location_ID FROM Location WHERE Name = 'Hearing 1'), 'You are found guilty of academic malpractice. Fined 20cr.', 'fine', 20),	
    ((SELECT Location_ID FROM Location WHERE Name = 'RAG 1'), 'You win a fancy dress competition. Awarded 15cr.', 'award', 15),
	((SELECT Location_ID FROM Location WHERE Name = 'Suspension'), 'You are in suspension. Roll a six to get out of it', NULL, NULL),
    ((SELECT Location_ID FROM Location WHERE Name = 'Visitor'), 'You are just visiting.', NULL, NULL),
	((SELECT Location_ID FROM Location WHERE Name = 'Ali G'), 'You get free resting place in Ali G.', NULL, NULL),
    ((SELECT Location_ID FROM Location WHERE Name = 'RAG 2'), 'You receive a bursary and share it with your friends. Give all other players 10cr.', 'share', 10),
    ((SELECT Location_ID FROM Location WHERE Name = 'Hearing 2'), 'You are in rent arrears. Fined 25cr.', 'fine', 25),
	((SELECT Location_ID FROM Location WHERE Name = 'Your''e Suspended'), 'You are Suspended! You move to Suspension without passing the Welcome Week', NULL, NULL);

-- Insert Game Status
INSERT INTO GameStatus (Game_Round, Moves_In_Round) VALUES
	(1,0);
	
--Insert Audit Logs
INSERT INTO AuditTrail (Game_Round, Player, "Location", Credit_Balance) VALUES
    (0, (SELECT Player_ID FROM Players WHERE Name = 'Gareth'), 
	(SELECT "Location" FROM Players WHERE Name = 'Gareth'), 
	(SELECT Credits FROM Players WHERE Name = 'Gareth')),
    (0, (SELECT Player_ID FROM Players WHERE Name = 'Uli'), 
	(SELECT "Location" FROM Players WHERE Name = 'Uli'), 
	(SELECT Credits FROM Players WHERE Name = 'Uli')),
    (0, (SELECT Player_id FROM Players WHERE Name = 'Pradyumn'), 
	(SELECT "Location" FROM Players WHERE Name = 'Pradyumn'), 
	(SELECT Credits FROM Players WHERE Name = 'Pradyumn')),
    (0, (SELECT Player_id FROM Players WHERE Name = 'Ruth'), 
	(SELECT "Location" FROM Players WHERE Name = 'Ruth'), 
	(SELECT Credits FROM Players WHERE Name = 'Ruth'));

