/* Thy Khue Ly */
USE Chinook

/* 1. Join the Album and Track tables. (8 rows) 
Display the Album Title, Track Name and Milliseconds.  
Display Milliseconds as seconds and name it Seconds.
Filter where the title = "Let There Be Rock". 
*/ 
SELECT
Album.Title 
,Track.Name
,(Track.Milliseconds/1000) AS Seconds
FROM Album
JOIN Track
	ON Album.AlbumId = Track.AlbumId
WHERE Album.Title = 'Let There Be Rock'


/* 2. Use the Employee table. (8 rows) 
Concatenate the first and last name into new column called FullName. 
Display the Birthdate in 3 different columns called Day, Month and Year. 
The Month column value should be the full name of the month. 
*/
SELECT
CONCAT (FirstName, ' ', LastName) AS FullName
,DATEPART(DAY, BirthDate) AS Day
,DATENAME(month,DATEPART(MONTH, BirthDate)) AS Month
,DATEPART(YEAR, BirthDate) as Year
FROM Employee

/* 3. Return all Customers and the Employees who are their support reps.  (59 rows)
 Display Employee first and last name, Customer first and last name, and Customer country. 
 Concatenate the employee's first and last name with a space in between.  
 Call the column CustomerRep. 
 Concatenate the customer's first and last name with a space in between.  
 Call the column CustomerName. 
 Order by CustomerRep and the customer's Country. 
*/
SELECT
CONCAT(Employee.FirstName, ' ', Employee.LastName) AS CustomerRep
,CONCAT(Customer.FirstName, ' ', Customer.LastName) AS CustomerName
,Customer.Country
FROM Customer
LEFT JOIN Employee
	ON Customer.SupportRepId = Employee.EmployeeId
ORDER BY CustomerRep, Customer.Country


/* 4. Return all Track names, their Album titles, and any associated Invoice IDs. (3,759 rows) 
Display Album Title, Track Name, and InvoiceId. 
Display the Track Name even if it does not have an associated InvoiceId. 
(Note some Tracks may have more than one InvoiceId.) 
Order by Track Name and InvoiceId in descending order. 
*/
SELECT 
Track.Name
,Album.Title
,InvoiceLine.InvoiceId 
FROM Track
LEFT JOIN Album 
	ON Track.AlbumId = Album.AlbumId
LEFT JOIN InvoiceLine
	ON Track.TrackId = InvoiceLine.TrackId
ORDER BY Track.Name DESC, InvoiceId DESC


/* 5. Run a query with the following modifications to the Album Title column: (347 rows) 
Display Title with all the spaces removed. Name it TitleNoSpaces. 
Display Title in all upper case letters. Name it TitleUpperCase. 
Display Title in reverse order. Name it TitleReverse. 
Display the character length of the Title column Name it TitleLength. 
Display the starting position of the first space in the Title column. Name it SpaceLocation.  
*/
SELECT
REPLACE(Title,' ','') AS TitleNoSpaces
,UPPER(Title) AS TitleUpperCase
,REVERSE(Title) AS TitleReverse
,LEN(Title) AS TitleLength
,CHARINDEX(' ',Title) AS SpaceLocation
FROM Album

/* 6. Display the current age in years of Employees. (8 rows)
Display FirstName, LastName, BirthDate, and Age. 
Age is a column you will have to build from birthdate and the current date. 
Hint: This question is tougher than it looks. I will accept a close answer.  
*/
SELECT
FirstName
,LastName
,BirthDate
,IIF( DAY(BirthDate)< DAY(GetDate()) AND MONTH(BirthDate) < MONTH(GetDate()) ,
	DateDiff(YEAR, BirthDate, GetDate()), 
	DateDiff(YEAR, BirthDate, GetDate())-1) AS Age
FROM Employee

/* 7. Return all employees and the name of the person they report to. (8 rows) 
Display EmployeeId, LastName, FirstName, ReportsTo, ManagerName
Manager name is the concatenated first and last name of an employee's manager. 
If an employee doesn't have a manager then enter 'N/A' in the MangerName column. 
*/
SELECT
E.EmployeeId
,E.LastName
,E.FirstName
,IIF (Mgr.FirstName IS NULL, 'N/A', CONCAT(Mgr.FirstName, ' ', Mgr.LastName)) 
	AS ManagerName
FROM Employee E
LEFT JOIN Employee Mgr	
  ON E.ReportsTo = Mgr.EmployeeId

/* 8. Use the Employee table. (8 rows)
Display Title and ShortTitle. 
Short title is derived from the Title column but has the first word in the title removed. (e.g. "General Manager" becomes "Manager".)
Remove any leading spaces. 
*/ 
SELECT
Title
,LTRIM(RIGHT(Title, LEN(Title) - CHARINDEX(' ',Title))) AS ShortTitle
From Employee

/* 9. Return a customer's initials from his or her first and last name. (59 rows)
Display FirstName, LastName, Initials. 
Order the records by Initials. 
*/ 
SELECT
FirstName
,LastName
,CONCAT(LEFT(FirstName,1),Left(LastName,1)) AS Initials
FROM Customer
ORDER BY Initials

/* 10. Return all album tracks purchased by Julia Barnett. (38 rows)
 Display customer LastName, Album Title, Track Name, and Inventory InvoiceDate. 
 Display InvoiceDate in this format - dd/mm/yyyy - and rename the column PurchaseDate. 
 Order the records by InvoiceDate, Title and Name. Hint: Your result set should have 38 records.
 */
 SELECT
 Customer.LastName
 ,CONVERT(varchar,Invoice.InvoiceDate,101) AS PurchaseDate
 ,Album.Title
 ,Track.Name AS TrackName
 FROM Track
 LEFT JOIN InvoiceLine
	ON Track.TrackId = InvoiceLine.TrackId
 LEFT JOIN Invoice 
	ON InvoiceLine.InvoiceId = Invoice.InvoiceId 
 LEFT JOIN Customer
	ON Customer.CustomerId = Invoice.CustomerId
 LEFT JOIN Album
	ON Album.AlbumId = Track.AlbumId
 WHERE Customer.LastName = 'Barnett' AND Customer.FirstName = 'Julia' 