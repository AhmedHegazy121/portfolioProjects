-- Standardize SaleDate format
-- Convert SaleDate to a standard date format and store in a new column 'SaleDateconverted'
SELECT SaleDateconverted, CONVERT(date, SaleDate)
FROM PortfolioProject..NashvilleHouse;

-- Update SaleDate column to store the converted date
UPDATE NashvilleHouse
SET SaleDate = CONVERT(date, SaleDate);

-- Add new column 'SaleDateconverted' for the standardized date format
ALTER TABLE NashvilleHouse
ADD SaleDateconverted DATE;

-- Populate the 'SaleDateconverted' column with the converted date values
UPDATE NashvilleHouse
SET SaleDateconverted = CONVERT(date, SaleDate);

-- Fill missing PropertyAddress values by joining with the same table based on ParcelID
SELECT *
FROM PortfolioProject..NashvilleHouse
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

-- Join on the same table to find PropertyAddress from rows with matching ParcelID
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
       ISNULL(a.PropertyAddress, b.PropertyAddress) AS populateAddress
FROM PortfolioProject..NashvilleHouse a
JOIN PortfolioProject..NashvilleHouse b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Update missing PropertyAddress values based on matching ParcelID
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHouse a
JOIN PortfolioProject..NashvilleHouse b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Break down PropertyAddress into individual components: Address, City, State
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHouse;

-- Extract Address (before the first comma)
SELECT 
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHouse;

-- Add columns for split address components
ALTER TABLE NashvilleHouse
ADD PropertySplitAddress NVARCHAR(255);

-- Update PropertySplitAddress with the extracted Address part
UPDATE NashvilleHouse
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

-- Add column for PropertySplitCity
ALTER TABLE NashvilleHouse
ADD PropertySplitCity NVARCHAR(255);

-- Update PropertySplitCity with the extracted City part
UPDATE NashvilleHouse
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

-- Show all data from the NashvilleHouse table after changes
SELECT *
FROM PortfolioProject..NashvilleHouse;

-- Split OwnerAddress into Address, City, and State
SELECT OwnerAddress
FROM PortfolioProject..NashvilleHouse;

-- Use PARSENAME to split OwnerAddress (assuming it's comma-separated)
SELECT 
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM PortfolioProject..NashvilleHouse;

-- Add columns for OwnerAddress components
ALTER TABLE NashvilleHouse
ADD OwnerSplitAddress NVARCHAR(255);

-- Update OwnerSplitAddress with the Address part
UPDATE NashvilleHouse
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE NashvilleHouse
ADD OwnerSplitCity NVARCHAR(255);

-- Update OwnerSplitCity with the City part
UPDATE NashvilleHouse
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE NashvilleHouse
ADD OwnerSplitState NVARCHAR(255);

-- Update OwnerSplitState with the State part
UPDATE NashvilleHouse
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

-- Convert 'y'/'n' to 'yes'/'no' in SoldAsVacant column
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHouse
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
       CASE 
           WHEN SoldAsVacant = 'y' THEN 'yes'
           WHEN SoldAsVacant = 'n' THEN 'no'
           ELSE SoldAsVacant
       END
FROM PortfolioProject..NashvilleHouse;

-- Update SoldAsVacant column to replace 'y' with 'yes' and 'n' with 'no'
UPDATE NashvilleHouse
SET SoldAsVacant = CASE 
                       WHEN SoldAsVacant = 'y' THEN 'yes'
                       WHEN SoldAsVacant = 'n' THEN 'no'
                       ELSE SoldAsVacant
                   END;

-- Remove duplicates based on ParcelID, PropertyAddress, SalePrice, and LegalReference
WITH RowNumCte AS (
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, LegalReference ORDER BY UniqueID) AS row_num
    FROM PortfolioProject..NashvilleHouse
)
-- Delete duplicate rows (where row_num > 1)
DELETE FROM RowNumCte
WHERE row_num > 1;

-- Select and view duplicate rows before deletion
WITH RowNumCte AS (
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, LegalReference ORDER BY UniqueID) AS row_num
    FROM PortfolioProject..NashvilleHouse
)
SELECT *
FROM RowNumCte
WHERE row_num > 1
ORDER BY PropertyAddress;

-- Drop unused columns from the table
ALTER TABLE PortfolioProject..NashvilleHouse
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE PortfolioProject..NashvilleHouse
DROP COLUMN SaleDate;

-- Show final data after modifications
SELECT *
FROM PortfolioProject..NashvilleHouse;
