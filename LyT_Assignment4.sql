/* Thy Khue Ly */
USE Chinook

/* 1. Display all tracks from the Track table and their associated media type name 
from the MediaType table. (3503 rows)
Create two derived columns called MediaType and EncodingFormat.
Call the Track.Name column TrackName and the MediaType.Name column MediaName.
The result set will have 4 columns: TrackName, MediaName, MediaType and EncodingFormat
For MediaType if the media is a video then display "Video" otherwise display "Audio".
For EncodingFormat if the media name contains AAC then display "AAC", if it contains MPEG
then display "MPEG" otherwise display "Unknown".
*/

SELECT T.Name TrackName
, MT.Name MediaName
, CASE  
	 WHEN MT.Name LIKE '%video%' THEN 'Video'
	 ELSE 'Audio' 
	 END as MediaType
, CASE 
	WHEN MT.Name LIKE '%AAC%' THEN 'AAC'
	WHEN MT.Name LIKE '%MPEG%' THEN 'MPEG'
	ELSE 'Unknown'
	END as EncodingFormat

FROM Track T 
	LEFT JOIN MediaType MT
	ON T.MediaTypeId = MT.MediaTypeId


/* 2. Display the total track count for each Media type. (5 rows)
The result set will have 2 columns: MediaTypeName, TotalTracks.
Hint: The TotalTracks for an MPEG audio file should equal 3034.
*/
SELECT MT.Name MediaTypeName
, COUNT(T.TrackId) TotalTracks
FROM Track T 
	LEFT JOIN MediaType MT
	ON T.MediaTypeId = MT.MediaTypeId
GROUP BY MT.Name

/* 3. Sum the total sales for each Sales Support Agent grouped by year. (15 rows)
The result set should have 4 columns: FirstName, LastName, SaleYear, TotalSales.
Use Invoice.Total for TotalSales and Invoice.InvoiceDate for SaleYear.
Hint: You should return 15 rows. The TotalSales for Steve Johnson in 2009 should equal 164.34.
*/
SELECT E.FirstName
, E.LastName
, YEAR(I.InvoiceDate) SaleYear
, SUM (I.Total) TotalSales 

FROM Employee E
	JOIN Customer C  ON C.SupportRepId = E.EmployeeId
	JOIN Invoice I ON I.CustomerId = C.CustomerId
	
GROUP BY E.FirstName, E.LastName, YEAR(I.InvoiceDate)

/* 4. Display the highest amount paid by each customer for a single invoice. (59 rows)
The result set should have 3 columns: LastName, FirstName and MaxInvoice.
MaxInvoice should be derived from the Invoice.Total column.
Hint: Fynn Zimmermann's MaxInvoice should be 14.91.
*/
SELECT C.LastName
, C.FirstName
, MAX(Total) as MaxInvoice
FROM Customer C
	LEFT JOIN Invoice I ON I.CustomerId = C.CustomerId
GROUP BY C.LastName, C.FirstName

/* 5. Check customer postal codes to determine if they are numeric. (59 rows)
The result set should have 3 columns: Country, PostalCode and NumericPostalCode.
NumericPostalCode is a derived column.
If the PostalCode column has a numeric value then return "Yes".
If it does not have a numeric value then return "No".
If the PostalCode column has a NULL value then return "Unknown".
Order the results by NumericPostalCode and Country.
*/
SELECT Country
, PostalCode
, CASE
WHEN PostalCode IS NOT NULL THEN 
	CASE WHEN ISNUMERIC(PostalCode)=1 THEN 'Yes'
		 WHEN ISNUMERIC(PostalCode)=0 THEN 'No'
		 END
WHEN PostalCode IS NULL THEN 'Unknown'
END NumericPostalCode
FROM Customer 
ORDER BY NumericPostalCode, Country

/* 6. Find the customers whose total purchases are greater than 42 dollars. (10 rows)
The result set should have 3 columns: FirstName, LastName, TotalSales.
TotalSales is derived from the Invoice table.
*/
SELECT C.FirstName
, C.LastName
, SUM(Total) TotalSales
FROM Customer C
LEFT JOIN Invoice I ON C.CustomerId = I.CustomerId 
GROUP BY C.FirstName, C.LastName
HAVING Sum(Total) > 42

/* 7. Which artist has the most tracks in the database? (1 row)
The result set should contain 1 column named TopArtist, and 1 row with the name of the artist.
(Note: Don't hard code the answer. I need to see the query logic.)
*/
 SELECT Name
FROM  ( SELECT Max(NumTracks)
		FROM ( SELECT A.Name, COUNT(*) as NumTracks
				FROM Artist A
						LEFT JOIN Album AB ON AB.ArtistId = A.ArtistId
						LEFT JOIN Track T ON T.AlbumId = AB.AlbumId 
				GROUP BY A.Name ) TrackCount ) as 
( SELECT A.Name, COUNT(*) as NumTracks
	FROM Artist A
	LEFT JOIN Album AB ON AB.ArtistId = A.ArtistId
	LEFT JOIN Track T ON T.AlbumId = AB.AlbumId 
				GROUP BY A.Name ) TrackCount 


/* 8. Assign customers to groups using a derived column named CustomerGrouping. (59 rows)
The result set will have 3 columns: FirsName, LastName and CustomerGrouping.
Customers with a last name starting with A-G will be assigned to Group1.
Customers with a last name starting with H-M will be assigned to Group2.
Customers with a last name starting with N-S will be assigned to Group3.
Customers with a last name starting with T-Z will be assigned to Group4.
If there is no last name then the CustomerGrouping column should return NULL.
*/
SELECT FirstName
, LastName
, CASE 
WHEN LastName LIKE '[A-G]%' THEN 'Group1'
WHEN LastName LIKE '[H-M]%' THEN 'Group2'
WHEN LastName LIKE '[N-S]%' THEN 'Group3'
WHEN LastName LIKE '[T-Z]%' THEN 'Group4'
END CustomerGrouping
FROM Customer

/* 9. List all the artists and a count of how many albums each artist has in the database. (275 rows)
The result set will have 2 columns: ArtistName and AlbumCount.
Order the results by AlbumCount and ArtistName.
*/
SELECT A.Name ArtistName
, COUNT(*) as AlbumCount
FROM Artist A
	LEFT JOIN Album AB ON AB.ArtistId = A.ArtistId
GROUP BY A.Name
	

/* 10. Place employees in departments based on their title. (8 rows)
The result set will have 4 columns: FirstName, LastName, Title and Department.
Department is derived column with the following criteria:
If an employee's title contains "Sales" then their department is "Sales".
If an employee's title contains "IT" then their department is "Technology".
If an employee's title contains "Manager" then their department is "Management".
The Management department will override Sales and Technology for employee placement.
Order your results by Department.*/ 
SELECT FirstName
, LastName
, Title
, CASE 
	WHEN Title LIKE '%Manager%' THEN 'Management' 
	WHEN Title LIKE '%Sales%' THEN 'Sales'
	WHEN Title LIKE '%IT%' THEN 'Technology'  
	END	as Department
FROM Employee
ORDER BY Department 
