clear all
set more off

global ROOT "C:\Users\Karly\Documents\Karlygash Dairabayeva\ECA Transport\Peru\"
global DATA "$ROOT\00_Data"
global OUTPUT "$ROOT\02_Output"
cd "$DATA"

**********************************************************************************************************
* Enterprise survey PERU (2019) , ENE
**********************************************************************************************************
use "$DATA\ENE_firm_data\Base_ENE-2017_Final.dta" 

svyset [pw=FACTOR_EXPANS], strata(E_FORZOSO_CD)
svydescribe

**********************************************************************************************************
* 1. The number of exporter companies, total and by department. Source: ENE
* exporter status = C6P624 
* 624. En los �ltimos doce meses, �su empresa realiz� exportaciones de productos/s*
svy: tab dpto if C6P624==1, missing count format(%9.1g) col

**********************************************************************************************************
* 2. Employment in exporting companies (number of employees and share in total employment) total and by department.
egen tot_emp= sum(C3P301A_T2), by(dpto) /*total employees*/

svy: mean C3P301A_T2 if C6P624==1 /*ave n of employees*/
svy: mean C3P301A_T2 if C6P624==2 /*ave n of employees -non-exporter*/

svy: total C3P301A_T2 if C6P624==1, over(dpto) cformat(%9.2f) /*total employees by dept*/
svy: ratio C3P301A_T2/tot_emp if C6P624==1, over(dpto) cformat(%9.3f) /*ratio of employees in total employees*/

egen tot_emp_exp= sum(C3P301A_T2) if C6P624==1, by(dpto) /*total employees*/
svy: ratio C3P301A_T2/tot_emp_exp if C6P624==1, over(dpto) cformat(%9.3f) /*ratio of employees in total employees*/


********************************************************************************
* 3. Sales , total and by deparment 
********************************************************************************
* sales = C9P904_1 *
egen tot_sales= sum(C9P904_1), by(dpto) /*total sales*/
svy: total C9P904_1 if C6P624==1, over(dpto) cformat(%9.2f) /*total sales by dept*/
svy: ratio C9P904_1/tot_sales if C6P624==1, over(dpto) cformat(%9.3f) /*ratio of sales in total sales*/

svy: mean C9P904_1 if C6P624==1 /*ave sales*/
svy: mean C9P904_1 if C6P624==2 /*ave sales - non-exporter */

egen tot_sales_exp= sum(C9P904_1) if C6P624==1 , by(dpto) /*total sales*/
svy: ratio C9P904_1/tot_sales_exp if C6P624==1, over(dpto) cformat(%9.3f) /*ratio of sales in total sales*/

********************************************************************************
* 4. Value added , total and by deparment 
********************************************************************************
egen tot_VA= sum(C9P904_3), by(dpto) /*total sales*/
svy: total C9P904_3 if C6P624==1, over(dpto) cformat(%9.2f) /*total sales by dept*/
svy: ratio C9P904_3/tot_VA if C6P624==1, over(dpto) cformat(%9.3f) /*ratio of sales in total sales*/

svy: mean C9P904_3 if C6P624==1 /*ave sales*/
svy: mean C9P904_3 if C6P624==2 /*ave sales - non-exporter */

