
--Cleaning Data in SQL Queries

select * from dbo.NashvilleHousing;



--Standardize date format
select SaleDate, convert(date, SaleDate) from dbo.NashvilleHousing;

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate);

select SaleDateConverted from dbo.NashvilleHousing;



--Populate property Address data
select *
from dbo.NashvilleHousing
order by ParcelID;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousing a
join dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ];
--where a.PropertyAddress is null;

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousing a
join dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;




--Breaking out Address into individual columns (address, city, state)
select PropertyAddress
from dbo.NashvilleHousing

select
--string before comma
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1 ) as Address,
--string after comma
substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress)) as address
from dbo.NashvilleHousing;

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1 );

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress));

select * from dbo.NashvilleHousing;



--more easy way with owner address
select 
parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',', '.'), 2),
parsename(replace(OwnerAddress, ',', '.'), 1)
from dbo.NashvilleHousing;

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3);

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2);

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1);

select * from dbo.NashvilleHousing;




-- Change Y and N to Yes and No in "Sold as Vacant" field
select distinct(SoldAsVacant), count(SoldAsVacant)
from dbo.NashvilleHousing
group by SoldAsVacant
order by 2;

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from dbo.NashvilleHousing;

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
                        when SoldAsVacant = 'N' then 'No'
	                    else SoldAsVacant
	               end;




-- Remove dublicates 
with RowNumCTE as (
select*,
ROW_NUMBER() over (
partition by ParcelId,
             PropertyAddress,
			 SalePrice,
			 LegalReference
			 order by
			      UniqueID
                   ) row_num
from dbo.NashvilleHousing
--order by ParcelID;
)

--delete  
--from RowNumCTE
--where row_num > 1

select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress

select *
from dbo.NashvilleHousing;



-- Delete unused columns
select *
from dbo.NashvilleHousing;

alter table dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
