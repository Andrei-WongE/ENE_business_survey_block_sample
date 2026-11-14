clear all
set more off

global ROOT "C:\Users\Karly\Documents\Karlygash Dairabayeva\ECA Transport\Peru\"
global DATA "$ROOT\00_Data"
global OUTPUT "$ROOT\02_Output"
cd "$DATA"


* product codes ISIC 4 *
import delimited "C:\Users\Karly\Documents\Karlygash Dairabayeva\ECA Transport\Peru\00_Data\ISIC4.txt", clear 
rename v1 ISIC4 
rename v2 description
drop in 1
drop if ISIC4=="B"|ISIC4=="D"|ISIC4=="K"|ISIC4=="M"
destring ISIC4,replace
sort ISIC4
save ISIC4,replace

import delimited "C:\Users\Karly\Documents\Karlygash Dairabayeva\ECA Transport\Peru\00_Data\ISIC4toISIC3.txt", clear 
rename isic31code  ISIC3 
sort ISIC3
merge ISIC3 using HS_toISIC3
ta _merge
rename isic4code ISIC4
sort ISIC4
drop _merge
sort hscombinedproductcode
merge hscombinedproductcode using hs17_toBEC_descrip
ta _merge
drop if _merge==2
sort ISIC4
drop _merge
save ISIC4toISIC3,replace

********************************************************************************
import delimited "C:\Users\Karly\Documents\Karlygash Dairabayeva\ECA Transport\Peru\00_Data\Concordance_HS_to_ISIC3.CSV", clear 
rename isicrevision3productcode ISIC3
sort ISIC3
save HS_toISIC3,replace


import excel "C:\Users\Karly\Documents\Karlygash Dairabayeva\ECA Transport\Peru\00_Data\HS2017toBECConversionAndCorrelationTables.xlsx", sheet("Conversion HS17-BEC") firstrow clear
rename ToBEC BEC4
sort BEC4
save hs17_toBEC,replace

import delimited "C:\Users\Karly\Documents\Karlygash Dairabayeva\ECA Transport\Peru\00_Data\Concordance_HS_toSIC.csv",  clear
rename sicproductcode SIC
sort hscombinedproductcode
save HS_toSIC,replace

import excel "C:\Users\Karly\Documents\Karlygash Dairabayeva\ECA Transport\Peru\00_Data\bec_description.xlsx", firstrow clear
drop Classification 
rename Code BEC4
sort BEC4
merge BEC4 using hs17_toBEC
ta _merge
drop if _merge<3
drop _merge
rename FromHS2017 hscombinedproductcode
destring hscombinedproductcode,replace
sort hscombinedproductcode
merge hscombinedproductcode using HS_toSIC
ta _merge
drop _merge
sort hscombinedproductcode
save hs17_toBEC_descrip,replace


**********************************************************************************************************
* Enterprise survey PERU (2019) , ENE
**********************************************************************************************************
use "$DATA\ENE_firm_data\Base_ENE-2017_Final_mod_3.dta" ,clear
svyset [pw=FACTOR_EXPANS], strata(E_FORZOSO_CD)
svydescribe
rename p506r4 ISIC4
sort ISIC4
drop _merge
merge ISIC4 using ISIC4toISIC3
ta _merge
drop if _merge==2
drop _merge
sort ID 
        quietly by ID: gen dup = cond(_N==1,0,_n)
		drop if dup>1
		drop dup

sort ISIC4
merge ISIC4 using ISIC4
ta _merge
rename ISIC4 p506r4
drop _merge
drop if ID==.
sort ID 
        quietly by ID: gen dup = cond(_N==1,0,_n)
		drop if dup>1
		drop dup

g durable_goods=1 if SIC==2010|SIC==20202030|SIC==2040|SIC==2050|SIC==2060|SIC==2070|SIC==2086|SIC==2090|SIC==2047
replace durable_goods=1 if SIC==2082|SIC==2084|SIC==2085|SIC==2111|SIC==2121|SIC==2131|SIC==2251|SIC==2252|SIC==2271|SIC==2272|SIC==2279
replace durable_goods=1 if SIC==2311|SIC==2321|SIC==2322|SIC==2327|SIC==2328|SIC==2331|SIC==2335|SIC==2337|SIC==2341|SIC==2342|SIC==2361|SIC==2391
replace durable_goods=1 if SIC==2511|SIC==2512|SIC==2514|SIC==2515|SIC==2591|SIC==2711|SIC==2721|SIC==22731|SIC==2732
replace durable_goods=1 if SIC==2834|SIC==2911|SIC==2992|SIC==3011|SIC==3143|SIC==3144|SIC==3161|SIC==3229|SIC==3262|SIC==3263|SIC==3524|SIC==3631|SIC==3632|SIC==3633|SIC==3634|SIC==3635
replace durable_goods=1 if SIC==3645|SIC==3651|SIC==3652|SIC==3661|SIC==3711|SIC==3713|SIC==3792|SIC==3716|SIC==3732|SIC==3751|SIC==3851|SIC==3861|SIC==3873
replace durable_goods=1 if SIC==3911|SIC==3914|SIC==3931|SIC==3944
save PERU_fulldata,replace

********************************************************************************
use PERU_fulldata,clear
 assert c(N)==19599

    nmissing p506r4 MUBIGEO //51 missing
    drop if p506r4==.|MUBIGEO==""
    rename p506r4 ciiu
    format ciiu %04.0f
    
    egen io_sectors1 = anymatch(ciiu), values(0111/0116, 0119, 0121/0130, 0141/0146,    0149, 0161/0164, 0170, 0210, 0220, 0230, 0240)
    egen io_sectors2 = anymatch(ciiu), values(0311, 0312, 0321, 0322)
    replace io_sectors2 = 2 if io_sectors2 == 1
    egen io_sectors3 = anymatch(ciiu), values(0610, 0620, 0910, 0721, 0729, 0810, ///
    0891, 0892 ,0893, 0899, 0990)
    replace io_sectors3 = 3 if io_sectors3 == 1
    egen io_sectors4 = anymatch(ciiu), values(1010, 1020, 1030, 1040, 1050, 1061, ///
    1062, 1071/1075, 1079, 1080, 1101/1104, 1200, 1311/1313, 1391/1394, 1399, 1410, ///
    1420, 1430, 1511, 1512, 1520, 1610, 1621/1623, 1629, 1701, 1702, 1709, 1811, ///
    1812, 1820, 1910, 1920, 2011/2013, 2021/2023, 2029, 2030, 2100, 2211, 2219, ///
    2220, 2310, 2391/2396, 2399, 2410, 2420, 2431, 2432, 2511/2513, 2520, 2591/2593, ///
    2599, 2620, 2651, 2652, 2660, 2670, 2680, 2610, 2630, 2640, 2710, 2720, ///
    2731/2733, 2740, 2750, 2790, 2811, 2812, 2817, 2813/2816, 2818, 2819, ///
    821/2826, 2829, 2910, 2930, 3011, 3012, 3020, 3030, 3040, 3091, 3092, 3099, /// 
    3100, 3211, 3212, 3311/3315, 3220, 3230, 3240, 3250, 3290, 3319, 3320)
    replace io_sectors4 = 4 if io_sectors4 == 1
    egen io_sectors5 = anymatch(ciiu), values(3510, 3520, 3530, 3600, 3700, 3811, ///
    3812, 3821, 3822, 3830, 3900)
    replace io_sectors5 = 5 if io_sectors5 == 1
    egen io_sectors6 = anymatch(ciiu), values(4100, 4311, 4321, 4322, 4329, 4330, ///
    4390, 4210, 4220, 4290, 4312)
    replace io_sectors6 = 6 if io_sectors6 == 1
    egen io_sectors7 = anymatch(ciiu), values(4530, 4540, 4610, 4620, 4630, 4641, ///
    4649, 4651, 4652, 4653, 4659, 4661, 4662, 4663, 4669, 4690, 4711, 4719, 4721, ///
    4722, 4723, 4730, 4741, 4742, 4751, 4752, 4753, 4759, 4761, 4762, 4763, 4764, ///
    4771, 4772, 4773, 4774, 4781, 4782, 4789, 4791, 4799, 4520)
    replace io_sectors7 = 7 if io_sectors7 == 1
    egen io_sectors8 = anymatch(ciiu), values(4911, 4912, 4921/4923, 4930, 5011, ///
    5012, 5021, 5022, 5110, 5120, 5210, 5221/5224, 5229, 5310, 5320)
    replace io_sectors8 = 8 if io_sectors8 == 1
    egen io_sectors9 = anymatch(ciiu), values(5510/5590, 5610, 5621/5630)
    replace io_sectors9 = 9 if io_sectors9 == 1
    egen io_sectors10 = anymatch(ciiu), values(5811/5813, 5911/5914, 5920, 6010, ///
    6020, 6110, 6120, 6130, 6190, 6201, 6202, 6209, 6311, 6312, 6391, 6399)
    replace io_sectors10 = 10 if io_sectors10 == 1
    egen io_sectors11 = anymatch(ciiu), values(6419, 6411, 6430, 6491, 6492, 6499, ///
    6420, 6511, 6512, 6611, 6612, 6619/6630, 6520, 6530, 6621, 6622, 6629, 6630)
    replace io_sectors11 = 11 if io_sectors11 == 1
    egen io_sectors12 = anymatch(ciiu), values(6910, 6920, 7010, 7020, 7110, 7210, ///
    7120, 7220, 7410, 7420, 7490, 7500, 7310, 7320, 7710, 7730, 7721, 7722, 7729, ///
    7740, 7911, 7912, 7990, 7810, 7820, 7830, 8010, 8020, 8030, 8110, 8121, 8129, ///
    8130, 8219, 8211, 8220, 8230, 8291, 8292, 8299) //9411//
    replace io_sectors12 = 12 if io_sectors12 == 1
    egen io_sectors13 = anymatch(ciiu), values(8411, 8412, 8413, 8421, 8422, 8423, 8430)
    replace io_sectors13 = 13 if io_sectors13 == 1
    egen io_sectors14 = anymatch(ciiu), values(8541, 8542, 8549, 8510, 8521, 8522, ///
    8530, 8541, 8542, 8550, 8610, 8620, 8690, 8710, 8720, 8730, 8790, 8810, 8890, ///
    9000, 9101, 9102, 9103, 9311, 9200, 9312, 9319, 9321, 9329, 9411, 9412, 9420, ///
    9491, 9492, 9499, 9511, 9512, 9521, 9522, 9524, 9529, 9602, 9609, 9601, 9603, ///
    9609, 9700, 6810, 6820)
    replace io_sectors14 = 14 if io_sectors14 == 1
    //Note: 9411 appearsin 12 AND 14, changed so it would only be in 14
    egen io_sectors = rowtotal(io_sectors*)
    //Checking if ony onw value per row was added
    egen count_of_zeros = anycount(io_sectors1-io_sectors14), values(0)  
    //Replace missing 
    replace io_sectors = . if io_sectors == 0 
    
    # delimit ;
    label define sectors
    1 "Productos agropecuarios, de caza y silvic." 
    2 "Productos de pesca y acuicultura"
    3 "Petróleo, gas, minerales y serv. conexos"
    4 "Productos manufacturados"
    5 "Servicio de electricidad, gas y agua"
    6 "Construcción"
    7 "Comercio, serv. de mant. y repar. de vehic."
    8 "Transp., almacenam., correo y mensajería"
    9 "Alojamiento y restaurantes"
    10 "Telecomunicaciones y otros serv. de inform."
    11 "Servicios financieros, seguros y pensiones"
    12 "Servicios prestados a empresas"
    13 "Serv. administracion publica y defensa"
    14 "Otros servicios";
    #delimit cr
    
    label values io_sectors sectors
    label var io_sectors "14 IO sectors"
    
    tab io_sectors //216 missing

********************************************************************************
* list of exporter codes *
********************************************************************************
    rename  ciiu p506r4

ta SIC  if C6P624==1 & durable_goods==1 /* durable goods*/
ta sicproductdescription  if C6P624==1 & durable_goods==1 /* durable goods*/

ta p506r4 if C6P624==1 & durable_goods==1
ta isicrevision3productdescription  if C6P624==1  & durable_goods==1

****************************************************************************************************************************************************************************************
* 1. The number of exporter companies, total and by sector. Source: ENE
* exporter status = C6P624 
* 624. En los �ltimos doce meses, �su empresa realiz� exportaciones de productos/s*
svy: tab dpto , missing count format(%9.1g) col


********************************************************************************
* employment in lockdown sectors 
********************************************************************************
  ///Create lockdown_sectors variable
    //Convet NAICS 2017 to ISIC Rev. 4, //https://www.census.gov/eos/www/naics/concordances/concordances.html

    //NAICS Classification: Restaurants and bars: 7223-7225.--> 5629, 5621, 5610, 5630, 5610
    //Travel and Transportation: 4811, 4812, 4853, 4854, 4859, 4881, 4883, 7211. --> 5110, 5120, 4922, 5223,
    // 5224, 8129, 3315, 5222, 8129, 3315, 3830, 5229, 5510, 5590, 9200
    //Personal Services: 6212, 8121, 8129. --> 8620, 9602, 9609, 7420, 5221, 6190, 9529
    //Entertainment: 7111, 7112, 7115, 7131, 7132, 7139. --> 9000, 9329, 9312, 9311, 9319, 3290, 3319, 7420,
    // 9321, 9200, 4922, 7990
    //Other sensitive retail: 4411, 4412, 4421, 4422, 4481, 4482, 4483, 4511, 4512, 4522, 4531, 4532, 4539, 5322,
    // 5323, 4243, 4413, 4543. --> 4510, 4752, 4510, 4530, 3315, 4753, 4763, 4510, 4540, 4773, 4759, 4752, 9522,
    // 4773, 4753, 9524, 4759, 4773, 4771, 4773, 9529, 9523, 4711, 4763, 4764, 4751, 4759, 4761, 4719, 4721, 4722,
    // 4761, 4773, 2396, 4752, 4759, 4774, 7722, 7729, 7721, 7730, 4641, 4530, 4742, 4540, 4752
    //Sensitive Manufacturing: 3352, 3361, 3362, 3363, 3364, 3366, 3371, 3372, 3379, 3399, 4231, 4232, 4239,
    // 3132, 3141, 3149, 3152. --> 2750, 2910, 2811, 2814, 2790, 3091, 2816, 2920, 2930, 2811, 2813, 2740,
    // 2399, 2399, 1392, 1399, 2220, 3011, 3020, 3030, 2591, 2819, 2930, 3030, 2813, 3011, 3315, 3012, 3100,
    // 3250, 3100, 1622, 2220, 2511, 2219, 2220, 3100, 1392, 1629, 2593, 2599, 2592, 3211, 3212, 2219, 2829,
    // 3220, 3230, 3240, 2640, 3092, 3230, 1399, 1629, 1701, 1709, 2022, 2817, 2819, 3290, 1629, 1811, 2220,
    // 2599, 2790, 1399, 1512, 1629, 1709, 2399, 2819, 3220, 2599, 2826, 3290, 3290, 3290, 1410, 1629, 2023,
    // 2819, 3220, 3240, 3290, 2818, 2599, 2710, 2790, 2815, 2812, 2651, 2599, 2815, 2816, 2819, 2829, 3250,
    // 4510, 4530, 4540, 4530, 4540, 4659, 4663, 4649, 4641, 4663, 4510, 4669, 4649, 4669, 4659, 4661, 4663,
    // 4690, 1312, 1420, 1399, 1391, 1420, 1393, 1392, 2220, 1392, 1512, 2220, 1394, 1311, 1313, 1393, 1394,
    // 1399, 1410, 1420

    gen lockdown_sectors = 0
*nmissing p506r4 ubigeo //51 missing |    drop if p506r4==.|MUBIGEO==.

    drop if p506r4==.
    rename p506r4 ciiu
    format ciiu %04.0f

    # delimit ;
      replace lockdown_sectors = 1 if inlist(ciiu, 1312, 1420, 1399, 1391, 1393, 1392, 2220, 1512, 1394, 1311,
      1313, 1410, 2811, 2814, 2790, 2910, 3091, 2818, 2819, 2599, 2710, 2815, 2812, 2651, 2816, 2829, 3250,
      2750, 2920, 2930, 2813, 2740, 2399, 3011, 3020, 3030, 2591, 3315, 3012, 3100, 1622, 2511, 2219, 1629,
      2593, 2592, 3211, 3212, 3220, 3230, 3240, 2640, 3092, 1701, 1709, 2022, 2817, 3290, 1811, 2826, 2023,
      4510, 4530, 4540, 4659, 4663, 4649, 4641, 4669, 4661, 4690, 4763, 4773, 4742, 4759, 4753, 9524, 4752,
      9522, 4711, 4721, 4722, 4771, 9529, 9523, 4764, 4751, 4761, 4719, 4723, 2396, 4774, 5110, 5120, 4922,
      5223, 5224, 8129, 5222, 3830, 5229, 7729, 7722, 7721, 7730, 8620, 9000, 9329, 9312, 9311, 9319, 3319,
      7420, 9321, 9200, 7990, 5510, 5590, 5629, 5621, 5610, 5630, 9602, 9609, 5221, 6190);
    # delimit cr
    //8,777 real changes made, based on 126 unique ciiu forvalues
    label var lockdown_sectors "lockdown_sectors"

g new_lockdown=lockdown_sectors
replace new_lockdown=0 if  C6P624==1
replace new_lockdown=0 if  durable_goods==1
replace new_lockdown=0 if  C4P408==1  & sector2r4_2==3 & C6P624==2

	/*
	label define regi 1 "Amazonas" 2 "Ancash" 3 "Apurimac" 4 "Arequipa" 5 "Ayacucho" 6 "Cajamarca" 8 "Cusco" 9 "Huancavelinca" 10 "Huanuco" ///
    11 "Ica" 12 "Junin" 13 "La Libertad" 14 "Lambayeque" 15 "Lima Metropolitana y Callao" 16 "Loreto" 17 "Mader de Dios" 18 "Moquegua" ///
    19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martin" 23 "Tacna" 24 "Tumbes" 25 "Ucayali" ,replace
    label values region regi
    replace region = 15 if region == 7 | lm == "1501"
    label var region "Regions"


****************************************************************************************************************************************************************
* C3P301A_T1 - employment
****************************************************************************************************************************************************************

* over the sectors *
svy: total C3P301A_T1 if C6P624==1 , over(sector1r4 ) cformat(%9.2f) 
svy: total C3P301A_T1 if durable_goods==1, over(sector1r4 ) cformat(%9.2f) 
svy: total C3P301A_T1 if C4P408==1  & sector2r4_2==3 , over( sector1r4) cformat(%9.2f) 
svy: total C3P301A_T1 if C4P408==1  & sector2r4_2==3 & C6P624==1, over( sector1r4) cformat(%9.2f) 
svy: total C3P301A_T1 if C4P408==1  & sector2r4_2==3 & C6P624==2, over( sector1r4) cformat(%9.2f) 
svy: total C3P301A_T1 if lockdown_sectors == 1  , over( sector1r4) cformat(%9.2f) 

svy: total C3P301A_T1 if new_lockdown == 1  , over( sector1r4) cformat(%9.2f) 

* total employment *
svy: total C3P301A_T1 , over(sector1r4 ) cformat(%9.2f) 
*/
* over the new IO sectors *
svy: total C3P301A_T1 , over(io_sectors ) cformat(%9.2f) 
svy: total C3P301A_T1 if C6P624==1 , over(io_sectors ) cformat(%9.2f) 
svy: total C3P301A_T1 if C4P408==1  & sector2r4_2==3 & C6P624==2, over( io_sectors) cformat(%9.2f) 
svy: total C3P301A_T1 if new_lockdown == 1  , over( io_sectors) cformat(%9.2f) 

svy: total C3P301A_T1 if durable_goods==1 & C6P624==2, over(io_sectors ) cformat(%9.2f) 
****************************************************************************************************************************************************************
* 4. Value added , total and by deparment  * GVA
****************************************************************************************************************************************************************
gen GVA = C9P904_7 - C9P905_9 //326 missing values and negative values!
    label var GVA "Gross Value Added"
replace GVA=0 if GVA<0
	
*C9P904_7 = 07 Total ingresos (03 al 06)
*C9P905_9 = 63 Gastos de servicios prestados por terceros (10 al 15 + 17 al 19)

* over the new IO sectors *
svy: total GVA , over(io_sectors ) cformat(%9.2f) 
svy: total GVA if C6P624==1 , over(io_sectors ) cformat(%9.2f) 
svy: total GVA if durable_goods==1 & C6P624==2, over(io_sectors ) cformat(%9.2f) 
svy: total GVA if C4P408==1  & sector2r4_2==3 & C6P624==2, over( io_sectors) cformat(%9.2f) 
svy: total GVA if new_lockdown == 1  , over( io_sectors) cformat(%9.2f) 

****************************************************************************************************************************************************************
* 5. Fin.vulnerability
****************************************************************************************************************************************************************
g FixedCosts= C9P905_9 + C9P905_16 + C9P905_20 + C9P905_21 + C9P905_26
g Variablecosts=C9P905_1 + C9P905_2 
g CashBuffer = (C9P904_7 - Variablecosts )/FixedCosts

sort io_sectors
joinby io_sectors using IO_COshare

g a=0.5
g SB= CashBuffer*(1-a*co)

svy: total SB, over(io_sectors ) cformat(%9.2f) 
svy: total SB, over(ciiu ) cformat(%9.2f) 

* SB= CB*(1-a*CO)/Fixed costs
*in ENE fix costs are in question 905 in the following PNGE categories: 631, 632, 633, 634, 635, 636, 6364+6365+6367, 637, 638, 639, 64, 65, 653, 654, 658 and "otros gastos" (651+652+655+656+659)

bysort io_sectors: centile (SB ), centile (25 ) 
 centile (SB ), centile (25 ) 
bysort io_sectors:  centile (SB ), centile (100 ) 
. summarize SB, detail

bysort io_sectors: egen p25 = pctile(SB), p(25)
drop if SB==.
g bottomq=1 if SB<=p25

svy: total C3P301A_T1 if bottomq==1 , over(io_sectors ) cformat(%9.2f) 
svy: tab io_sectors if bottomq==1, missing count format(%9.1g) col
svy: tab io_sectors , missing count format(%9.1g) col
/*
. use "C:\Users\Karly\Documents\Karlygash Dairabayeva\ECA Transport\Peru\00_Data\ISIC4.dta" , clear
rename ISIC4 isic4
sort isic4 
joinby isic4 using CB_isic4

. save "C:\Users\Karly\Documents\Karlygash Dairabayeva\ECA Transport\Peru\00_Data\CB_isic4.dta"
