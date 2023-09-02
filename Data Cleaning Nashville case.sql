
## Cleaning data in SQL Queries

## Standardize Data Format

SELECT
  SaleDate,
  FORMAT_TIMESTAMP('%Y-%m-%d', PARSE_TIMESTAMP('%B %e, %Y', SaleDate)) AS FormattedSaleDate
FROM
  `portfolioproject-397108.PortfolioProject.Nashville_DataCleaning`;



## Populate Property Address Data
## if ParcelID have the same ID and Address

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress,b.PropertyAddress) as MergePropertyAddress
FROM `portfolioproject-397108.PortfolioProject.Nashville_DataCleaning` a
JOIN `portfolioproject-397108.PortfolioProject.Nashville_DataCleaning` b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID_ <> b.UniqueID_
WHERE a.PropertyAddress is null



## Breaking out Address Into Individual Coloums (Address, City, State)

## for PropertyAddress

SELECT UniqueID_,
  SUBSTRING(PropertyAddress, 1, STRPOS(PropertyAddress, ',') - 1) AS Address
FROM
  `portfolioproject-397108.PortfolioProject.Nashville_DataCleaning`;


SELECT UniqueID_,
  SUBSTRING(PropertyAddress, 1, STRPOS(PropertyAddress, ',') - 1) AS Address ,
  SUBSTRING(PropertyAddress, STRPOS(PropertyAddress, ',') + 1) AS SeparateAddress, LENGTH(PropertyAddress) AS AddressLength
FROM
  `portfolioproject-397108.PortfolioProject.Nashville_DataCleaning`;


## For Owner Address

SELECT UniqueID_,
  SPLIT(OwnerAddress, ', ')[SAFE_OFFSET(0)] AS AddressPart1,
  SPLIT(OwnerAddress, ', ')[SAFE_OFFSET(1)] AS AddressPart2,
  SPLIT(OwnerAddress, ', ')[SAFE_OFFSET(2)] AS AddressPart3
FROM
  `portfolioproject-397108.PortfolioProject.Nashville_DataCleaning`;



## Change Y and N to Yes and No in "Sold as Vacant" field

SELECT
  CASE WHEN SoldAsVacant = true THEN 'yes' ELSE 'no' END AS SoldAsVacant,
  COUNT(SoldAsVacant) AS Count
FROM
  `portfolioproject-397108.PortfolioProject.Nashville_DataCleaning`
GROUP BY SoldAsVacant
ORDER BY Count DESC;

