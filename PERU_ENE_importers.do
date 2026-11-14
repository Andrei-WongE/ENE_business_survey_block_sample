clear all
set more off

global ROOT "C:\Users\Karly\Documents\Karlygash Dairabayeva\ECA Transport\Peru\"
global DATA "$ROOT\00_Data"
global OUTPUT "$ROOT\02_Output"
cd "$DATA"

use PERU_fulldata,clear

**********************************************************************************************************
* Enterprise survey PERU (2019) , ENE
**********************************************************************************************************
use "$DATA\ENE_firm_data\Base_ENE-2017_Final_mod_3.dta" ,clear
svyset [pw=FACTOR_EXPANS], strata(E_FORZOSO_CD)
svydescribe

********************************************************************************
****************************************************************************************************************************************************************************************
* 1. The number of importer companies in manufacturing, total and by sector. Source: ENE
* importer status = C4P408 
*  408. | Durante el  a�o 2016, Su empresa hizo pedidos de insumos a proveedores inte *
/*
 codebook sector2r4_2

---------------------------------------------------------------------------------------------------------------------------------------------
sector2r4_2                                                                                                               Sectores econ�micos
---------------------------------------------------------------------------------------------------------------------------------------------

                  type:  numeric (byte)
                 label:  sector2r4_2

                 range:  [1,8]                        units:  1
         unique values:  8                        missing .:  61/19,599

            tabulation:  Freq.   Numeric  Label
                           153         1  Pesca y acuicultura
                           368         2  Explotaci�n de minas y canteras
                         3,516         3  Industrias manufactureras
                           243         4  Suministro de electricidad, gas
                                          y agua
                         1,056         5  Construcci�n
                         6,276         6  Comercio
                         1,414         7  Transporte y almacenamiento
                         6,512         8  Servicios
                            61         .  

							
*/
ta C4P408
svy: tab dpto , missing count format(%9.1g) col
svy: tab dpto if C4P408==1, missing count format(%9.1g) col
svy: tab dpto if C4P408==1 & sector2r4_2==3, missing count format(%9.1g) col

*****************************************************************************************************************************************************************************************
* 2. Employment in importer companies (number of employees and share in total employment) total and by department.
*****************************************************************************************************************************************************************************************

svy: mean C3P301A_T2 if C6P624==1 
svy: mean C3P301A_T2 if C6P624==1 & sector2r4_2==3
svy: mean C3P301A_T2 if C6P624==2 

svy: total C3P301A_T2 , over(dpto) cformat(%9.2f) 
svy: total C3P301A_T2 if C4P408==1 & sector2r4_2==3, over(dpto) cformat(%9.2f) 
svy: total C3P301A_T2 if C4P408==1 , over(dpto) cformat(%9.2f) 
svy: total C3P301A_T2 if C4P408==1 & sector2r4_2==3, over(SIC) cformat(%9.2f) 


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
svy: total C9P904_1 , over(dpto) cformat(%9.2f) 

svy: total C9P904_1 if C4P408==1, over(dpto) cformat(%9.2f) 
svy: total C9P904_1 if C4P408==1 & sector2r4_2==3, over(dpto) cformat(%9.2f) 

 

********************************************************************************
* 4. Value added , total and by deparment 
********************************************************************************
*egen tot_VA= sum(C9P904_3), by(dpto) 

gen GVA = C9P904_7 - C9P905_9 //326 missing values and negative values!
    label var GVA "Gross Value Added"
replace GVA=0 if GVA<0


svy: total GVA if C4P408==1 & sector2r4_2==3, over(dpto) cformat(%9.2f) 
svy: total GVA if C4P408==1 , over(dpto) cformat(%9.2f) 
svy: total GVA , over(dpto) cformat(%9.2f) 

/*
svy: total C9P904_3 , over(dpto) cformat(%9.2f) 

svy: mean C9P904_3 if C6P624==1 /*ave sales*/
svy: mean C9P904_3 if C6P624==2 /*ave sales - non-exporter */


svy: total C9P904_3 if C6P624==1, over(groupnum) cformat(%9.2f) 
egen tot_VA= sum(C9P904_3), by(groupnum) 
svy: ratio C9P904_3/tot_VA if C6P624==1, over(groupnum) cformat(%9.3f) 

svy: total C9P904_3 if C6P624==1, over(p506r4) cformat(%9.2f) 
svy: ratio C9P904_3/tot_VA if C6P624==1, over(p506r4) cformat(%9.3f) 

