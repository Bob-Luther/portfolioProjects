-- Data cleaning in SQL Queries
	
	Select *
	from portfolioproject..housing

-- Standardizing Data format

	Select SalesDate,
	convert(date, SaleDate) as sales_date_2
	from portfolioproject..housing
	

	update portfolioproject..housing
	set saledate = convert(date, saledate)

	alter table portfolioproject..housing
	add Salesdate date

	update portfolioproject..housing
	set salesdate = convert(DATE, SALEDATE)

--------------------------------------------------------------------------------------------------------------

--	Property address data

	select propertyaddress
	from portfolioproject..housing
	where PropertyAddress is null


	select a.ParcelID, a.propertyaddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
	from portfolioproject..housing a
	join portfolioproject..housing  b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
	where a.PropertyAddress is null

	update a
	set propertyaddress = ISNULL(a.propertyaddress, b.PropertyAddress)
	from housing a
	join housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

---------------------------------------------------------------------------------------------------------------
--	Breaking address into individual columns ( Address, city, state)
--	For propertyaddress
	
	select propertyaddress
	from portfolioproject..housing

--	split column using substring()	
	select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyaddress) -1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress)) as Address

	from portfolioproject..housing

--	update table
	alter table portfolioproject..housing
	add propertysplitaddress nvarchar(255)

	update portfolioproject..housing
	set propertysplitaddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyaddress) -1)

	alter table portfolioproject..housing
	add propertysplitcity nvarchar(255)

	update portfolioproject..housing
	set propertysplitcity = SUBSTRING(PropertyAddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress))


--	for owneraddress

	select OwnerAddress
	from portfolioproject..housing

--	split column using parsename() 
	select owneraddress,
	PARSENAME(replace(owneraddress, ',', '.'), 3) as ownersplitaddress,
	PARSENAME(replace(owneraddress, ',', '.'), 2) as owner_city,
	PARSENAME(replace(owneraddress, ',', '.'), 1) as owner_state
	from portfolioproject..housing

--	update table
	alter table portfolioproject..housing
	add ownersplitaddress nvarchar(255)

	update portfolioproject..housing
	set ownersplitaddress = PARSENAME(replace(owneraddress, ',', '.'), 3) 

	alter table portfolioproject..housing
	add owner_city nvarchar(255)

	update portfolioproject..housing
	set owner_city = PARSENAME(replace(owneraddress, ',', '.'), 2)

	alter table portfolioproject..housing
	add owner_state nvarchar(255)

	update portfolioproject..housing
	set owner_state = PARSENAME(replace(owneraddress, ',', '.'), 1)


-------------------------------------------------------------------------------------------

--	Change Y and N to YES and NO in "Sold as vacant" column

	select distinct SoldAsVacant
	from portfolioproject..housing

--	changing using case statement
	select SoldAsVacant,
	case 
	when SoldAsVacant = 'Y' then 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
	from portfolioproject..housing

-- Update the table
	update portfolioproject..housing
	Set SoldAsVacant = case 
	when SoldAsVacant = 'Y' then 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END

--------------------------------------------------------------------------------------------

-- Removing Duplicates

	with cte1 as
	(
	select *, 
	ROW_NUMBER () over (partition by 
									 [ParcelID],
									 [PropertyAddress],
									 [SalePrice],
									 [SaleDate],
									 [LegalReference]
									 order by
									 [UniqueID ]) as Row_num
	from portfolioproject..housing
	)
	select * 
	from cte1
	where Row_num > 1
	

------------------------------------------------------------------------------------------

-- Delete few columns
	
	alter table portfolioproject..housing
	drop column propertyaddress, owneraddress