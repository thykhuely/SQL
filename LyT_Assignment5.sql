
IF DB_ID('MyDB_ThyKhueLy') IS NOT NULL DROP DATABASE MyDB_ThyKhueLy

/* Create a new database */ 
CREATE DATABASE MyDB_ThyKhueLy 

GO 
USE MyDB_ThyKhueLy  
/* Copy all records and columns from Customer table into the new table
	in the database called "User" */ 
SELECT * 
INTO Users
FROM Chinook.dbo.Customer


/* Delete all records in Users Table that have odd CustomerId number */
 DELETE Users
 WHERE (CustomerId % 2) =  1

 /* Update the Company Column in User table */
 UPDATE Users
 SET Company = CASE  
					WHEN Email LIKE '%gmail%' THEN 'Google'
					WHEN Email LIKE '%yahoo%' THEN 'Yahoo!'
					ELSE Company
					END	

 /* Rename Users CustomerId column to "UserId" */
 EXEC sp_rename 'Users.CustomerId', 'UserId', 'COLUMN'
 
 /* Add a Primary Key to the Users table, 
 use the UserId as primary key, name the key "pk_Users" */
 ALTER TABLE Users 
 ADD CONSTRAINT pk_Users PRIMARY KEY (UserId) 

 /* Create an Address table in the database */
 CREATE TABLE Address (
	 AddressId int IDENTITY(1,1) PRIMARY KEY
	 , AddressType varchar(10)
	 , AddressLine varchar(50)
	 , City varchar(30)
	 , State varchar(2)
	 , UserId int
	 , CreateDate datetime DEFAULT GETDATE() ) 

 /* Add a unique constraint to the Address Table */
 ALTER TABLE Address
 ADD CONSTRAINT uc_AddressType UNIQUE (AddressId, AddressType)
 
 /* Add a foreign key, which is the UserId in the Users table */
 ALTER TABLE Address
 ADD CONSTRAINT fk_UserAddress FOREIGN KEY (UserId) 
	 REFERENCES Users(UserId)

 /* Insert 3 recrods into the Address table */
 INSERT INTO Address (AddressType, AddressLine, City, State, UserId)
 VALUES 
	('home','111 Elm St.', 'Los Angeles', 'CA',2) 
	, ('home','222 Palm Ave.' , 'San Diego', 'CA',4)
	, ('work','333 Oak Ln.', 'La Jolla', 'CA',4) 
	  
 /* Select all records from the Address and Users table */
 SELECT *
 FROM Users
 
 SELECT *
 FROM Address

USE master