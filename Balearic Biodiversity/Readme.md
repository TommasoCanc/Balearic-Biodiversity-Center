## Pipeline Balearic Biodiversity data.

1. Create a ***NEW*** .csv file starting from the original list changing the columns' name as follow: "Taxon", "Family", and "Group". Hereafter: **newList**

2. Check nomenclature removing unnecessary words like subgenus, gr., etc.

    📁 Save in **01_originalList**

#### Resolve binomial nomenclature

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

   ### Check taxa distribution

5. Once we have a good taxonomy list, we need to check each species' distribution to remove those taxa outside their native range. To do that, we use the script *01_Distribution_IUCN.R*.
The result of this script is a data frame containing the native range of each species retrieved from IUCN information.

Species with a native range out of Spain have to be removed from the original list.
Classify the species present in Spain with the label **"present"** whereas the species out of the range with the labe **"absent"**.

   ***NOTE:*** Species with NA values in the IUCN .csv file do not have information in the IUCN web. Taxa without spatial information have to be checked manually.
   
   
   ### Fauna Europaea download

6. With the species list obtained after checked the species distribution, we can download the information stored in Fauna Europaea (https://fauna-eu.org). To the scope, we use the script *03_Download_fauna_europaea_v2.R*. In this case we can obtain the distribution for Balearic islands. In Fauna Europaea the Balearic Islands are identified as *Balearic Is.*.




8.			Download spatial information stored in Fauna Europaea 
-	Run the first chunk R script 02_Download_fauna_europaea.R to download the regional distribution of each taxon based on the original list.
-	Run the second chunk of the script to retrieve all the species belonging to a specific genus. Then this new list is the base for retrieving information about the distribution of the species.
9)	Save two .csv files. 
-	The first one contains the merged result between the original list and that originated starting from the Genus.
-	The second one contains the presence/absence information derived from the list of taxa originating from the Genus. This file helps check the doubtful presence.
10)	Copy and paste the information in the XXX_finalList_YYYY_MM_DD; sheet  faunaEuropaea.

NOTE: If you have a record from the original list saved with NA and the same record is present in the table derived by the genus, this is a new record compared to the original list.

Aeshna cyanea (Muller, 1764)	NA	NA	NA
Aeshna cyanea (Muller, 1764)	Balearic Is.	Present	Genus derived

NOTE: if the species have only NA values, the species is not present in the Fauna Europaea.

9)	Create a conditional column “Status (xy)” containing this formula =IF(D2=H2;D2;"doubtful"). 
Apply to such column 3 conditional formatting: 
"doubtful" Yellow field;
"absent" Red field;
"present" Green field.
10)	Carefully check the record and try to fill the empty or NA space.

GBIF DOWNLOAD INFO
11)	Download spatial information stored in GBIF (https://www.gbif.org)
-	Run the first chunk R script 03_Download_gbif.R to download the occurrences of the taxa based on the original list. 
	This script produces an R list composed of two objects:
	- info: Contains information about species name, scientific name, GBIF taxon key, taxonomic status (e.g., synonym, accepted), number of occurrences in Spain, and number of occurrences in the Balearic Islands. The last column presenceAbsence is derived from the number of Balearic occurrences. If >= 5 the species is considered present, otherwise not.
	- data: Contains spatial information, occurrence sampling events and institution info.
- Run the second chunk of the script. As for Fauna Europaea, we retrieve the species starting from the genus. Also in this case, we produce a list containing the objects: info and data.
From both the objects we remove fossil specimens and those with 0 occurrences in Spain.
12)	Save four .csv files.
-	The first contains merged information between the original list and that retrieved starting from the genus.
-	The second contains info retrieved from the species obtained using the genus as the base.
-	The third contains spatial information on the taxa of the original list.
-	The fourth contains spatial information derived from the taxa obtained from the genus.
13)	 Copy and paste the information in the XXX_finalList_YYYY_MM_DD; sheet  gbif.
14)	Create a conditional column “Status (xy)” containing this formula =IF(D2=H2;D2;"doubtful"). 
Apply to such column 3 conditional formatting: 
"doubtful" Yellow field;
"absent" Red field;
"present" Green field.
15)	 Filter removing the taxa with 0 occurrences in column M.
16)	Carefully check the record and try to fill the empty on NA space.

MERGE THE INFO
17)	 In the originalist sheet add the columns: “bioatlas”; “faunaEuropaea”; “gbif”; “total”. 
18)	 Fill the column bioatlas with the string “present”, since the original list was downloaded from bioatlas. Then, fill the other two columns using the function VLOOKUP.
19)	Add a temporary column with the following formula: 
=IF(OR(D2 <> "present"; E2 <> "present"; F2 <> "present"); "check"; "present").
With this formula we consider a species present in the Balearic territory only if all the information sources agree with the present statement. If not we need to check. 
20)	In the column “total” we can insert the sure presence. We consider the species absent if there are 2 or 3 absent values, or doubtful if there are two present and 1 absent/NA values.
