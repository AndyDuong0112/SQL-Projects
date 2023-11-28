/*

Cleaning Data in SQL Queries

*/
SELECT *
FROM [dbo].[NashvilleHousing];

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE [dbo].[NashvilleHousing]
ALTER COLUMN SaleDate date;

SELECT SaleDate
FROM [dbo].[NashvilleHousing];

--------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data

SELECT a.ParcelID, a.PropertyAddress, a.ParcelID, b.PropertyAddress
FROM [dbo].[NashvilleHousing] AS a
INNER JOIN [dbo].[NashvilleHousing] AS b
ON a.ParcelID = B.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[NashvilleHousing] AS a
INNER JOIN [dbo].[NashvilleHousing] AS b
ON a.ParcelID = B.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- PropertyAddress Column
SELECT PropertyAddress
FROM [dbo].[NashvilleHousing];

SELECT PropertyAddress
, SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1) AS [Address]
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) AS [City]
FROM [dbo].[NashvilleHousing];

ALTER TABLE [dbo].[NashvilleHousing]
ADD [Address] nvarchar(255);

UPDATE [dbo].[NashvilleHousing]
SET Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1);

ALTER TABLE [dbo].[NashvilleHousing]
ADD [City] nvarchar(255);

UPDATE [dbo].[NashvilleHousing]
SET City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress));

-- OwnerAddress Column
SELECT OwnerAddress
FROM [dbo].[NashvilleHousing];

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM [dbo].[NashvilleHousing];

ALTER TABLE [dbo].[NashvilleHousing]
ADD [Owner_Address] nvarchar(255);

UPDATE [dbo].[NashvilleHousing]
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress,',','.'), 3);

ALTER TABLE [dbo].[NashvilleHousing]
ADD [Owner_City] nvarchar(255);

UPDATE [dbo].[NashvilleHousing]
SET Owner_City = PARSENAME(REPLACE(OwnerAddress,',','.'), 2);

ALTER TABLE [dbo].[NashvilleHousing]
ADD [Owner_State] nvarchar(255);

UPDATE [dbo].[NashvilleHousing]
SET Owner_State = PARSENAME(REPLACE(OwnerAddress,',','.'), 1);

--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT SoldAsVacant
FROM [dbo].[NashvilleHousing];

SELECT
CASE 
	WHEN SoldAsVacant LIKE 'N' THEN 'No'
	WHEN SoldAsVacant LIKE 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END
FROM [dbo].[NashvilleHousing];

UPDATE [dbo].NashvilleHousing
SET SoldAsVacant = CASE 
						WHEN SoldAsVacant LIKE 'N' THEN 'No'
						WHEN SoldAsVacant LIKE 'Y' THEN 'Yes'
						ELSE SoldAsVacant
				   END;

-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
WITH CTE_table
AS (
SELECT *
, ROW_NUMBER() OVER (PARTITION BY ParcelID
								, PropertyAddress
								, SalePrice
								, SaleDate
								, LegalReference ORDER BY UniqueID) AS [duplicate_count]
FROM [dbo].[NashvilleHousing]);

SELECT *
FROM CTE_table
WHERE duplicate_count > 1;

DELETE FROM CTE_table
WHERE duplicate_count > 1;

---------------------------------------------------------------------------------------------------------
-- Delete Unused Columns ( OwnerAddress, TaxDistrict, PropertyAddress, SaleDate )

ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress
          , TaxDistrict
		  , PropertyAddress
		  , SaleDate;

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO

















