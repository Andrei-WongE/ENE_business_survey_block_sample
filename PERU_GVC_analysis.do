
clear all
set more off

global ROOT "C:\Users\Karly\Documents\Karlygash Dairabayeva\ECA Transport\Peru\"
global DATA "$ROOT\00_Data"
global OUTPUT "$ROOT\02_Output"
cd "$DATA"

**********************************************************************************************************
* Enterprise survey PERU (2019) , ENE
**********************************************************************************************************
use "$DATA\ENE_firm_data\Base_ENE-2017_Final_mod_3.dta" ,clear
svyset [pw=FACTOR_EXPANS], strata(E_FORZOSO_CD)
svydescribe

********************************************************************************
**

destring M_DIVISION_CD, g(ISIC4_2digit)
g sector_ICIO="Agriculture, hunting, forestry and fishing"  if ISIC4_2digit==01|ISIC4_2digit==02|ISIC4_2digit==03
g ICIO="D01T03" if ISIC4_2digit==01|ISIC4_2digit==02|ISIC4_2digit==03

replace sector_ICIO="Mining and extraction of energy producing products"  if ISIC4_2digit==05|ISIC4_2digit==06
replace ICIO="D05T06"  if ISIC4_2digit==05|ISIC4_2digit==06

replace sector_ICIO="Mining and quarrying of non-energy producing products"  if ISIC4_2digit==07|ISIC4_2digit==08
replace ICIO="D07T08" if ISIC4_2digit==07|ISIC4_2digit==08

replace sector_ICIO="Mining and quarrying of non-energy producing products"  if ISIC4_2digit==09
replace ICIO="D09" if ISIC4_2digit==09
    

replace sector_ICIO="Food products, beverages and tobacco"   if ISIC4_2digit==10 |ISIC4_2digit==11|ISIC4_2digit==12
replace ICIO="D10T12" if ISIC4_2digit==10 |ISIC4_2digit==11|ISIC4_2digit==12 

replace sector_ICIO="Textiles, textile products, leather and footwear"   if ISIC4_2digit==13 |ISIC4_2digit==14|ISIC4_2digit==15
replace ICIO="D13T15" if ISIC4_2digit==13 |ISIC4_2digit==14|ISIC4_2digit==15

replace sector_ICIO="Wood and products of wood and cork"   if ISIC4_2digit==16
replace ICIO="D16" if ISIC4_2digit==16

replace sector_ICIO="Paper products and printing"   if ISIC4_2digit==17 |ISIC4_2digit==18
replace ICIO="D17T18"  if ISIC4_2digit==17 |ISIC4_2digit==18

replace sector_ICIO="Coke and refined petroleum products"   if ISIC4_2digit==19
replace ICIO="D19"  if ISIC4_2digit==19 

replace sector_ICIO="Chemicals and chemical products"   if ISIC4_2digit==20|ISIC4_2digit==21
replace ICIO="D20T21" if ISIC4_2digit==20|ISIC4_2digit==21

replace sector_ICIO="Rubber and plastics products"   if ISIC4_2digit==22
replace ICIO="D22"  if ISIC4_2digit==22

replace sector_ICIO="Other non-metallic mineral products"   if ISIC4_2digit==23
replace ICIO="D23"  if ISIC4_2digit==23

replace sector_ICIO="Basic metals"   if ISIC4_2digit==24
replace ICIO="D24"  if ISIC4_2digit==24

replace sector_ICIO="Fabricated metal products"   if ISIC4_2digit==25
replace ICIO="D25"  if ISIC4_2digit==25

replace sector_ICIO="Computer, electronic and optical equipment"   if ISIC4_2digit==26
replace ICIO="D26"  if ISIC4_2digit==26

replace sector_ICIO="Electrical machinery and apparatus, nec"   if ISIC4_2digit==27
replace ICIO="D27"  if ISIC4_2digit==27

replace sector_ICIO="Machinery and equipment, nec"   if ISIC4_2digit==28
replace ICIO="D28"  if ISIC4_2digit==28

replace sector_ICIO="Motor vehicles, trailers and semi-trailers"   if ISIC4_2digit==29
replace ICIO="D29"  if ISIC4_2digit==29

replace sector_ICIO="Other transport equipment"   if ISIC4_2digit==30
replace ICIO="D30"  if ISIC4_2digit==30

replace sector_ICIO="Manufacturing nec; repair of machinery and equipment"   if ISIC4_2digit==31 |ISIC4_2digit==32|ISIC4_2digit==33
replace ICIO="20D31T33" if ISIC4_2digit==31 |ISIC4_2digit==32|ISIC4_2digit==33

replace sector_ICIO="Electricity, gas, water supply, sewerage, waste and remediation services"   if ISIC4_2digit==35 |ISIC4_2digit==36|ISIC4_2digit==37|ISIC4_2digit==38|ISIC4_2digit==39
replace ICIO="21D35T39" if ISIC4_2digit==35 |ISIC4_2digit==36|ISIC4_2digit==37|ISIC4_2digit==38|ISIC4_2digit==39

replace sector_ICIO="Construction"  if ISIC4_2digit==41 |ISIC4_2digit==42|ISIC4_2digit==43
replace ICIO="D41T43" if ISIC4_2digit==41 |ISIC4_2digit==42|ISIC4_2digit==43

replace sector_ICIO="Wholesale and retail trade; repair of motor vehicles"   if ISIC4_2digit==45 |ISIC4_2digit==46|ISIC4_2digit==47
replace ICIO="D45T47" if ISIC4_2digit==45 |ISIC4_2digit==46|ISIC4_2digit==47

replace sector_ICIO="Transportation and storage"   if ISIC4_2digit==49 |ISIC4_2digit==50 |ISIC4_2digit==51|ISIC4_2digit==52|ISIC4_2digit==53
replace ICIO="D49T53" if ISIC4_2digit==49 |ISIC4_2digit==50 |ISIC4_2digit==51|ISIC4_2digit==52|ISIC4_2digit==53

replace sector_ICIO="Accomodation and food services"   if ISIC4_2digit==55 |ISIC4_2digit==56 
replace ICIO="D55T56" if ISIC4_2digit==55 |ISIC4_2digit==56 

replace sector_ICIO="Publishing, audiovisual and broadcasting activities"   if ISIC4_2digit==58 |ISIC4_2digit==59  |ISIC4_2digit==60
replace ICIO="D58T60" if ISIC4_2digit==58 |ISIC4_2digit==59  |ISIC4_2digit==60

replace sector_ICIO="Telecommunications"   if ISIC4_2digit==61
replace ICIO="D61"  if ISIC4_2digit==61

replace sector_ICIO="IT and other information services"   if ISIC4_2digit==62|ISIC4_2digit==63
replace ICIO="D62T63"   if ISIC4_2digit==62|ISIC4_2digit==63

replace sector_ICIO="Financial and insurance activities"   if ISIC4_2digit==64|ISIC4_2digit==65|ISIC4_2digit==66
replace ICIO="D64T66" if ISIC4_2digit==64|ISIC4_2digit==65|ISIC4_2digit==66

replace sector_ICIO="Real estate activities"   if ISIC4_2digit==68
replace ICIO="D68"  if ISIC4_2digit==68

replace sector_ICIO="Other business sector services"   if ISIC4_2digit>=69 & ISIC4_2digit<=75 |ISIC4_2digit>=77 & ISIC4_2digit<=82
replace ICIO="D69T82" if ISIC4_2digit>=69 & ISIC4_2digit<=75 |ISIC4_2digit>=77 & ISIC4_2digit<=82

replace sector_ICIO="Public admin. and defence; compulsory social security"   if ISIC4_2digit==84
replace ICIO="D84"  if ISIC4_2digit==84

replace sector_ICIO="Education"   if ISIC4_2digit==85
replace ICIO="D85"  if ISIC4_2digit==85

replace sector_ICIO="Health and social work"   if ISIC4_2digit==86 |ISIC4_2digit==87  |ISIC4_2digit==88
replace ICIO="D86T88" if ISIC4_2digit==86 |ISIC4_2digit==87  |ISIC4_2digit==88

replace sector_ICIO="Other community, social and personal services"   if ISIC4_2digit>=90 & ISIC4_2digit<=96
replace ICIO="D90T96" if ISIC4_2digit>=90 & ISIC4_2digit<=96

replace sector_ICIO="Private households with employed persons"   if ISIC4_2digit==97 |ISIC4_2digit==98
replace ICIO="D97T98" if ISIC4_2digit==97 |ISIC4_2digit==98

*********** aggregates ***********
g ICIO_agg="D10T33"
g ICIO_agg_descr="Total Manufacturing" if  ISIC4_2digit>=10 |ISIC4_2digit<=33

replace ICIO_agg="D05T09"
replace ICIO_agg_descr="Mining and quarrying" if ICIO=="D05T06" |ICIO=="D07T08"|ICIO=="D09"

replace ICIO_agg="D01T03"
replace ICIO_agg_descr="Agriculture, forestry and fishing" if ISIC4_2digit==01|ISIC4_2digit==02|ISIC4_2digit==03

replace ICIO_agg="D35T39"
replace ICIO_agg_descr="Electricity, gas, water supply, sewerage, waste and remediation services" if ISIC4_2digit>=35 & ISIC4_2digit<=39

replace ICIO_agg="D41T43"
replace ICIO_agg_descr="Construction" if ISIC4_2digit>=41 & ISIC4_2digit<=43

replace ICIO_agg="D45T82"
replace ICIO_agg_descr="Total business sector services" if ISIC4_2digit>=45 & ISIC4_2digit<=82

replace ICIO_agg="D84T98"
replace ICIO_agg_descr="Public admin, education and health; social and personal services" if ISIC4_2digit>=84 & ISIC4_2digit<=98


ta _merge

sort ICIO
drop _merge
merge ICIO using EXGR_TFVAIND
ta _merge
drop if ID==.
sort ID 
        quietly by ID: gen dup = cond(_N==1,0,_n)
		drop if dup>1
		drop dup
drop if MRUC==""

sort ICIO
drop _merge
joinby ICIO using EXGR_FVA

sort ICIO
joinby ICIO using EXGR_FVASH

sort ICIO
joinby ICIO using EXGR_DVAFXSH

/*
/*
/*

encode ICIO, g (number)
  set matsize 800
  set emptycells     drop

  /*
svy: total C3P301A_T2 , over( number) cformat(%9.2f) 
svy: total C3P301A_T2 , over(dpto number) cformat(%9.2f) 
egen tot_empl= sum(C3P301A_T2), by(ICIO dpto) /*total sales*/
*/
sort dpto number
egen totemployment=sum(C3P301A_T2)
by dpto number: egen employment2=sum(C3P301A_T2)
gen sh_empl=employment2/totemployment
generate w2employment=C3P301A_T2/employment2

*g FVA_sector=EXGR_FVASH*w2employment
g FVA_sector=EXGR_TFVAIND*w2employment

by dpto number: egen avFVA=mean(EXGR_FVASH)
gen intermed2 =w2employment*EXGR_FVASH 
by dpto : egen w2FVA =sum(intermed2)
order C3P301A_T2  dpto, after(number)

svy: total FVA_sector , over(dpto ) cformat(%9.2f) 

/*
local time "old new" 
foreach x of local time { 
by group: egen avtarif_`x'=mean(rate_`x')
gen intermed2_`x' =w2import*rate_`x' 
by group: egen w2tarif_`x' =sum(intermed2_`x')
}
svy: total FVA_sector , over(dpto ) cformat(%9.2f) 

order C3P301A_T2  dpto, after(number)

********************************************************************************
* employment by sector:
use empl_sector.dta, clear

drop sector
sort dpto
by dpto: egen sum=sum(labor)
drop if labor==.
*/
*/
*/
*/
* FVA and DVA by sector, using total employment as weights *
cd "C:\Users\Karly\Documents\Karlygash Dairabayeva\ECA Transport\Peru\02_Output\"
use fva_dva_sector,clear
rename icio ICIO
sort ICIO
joinby ICIO using share_VALU
g dva_sector=DVA_sh_va*weight_empl

sort ICIO
joinby ICIO using "C:\Users\Karly\Documents\Karlygash Dairabayeva\ECA Transport\Peru\02_Output\icio_sector.dta",

collapse(sum) fva_sector dva_sector, by(dpto)
collapse(sum) fva_sector dva_sector, by(ICIO sector_icio)

/*
keep ICIO sector_ICIO ICIO_agg ICIO_agg_descr EXGR_TFVAIND EXGR_FVA EXGR_FVASH
sort sector_ICIO EXGR_TFVAIND EXGR_FVA EXGR_FVASH
quietly by sector_ICIO EXGR_TFVAIND EXGR_FVA EXGR_FVASH: gen dup = cond(_N==1,0,_n)
		drop if dup>1
		drop dup

*collapse(sum) EXGR_FVA, by (ICIO_agg ICIO_agg_descr)
collapse(mean) EXGR_TFVAIND EXGR_FVASH, by (ICIO_agg ICIO_agg_descr)
		/*

********************************************************************************
* GVC data *
********************************************************************************

import delimited "$DATA\All_Core_Indicators\EXGR_TFVAIND.csv" , delimiter("|") clear 
rename v5 year
rename v6 EXGR_TFVAIND 
rename v4 ICIO
rename v2 reporter
rename v3 partner
drop v1
keep if reporter=="PER"
keep if year==2015
sort ICIO
save EXGR_TFVAIND,replace

import delimited "$DATA\All_Core_Indicators\EXGR_FVA.csv" , delimiter("|") clear 
rename v5 year
rename v6 EXGR_FVA 
rename v4 ICIO
rename v2 reporter
rename v3 partner
drop v1
keep if reporter=="PER"
keep if year==2015
sort ICIO
save EXGR_FVA,replace


import delimited "$DATA\All_Core_Indicators\EXGR_FVASH.csv" , delimiter("|") clear 
rename v5 year
rename v6 EXGR_FVASH 
rename v4 ICIO
rename v2 reporter
rename v3 partner
drop v1
keep if reporter=="PER"
keep if year==2015
sort ICIO
save EXGR_FVASH,replace

import delimited "$DATA\All_Core_Indicators\DEXFVApSH.csv" , delimiter("|") clear 
rename v5 year
rename v6 DEXFVApSH 
rename v4 ICIO
rename v2 reporter
keep if v3=="PER"
rename v3 partner
drop v1
keep if reporter=="PER"
keep if year==2015
sort ICIO
save DEXFVApSH,replace
*/
*/
*/
*/
use   "C:\Users\Karly\Documents\Karlygash Dairabayeva\ECA Transport\Peru\02_Output\fva_dva_shares.dta",clear
collapse(mean)exgr_fvash exgr_tfvaind exgr_dvafxsh , by(icio_agg_descr)



/*
import delimited "$DATA\All_Core_Indicators\EXGR_DVAFXSH.csv" , delimiter("|") clear 
rename v5 year
rename v6 EXGR_DVAFXSH 
rename v4 ICIO
rename v2 reporter
rename v3 partner
drop v1
keep if reporter=="PER"
keep if year==2015
sort ICIO
joinby ICIO using "C:\Users\Karly\Documents\Karlygash Dairabayeva\ECA Transport\Peru\02_Output\icio_peru_sectors.dta" 
egen sum=sum(EXGR_DVAFXSH)
g share=EXGR_DVAFXSH/sum
collapse(sum) share, by (icio_agg_descr)
save EXGR_DVAFXSH,replace

import delimited "$DATA\All_Core_Indicators\FEXDVApSH.csv" , delimiter("|") clear 
keep if v2=="PER"
rename v5 year
keep if year==2015
rename v6 FEXDVApSH 
gsort -FEXDVApSH
*/

*Total domestic value added embodied in gross exports (by sector), USD
import delimited "$DATA\All_Core_Indicators\EXGR_DVA.csv" , delimiter("|") clear 
keep if v2=="PER"
rename v5 year
rename v6 EXGR_DVA 
keep if year==2015
drop if v3=="ZNAM"|v3=="ZASI"|v3=="ZSCA" |v3=="ZOTH"|v3=="ZEUR"|v3=="G20"|v3=="EA12"|v3=="EA19"|v3=="EU13"|v3=="EU15"|v3=="EU28"|v3=="EASIA"|v3=="ASEAN"|v3=="APEC"|v3=="NONOECD"|v3=="OECD"|v3=="WLD"
rename v4 ICIO
sort ICIO
joinby ICIO using "C:\Users\Karly\Documents\Karlygash Dairabayeva\ECA Transport\Peru\02_Output\icio_peru_sectors.dta" 
*collapse(sum)EXGR_DVA, by(v3)
collapse(sum)EXGR_DVA, by(ICIO)
sort ICIO
save EXGR_DVA,replace

import delimited "$DATA\All_Core_Indicators\VALU.csv" , delimiter("|") clear 
keep if v2=="PER"
rename v5 year
rename v6 VALU 
rename v4 ICIO
keep if year==2015
keep ICIO VALU
sort ICIO
joinby ICIO using EXGR_DVA
g DVA_sh_va=(EXGR_DVA/VALU)*100
order VALU, after(EXGR_DVA)
sort ICIO
save share_VALU,replace


/* backward and forward GVC participation 
5.11 DEXFVApSH : Backward participation in GVCs, percentage
5.13 FEXDVApSH: Forward participation in GVCs, percentage
*/
import delimited "$DATA\All_Core_Indicators\DEXFVApSH.csv" , delimiter("|") clear 
keep if v3=="PER"
rename v5 year
rename v6 DEXFVApSH 
rename v4 ICIO
keep if year==2015
drop if v2=="ZNAM"|v2=="ZASI"|v2=="ZSCA" |v2=="ZOTH"|v2=="ZEUR"|v2=="G20"|v2=="EA12"|v2=="EA19"|v2=="EU13"|v2=="EU15"|v2=="EU28"|v2=="EASIA"|v2=="ASEAN"|v2=="APEC"|v2=="NONOECD"|v2=="OECD"|v2=="WLD"

import delimited "$DATA\All_Core_Indicators\FEXDVApSH.csv" , delimiter("|") clear 
keep if v2=="PER"
drop if v3=="ZNAM"|v3=="ZASI"|v3=="ZSCA" |v3=="ZOTH"|v3=="ZEUR"|v3=="G20"|v3=="EA12"|v3=="EA19"|v3=="EU13"|v3=="EU15"|v3=="EU28"|v3=="EASIA"|v3=="ASEAN"|v3=="APEC"|v3=="NONOECD"|v3=="OECD"|v3=="WLD"
rename v5 year
rename v6 FEXDVApSH 
rename v4 ICIO
keep if year==2015
gsort -FEXDVApSH

* by sector 
* 5.12 EXGR_DVAFXSH: Domestic value added embodied in foreign exports as share of gross exports, percentage
* It is often considered as a measure of 'forward linkages' in analyses of GVCs

import delimited "$DATA\All_Core_Indicators\EXGR_DVAFXSH.csv" , delimiter("|") clear 
keep if v2=="PER"
rename v5 year
keep if year==2015
rename v6 EXGR_DVAFXSH 
rename v4 ICIO
sort ICIO
joinby ICIO using "C:\Users\Karly\Documents\Karlygash Dairabayeva\ECA Transport\Peru\02_Output\icio_peru_sectors.dta" 

* 5.9 EXGR_FVASH: Foreign value added share of gross exports, percentage
* It is a ‘FVA intensity measure' often referred to as 'import content of exports' and considered as a measure of 'backward linkages' in analyses of GVCs.
import delimited "$DATA\All_Core_Indicators\EXGR_FVASH.csv" , delimiter("|") clear 
keep if v2=="PER"
rename v5 year
keep if year==2015
rename v6 EXGR_FVASH 
rename v4 ICIO
sort ICIO
sort ICIO
merge ICIO using "C:\Users\Karly\Documents\Karlygash Dairabayeva\ECA Transport\Peru\02_Output\icio_peru_sectors.dta" 
ta _merge

* 6.2 FFD_DVApSH: Domestic value added embodied in foreign final demand, partner shares, percentage
import delimited "$DATA\All_Core_Indicators\FFD_DVApSH.csv" , delimiter("|") clear 
keep if v4=="DTOTAL"
keep if v2=="PER"
*drop if v3=="ZNAM"|v3=="ZASI"|v3=="ZSCA" |v3=="ZOTH"|v3=="ZEUR"|v3=="G20"|v3=="EA12"|v3=="EA19"|v3=="EU13"|v3=="EU15"|v3=="EU28"|v3=="EASIA"|v3=="ASEAN"|v3=="APEC"|v3=="NONOECD"|v3=="OECD"|v3=="WLD"

keep if v3=="ZNAM"|v3=="ZASI"|v3=="ZSCA" |v3=="ZOTH"|v3=="ZEUR"|v3=="G20"|v3=="EA12"|v3=="EA19"|v3=="EU13"|v3=="EU15"|v3=="EU28"|v3=="EASIA"|v3=="ASEAN"|v3=="APEC"|v3=="NONOECD"|v3=="OECD"|v3=="WLD"

keep if v3=="ZEUR"|v3=="ZASI"|v3=="ZNAM"|v3=="ZOTH"|v3=="ZSCA" 

rename v6 FFD_DVApSH
rename v5 year
reshape wide FFD_DVApSH, i(v3)j(year)
