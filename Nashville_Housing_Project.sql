/*

Cleaning Data ins SQL Queries

*/

USE NashvilleHousing_Project;

Select *
From dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate, SaleDateConverted, CONVERT(Date, SaleDate)
From dbo.NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


-----------------------------------------------------------------------------------------------------------

-- Populate Property Adress data

Select *
From dbo.NashvilleHousing
Where PropertyAddress Is Null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
Join dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
Join dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]




-----------------------------------------------------------------------------------------------------------

--Breaking out address into Individual Columns (adress, Cit, State)

Select PropertyAddress
From dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) As Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) As City
From dbo.NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


Alter Table NashvilleHousing
Add PorpertySplitCity Nvarchar (255)

Update NashvilleHousing
SET PorpertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- Owner Address with Parsename

Select OwnerAddress
From dbo.NashvilleHousing

Select 
Parsename(Replace(OwnerAddress, ',', '.'), 3) 
,Parsename(Replace(OwnerAddress, ',', '.'), 2)
,Parsename(Replace(OwnerAddress, ',', '.'), 1)
From dbo.NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar (255)

Update NashvilleHousing
SET OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar (255)

Update NashvilleHousing
SET OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar (255)

Update NashvilleHousing
SET OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1)


-----------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes an No in "Sold as Vacant"

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant
,CASE 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END
From dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = 
CASE 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END



-----------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER(
	Partition By	ParcelID,
				PropertyAddress,
				SalePrice,
				LegalReference
				Order By
				UniqueID
				) row_num
From dbo.NashvilleHousing
)

Delete
From RowNumCTE
Where row_num > 1

/*
Select *
From RowNumCTE
Where row_num > 1
*/


-----------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From dbo.NashvilleHousing

Alter Table dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate