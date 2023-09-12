SELECT * FROM Housing_Data_Cleaning


----------------------------------------
--Change Date Format From (SaleDate) 
----------------------------------------


SELECT Sales_date FROM  Housing_Data_Cleaning

SELECT SaleDate ,CONVERT(date,SaleDate)
FROM Housing_Data_Cleaning

update Housing_Data_Cleaning
SET Sales_date = CONVERT(date,SaleDate)

ALTER TABLE Housing_Data_Cleaning
ADD Sales_date date


----------------------------------------------------
--Pooulate Property Address data
----------------------------------------------------

SELECT [UniqueID ],ParcelID,PropertyAddress FROM Housing_Data_Cleaning
--where PropertyAddress is null

SELECT a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress 
FROM Housing_Data_Cleaning a join Housing_Data_Cleaning b 
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE  a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Housing_Data_Cleaning a join Housing_Data_Cleaning b 
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


----------------------------------------------------------------------------------------------------------------------
-- Breaking Out Address into Individual Columns From this(PropertyAddress,OwnerAddress) To This (Address, City, State)
----------------------------------------------------------------------------------------------------------------------


SELECT PropertyAddress from Housing_Data_Cleaning

SELECT SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) ,
SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)  )
       
FROM Housing_Data_Cleaning


ALTER TABLE Housing_Data_Cleaning
add PropertySplitAddress nvarchar (255)

update Housing_Data_Cleaning
 set PropertysplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) 


ALTER TABLE Housing_Data_Cleaning
ADD PropertyCity nvarchar(255)


update Housing_Data_Cleaning
SET PropertySplitCity = SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)  )

----Split Owner Address

SELECT OwnerAddress from Housing_Data_Cleaning

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Housing_Data_Cleaning


ALTER TABLE Housing_Data_Cleaning
add OwnerSplitAddress nvarchar(255)

update Housing_Data_Cleaning
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER table Housing_Data_Cleaning
add OwnerCity nvarchar(255)


update Housing_Data_Cleaning
set OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER table Housing_Data_Cleaning
ADD OwnerState nvarchar(255)


update Housing_Data_Cleaning
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * from Housing_Data_Cleaning

-----------------------------------------------------------------
--- change Y and N to Yes and No in "sold as vacation" field
-----------------------------------------------------------------



SELECT SoldAsVacant ,COUNT(SoldAsVacant)
FROM Housing_Data_Cleaning
Group by SoldAsVacant
order by 2 

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from Housing_Data_Cleaning

UPDATE Housing_Data_Cleaning

SET SoldAsVacant = 
CASE   WHEN SoldAsVacant = 'Y' THEN 'Yes' 
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



---------------------------------------
--- Remove Duplicates Using CTE
---------------------------------------



SELECT * FROM Housing_Data_Cleaning

WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, salePrice, Sales_date, legalReference
               ORDER BY Uniqueid
           ) AS ROW_Num
    FROM Housing_Data_Cleaning
)
--DELETE 
--FROM RowNumCTE
--WHERE ROW_Num > 1
--ORDER BY ParcelID
SELECT *  
FROM RowNumCTE
WHERE ROW_Num > 1
ORDER BY ParcelID



-----------------------------------------------
-- Delete Unused Column
-----------------------------------------------


ALTER TABLE Housing_Data_Cleaning
DROP COLUMN saleDate

ALTER TABLE Housing_Data_Cleaning
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict  