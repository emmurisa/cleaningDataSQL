/*

Cleaning Data in SQL Queries

*/

Select *
From PortafolioProject.dbo.NasvilleHousing

------------------------------------------------------------------------------------------------------------------------------------

-- Standarize Date Format

Select SaleDateConverted, convert(date, SaleDate)
From PortafolioProject.dbo.NasvilleHousing

--Update NashvilleHousing
--SET SaleDate = Convert(date, SaleDate)

Alter table PortafolioProject.dbo.NasvilleHousing
Add SaleDateConverted date;

Update PortafolioProject.dbo.NasvilleHousing
SET SaleDateConverted = Convert(date, SaleDate)

------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortafolioProject.dbo.NasvilleHousing
Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortafolioProject.dbo.NasvilleHousing a
JOIN PortafolioProject.dbo.NasvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortafolioProject.dbo.NasvilleHousing a
JOIN PortafolioProject.dbo.NasvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortafolioProject.dbo.NasvilleHousing
--Where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))  as RestAddress
From PortafolioProject.dbo.NasvilleHousing

Alter table PortafolioProject.dbo.NasvilleHousing
Add PropertySplitAddress nvarchar(255);

Update PortafolioProject.dbo.NasvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter table PortafolioProject.dbo.NasvilleHousing
Add PropertySplitCity nvarchar(255);

Update PortafolioProject.dbo.NasvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))

Select PropertySplitAddress, PropertySplitCity
From PortafolioProject.dbo.NasvilleHousing


Select
parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',', '.'), 2),
parsename(replace(OwnerAddress, ',', '.'), 1)
From PortafolioProject.dbo.NasvilleHousing


--select OwnerAddress
--from PortafolioProject..NasvilleHousing


Alter table PortafolioProject.dbo.NasvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update PortafolioProject.dbo.NasvilleHousing
SET OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)



Alter table PortafolioProject.dbo.NasvilleHousing
Add OwnerSplitCity nvarchar(255);

Update PortafolioProject.dbo.NasvilleHousing
SET OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)



Alter table PortafolioProject.dbo.NasvilleHousing
Add OwnerSplitState nvarchar(255);

Update PortafolioProject.dbo.NasvilleHousing
SET OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)

Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
From PortafolioProject.dbo.NasvilleHousing


------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(soldAsVacant), count(soldAsVacant)
From PortafolioProject.dbo.NasvilleHousing
Group by SoldAsVacant
Order by 2




Select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
From PortafolioProject.dbo.NasvilleHousing


update PortafolioProject.dbo.NasvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end



------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE AS(
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

From PortafolioProject.dbo.NasvilleHousing
--order by ParcelID
)
--Delete 
--From RowNumCTE
--Where row_num > 1
--order by PropertyAddress

Select *
From RowNumCTE
Where row_num > 1
order by PropertyAddress


------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortafolioProject.dbo.NasvilleHousing

Alter table PortafolioProject.dbo.NasvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
