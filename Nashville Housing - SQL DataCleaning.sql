/****** Script for SelectTopNRows command from SSMS  ******/

-- Selecting top 100 rows
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousing]


-------------------------------------------------------------------------------------------------------------------------


-- Q1. Select all data from Table 
-- (dbo is schema)

select *from PortfolioProject.dbo.NashvilleHousing


-------------------------------------------------------------------------------------------------------------------------


--Q2. Missing data in a particular column

select *from PortfolioProject.dbo.NashvilleHousing where OwnerName IS NULL 

-------------------------------------------------------------------------------------------------------------------------


--Q3. Patterns associated with Missing Data

select *from PortfolioProject.dbo.NashvilleHousing where OwnerName IS NULL AND SalePrice > 100000


-------------------------------------------------------------------------------------------------------------------------


--Q4. Converting Data in SQL 

select SaleDate, CONVERT(date,SaleDate) as ConvertedSaleDate
from PortfolioProject.dbo.NashvilleHousing


-------------------------------------------------------------------------------------------------------------------------


--Q5. Change column name. It is temporary 

Update NashvilleHousing 
SET SaleDate = CONVERT (date,SaleDate)


-------------------------------------------------------------------------------------------------------------------------


--Q6. Adding a new column to table 

ALTER TABLE NashvilleHousing ADD SaleDateConverted Date


-------------------------------------------------------------------------------------------------------------------------


--Q7. Updating the newly added Column and adding values from a different column 

Update NashvilleHousing 
SET SaleDateConverted = CONVERT (date,SaleDate)


-------------------------------------------------------------------------------------------------------------------------


--Direct Method of changing SaleDate type to date

ALTER TABLE NashvilleHousing alter COLUMN SaleDate Date


-------------------------------------------------------------------------------------------------------------------------


--Q8. Populate property address
--Self Join
--Here Parcel ID is same but Unique ID is not same
--1st part is showing the null values where PropertyAddress is null
-- ISNULL will replace the a.PropertyAddress to b.PropertyAddress

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL ( a.PropertyAddress, b.PropertyAddress)
from 
PortfolioProject.dbo.NashvilleHousing a
JOIN
PortfolioProject.dbo.NashvilleHousing b 
ON
a.ParcelID = b.ParcelID
AND
a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 
 

-- 2nd Part is updating the data where PropertyAddress is null

UPDATE a
SET
a.PropertyAddress = ISNULL ( a.PropertyAddress, b.PropertyAddress)
from 
PortfolioProject.dbo.NashvilleHousing a
JOIN
PortfolioProject.dbo.NashvilleHousing b 
ON
a.ParcelID = b.ParcelID
AND
a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 


-------------------------------------------------------------------------------------------------------------------------


--Q9. Breaking out Property Address into Individual columns

--1 > Showing how to divide the tables 
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing


--2 >  Adding 2 columns to table and updating value 

   --column 1
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar (225)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) 


    --column 2
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar (225)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


-------------------------------------------------------------------------------------------------------------------------


--Q10.> Breaking out Owner Address into Individual columns

--1>
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar (225)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME ( REPLACE ( OwnerAddress, ',' , '.') , 3)

--2>
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar (225)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME ( REPLACE ( OwnerAddress, ',' , '.') , 2)

--3>
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar (225)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME ( REPLACE ( OwnerAddress, ',' , '.') , 1)


-------------------------------------------------------------------------------------------------------------------------


--Q11.> Replace Y & N to Yes and No 


select distinct (SoldAsVacant), COUNT (SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2 desc


Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
from PortfolioProject.dbo.NashvilleHousing


UPDATE  PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END


-------------------------------------------------------------------------------------------------------------------------


--Q12.> Remove duplicates 

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing


-------------------------------------------------------------------------------------------------------------------------


--Q13.>  Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
