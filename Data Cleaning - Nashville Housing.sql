/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM NashvilleHousing

-- Standardize Data Format

/*
	1. SaleDate has a value of Date and Time. So, we need to have only Date value on the SaleDate.
	2. Coverting the data with "Date" datatype
*/
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- Adding a new table called SaleDateConverted as "Date" DataType to the Nashville Housing Database
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

--Since "SaleDate" column in the database has a data with date and time. We are converting that specific data into "Date" format and updating it into a new column called "SaleDateConverted"
Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM NashvilleHousing


-- Populate Property Address Data

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

-- Self Joining the table to understand if the Parcel ID and PropertyAddress has the same data
-- RESULT: Looks like the database has "NULL" for approx 35 records in PropertyAddress and it's not getting populated even though there's a value on the PropertyAddress
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-- Here we created a column with the acutall populated PropertyAddress for ParcelID
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-- Updating the table
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)
-- Delimiter separates different columns or different values
-- PropertyAddress has a value of Address, City, and State
SELECT PropertyAddress
FROM NashvilleHousing

/*
We're querring just the address by using substring which starts from 1st position all the way to index which has "," value.
CHARINDEX(',', PropertyAddress) returns a number where it found ',' on the PropertyAddress. If we use -1, we can remove the ',' on our data.
*/
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
FROM NashvilleHousing

-- Populating City from PropertyAddress
/*
Substring(PropertyAddress) - get's the whole PropertyAddress and runs until it finds "," in the PropertyAddress.
CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress) - It removes the ',' from the PropertyAddress and runs till the length of the PropertyAddress. 
Then it takes the remaining value and creates a column to display the remaining value.
*/
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) AS City
FROM NashvilleHousing

/*
	1. Creating a new column called "PropertySplitAddress" with a nvarchar(255).
	2. Updating the value of creating column with just the PropertyAddress not city and state
*/
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

/*
	1. Creating a new column called "PropertySplitCity" with a nvarchar(255).
	2. Updating the value of creating column with just the PropertyCity not address and state
*/
ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


SELECT *
FROM NashvilleHousing


-- Same with OwnerAddress (Spliting up the Address, City, and State) using a PARSE NAME

SELECT OwnerAddress
FROM NashvilleHousing

/*
	1. PARSENAME - works only with a period value in the data.
	2. So, we are replacing the ',' with '.' for easy populating the OwnerAddress
	3. PARSENAME works kinda backwards. Inorder to get the table with Address, City, and State Column, we need to put 3, 2, 1
*/
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)
FROM NashvilleHousing

/*
	1. Creating a new column called "OwnerSplitAddress" with a nvarchar(255).
	2. Updating the value of creating column with just the OwnerAddress not city and state
*/
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3)

/*
	1. Creating a new column called "OwnerSplitCity" with a nvarchar(255).
	2. Updating the value of creating column with just the OwnerCity not address and state
*/
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2)

/*
	1. Creating a new column called "OwnerSplitState" with a nvarchar(255).
	2. Updating the value of creating column with just the OwnerState not address and City
*/
ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)

SELECT *
FROM NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant =	'N' THEN 'No'
						ELSE SoldAsVacant
						END

SELECT *
FROM NashvilleHousing



-- Remove Duplicates
/*
	1. When we have duplicate rows in the table, we need to be able to indentify those rows. [i.e] Rank, Order Rank, Row Number
*/

WITH RowNumberCTE AS
(
SELECT *,
ROW_NUMBER () OVER (
						PARTITION BY 
						ParcelId, PropertyAddress, SalePrice, SaleDate, LegalReference 
						ORDER BY UniqueID 
					) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumberCTE
WHERE row_num > 1
ORDER BY PropertyAddress


--- Delete Unused Columns

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate