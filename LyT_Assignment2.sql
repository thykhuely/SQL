/*Student Name: Thy Khue Ly*/
USE Chinook
/* 1. Display FirstName and LastName 
from the Employee table where the ReportsTo column isn't null.  (7 rows)  
*/ 
SELECT 
FirstName
,LastName
FROM Employee
WHERE ReportsTo IS NOT NULL

/* 2. Display all customers in the Customer table 
that do not live in the state California.  (56 rows)  
*/
SELECT * 
FROM Customer
WHERE (State <> 'CA') OR (State IS NULL)

/* 3. Display all records in the Invoice table 
that have an InvoiceDate between April 1st 2010 and May 1st 2010.  (7 rows) 
 */

SELECT * 
FROM Invoice
WHERE InvoiceDate BETWEEN '2010-04-01' AND '2010-05-01'

/* 4. Display the Title and AlbumId from the Album table 
where the title starts with the word "The".  (30 rows)  
*/
SELECT 
Title
,AlbumId
FROM Album
WHERE Title LIKE 'The%'

/* 5. Find all records from the Album table 
where the title doesn't start with the letters A through Z.  (3 rows)  
*/
SELECT * 
FROM Album
WHERE Title LIKE '[^A-Z]%' 

/* 6. Display CustomerId, BillingCity, BillingCountry and InvoiceDate 
from the Invoice table where the BillingCountry is equal to Canada, Germany, France, Spain or India.  
Order the records by InvoiceDate in descending order.  (139 rows)  
*/
SELECT
CustomerId
,BillingCity
,BillingCountry
,InvoiceDate
FROM Invoice
WHERE BillingCountry IN ('Canada', 'Germany', 'France', 'Spain', 'India')
ORDER BY InvoiceDate DESC

/* 7. Display all records in the Album table 
where the artist associated with the album has a name containing the word "Black". 
Hint: You will need to use the Artist table. (6 rows)  
*/
SELECT * 
FROM Album
WHERE ArtistId IN(
	SELECT ArtistId
	FROM Artist
	WHERE Name LIKE '%Black%')

/* 8. Display all records in the Track table 
that do not have an invoice. 
Hint: You will need to use the InvoiceLine table. (1519 rows)  
*/
SELECT *
FROM Track 
WHERE NOT EXISTS (
	SELECT *
	FROM InvoiceLine 
	WHERE Track.TrackId =  InvoiceLine.TrackId)

/* 9. Display all records 
from the Track table where the MediaTypeId equals 5 and the GenreId is not equal to 1, 
or the Composer is Gene Simmons. (16 rows)  
*/
SELECT *
FROM Track
WHERE (MediaTypeId = 5 AND GenreId <> 1) OR Composer = 'Gene Simmons'

/* 10. Display all records 
from the Track table where the AlbumId equals 237 
and the Composer column contains the name Dylan or Hendrix.  (3 rows) 
*/
SELECT *
FROM Track
WHERE AlbumID = 237 AND 
	 (Composer LIKE '%Dylan%' OR Composer LIKE '%Hendrix%')