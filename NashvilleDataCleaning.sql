/* 

Cleaning Data in SQL Queries

*/

select * 
from PortfolioProject.dbo.NashvilleHousing;

---------------------------------------------

-- Standardize Date Format

select SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing;

-- this didn't workout

update NashvilleHousing
SET SaleDate = Convert(Date, SaleDate);


-- New Command


-- creating the column

alter table NashvilleHousing
Add SaleDateConverted Date;

-- updating the column with values

update NashvilleHousing
set SaleDateConverted = convert(Date, SaleDate);


-- Populate Property Address Data

select *
from PortfolioProject.dbo.NashvilleHousing
-- where PropertyAddress is Null
order by ParcelID


-- Using Self Join for this as parcel id is same for same address
-- ISNULL(check what is null, populate this with null)

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is Null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is Null


-- Breaking Out Address(Property and  Owner) into indiviual columns (Address, City, State)

-- Breaking Out property address

select propertyaddress
from PortfolioProject.dbo.NashvilleHousing

-- Using Substring as the PropertyAddress is divided by a ',' with address and city
-- CharIndex('value', Column) is used to locate the value and prints out the len from start

select substring(PropertyAddress, 1, CharIndex(',', PropertyAddress) -1) as Address,
substring(PropertyAddress, CharIndex(',', PropertyAddress) +1, Len(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
Add SplitAddress nvarchar(255);

update NashvilleHousing
set SplitAddress = substring(PropertyAddress, 1, CharIndex(',', PropertyAddress) -1);

alter table NashvilleHousing
Add PropertyCity nvarchar(255);

update NashvilleHousing
set PropertyCity = substring(PropertyAddress, CharIndex(',', PropertyAddress) +1, Len(PropertyAddress));

select *
from PortfolioProject.dbo.NashvilleHousing


-- Breaking Out Owner Address Not using Substring but using ParseName(replace(), LastValue)

select
parsename(replace(OwnerAddress, ',' , '.'), 3),
parsename(replace(OwnerAddress, ',' , '.'), 2),
parsename(replace(OwnerAddress, ',' , '.'), 1)
from PortfolioProject.dbo.NashvilleHousing;

alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress  = parsename(replace(OwnerAddress, ',' , '.'), 3)

alter table NashvilleHousing
Add OwnerCity nvarchar(255);

update NashvilleHousing
set OwnerCity = parsename(replace(OwnerAddress, ',' , '.'), 2)

alter table NashvilleHousing
Add OwnerState nvarchar(255);

update NashvilleHousing
set OwnerState= parsename(replace(OwnerAddress, ',' , '.'), 1)

select *
from PortfolioProject.dbo.NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
	   as NewSoldAsVacant
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

select *
from PortfolioProject.dbo.NashvilleHousing


-- Remove Duplication

-- Using windows functions
-- CTE : common table expression (CTE) is a temporary named result set that you can reference within a SELECT, INSERT, UPDATE, or DELETE statement. You can also use a CTE in a CREATE a view, as part of the view’s SELECT query. In addition, as of SQL Server 2008, you can add a CTE to the new MERGE statement. 

With RowNumCTE AS (
select *, 
	ROW_NUMBER() over (
	Partition by ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
				) row_num
from PortfolioProject.dbo.NashvilleHousing
-- order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
order by propertyaddress

-- Deleting Unused Columns

select *
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate
