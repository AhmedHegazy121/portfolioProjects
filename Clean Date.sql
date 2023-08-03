select *
from PortiolioProject..NashvilleHouse

--standerdize data format
select SaleDateconverted, CONVERT(date,SaleDate)
from PortiolioProject..NashvilleHouse

update NashvilleHouse  
set SaleDate= CONVERT(date, SaleDate)

alter table NashvilleHouse 
add SaleDateconverted date ;

update NashvilleHouse  
set SaleDateconverted = CONVERT(date, SaleDate)

--populate property adress date
select*
from PortiolioProject..NashvilleHouse
--where PropertyAddress  is null
order by ParcelID

select a.ParcelID ,a.PropertyAddress,b.ParcelID ,b.PropertyAddress ,
isnull(a.PropertyAddress,b.PropertyAddress) as populateAdress
 from PortiolioProject.. NashvilleHouse a
 join PortiolioProject.. NashvilleHouse b
 on a.ParcelID =b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null

 update a
 set 
  a.PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
 from PortiolioProject..  NashvilleHouse a
 join PortiolioProject .. NashvilleHouse b
 on a.ParcelID =b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null

 -- breaking out adressinto individual (adress, city , state)
 select PropertyAddress
 from PortiolioProject ..NashvilleHouse

 select 
SUBSTRING (  PropertyAddress , 1 , CHARINDEX (',' ,  PropertyAddress)-1) as adress ,
SUBSTRING (  PropertyAddress , CHARINDEX (',' , PropertyAddress)+1 ,LEN( PropertyAddress)) as adress
 from PortiolioProject ..NashvilleHouse

 alter table NashvilleHouse 
 add PropertySplitAddress nvarchar (255)
 update NashvilleHouse 
 set PropertySplitAddress = SUBSTRING (  PropertyAddress , 1 , CHARINDEX (',' ,  PropertyAddress)-1) 
  
alter table NashvilleHouse  
add PropertySplitCity nvarchar(255)
update NashvilleHouse  
set PropertySplitCity = SUBSTRING (  PropertyAddress , CHARINDEX (',' , PropertyAddress)+1 ,LEN( PropertyAddress))

select * 
from PortiolioProject .. NashvilleHouse 


select OwnerAddress
from PortiolioProject..NashvilleHouse


 select
 parsename(replace(OwnerAddress ,',' , '.' ), 3)
 ,parsename(replace(OwnerAddress ,',' , '.' ), 2)
 ,parsename(replace(OwnerAddress ,',' , '.' ), 1)
from PortiolioProject..NashvilleHouse


alter table NashvilleHouse 
 add OwnerSplitAddress nvarchar (255)
 update NashvilleHouse 
 set OwnerSplitAddress = parsename(replace(OwnerAddress ,',' , '.' ), 3)


 alter table NashvilleHouse 
 add OwnerSplitCity nvarchar (255)
 update NashvilleHouse 
 set OwnerSplitcity = parsename(replace(OwnerAddress ,',' , '.' ), 2)

 
 alter table NashvilleHouse 
 add OwnerSplitstate nvarchar (255)
 update NashvilleHouse 
 set OwnerSplitstate = parsename(replace(OwnerAddress ,',' , '.' ), 1)



 --change y and n to yes and no 
 select distinct (SoldAsVacant) ,count(SoldAsVacant)
 from PortiolioProject ..NashvilleHouse
 group by SoldAsVacant
 order by 2

 select SoldAsVacant
  , case when SoldAsVacant ='y' then 'yes'
        when SoldAsVacant ='n' then 'no'
		else SoldAsVacant end
 from PortiolioProject ..NashvilleHouse

 update NashvilleHouse
 set SoldAsVacant =  case when SoldAsVacant ='y' then 'yes'
        when SoldAsVacant ='n' then 'no'
		else SoldAsVacant end

--    remove dupplicate

	with RowNumCte AS(
	select * ,  
	row_number() over ( 
	     partition by ParcelID,
                      PropertyAddress ,
					   SalePrice ,
					   LegalReference
					   order by
					  UniqueID ) as row_num
	  from PortiolioProject ..NashvilleHouse
	  )
       delete
	  from RowNumCte
	  where row_num >1
	  --order by PropertyAddress



	   
	 with RowNumCte AS(
	select * ,  
	row_number() over ( 
	     partition by ParcelID,
                      PropertyAddress ,
					   SalePrice ,
					   LegalReference
					   order by
					  UniqueID ) as row_num
	  from PortiolioProject ..NashvilleHouse
	  )
      select *
	  from RowNumCte
	  where row_num >1
	  order by PropertyAddress


	  --delete unused columns


	  alter table PortiolioProject ..NashvilleHouse
	  drop  column OwnerAddress,TaxDistrict , PropertyAddress
	  
	  alter table PortiolioProject ..NashvilleHouse
	  drop  column SaleDate


     select * from PortiolioProject ..NashvilleHouse