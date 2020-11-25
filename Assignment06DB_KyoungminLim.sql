--*************************************************************************--
-- Title: Assignment06
-- Author: Kyoungmin Lim
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2020-11-25,KyoungminLim,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_KyoungminLim')
	 Begin 
	  Alter Database [Assignment06DB_KyoungminLim] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_KyoungminLim;
	 End
	Create Database Assignment06DB_KyoungminLim;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_KyoungminLim;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5 pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
Go
Create 
View vCategories
WITH SCHEMABINDING
AS
Select CategoryID, CategoryName From [dbo].[Categories];
Go

Select * from Categories;
Select * from vCategories;

Go
Create
View vProducts
WITH SCHEMABINDING
AS
Select ProductID, ProductName, CategoryID, UnitPrice From [dbo].[Products];
Go

Select * from Products;
Select * from vProducts;

Go
Create
View vEmployees
WITH SCHEMABINDING
AS
Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From [dbo].[Employees]
Go

Select * from Employees;
Select * from vEmployees;

Go
Create
View vInventories
WITH SCHEMABINDING
AS
Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count] From [dbo].[Inventories]
Go

Select * from Inventories;
Select * from vInventories;

-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
Deny Select On Categories to public;
Grant Select On vCategories to public;

Deny Select On Products to public;
Grant Select on vProducts to public;

Deny Select on Employees to public;
Grant Select on vEmployees to public;

Deny Select on Inventories to public;
Grant select on vInventories to public;

-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00
Go 
Create
View vCategoryProducts
AS
Select TOP 1000000000
CategoryName, ProductName, UnitPrice from vCategories as C INNER JOIN vProducts as P
On C.CategoryID=P.CategoryID
Order By CategoryName, PRoductName;
Go

Select * from vCategoryProducts

-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83
Go 
Create
View vProductsInventories
AS
Select TOP 1000000000
ProductName, InventoryDate, [Count] from vProducts as P INNER JOIN vInventories as I
On P.ProductID=I.ProductID
Order By ProductName, InventoryDate, [Count];
Go

Select * from vProductsInventories

-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth
Go 
Create
View vInventoriesEmployees
AS
Select TOP 1000000000
InventoryDate,[EmployeeFirstName]+' '+[EmployeeLastName] as EmployeeName from vInventories as I INNER JOIN vEmployees as E
On I.EmployeeID=E.EmployeeID
Group By InventoryDate, EmployeeName;
Go

Select * from vInventoriesEmployees

Drop View vInventoriesEmployees

Go 
Create
View vInventoriesEmployees
AS
Select DISTINCT TOP 1000000000
InventoryDate,[EmployeeFirstName]+' '+[EmployeeLastName] as EmployeeName from vInventories as I INNER JOIN vEmployees as E
On I.EmployeeID=E.EmployeeID
Order By InventoryDate, EmployeeName;
Go

Select * from vInventoriesEmployees

-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54
Go
Create
View vCategoriesProductsInventories
AS
Select TOP 100000000
CategoryName, ProductName, InventoryDate, [Count] from vCategories as C 
INNER JOIN vProducts as P On C.CategoryID=P.CategoryID
INNER JOIN vInventories as I On P.ProductID=I.ProductID
Order by CategoryName, ProductName, InventoryDate, [Count];
Go

Select * from vCategoriesProductsInventories

-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan
Go
Create
View vCategoriesProductsInventoriesEmployees
AS
Select TOP 100000000
CategoryName, ProductName, InventoryDate, [Count], [EmployeeFirstName]+' '+[EmployeeLastName] as EmployeeName from vCategories as C 
INNER JOIN vProducts as P On C.CategoryID=P.CategoryID
INNER JOIN vInventories as I On P.ProductID=I.ProductID
INNER JOIN vEmployees as E On I.EmployeeID=E.EmployeeID
Order by InventoryDate, CategoryName, ProductName, EmployeeName;
Go

Select * from vCategoriesProductsInventoriesEmployees

-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King
Go
Create
View vCategoriesProductsInventoriesEmployeesChaiChang
AS
Select TOP 100000000
CategoryName, ProductName, InventoryDate, [Count], [EmployeeFirstName]+' '+[EmployeeLastName] as EmployeeName from vCategories as C 
INNER JOIN vProducts as P On C.CategoryID=P.CategoryID
INNER JOIN vInventories as I On P.ProductID=I.ProductID
INNER JOIN vEmployees as E On I.EmployeeID=E.EmployeeID
Where ProductName IN ('Chai', 'Chang')
Order by InventoryDate, CategoryName, ProductName, EmployeeName;
Go

Select * from vCategoriesProductsInventoriesEmployeesChaiChang

-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan
Go
Create
View vEmployeeManager
AS 
Select TOP 100000000
[Manager]=Mgr.EmployeeFirstName +' '+Mgr.EmployeeLastName, [Employee]=Emp.EmployeeFirstName +' '+Emp.EmployeeLastName
From vEmployees as Mgr inner join vEmployees as Emp
On Emp.ManagerID=Mgr.EmployeeID
Order by Manager, Employee
Go

Select * from vEmployeeManager

-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan
Go
Create
View vAllCategoriesProductsInventoriesEmployees
AS
Select TOP 100000000
C.CategoryID, CategoryName, P.ProductID, ProductName, UnitPrice, InventoryID, InventoryDate, [Count], E.EmployeeID, 
[Employee]=E.EmployeeFirstName +' '+E.EmployeeLastName, [Manager]=M.EmployeeFirstName +' '+M.EmployeeLastName 
from vCategories as C 
INNER JOIN vProducts as P On C.CategoryID=P.CategoryID
INNER JOIN vInventories as I On P.ProductID=I.ProductID
INNER JOIN vEmployees as E On I.EmployeeID=E.EmployeeID
INNER JOIN vEmployees as M On E.ManagerID=M.EmployeeID
Order by CategoryID, CategoryName, ProductID, ProductName,UnitPrice, InventoryID, InventoryDate, [Count], Employee, Manager;
Go

Select * from vAllCategoriesProductsInventoriesEmployees

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vCategoryProducts]
Select * From [dbo].[vProductsInventories]
Select * From [dbo].[vInventoriesEmployees]
Select * From [dbo].[vCategoriesProductsInventories]
Select * From [dbo].[vCategoriesProductsInventoriesEmployees]
Select * From [dbo].[vCategoriesProductsInventoriesEmployeesChaiChang]
Select * From [dbo].[vEmployeeManager]
Select * From [dbo].[vAllCategoriesProductsInventoriesEmployees]
/***************************************************************************************/