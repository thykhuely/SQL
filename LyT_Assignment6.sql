USE Chinook
 
IF OBJECT_ID('Track_v_tkl') IS NOT NULL DROP VIEW Track_v_tkl
IF OBJECT_ID('ArtistAlbum_fn_tkl') IS NOT NULL DROP FUNCTION ArtistAlbum_fn_tkl
IF OBJECT_ID('TracksByArtist_p_tkl') IS NOT NULL DROP PROC TracksByArtist_p_tkl

/* 1. Create a new view called Track_v_[Your Initials].
Example: Track_v_edw
Add all Columns from the Track table to the view.
Add the Name column from the Genre table and call it GenreName.
Add the Name column from the MediaType table and call it MediaTypeName.
*/
GO
CREATE VIEW Track_v_tkl AS
SELECT T.*
, G.Name AS GenreName
, MT.Name AS MediaTypeName 
FROM Track T
JOIN Genre G
	ON T.GenreId = G.GenreId
JOIN MediaType MT
	ON T.MediaTypeId = MT.MediaTypeId

/* 2. Create a new function called ArtistAlbum_fn_[Your Initials]
Example: ArtistAlbum_fn_edw
The function will take a track ID as input and output the track’s artist and album.
The function will accept a single parameter called @TrackId with a datatype of int.
The function will return a single value with a datatype of varchar(100).
The Artist name and Album title will be concatenated into a single value with a dash in-between.
Hint: You will need to write a SELECT statement for the concatenate line. You will also need to
declare a variable in the function (I used the following: DECLARE @ArtistAlbum varchar(100) ).
*/ 
GO
CREATE FUNCTION ArtistAlbum_fn_tkl (@TrackId int)
RETURNS varchar(100)
AS
BEGIN
DECLARE @ArtistAlbum varchar(100)
SELECT
	@ArtistAlbum = CONCAT (A.Name,'-',Al.Title)
FROM Track T
LEFT JOIN Album Al ON Al.AlbumId = T.AlbumId
LEFT JOIN Artist A ON A.ArtistId = Al.ArtistId
RETURN @ArtistAlbum
END
 
/* 3. Create a new stored procedure called TracksByArtist_p_[Your Initals]
Example: TracksByArtist_p_edw
The procedure will need to return an Artist’s name as well as any album titles and track names
associated with the artist.
Include the following in the output: Artist name as ArtistName, album title as AlbumTitle, track
name as TrackName
The procedure will take a single parameter called @ArtistName with a datatype of varchar(100).
The procedure will do a search of the ArtistName column based on the value entered for the
parameter. Partial matches should be returned.
Hint: The WHERE clause should include a LIKE keyword as well as the @ArtistName parameter.
You may need to use concatenation in your WHERE clause.
*/
GO 
CREATE PROC TracksByArtist_p_tkl 
	@ArtistName varchar(100) AS
SELECT A.Name AS ArtistName
, Al.Title AS AlbumTitle
, T.Name AS TrackName
FROM Artist A
LEFT JOIN Album Al 
	ON A.ArtistId = Al.ArtistId
LEFT JOIN Track T 
	ON Al.AlbumId = T.AlbumId
WHERE A.Name LIKE CONCAT('%',@ArtistName,'%')

/* 4. Write a SELECT statement using the Track_v view_[Your Initals]. (2 rows)
Include the following columns from the view: Name, GenreName, MediaTypeName.
Add the Title column from the Album table.
Filter on the track name where the name equals “Babylon”.
*/
GO
SELECT Name
, GenreName
, MediaTypeName
, Album.Title
FROM Track_v_tkl
JOIN Album
	 ON Track_v_tkl.AlbumId = Album.AlbumId
WHERE Name = 'Babylon' 

/* 5. Write a SELECT statement using the Track_v_[Your Initals] view and
ArtistAlbum_fn_[Your Initals] function. (1 row)
The SELECT statement will have Track_v as the data source and include 2 columns.
The first column will contain the ArtistAlbum_fn function with TrackId as a parameter.
Name the first column “Artist and Album”.
The second column will be the track name column. Name it TrackName.
Filter the statement on GenreName equals “Opera”.
*/

SELECT 
dbo.ArtistAlbum_fn_tkl(TrackId) AS [Artist and Album]
, Name as TrackName
FROM Track_v_tkl
WHERE GenreName = 'Opera'

/* 6. Execute the TracksByArtist_p_[Your Initals] procedure twice.
Execute it once with a parameter of “black”. (56 rows)
Execute it once with a parameter of “white”. (1 row)
*/

EXEC TracksByArtist_p_tkl '%black%'
EXEC TracksByArtist_p_tkl '%white%'

/* 7. Alter the TracksByArtist_p_[Your Initals] procedure.
Give the @ArtistName parameter a default value of “Scorpions”.
*/ 
GO
ALTER PROC TracksByArtist_p_tkl
	@ArtistName varchar(100) = 'Scorpions' AS
SELECT A.Name AS ArtistName
, Al.Title AS AlbumTitle
, T.Name AS TrackName
FROM Artist A
LEFT JOIN Album Al
	ON A.ArtistId = Al.ArtistId
LEFT JOIN Track T 
	ON Al.AlbumId = T.AlbumId
WHERE A.Name LIKE CONCAT('%',@ArtistName,'%')

/* 8. Execute the TracksByArtist_p_[Your Initals]. (12 rows)
Execute the procedure without a parameter.
Hint: Your procedure should return data.
*/
GO
EXEC TracksByArtist_p_tkl

/* 9. Begin a Transaction and run an UPDATE statement.
Begin a transaction.
Update the LastName field in the Employee table to equal your last name.
Only update the record with an EmployeeId = 1.
*/

BEGIN TRANSACTION
UPDATE Employee
SET LastName = 'Ly'
WHERE EmployeeId = 1 

/* 10. View the results, rollback the transaction and view the results again. (2 rows total)
Display the EmployeeId and LastName from the Employee table where the ID equals 1.
Rollback the transaction you started in question #9.
Display the EmployeeId and LastName from the Employee table where the ID equals 1.
Hint: You should see different results.
*/
SELECT EmployeeId
, LastName
FROM Employee
WHERE EmployeeId = 1

ROLLBACK TRANSACTION

SELECT EmployeeId
, LastName
FROM Employee
WHERE EmployeeId = 1

