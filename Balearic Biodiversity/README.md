# Pipeline to check the Balearic Biodiversity data.


#### 1. Create starting checklist

1. Create a ***NEW*** .csv file starting from the original list changing the columns' name as follow: "Taxon", "Family", and "Group". Hereafter: **newList**

2. Check nomenclature removing unnecessary words like subgenus, gr., etc.

    📁 Save in **01_originalList**

#### 2. Resolve binomial nomenclature

3. We use the script: *01_Taxonomic_check.R* to resolve synonyms.
We use the function `synonyms` from the *taxize* R package to search for synonym names. The resulting object is a data frame with two columns: 
**i)** the name stored in the original data set; **ii)** the accepted name if the original name is a synonym. 

> _**NOTE**_: The "Not found" string in the second column means that the binomial name is absent from the reference database. Whereas the sting "No data" means that the `synonyms` function returned the error 404, and the query of the binomial name was skipped.

4. Once we obtain the reviewed taxonomic list (*point 3*), we can manually correct the original list.

    📁 Save in **02_taxonomyCheck**

 > _**NOTE**_: Data with "Not found" or "No data" strings have to be searched manually.


Databases used for taxonomic check

| Reference database | Biological group |
|--------------------|------------------|
| Reptilia           | ITIS             |
|                    |                  |

#### 3. Higher taxonomy rank

5. We use the script *02_higherTaxonomy* to complete the higher taxonomic rank for each taxon.

      📁 Save in **03_higherTaxonomy**

> _**NOTE**_: Data with NA values in the columns _kingdom_,	_phylum_, _class_, _order_, _family_, _genus_, _species_, and _subspecies_ have to be searched manually because they are not present in the reference database.

Databases used for retrieve higher taxonomic rank

| Reference database | Biological group |
|--------------------|------------------|
| Reptilia           | ITIS             |
|                    |                  |

#### 4. Check taxa distribution

6. We need to check each species' distribution to remove those taxa outside their native range. To do that, we use the script *03_distributionIUCN.R*.
      The result of this script is a data frame containing the native range of each species retrieved from IUCN at Spanish level. Species with a native range out of Spain have to be flagged and finally they will remove from the final checklist.

7. We need to add a column in the .csv **higher taxonomy** to include the IUCN flags.

**Column name**: iucnDistribution
**Flags**: i) present; ii) absent

 > _**NOTE**_: Species with NA values do not have information in the IUCN web. Thus we have to be checked manually.
   
   👉 _**Tip**_: We can follow these steps to add IUCN information easily:
       * Filter the column _country_ for Spain to select the present taxa.
       * Filter the column _country_ for NA to select the taxa with any information in IUCN.
       * Filter the column _country_ excluding Spain and NA to select the absent taxa. If a taxon has been flagged as present (point 1) has to remain present since the taxon distribution is extended to many countries.   
   
   📁 Save in **04_IUCN**
   
#### 5. Fauna Europaea download

6. We use the script _04_downloadFaunaEuropaea.R_ to download presence information from [Fauna europaea](https://fauna-eu.org) (FE). With this database, we can limit the species' presence to the Balearic Islands (info in FE _*Balearic Is.*_ ).

To obtain a complete data set of the Balearic Islands' biodiversity, we also download the information concerning all the species belonging to the genera listed in our original list. Therefore as a final result of this script, we obtain two .csv files:
i) _XXX_faunaEuropaea_DATE_: This file contains the merged information retrieved of the species presence starting from the taxa list and the presence of species retrieved using the genus as starting point.
ii) _XXX_faunaEuropaea_pa_DATE_: This file contains information about the explicit absence or doubtful presence reported in FE.

We need to add a column in the .csv **higher taxonomy** to include the FE information.

**Column name**: faunaEuropaea
**Flags**: i) present; ii) absent

   📁 Save in **05_faunaEuropaea**

> _**NOTE**_: If exist a incongruence of presence information between the original and derived taxa, it means that we gain a new species for the Balearic Islands. 
For example:
Aeshna cyanea (Muller, 1764)	NA	NA	NA   Original list
Aeshna cyanea (Muller, 1764)	Balearic Is.	Present	Genus derived

If the species have only NA values, the species is not present in the Fauna Europaea thus need to be checked manually.


#### 6. GBIF download 

We use the script _05_downloadGBIF.R_ to download the presence information from Global Biodiversity Information Facility ([GBIF](https://www.gbif.org)). As for the FE, with use the same approach "genus base" to include the maximum number of species as possible. 

To detect the taxa presence in the Balearic Islands, we use the number of occurrences included in the spatial polygon "POLYGON((0.898 38,4.592 38,4.592 40.295,0.898 40.295,0.898 38))". We consider a species as present if the number of occurrence is >= 5.

The results of this script are two .csv files:
i) _XXX_gbifData_DATE_: This file contain the global information retrieved from the taxa of he original list and that obtained from the genus base approach.
ii) _XXX_gbifInfo_DATE_: This file contain data obrained only with the genus based approach.

We need to add a column in the .csv **higher taxonomy** to include the GBIF information.

**Column name**: gbif
**Flags**: i) present; ii) absent

📁 Save in **06_gbif

 👉 _**Tip**_: We can follow these steps to add IUCN information easily:
       * Filter the column _country_ for Spain to select the present taxa.
       * Filter the column _country_ for NA to select the taxa with any information in IUCN.
       * Filter the column _country_ excluding Spain and NA to select the absent taxa. If a taxon has been flagged as present (point 1) has to remain present since the taxon distribution is extended to many countries.   