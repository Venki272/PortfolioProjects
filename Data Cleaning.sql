/***** Cleaning Data in SQL Queries *****/

--Select * from PortfolioProject.dbo.HousingData;

--------------------------------------------------------------------------------------------------------------------------

--STANDARDIZE DATE FORMAT
ALTER TABLE HousingData 
Add SaleDateConverted Date;

Update HousingData
SET SaleDateConverted = CONVERT(Date,SaleDate);

--------------------------------------------------------------------------------------------------------------------------

--POPULATE PROPERTY ADDRESS DATA
Select * from PortfolioProject.dbo.HousingData
--where PropertyAddress is null
order by ParcelID;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject.dbo.HousingData a
JOIN PortfolioProject.dbo.HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null;

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.HousingData a
JOIN PortfolioProject.dbo.HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null;

--------------------------------------------------------------------------------------------------------------------------

--BREAKING PROPERTY ADDRESS AND OWNER ADDRESS INTO MULTIPLE COLUMNS (ADDRESS,CITY,STATE)
Select PropertyAddress
from PortfolioProject.dbo.HousingData;
--where PropertyAddress is null
--order by ParcelID

SELECT
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address1
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address2
from PortfolioProject.dbo.HousingData;

ALTER TABLE HousingData
Add PropertySplitAddress Nvarchar(255); --[new column to store address]

Update HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );

ALTER TABLE HousingData
Add PropertySplitCity Nvarchar(255); --[new column to store city]

Update HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));

--Select * from PortfolioProject.dbo.HousingData;

Select OwnerAddress
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from PortfolioProject.dbo.HousingData;

ALTER TABLE HousingData
Add OwnerSplitAddress Nvarchar(255);

Update HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

ALTER TABLE HousingData
Add OwnerSplitCity Nvarchar(255);

Update HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

ALTER TABLE HousingData
Add OwnerSplitState Nvarchar(255);

Update HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

--Select * from PortfolioProject.dbo.HousingData;

--------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field
Select SoldAsVacant, Count(SoldAsVacant)
from PortfolioProject.dbo.HousingData
Group by SoldAsVacant
order by 2;

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from PortfolioProject.dbo.HousingData;

Update HousingData
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

--IDENTIFY DUPLICATES
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
					  ) row_num
from PortfolioProject.dbo.HousingData
--order by ParcelID
)
Select *
--Delete
from RowNumCTE
where row_num > 1
Order by PropertyAddress;

--Select * from PortfolioProject.dbo.HousingData;

---------------------------------------------------------------------------------------------------------

--DELETE UNUSED COLUMNS
Select * from PortfolioProject.dbo.HousingData;

ALTER TABLE PortfolioProject.dbo.HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--Importing Data using BULK INSERT	
/*
USE PortfolioProject;
GO
BULK INSERT HousingData from 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
   WITH (
      FIELDTERMINATOR = ',',
      ROWTERMINATOR = '\n'
);
GO
*/