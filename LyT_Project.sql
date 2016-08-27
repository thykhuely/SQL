/* Thy Khue Ly */ 
USE Chinook

/* 1. Provide a report displaying the 10 artists with the most sales 
from July 2011 through June 2012.
Do not include any video tracks in the sales. 
Display the Artist's name and the total sales for the year. 
Include ties for 10th if there are any. 
*/
SELECT ArtistName
, TotalSales
FROM
( SELECT A.Name ArtistName
, A.ArtistId
, SUM (IL.UnitPrice * IL.Quantity) TotalSales
, RANK() OVER (ORDER BY SUM (IL.UnitPrice * IL.Quantity) DESC) AS SalesRank
FROM Artist A
LEFT JOIN Album Al ON Al.ArtistId = A.ArtistId
	JOIN Track T ON T.AlbumId = Al.AlbumId
	JOIN InvoiceLine IL ON IL.TrackId = T.TrackId
	JOIN ( SELECT InvoiceDate, InvoiceId, BillingCountry
			FROM  Invoice 
			WHERE InvoiceDate >= '2011-07-01' AND InvoiceDate <= '2012-06-30' ) I 
			ON I.InvoiceId = IL.InvoiceId
GROUP BY A.Name, A.ArtistId ) RankbySales
WHERE SalesRank <= 10
ORDER BY TotalSales DESC

/* 2. Provide a report displaying the total sales for all Sales Support Agents grouped by year and
quarter. Include data from January 2010 through June 2012. Each year has 4 Sales Quarters
divided as follows:
Jan-Mar: Quarter 1
Apr-Jun: Quarter 2
Jul-Sep: Quarter 3
Oct-Dec: Quarter 4
The Sales Quarter column should display its values as First, Second, Third, Fourth. The data
needs to be ordered by the employee name, the fiscal year, and the sales quarter. The sales
quarter order should be numeric and not alphabetical (e.g. “Third” comes before “Fourth”).
*/  
SELECT CONCAT(E.FirstName, ' ', E.LastName) [Employee Name]
, YEAR(I.InvoiceDate) FiscalYear
, SalesQuarter
, MAX(I.Total) [Highest Sales]
, COUNT(I.Total) [Number of Sales]
, SUM(I.Total) [Total Sales]

FROM Employee E
LEFT JOIN Customer C ON C.SupportRepId = E.EmployeeId
LEFT JOIN 
	(SELECT Total
	, CustomerId
	, InvoiceDate
	, CASE
		WHEN (MONTH(I.InvoiceDate) >= 1 AND MONTH(I.InvoiceDate) <= 3) THEN 'First'
		WHEN (MONTH(I.InvoiceDate) >= 4 AND MONTH(I.InvoiceDate) <= 6) THEN 'Second'
		WHEN (MONTH(I.InvoiceDate) >= 7 AND MONTH(I.InvoiceDate) <= 9) THEN 'Third'
		ELSE 'Fourth'
		END AS SalesQuarter
	FROM Invoice I
	WHERE InvoiceDate >= '2010-01-01' AND InvoiceDate <= '2012-06-30') I 
	ON I.CustomerId = C.CustomerId

GROUP BY CONCAT(E.FirstName, ' ', E.LastName), YEAR(I.InvoiceDate), SalesQuarter

ORDER BY CONCAT(E.FirstName, ' ', E.LastName)
, YEAR(I.InvoiceDate)
, CASE SalesQuarter 
	WHEN 'First' THEN 1
	WHEN 'Second' THEN 2
	WHEN 'Third' THEN 3
	ELSE 4
	END

/* 3. The Sales Reps have discovered duplicate Playlists in the database. Some but not all of the
Playlists have Tracks associated with them. 
The duplicates have the same Playlist name, but have a higher Playlist ID. 
Write a report that displays the duplicate Playlist IDs and Playlist Names, as well as any associated Track IDs if they exist. 
Your result set will be marked for deletion so it must be accurate.
*/ 

SELECT OfficialPlayList.Name [Playlist Name]
, P.PlaylistId [Playlist ID]
, TrackId [Track ID]

FROM 
( SELECT P.Name
		, MIN(PlaylistId) AS MinId
		, COUNT(P.Name) as PlayistCount
	FROM Playlist P
	GROUP BY P.Name
	HAVING COUNT(P.Name) > 1) OfficialPlayList
LEFT JOIN Playlist P
	 ON (OfficialPlayList.Name = P.Name AND OfficialPlayList.MinId <> P.PlaylistId )
LEFT JOIN PlaylistTrack PT 
	ON PT.PlaylistId = P.PlaylistId

/* 4. Management would like to view Artist popularity by Country. 
Provide a report that displays the Customer country and the Artist name. 
Determine the total number of tracks sold by an artist to each country, and the total unique tracks by artist sold to each country. 
Include a column that shows the difference between the track count and the unique track count. 
Include the total revenue which will be the cost of the track multiplied by the number of tracks purchased.
Include a column that shows whether the tracks are audio or video (Hint: Videos have a
MediaTypeId =3). The range of data will be between July 2009 and June 2013. 
Order the results by Country, Track Count and Artist Name.
*/

SELECT BillingCountry Country
, A.Name [Artist Name]
, COUNT(IL.TrackId) [Track Count] 
, COUNT(DISTINCT T.Name) [Unique Track Count]
, COUNT(IL.TrackId) - COUNT(DISTINCT T.Name) [Count Difference]
, SUM(IL.Quantity * IL.UnitPrice) [Total Revenue]
, CASE 
	WHEN MT.Name LIKE '%audio%' THEN 'Audio'
	WHEN MT.Name LIKE '%video%' THEN 'Video'
	END AS [Media Type] 

FROM Artist A
  LEFT JOIN Album AL ON AL.ArtistId = A.ArtistId
  LEFT JOIN Track T ON T.AlbumId = AL.AlbumId
  LEFT JOIN MediaType MT ON T.MediaTypeId = MT.MediaTypeId
  JOIN InvoiceLine IL ON T.TrackId = IL.TrackId
  JOIN 
	( SELECT InvoiceDate, InvoiceId, BillingCountry
		FROM  Invoice 
		 WHERE InvoiceDate >= '2009-07-01' AND InvoiceDate <= '2013-06-30' ) I 
		ON I.InvoiceId = IL.InvoiceId

GROUP BY A.Name, BillingCountry, MT.Name
ORDER BY Country, [Track Count], [Artist Name]

/* 5. HR wants to plan birthday celebrations for all employees in 2016. They would like a list of
employee names and birth dates, as well as the day of the week the birthday falls on in 2016.
Celebrations will be planned the same day as the birthday if it falls on Monday through Friday. If
the birthday falls on a weekend then the celebration date needs to be set on the following
Monday. Provide a report that displays the above date logic. The column formatting needs to
be the same as in the example below. (Hint: This is a tough one. I used 7 different functions in
my solution. You will need to nest functions inside other functions. Don’t worry about
accounting for leap birthdays in your script.) 
*/

IF OBJECT_ID('BirthDate2016_fn') IS NOT NULL DROP FUNCTION BirthDate2016_fn
IF OBJECT_ID('DayOfWeek_fn') IS NOT NULL DROP FUNCTION DayOfWeek_fn
GO
CREATE FUNCTION BirthDate2016_fn (@BirthDate datetime)
RETURNS datetime
AS
BEGIN
DECLARE @day int, @month int   
SELECT  @day = DAY(@BirthDate), @month = MONTH(@BirthDate)
FROM Employee
RETURN DATEADD(day, @day-1, DATEADD(month, @month-1, DATEADD(year, 2016-1900, 0)))
END
GO 

GO 
CREATE FUNCTION DayOfWeek_fn (@date datetime)
RETURNS varchar(10)
AS
BEGIN
RETURN DATENAME(WEEKDAY,@date)
END
GO 

SELECT CONCAT(FirstName, ' ', LastName) FullName
, CONVERT(varchar,E.BirthDate,101) [Birth Date]
, CONVERT(varchar, dbo.BirthDate2016_fn(E.BirthDate),101) [Birth Day 2016]
, dbo.DayOfWeek_fn(dbo.BirthDate2016_fn(E.BirthDate)) [Birth Day of Week]
, CONVERT(varchar, E.[Celebration Date], 101) [Celebration Date]
, dbo.DayOfWeek_fn(dbo.BirthDate2016_fn(E.[Celebration Date])) [Celebration Day of Week]
FROM Employee
JOIN 
( SELECT EmployeeId
, BirthDate 
, CASE
	WHEN dbo.DayOfWeek_fn(dbo.BirthDate2016_fn(BirthDate)) = 'Saturday'
	THEN DATEADD(day,2, dbo.BirthDate2016_fn(BirthDate))
	WHEN dbo.DayOfWeek_fn(dbo.BirthDate2016_fn(BirthDate)) = 'Sunday'
	THEN DATEADD(day,1, dbo.BirthDate2016_fn(BirthDate))
	ELSE dbo.BirthDate2016_fn(BirthDate)
	END AS [Celebration Date]
  FROM Employee ) E ON E.EmployeeId = Employee.EmployeeId


/* 6. Management is interested in consolidating the Media Types and Genres offered. Specifically
they want to see which Genres and Media Types are underperforming in terms of Track sales.
Provide a report that groups Media Type and Genre. 
Include a column that shows the Unique Track Count of available tracks, 
as well as a column called Tracks Purchased Count that shows the count of tracks purchased. 
Include a column called Total Revenue for track purchases.
Include a column called Percentile dividing Track Purchases Count by Unique Track Count and
showing it as a percentile. 
Only include rows that have less than 10 in Total Revenue, or have a Percentile of less than 50. 
Order by Total Revenue in ascending order, Percentile in descending order, and Genre in ascending order.
*/ 

SELECT MT.Name [Media Type]
, G.Name Genre
, COUNT(DISTINCT T.TrackId) [Unique Track Count]
, SUM( CASE WHEN ( (IL.Quantity * IL.UnitPrice) > 0 
  AND (IL.Quantity * IL.UnitPrice) IS NOT NULL ) THEN 1 
  ELSE 0 END )  [Track Purchased Count] 
, CASE 
	WHEN SUM(IL.Quantity * IL.UnitPrice) IS NULL THEN 0 
	ELSE SUM(IL.Quantity * IL.UnitPrice) 
	END AS [Total Revenue]
, CAST ( 100 * ( CONVERT(DECIMAL(18,2), COUNT(IL.TrackId)) / 
	CONVERT(DECIMAL(18,2), COUNT(DISTINCT T.TrackId)) ) 
	AS DECIMAL(18,2) ) [Percentile]

FROM  Track T 
  LEFT JOIN Genre G ON G.GenreId = T.GenreId
  LEFT JOIN MediaType MT ON T.MediaTypeId = MT.MediaTypeId
  LEFT JOIN InvoiceLine IL ON T.TrackId = IL.TrackId

GROUP BY MT.Name, G.Name

HAVING  
( ( CAST ( 100 * ( CONVERT(DECIMAL(18,2), COUNT(IL.TrackId)) / 
	CONVERT(DECIMAL(18,2), COUNT(DISTINCT T.TrackId)) ) AS DECIMAL(18,2) ) < 50 ) 
	OR SUM(IL.Quantity * IL.UnitPrice) < 10 ) 

ORDER BY [Total Revenue] ASC, Percentile DESC, G.Name ASC