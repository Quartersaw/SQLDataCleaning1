-- Data Cleaning using SQL

select *
from PortfolioProject..NashvilleHousing;

-- Convert the SaleDate column from DateTime to Date
alter table PortfolioProject..NashvilleHousing
alter column SaleDate date;

-- Check for null values in PropertyAddress
select *
from PortfolioProject..NashvilleHousing
where PropertyAddress is null;

-- Each property's ParcelID and PropertyAddress are linked.
-- Because of this, ParcelID's from subsequent sales can be used to find the corresponding address.
select *
from PortfolioProject..NashvilleHousing
where ParcelID in (
	select ParcelID
	from PortfolioProject..NashvilleHousing
	where PropertyAddress is null);

update a
set PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress )
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null;

-- Breaking the PropertyAddress up into street and city columns using the comma as a delimiter.
alter table PortfolioProject..NashvilleHousing
add PropertyCity nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertyCity = SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

update PortfolioProject..NashvilleHousing
set PropertyAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

-- Breaking the OwnerAddress into street, city and state columns using ParseName().
alter table PortfolioProject..NashvilleHousing
add OwnerState varchar(255);

update PortfolioProject..NashvilleHousing
set OwnerState = PARSENAME( replace(OwnerAddress, ',', '.'), 1 );

alter table PortfolioProject..NashvilleHousing
add OwnerCity varchar(255);

update PortfolioProject..NashvilleHousing
set OwnerCity = PARSENAME( replace(OwnerAddress, ',', '.'), 2 );

update PortfolioProject..NashvilleHousing
set OwnerAddress = PARSENAME( replace(OwnerAddress, ',', '.'), 3 );

-- SoldAsVacant currently has both 'y', 'yes', 'n' & 'no' entries that should be consolidated.
select distinct SoldAsVacant, count(soldasvacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant;

update PortfolioProject..NashvilleHousing
set SoldAsVacant =	case when SoldAsVacant = 'Y' then 'Yes'
						when SoldasVacant = 'N' then 'No'
						else SoldAsVacant
					end;

-- Remove duplicates.
with RowNumCTE as(
select *, ROW_NUMBER() over( partition by parcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID ) as RowNumber
from  PortfolioProject..NashvilleHousing
)
delete
from RowNumCTE
where RowNumber > 1;

-- Delete unused columns
alter table PortfolioProject..NashvilleHousing
drop column TaxDistrict;