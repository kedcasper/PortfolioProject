/*
Cleaning Data in SQL Queries 
*/

SELECT *
FROM [dbo].[Nashville_Housing]


-- Standardize Date Format
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM [dbo].[Nashville_Housing]

UPDATE Nashville_Housing
SET SaleDate = CONVERT(Date,SaleDate)



-- Populate Property Address Data (for addresses that are null)
SELECT *
FROM [dbo].[Nashville_Housing]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [dbo].[Nashville_Housing] AS a
JOIN [dbo].[Nashville_Housing] AS b 
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID 
WHERE a.PropertyAddress IS NULL

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) 
FROM [dbo].[Nashville_Housing] AS a
JOIN [dbo].[Nashville_Housing] AS b 
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


-- Breaking out Address into Individual Columns (Address, City, State) 

SELECT PropertyAddress
FROM [dbo].[Nashville_Housing]

SELECT 
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS City
FROM [dbo].[Nashville_Housing]


--THIS CREATES NEW COLUMNS IN TABlE
ALTER TABLE Nashville_Housing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Nashville_Housing
SET PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Nashville_Housing
ADD PropertySplitCity NVARCHAR(255);

UPDATE Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT *
FROM [dbo].[Nashville_Housing]

SELECT OwnerAddress
FROM [dbo].[Nashville_Housing]

--USING PARSENAME to seperate Owner Address
SELECT 
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM [dbo].[Nashville_Housing]

--Now add the new columns and data to table
ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashville_Housing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Nashville_Housing
ADD OwnerSplitState NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM [dbo].[Nashville_Housing]


-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT 
    DISTINCT SoldAsVacant,
    COUNT(SoldAsVacant) AS Total_Count
FROM [dbo].[Nashville_Housing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END
FROM [dbo].[Nashville_Housing]

UPDATE Nashville_Housing
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END

-- Remove Dupilcates
WITH RowNumCTE AS( 
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID, 
                    PropertyAddress,
                    SalePrice, 
                    SaleDate,
                    LegalReference
                    ORDER BY
                        UniqueID
    ) AS Row_Num
FROM [dbo].[Nashville_Housing]
--ORDER BY ParcelID
)
--DELETE 
--FROM RowNumCTE 
--WHERE Row_Num > 1 
SELECT *
FROM RowNumCTE 
WHERE Row_Num > 1
--After running commented out section, ran the select all from table and there was none! No more duplicates


-- Delete Unused Columns
SELECT *
FROM [dbo].[Nashville_Housing]

ALTER TABLE [dbo].[Nashville_Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress



