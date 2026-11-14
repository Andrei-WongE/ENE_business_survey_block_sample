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

/*
******************************************************************************************
rename hscombinedproductcode hs6
g hs4=int(hs6/100)
g hs2=int(hs4/100)

gen group=""
replace group="Animal" if hs2==1|hs2==2|hs4==1601|hs4==1602
replace group="Dairy" if (hs4>=401&hs4<=406)
replace group="Fruit" if hs2==7|hs2==8 |(hs4>=1105&hs4<=1106)|(hs4>=2001&hs4<=2008)|hs2==19|(hs4>=601&hs4<=603)|hs4==1211|hs2==13|hs2==14
replace group="Coffee" if hs4>=901&hs4<=903|(hs2==18&hs4!=1802) |hs4==2101
replace group="Cereals" if (hs4>=407&hs4<=410)|(hs4>=1101&hs4<=1104)|(hs4>=1107&hs4<=1109)|hs2==19 |(hs4>=2102&hs4<=2106) |hs4==2209 |hs2==10
replace group="Oilseeds" if (hs4>=1201&hs4<=1208)|(hs2==15& hs6<150410)|(hs6>150410&hs6<150420)|(hs6>150420&hs2==15) |(hs4>=2304&hs4<=2306)|hs4==3823
replace group="Sugars"  if hs2==17
replace group="Beverages & tobacco" if hs4==2009|(hs4>=2201&hs4<=2208)|hs2==24
replace group="Cotton" if(hs4>=5201 &hs4<=5203) 
replace group="Other agric" if(hs4>=0904&hs4<=0910)|(hs2==05& hs4<0508) |(hs4>0508&hs6<051191)|(hs6>051191&hs2==5)|hs4==0604|(hs4>=1209 &hs4<=1210 )|(hs4>=1212 &hs4<=1214)|hs4==1802|hs6==230110|(hs4>=2302 &hs4<=2303)|(hs4>=2307 &hs4<=2309)|(hs6>=290543 &hs6<=290545)|hs4==3301|(hs4>=3501 &hs4<=3505)|hs6==380910 |hs6==382460|(hs4>=4101 &hs4<=4103) |hs4==4301|(hs4>=5001 &hs4<=5003)|(hs4>=5101&hs4<=5103)|(hs4>=5301 &hs4<=5302)

gen agric=0
replace agric=1 if group!=""

***
replace group="Fish" if hs2==3|hs4==0508|hs6==51191|hs6==150410|hs6==150420|(hs4>=1603&hs4<=1605)|hs6==230120
replace group="Minerals" if (hs4>=2601&hs4<=2617)|hs4==2620|(hs2>=72&hs4<7321)|(hs4>7322&hs2<=76)|(hs2>=78&hs4<8304)|(hs4>8305& hs2==83)|hs2==25|(hs4>=2618 &hs4<=2619)|hs4==2621|(hs4>=2701&hs4<=2704)|(hs4>=2706&hs4<=2708)|(hs4>=2711&hs4<=2715)|hs2==31|hs4==3403|(hs2>=68&hs2<6807)| (hs2>6807& hs6<701911)|(hs6>701919&hs6<701940)|(hs6>701959 &hs2<=71)|(hs6>=911310&hs6<=911320)
replace group="Petroleum" if hs4==2709 | hs4==2710
replace group="Chemicals" if hs4==2705 |(hs2>=28&hs6<290543)|(hs6>290545& hs6<300590)|(hs6>300590&hs2==30)| ((hs2>=32&hs2<=33)&(hs4!=3301&hs6!=330620)) |(hs2==34&(hs4!=3403&hs4!=3406))|(hs4>=3506&hs4<= 3507)|(hs4>=3601 &hs4<=3604)|((hs2>=37&hs2<=39)&(hs6!=380910&hs4!=3823&hs4!=382460&hs6!=392112&hs6!=392113&hs6!=392190))   
replace group="Wood" if hs2==44|hs2==45|hs2==47|hs2==48|hs2==49|((hs4>=9401&hs4<=9404)& hs6!=940490)|hs6==961900
replace group="Textiles" if hs6==300590|hs6==330620 |hs6==392112|hs6==392113|hs6==392190|hs6==420212|hs6==420222|hs6==420232 |hs6==420292| (hs4>5003 &hs4<5100)|(hs4>5103&hs4<5201)|(hs4>5203&hs4<5301)|(hs4>5302& hs2<=60)|hs2==63|hs6==640520|hs6==640610|(hs4>=6501 &hs4<=6505)|hs4==6601|(hs6>=701911 &hs6<=701919) |(hs6>=701940 &hs6<=701959)|hs6==870821|hs4==8804|hs6==911390|hs6==940490|hs6==961210
replace group="Clothing" if hs2== 61|hs2==62
replace group="Leather" if hs2==40|(hs2==41&hs4<4101)|(hs2==41&hs4>4103)|(hs4>=4201&hs6<420212)|(hs6>420212&hs6<420222)|(hs6>420222&hs6<420232)|(hs6>420232&hs6<420292) |(hs6>420292&hs4<=4205)|(hs4>=4302&hs4<=4304 )|(hs2==64&(hs6!=640520&hs6!=640610))|hs4==9605
replace group="Non-electrical" if(hs4>=7321 &hs4<= 7322)|(hs2==84&hs6<846721)|(hs6>846729&hs2==84)|hs6==850860|hs6==852841|hs6==852851|hs6==852861|hs4==8608|hs4==8709
replace group="Electrical machinery" if (hs6>846721&hs6<846729)|(hs2>=85&hs6<850860)|(hs6>850860 & hs6<852841)|(hs6>852841 &hs6<852851 )|( hs6>852851 & hs6<852861)| ( hs6>852861&hs6<8519)|hs6==852352 |hs4>8523&hs2==85
replace group="Transport" if (hs2==86&hs4!=8608)|((hs4>=8701 &hs4<=8708 )&(hs6!=870821))|(hs4>=8711 &hs4<=8714 )|hs4==8716|(hs4>=8801&hs4<=8803)|hs2==89
replace group="Other Manufactures" if hs4==2716|hs4==3406|(hs4>=3605&hs4<=3606 )|hs4==4206|hs2==46|(hs4>=6506 &hs4<=6507)|(hs4>=6602&hs4<=6603)|hs2==67|hs4==6807|(hs4>=8304 &hs4<=8305 )|((hs4>=8519 &hs4<=8523)&hs6!=852352)|hs4==8710|hs4==8715|hs4==8805|((hs2>=90&hs2<=93)& (hs4!=9113))|(hs4>=9405&hs4<=9406)|(hs2>=95& hs4<9605)|(hs4>9605& hs6<961210)|(hs6>961210&hs6<961900)|(hs6>961900 & hs2<=97)

gen groupnum=0
replace groupnum=1 if group=="Animal"
replace groupnum=2 if group=="Dairy"
replace groupnum=3 if group=="Fruit"
replace groupnum=4 if group=="Coffee"
replace groupnum=5 if group=="Cereals"
replace groupnum=6 if group=="Oilseeds"
replace groupnum=7 if group=="Sugars"
replace groupnum=8 if group=="Beverages & tobacc"
replace groupnum=9 if group=="Cotton"
replace groupnum=10 if group=="Other agric"
replace groupnum=11 if group=="Fish"
replace groupnum=12 if group=="Minerals"
replace groupnum=13 if group=="Petroleum"
replace groupnum=14 if group=="Chemicals"
replace groupnum=15 if group=="Wood"
replace groupnum=16 if group=="Textiles"
replace groupnum=17 if group=="Clothing"
replace groupnum=18 if group=="Leather"
replace groupnum=19 if group=="Non-electrical"
replace groupnum=20 if group=="Electrical machinery"
replace groupnum=21 if group=="Transport"
replace groupnum=22 if group=="Other Manufactures"

replace agric=1 if group=="Animal"|group=="Dairy"|group=="Fruit"|group=="Coffee"|group=="Cereals"|group=="Oilseeds"|group=="Sugars"|group=="Beverages & tobacco"|group=="Cotton"|group=="Other agric"

sort groupnum

rename hs6 productcode
sort productcode

merge productcode using productdescriptionHS6
ta _merge
drop if _merge==2
drop _merge
*/
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
* list of exporter codes *
********************************************************************************
ta SIC  if C6P624==1 & durable_goods==1 /* durable goods*/
ta sicproductdescription  if C6P624==1 & durable_goods==1 /* durable goods*/

ta p506r4 if C6P624==1 & durable_goods==1
ta isicrevision3productdescription  if C6P624==1  & durable_goods==1
/*
ta BEC4  if C6P624==1 & durable_goods==1
ta Description  if C6P624==1 & durable_goods==1
ta hscombinedproductdescription  if C6P624==1  & durable_goods==1
ta group  if C6P624==1 
ta description   if C6P624==1 
*/
/*
* all exporters *
ta p506r4 if C6P624==1 
ta isicrevision3productdescription  if C6P624==1  
keep if C6P624==1
rename p506r4 ISIC4
sort ISIC4
joinby ISIC4 using ISIC4
sort ISIC4 description
        quietly by ISIC4 description: gen dup = cond(_N==1,0,_n)
		drop if dup>1
		drop dup
keep ISIC4 description
*/
****************************************************************************************************************************************************************************************
* 1. The number of exporter companies, total and by sector. Source: ENE
* exporter status = C6P624 
* 624. En los �ltimos doce meses, �su empresa realiz� exportaciones de productos/s*
svy: tab dpto , missing count format(%9.1g) col
/*
svy: tab dpto if C6P624==1, missing count format(%9.1g) col
svy: tab dpto if C6P624==1 & durable_goods==1, missing count format(%9.1g) col
*****************************************************************************************************************************************************************************************
* 2. Employment in exporting companies (number of employees and share in total employment) total and by department.
*****************************************************************************************************************************************************************************************

svy: mean C3P301A_T2 if C6P624==1 
svy: mean C3P301A_T2 if C6P624==1 & durable_goods==1
svy: mean C3P301A_T2 if C6P624==2 

svy: total C3P301A_T2 , over(dpto) cformat(%9.2f) 
svy: total C3P301A_T2 if C6P624==1 & durable_goods==1, over(dpto) cformat(%9.2f) 
svy: total C3P301A_T2 if C6P624==1 , over(dpto) cformat(%9.2f) 
svy: total C3P301A_T2 if C6P624==1 & durable_goods==1, over(SIC) cformat(%9.2f) 


svy: total C3P301A_T2 if C6P624==1 , over(groupnum) cformat(%9.2f) 
egen tot_emp2= sum(C3P301A_T2), by(groupnum) 

svy: total C3P301A_T2 if C6P624==1, over(p506r4) cformat(%9.2f) 

ta p506r4 if C6P624==1
ta isicrevision3productdescription  if C6P624==1 
*ta p506r4 if groupnum==0

*egen tot_emp_exp= sum(C3P301A_T2) if C6P624==1, by(p506r4) 
*svy: ratio C3P301A_T2/tot_emp_exp if C6P624==1, over(p506r4) cformat(%9.3f) 

******************************************************************************************************************************************************************************************
* 3. Sales , total and by deparment 
******************************************************************************************************************************************************************************************
* sales = C9P904_1 *
egen tot_sales= sum(C9P904_1), by(dpto) /*total sales*/
svy: total C9P904_1 if C6P624==1, over(dpto) cformat(%9.2f) 
svy: ratio C9P904_1/tot_sales if C6P624==1, over(dpto) cformat(%9.3f) 

svy: mean C9P904_1 if C6P624==1 
svy: mean C9P904_1 if C6P624==2 

egen tot_sales_exp= sum(C9P904_1) if C6P624==1 , by(dpto) 
svy: ratio C9P904_1/tot_sales_exp if C6P624==1, over(dpto) cformat(%9.3f) 

svy: total C9P904_1 if C6P624==1, over(groupnum) cformat(%9.2f) 
egen tot_sales= sum(C9P904_1), by(groupnum) 
svy: ratio C9P904_1/tot_sales if C6P624==1, over(groupnum) cformat(%9.3f) 

svy: total C9P904_1 if C6P624==1, over(p506r4) cformat(%9.2f) 
svy: ratio C9P904_1/tot_sales if C6P624==1, over(p506r4) cformat(%9.3f) 

*/
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

g new_sector=""
replace new_sector="Pesca y acuicultura" if sector1r4==1
replace new_sector="Extracción de petróleo, gas, minerales y serv. conexos" if sector1r4==2
replace new_sector="Manufactura" if sector1r4==3
replace new_sector="Electricidad, gas y agua" if sector1r4==4 
replace new_sector="Electricidad, gas y agua" if sector1r4==5 
replace new_sector="Construcción" if sector1r4==6 
replace new_sector="Comercio, serv. de mant. y repar. de vehíc." if sector1r4==7 
replace new_sector="Transporte, almacen., correo y mensajería" if sector1r4==8 
replace new_sector="Alojamiento y restaurantes" if sector1r4==9 
replace new_sector="Transporte, almacen., correo y mensajería" if sector1r4==10

replace new_sector="Servicios financieros, seguros y pensiones" if sector1r4==11
replace new_sector="Otros servicios" if sector1r4==12
replace new_sector="Servicios prestados a empresas" if sector1r4==13
replace new_sector="Administración pública y defensa" if sector1r4==14
replace new_sector="Otros servicios" if sector1r4>=15

gen sector_num=0
replace sector_num=2 if sector1r4==1
replace sector_num=3 if sector1r4==2
replace sector_num=4 if sector1r4==3
replace sector_num=5 if sector1r4==4 
replace sector_num=5 if sector1r4==5 

replace sector_num=6 if sector1r4==6 
replace sector_num=7 if sector1r4==7 
replace sector_num=8 if sector1r4==8 
replace sector_num=9 if sector1r4==9 
replace sector_num=10 if sector1r4==10
replace sector_num=11 if sector1r4==11
replace sector_num=14 if new_sector=="Otros servicios"
replace sector_num=12 if new_sector=="Servicios prestados a empresas"
replace sector_num=13 if new_sector=="Administración pública y defensa" 

	/*
	label define regi 1 "Amazonas" 2 "Ancash" 3 "Apurimac" 4 "Arequipa" 5 "Ayacucho" 6 "Cajamarca" 8 "Cusco" 9 "Huancavelinca" 10 "Huanuco" ///
    11 "Ica" 12 "Junin" 13 "La Libertad" 14 "Lambayeque" 15 "Lima Metropolitana y Callao" 16 "Loreto" 17 "Mader de Dios" 18 "Moquegua" ///
    19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martin" 23 "Tacna" 24 "Tumbes" 25 "Ucayali" ,replace
    label values region regi
    replace region = 15 if region == 7 | lm == "1501"
    label var region "Regions"



svy: total C3P301A_T2 if lockdown_sectors == 1, over(dpto ) cformat(%9.2f) 
svy: total GVA if lockdown_sectors == 1, over(dpto) cformat(%9.2f) 

* by firm size *
g size=""
replace size="micro" if C3P301A_T2<=10
replace size="small" if C3P301A_T2>10 & C3P301A_T2 <49
replace size="medium" if C3P301A_T2>50 & C3P301A_T2 <100
replace size="large" if C3P301A_T2>100

encode size, g(size2)
svy: total C3P301A_T2 if lockdown_sectors == 1, over(size2 ) cformat(%9.2f) 

svy: total C3P301A_T2 if C6P624==1 & durable_goods==1, over(size2 ) cformat(%9.2f) 

svy: total C3P301A_T2 if C4P408==1 & sector2r4_2==3, over(size2 ) cformat(%9.2f) 

svy: total C3P301A_T2 , over(size2 ) cformat(%9.2f) 

* additional figures *
svy: total C3P301A_T2 if lockdown_sectors == 1, over(ciiu ) cformat(%9.2f) 
svy: total C3P301A_T2 , over(dpto ) cformat(%9.2f) 
svy: total C3P301A_T2 if lockdown_sectors == 1, over(dpto sector2r4_2) cformat(%9.2f) 


****************************************************************************************************************************************************************
* C3P301A_T1 - employment
****************************************************************************************************************************************************************

svy: total C3P301A_T1 if lockdown_sectors == 1, over(ciiu ) cformat(%9.2f) 
svy: total C3P301A_T1 , over(dpto ) cformat(%9.2f) 
svy: total C3P301A_T1 , over(sector2r4_2 ) cformat(%9.2f) 

svy: total C3P301A_T1 if lockdown_sectors == 1, over(dpto sector2r4_2) cformat(%9.2f)  
svy: total C3P301A_T1 if lockdown_sectors == 1, over( sector2r4_2) cformat(%9.2f)  

* importers, manufacturing *

svy: total C3P301A_T1 if C4P408==1  & sector2r4_2==3 , over( ciiu) cformat(%9.2f) 
svy: total C3P301A_T1 if C4P408==1  & sector2r4_2==3 & C6P624==1, over( ciiu) cformat(%9.2f) 
svy: total C3P301A_T1 if C4P408==1  & sector2r4_2==3 & C6P624==2, over( ciiu) cformat(%9.2f) 

  
svy: total C3P301A_T1 if C4P408==1  & sector2r4_2==3 , over(dpto ciiu) cformat(%9.2f)  
svy: total C3P301A_T1 if C4P408==1  & sector2r4_2==3 , over(dpto ciiu) cformat(%9.2f)  
  
* all exporters*
svy: total C3P301A_T1 if C6P624==1 , over(ciiu ) cformat(%9.2f) 
svy: total C3P301A_T1 if durable_goods==1, over(ciiu ) cformat(%9.2f) 

svy: total C3P301A_T1 if C6P624==1, over(dpto sector2r4_2) cformat(%9.2f)  
svy: total C3P301A_T1 if C6P624==1, over( sector2r4_2) cformat(%9.2f)  
svy: total C3P301A_T1 if durable_goods==1, over(dpto sector2r4_2) cformat(%9.2f)  

svy: total C3P301A_T1 , over( sector2r4_2) cformat(%9.2f)  

* all exporters and producers of durable goods *
replace durable_goods=0 if durable_goods==.
*g exporter_durablegoodprod=1 if C6P624==1 & durable_goods==1
*replace exporter_durablegoodprod=0 if exporter_durablegoodprod==.

svy: total C3P301A_T1 if C6P624==1 & durable_goods==0, over(ciiu ) cformat(%9.2f) 

svy: total C3P301A_T1 if durable_goods==1 , over(ciiu ) cformat(%9.2f) 

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
svy: total C3P301A_T1 , over(sector_num ) cformat(%9.2f) 
svy: total C3P301A_T1 if C6P624==1 , over(sector_num ) cformat(%9.2f) 
svy: total C3P301A_T1 if C4P408==1  & sector2r4_2==3 & C6P624==2, over( sector_num) cformat(%9.2f) 
svy: total C3P301A_T1 if new_lockdown == 1  , over( sector_num) cformat(%9.2f) 

svy: total C3P301A_T1 if durable_goods==1 & C6P624==2, over(sector_num ) cformat(%9.2f) 
****************************************************************************************************************************************************************
* 4. Value added , total and by deparment  * GVA
****************************************************************************************************************************************************************
gen GVA = C9P904_7 - C9P905_9 //326 missing values and negative values!
    label var GVA "Gross Value Added"
replace GVA=0 if GVA<0
	
*C9P904_7 = 07 Total ingresos (03 al 06)
*C9P905_9 = 63 Gastos de servicios prestados por terceros (10 al 15 + 17 al 19)

/*
* all exporters and producers of durable goods *
svy: total GVA if C6P624==1 & durable_goods==0, over(ciiu ) cformat(%9.2f) 

svy: total GVA if durable_goods==1 , over(ciiu ) cformat(%9.2f) 
svy: total GVA , over(dpto ) cformat(%9.2f) 

* importers, manufacturing *

svy: total GVA if C4P408==1  & sector2r4_2==3 , over( ciiu) cformat(%9.2f) 
svy: total GVA if C4P408==1  & sector2r4_2==3 & C6P624==1, over( ciiu) cformat(%9.2f) 
svy: total GVA if C4P408==1  & sector2r4_2==3 & C6P624==2, over( ciiu) cformat(%9.2f) /* importers, excludes exporting*/

svy: total GVA if C6P624==1 & durable_goods==1, over(dpto) cformat(%9.2f) 
svy: total GVA if C6P624==1  , over(dpto) cformat(%9.2f) 
svy: total GVA , over(dpto) cformat(%9.2f) 

svy: total GVA if lockdown_sectors == 1, over(ciiu ) cformat(%9.2f) 
svy: total GVA , over(dpto ) cformat(%9.2f) 
svy: total GVA , over(sector2r4_2 ) cformat(%9.2f) 

svy: total GVA if lockdown_sectors == 1, over(dpto sector2r4_2) cformat(%9.2f)  
svy: total GVA if lockdown_sectors == 1, over( sector2r4_2) cformat(%9.2f)  

* importers, manufacturing *
svy: total GVA if C4P408==1  & sector2r4_2==3 , over( ciiu) cformat(%9.2f) 
  
svy: total GVA if C4P408==1  & sector2r4_2==3 , over(dpto ciiu) cformat(%9.2f)  
svy: total GVA if C4P408==1  & sector2r4_2==3 , over(dpto ciiu) cformat(%9.2f)  

* all exporters and producers of durable goods *
svy: total GVA if C6P624==1, over(ciiu ) cformat(%9.2f) 
svy: total GVA if  durable_goods==1, over(ciiu ) cformat(%9.2f) 

svy: total GVA if C6P624==1, over(dpto sector2r4_2 ) cformat(%9.2f) 
svy: total GVA if C6P624==1, over( sector2r4_2 ) cformat(%9.2f) 

svy: total GVA if  durable_goods==1, over(dpto sector2r4_2 ) cformat(%9.2f) 

* over the sectors *
svy: total GVA if C6P624==1 , over(sector1r4 ) cformat(%9.2f) 
svy: total GVA if durable_goods==1, over(sector1r4 ) cformat(%9.2f) 
svy: total GVA if C4P408==1  & sector2r4_2==3 , over( sector1r4) cformat(%9.2f) 
svy: total GVA if C4P408==1  & sector2r4_2==3 & C6P624==1, over( sector1r4) cformat(%9.2f) 
svy: total GVA if C4P408==1  & sector2r4_2==3 & C6P624==2, over( sector1r4) cformat(%9.2f) 
svy: total GVA if lockdown_sectors == 1  , over( sector1r4) cformat(%9.2f) 

**= total GVA *
svy: total GVA , over(sector1r4 ) cformat(%9.2f) 
svy: total GVA if new_lockdown == 1  , over( sector1r4) cformat(%9.2f) 

svy: total GVA if sector1r4 == 9  & C6P624==1,  cformat(%9.2f) 
svy: total GVA if sector1r4 == 9  & durable_goods==1,  cformat(%9.2f) 
* gen nacimi_2   = real(substr((overdptociiu),-4,4)) /* extracting last 4 digits */
*/

* over the new IO sectors *
svy: total GVA , over(sector_num ) cformat(%9.2f) 
svy: total GVA if C6P624==1 , over(sector_num ) cformat(%9.2f) 
svy: total GVA if durable_goods==1 & C6P624==2, over(sector_num ) cformat(%9.2f) 
/*
svy: total GVA if C4P408==1  & sector2r4_2==3 & C6P624==2, over( sector_num) cformat(%9.2f) 
svy: total GVA if new_lockdown == 1  , over( sector_num) cformat(%9.2f) 

/*
keep  if C6P624==1 & durable_goods==1
keep ciiu
sort ciiu 
        quietly by ciiu: gen dup = cond(_N==1,0,_n)
		drop if dup>1
		drop dup
		sort ciiu 

save ciiu_exporters_durable,replace


keep  if C4P408==1 & sector2r4_2==3
keep ciiu
sort ciiu 
        quietly by ciiu: gen dup = cond(_N==1,0,_n)
		drop if dup>1
		drop dup
		sort ciiu 

save ciiu_importer_manuf,replace
/*
keep if C6P624==1 & durable_goods==1
*keep if C4P408==1 & sector2r4_2==3
*keep if lockdown_sectors == 1
sort ciiu
merge ciiu using enaho
drop if _merge==2

*count_pers income
sort count_pers 
        quietly by count_pers: gen dup = cond(_N==1,0,_n)
		drop if dup>1
		drop dup

*ta ciiu count_pers
keep ciiu count_pers

*svy: total count_pers if lockdown_sectors == 1, over(dpto) cformat(%9.2f) 

/*
use "C:\Users\Karly\Documents\Karlygash Dairabayeva\ECA Transport\Peru\00_Data\ENAHO_aggreg\agregated_enaho_1.dta",clear
    rename p506r4 ciiu
sort ciiu
save enaho,replace
/*
rename M_CIIU_V4 ciuu
replace lockdown_sectors = 1 if ciiu==1312|ciuu=1420|ciiu==1399|ciiu==1391|ciiu==1393|ciiu==1392|ciiu==2220|ciiu==1512|ciiu==1394|ciiu==1311

