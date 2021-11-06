
-- popunjavanje adrese


select nashville_housing.propertyaddress from nashville_housing
where nashville_housing.propertyaddress is null;


update Nashville_Housing a
    SET PROPERTYADDRESS = (SELECT MAX(b.PROPERTYADDRESS)
                    FROM Nashville_Housing b
                    WHERE a.PARCELID = b.PARCELID AND 
                        b.PROPERTYADDRESS IS NOT NULL
                    )
    where PROPERTYADDRESS is null;




-- razdvajanje adresa u individualne kolone

select nashville_housing.propertyaddress from nashville_housing

select substr(propertyaddress, 1, INSTR(propertyaddress,',') - 1) as address,
substr(propertyaddress, INSTR(propertyaddress,',') + 1, length(propertyaddress) ) as address
from nashville_housing;

alter table nashville_housing
add property_split_address varchar2(128);

update nashville_housing
set property_split_address = substr(propertyaddress, 1, INSTR(propertyaddress,',') - 1)

alter table nashville_housing
add property_split_city varchar2(128);

update nashville_housing
set property_split_city = substr(propertyaddress, INSTR(propertyaddress,',') + 1, length(propertyaddress) ) 

select * from nashville_housing;

--- razdvajanje adrese vlasnika



select REGEXP_SUBSTR(OWNERADDRESS, '[^,]+', 1,1) as address,
REGEXP_SUBSTR(OWNERADDRESS, '[^,]+', 1,2) as city,
REGEXP_SUBSTR(OWNERADDRESS, '[^,]+', 1,3) as country
from nashville_housing;



alter table nashville_housing
add owner_split_address varchar2(128);

update nashville_housing
set owner_split_address = REGEXP_SUBSTR(OWNERADDRESS, '[^,]+', 1,1);

alter table nashville_housing
add owner_split_city varchar2(128);

update nashville_housing
set owner_split_city = REGEXP_SUBSTR(OWNERADDRESS, '[^,]+', 1,2);

alter table nashville_housing
add owner_split_state varchar2(128);

update nashville_housing
set owner_split_state = REGEXP_SUBSTR(OWNERADDRESS, '[^,]+', 1,3);

-- promjena Y i N u Yes i No u "Sold as Vacant" polju

select distinct SOLDASVACANT, count(SOLDASVACANT)
from nashville_housing
group by SOLDASVACANT
order by 2;

select SOLDASVACANT,
CASE when SOLDASVACANT = 'Y' Then 'Yes'
    when SOLDASVACANT = 'N' Then 'No'
    ELSE SOLDASVACANT
    END
from nashville_housing;

update nashville_housing
set SOLDASVACANT = CASE when SOLDASVACANT = 'Y' Then 'Yes'
    when SOLDASVACANT = 'N' Then 'No'
    ELSE SOLDASVACANT
    END;
    
--brisanje duplikata

delete from nashville_housing  
where uniqueid_ in (select uniqueid_ from ( SELECT
    uniqueid_,
    parcelid,
    propertyaddress,
    saleprice,
    saledate,
    legalreference,
    ROW_NUMBER()
    OVER(PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference
         ORDER BY
             uniqueid_
    ) row_num
FROM
    nashville_housing
)
WHERE row_num > 1
);

-- brisanje neiskoristenih kolona

alter table nashville_housing
drop (OWNERADDRESS, TAXDISTRICT, PROPERTYADDRESS);

select * from nashville_housing;
