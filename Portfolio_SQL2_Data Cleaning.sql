use portfolio_2;

select * from nashvillehousing;

-- Standardize date format

select saledate, CONVERT(Date, Saledate)
from nashvillehousing;

update nashvillehousing
SET saledate = CONVERT(Date, Saledate);

ALTER TABLE nashvillehousing
ADD SaleDateConverted Date;

update nashvillehousing
SET SaleDateConverted = CONVERT(Date, Saledate);

-- Populate Property Address Data

select *
from nashvillehousing 
where PropertyAddress is NULL
order by parcelID;

select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.propertyaddress, b.propertyadress)
from nashvillehousing a
JOIN nashvillehousing b
   on a.parcelID = b.parcelID
   AND a.uniqueID <> b.uniqueID
where a.PropertyAddress is NULL;

update a
SET propertyaddress = ISNULL(a.propertyaddress, b.propertyadress)
From nashvillehousing a
JOIN nashvillehousing b
   on a.parcelID = b.parcelID
   AND a.uniqueID <> b.uniqueID
where a.PropertyAddress is NULL;

-- Breaking out Address into Individual columns (Address, City, State)

select OwnerAddress from nashvillehousing;

select
PARSENAME(REPLACE(OwnerAddress, ',' , '.' ), 3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.' ), 2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.' ), 1)
from nashvillehousing;

ALTER TABLE nashvillehousing
ADD OwnerSplitAddress nvarchar(255);

update nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3);

ALTER TABLE nashvillehousing
ADD OwnerSplitCity nvarchar(255);

update nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2);

ALTER TABLE nashvillehousing
ADD OwnerSplitState nvarchar(255);

update nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1);

select * from nashvillehousing;

-- Change Y and N to Yes and NO in "Sold as Vacant" field

select DISTINCT(soldasvacant), count(soldasvacant)
from nashvillehousing
group by soldasvacant
order by soldasvacant;

select soldasvacant,
  CASE
  when soldasvacant = 'Y' THEN 'YES'
  when soldasvacant = 'N' THEN 'NO'
  else soldasvacant
  END
from nashvillehousing;

update nashvillehousing 
SET soldasvacant =  CASE
  when soldasvacant = 'Y' THEN 'YES'
  when soldasvacant = 'N' THEN 'NO'
  else soldasvacant
  END;
  
  
-- Remove Duplicates

WITH RowNUmCTE as(
select *,
   ROW_NUMBER() OVER(
   PARTITION BY ParcelID,
                PropertyAddress,
                saleprice,
                saledate,
                legalreference
                ORDER BY
                  UniqueID) row_num
from nashvillehousing
-- order by ParcelID
)
DELETE from RowNumCTE
where row_num>1;

-- Delete Unused columns

select * from nashvillehousing;

ALTER TABLE Nashvillehousing
DROP COLUMN OwnerAddress;

ALTER TABLE Nashvillehousing
DROP COLUMN TaxDistrict;

