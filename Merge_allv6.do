///-----------------------------------------------------------------------------
/// Project: Impact of COVID-19 on GVC´s of Peru.
/// Creation date: 01/06/2020
/// Last modification: 23/07/2020
/// Author: Andrei Wong Espejo, awongespejo@worldbank.org
///-----------------------------------------------------------------------------

///-----------------------------------------------------------------------------
/// Program Setup
///-----------------------------------------------------------------------------

    version 16              // Set Version number for backward compatibility
    set more off            // Disable partitioned output
    clear all               // Start with a clean slate
    set linesize 80         // Line size limit to make output more readable
    macro drop _all         // clear all macros
    capture log close       // Close existing log files
    //log using covidtxt, text replace      // Open log file
///-----------------------------------------------------------------------------

///-----------------------------------------------------------------------------

    /* RUNS THE FOLLOWING:
    0. Installs the require packages (Only run once! Need to decomment section!)
    1. Data wrangling
    2. Merge
    3. Generating requested stats

    */
///-----------------------------------------------------------------------------

    //Set directory
    global base "D:\Documents\Consultorias\World_Bank\Impact_COVID_note\Data\"
    cd "$base"

   //Install required packages!
   /*
    ssc install nmissing, replace
    ssc install distinct, replace
    ssc install keeporder, replace
    net install http://www.stata.com/users/kcrow/tab2xl, replace
    ssc install sumstats, replace
    ssc install labutil, replace
    net from https://www.sealedenvelope.com/ // Install xfill
   */

/////////////////////////////////////////////////////////////
//// 1. Data wrangling           ////
////////////////////////////////////////////////////////////

    // Dataset A: ENAHO / ID_vars = ubigeo, p506r4, p506, p505r4, p505 by employed HH
    // Dataset B: COVID / ID_vars = ubigeo, sector (p506r4), occupation (p505r4) by occ/sector/region
    // Dataset C: ENE   / ID_vars = ID, UBIGEO, p506r4 by firm (ID)
    // Dataset D: TivA  / ID_vars = p506r4 by sector (???)

/// Dataset A: ENAHO
    use "$base\ENAHO_2018\base_merged_main_var.dta", clear
    dis ustrto(ustrnormalize("ÁÉÍÓÚÑáéíóúñ", "nfd"), "ascii", 2)
    assert c(N) == 32403 // 5059 sin jefe de hogar

    nmissing p506r4 p505r4 //529 missing
    drop if p506r4==.|p505r4==.
    destring ciiu, replace
    format ciiu %04.0f
    destring ubigeo, replace
    format ubigeo %06.0f

    sort ciiu
    distinct ciiu ubigeo, joint

    count //  31,874

    tempfile base_enaho
    save "`base_enaho'"

    //
/// Dataset B: COVID
    use "$base\Gabriel and Aakash data\covid_econ_map_disagg.dta", clear

    destring ubigeo, replace
    format ubigeo %06.0f
    ren sector p506r4
    ren occupation p505r4
    format p506r4 p505r4 %04.0f
    count  //216,843

    tempfile base_covid
    save "`base_covid'"

    //collapse (mean) prox (sum) income [pw=fac500a] ,by(p505r4 p506r4 ubigeo)
    //sort p505r4 p506r4 ubigeo
    //count  //73,150

    //tempfile base_covid2
    //save "$base\Gabriel and Aakash data\base_covid2"

    //

///Dataset C: ENE
    //use "D:\Documents\Data\ENE\2017\Base_ENE-2017_Final_mod", clear
    use "D:\Documents\Data\ENE\2017\PERU_fulldata", clear
    assert c(N)==19599

    //Only when using PERU_fulldata
    *
     rename UBIGEO ubigeo
     gen region = floor(ubigeo/10000)
     gen lm = floor(ubigeo/100)

        label define regi 1 "Amazonas" 2 "Ancash" 3 "Apurimac" 4 "Arequipa" ///
        5 "Ayacucho" 6 "Cajamarca" 8 "Cusco" 9 "Huancavelica" 10 "Huanuco" ///
        11 "Ica" 12 "Junin" 13 "La Libertad" 14 "Lambayeque" 15 "Lima Metropolitana y Callao" 16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" ///
        21 "Puno" 22 "San Martin" 23 "Tacna" 24 "Tumbes" 25 "Ucayali" ,replace
        label values region regi
        replace region = 15 if region == 7 | lm == 1501
        label var region "Regions"

            //0.Get "ciiu_code" variable [used for groups based on UN's "REV 4" document]
        gen p506r4_str = string(p506r4)
        replace p506r4_str = "0" + p506r4_str if length(p506r4_str) ==3
        gen ciiu_code =  substr(p506r4_str, 1, 2)
      replace ciiu_code = "" if ciiu_code == "."
        replace ciiu_code = "0" + ciiu_code if length(ciiu_code) == 1

      tab ciiu_code, missing sort

      //1. Low-level ciiu groups (21 categories, the standard in "UN Doc ISIC REV 4.pdf")
      gen g_ciiu = .
        *-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        replace g_ciiu = 1 if ciiu_code == "01" | ciiu_code == "02" | ciiu_code == "03"

        replace g_ciiu = 2 if ciiu_code == "05" | ciiu_code == "06" | ciiu_code == "07"
        replace g_ciiu = 2 if ciiu_code == "08" | ciiu_code == "09"

        replace g_ciiu = 3 if ciiu_code == "10" | ciiu_code == "11" | ciiu_code == "12"
        replace g_ciiu = 3 if ciiu_code == "13" | ciiu_code == "14" | ciiu_code == "15"
        replace g_ciiu = 3 if ciiu_code == "16" | ciiu_code == "17" | ciiu_code == "18"
        replace g_ciiu = 3 if ciiu_code == "19" | ciiu_code == "20" | ciiu_code == "21"
        replace g_ciiu = 3 if ciiu_code == "22" | ciiu_code == "23" | ciiu_code == "24"
        replace g_ciiu = 3 if ciiu_code == "25" | ciiu_code == "26" | ciiu_code == "27"
        replace g_ciiu = 3 if ciiu_code == "28" | ciiu_code == "29" | ciiu_code == "30"
        replace g_ciiu = 3 if ciiu_code == "31" | ciiu_code == "32" | ciiu_code == "33"

        replace g_ciiu = 4 if ciiu_code == "35"

        replace g_ciiu = 5 if ciiu_code == "36" | ciiu_code == "37" | ciiu_code == "38"
        replace g_ciiu = 5 if ciiu_code == "39"

        replace g_ciiu = 6 if ciiu_code == "41" | ciiu_code == "42" | ciiu_code == "43"

        replace g_ciiu = 7 if ciiu_code == "45" | ciiu_code == "46" | ciiu_code == "47"

        replace g_ciiu = 8 if ciiu_code == "49" | ciiu_code == "50" | ciiu_code == "51"
        replace g_ciiu = 8 if ciiu_code == "52" | ciiu_code == "53"

        replace g_ciiu = 9 if ciiu_code == "55" | ciiu_code == "56"

        replace g_ciiu = 10 if ciiu_code == "58" | ciiu_code == "59" | ciiu_code == "60"
        replace g_ciiu = 10 if ciiu_code == "61" | ciiu_code == "62" | ciiu_code == "63"

        replace g_ciiu = 11 if ciiu_code == "64" | ciiu_code == "65" | ciiu_code == "66"

        replace g_ciiu = 12 if ciiu_code == "68"

        replace g_ciiu = 13 if ciiu_code == "69" | ciiu_code == "70" | ciiu_code == "71"
        replace g_ciiu = 13 if ciiu_code == "72" | ciiu_code == "73" | ciiu_code == "74"
        replace g_ciiu = 13 if ciiu_code == "75"

        replace g_ciiu = 14 if ciiu_code == "77" | ciiu_code == "78" | ciiu_code == "79"
        replace g_ciiu = 14 if ciiu_code == "80" | ciiu_code == "81" | ciiu_code == "82"

        replace g_ciiu = 15 if ciiu_code == "84"

        replace g_ciiu = 16 if ciiu_code == "85"

        replace g_ciiu = 17 if ciiu_code == "86" | ciiu_code == "87" | ciiu_code == "88"

        replace g_ciiu = 18 if ciiu_code == "90" | ciiu_code == "91" | ciiu_code == "92"
        replace g_ciiu = 18 if ciiu_code == "93"

        replace g_ciiu = 19 if ciiu_code == "94" | ciiu_code == "95" | ciiu_code == "96"

        replace g_ciiu = 20 if ciiu_code == "97" | ciiu_code == "98"

        replace g_ciiu = 21 if ciiu_code == "99"
        *-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
      label define g_ciiu 1 "A: Agriculture/Fishing" 2 "B: Mining" 3 "C: Manufacturing" 4 "D: Energy" 5 "E: Water/Trash" 6 "F: Construction" 7 "G: Commerce" 8 "H: Transportation" 9 "I: Restaurants/Hotels" 10 "J: Telecom" 11 "K: Finance" 12 "L: Real Estate" 13 "M: Professional services/Research" 14 "N: Private Admin" 15 "O: Public Admin" 16 "P: Teaching" 17 "Q: Health" 18 "R: Art" 19 "S: Other services" 20 "T: Housework" 21 "U: Foreign Org."
      label values g_ciiu g_ciiu

        tab g_ciiu, missing sort

        //2.High-level ciiu groups (10 categories, based Table 4.1 in "UN Doc ISIC REV 4.pdf")

            gen g_hl_ciiu = .
                *-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
                replace g_hl_ciiu =  1 if g_ciiu == 1
                replace g_hl_ciiu =  2 if g_ciiu == 2 | g_ciiu == 3 | g_ciiu == 4| g_ciiu == 5
                replace g_hl_ciiu =  3 if g_ciiu == 6
                replace g_hl_ciiu =  4 if g_ciiu == 7 | g_ciiu == 8 | g_ciiu == 9
                replace g_hl_ciiu =  5 if g_ciiu == 10
                replace g_hl_ciiu =  6 if g_ciiu == 11
                replace g_hl_ciiu =  7 if g_ciiu == 12
                replace g_hl_ciiu =  8 if g_ciiu == 13 | g_ciiu == 14
                replace g_hl_ciiu =  9 if g_ciiu == 15 | g_ciiu == 16 | g_ciiu == 17
                replace g_hl_ciiu = 10 if g_ciiu == 18 | g_ciiu == 19 | g_ciiu == 20 | g_ciiu == 21
                *-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
            label define g_hl_ciiu 1 "I: Agriculture/Fishing" 2 "II: Mining/Manufacturing/Utilities" 3 "III: Construction" 4 "IV: Commerce/Transportation/Restaurants" 5 "V: Telecom" 6 "VI: Finance" 7 "VII: Real Estate" 8 "VIII: Professional/Research/Private Admin" 9 "IX: Public Admin/Teaching/Health" 10 "X: Other services", replace
            label values g_hl_ciiu g_hl_ciiu

            tab g_hl_ciiu

    // */

    //Only when using Base_ENE-2017_Final_mod
    /*
        drop _merge
    // */
    nmissing p506r4 ubigeo //51 missing
    drop if p506r4==.|ubigeo==.
    rename p506r4 ciiu
    format ciiu %04.0f

    #delimit ;
    keeporder ID ciiu ubigeo region g_ciiu g_hl_ciiu P25 T_EMPRESA_CD C1P111_1
    C1P111_2 C1P111_3 C3P301A_1 C3P301A_2 C3P301A_3 C3P301A_4 C3P301A_5 C3P301A_T1
    C3P301A_T2 C9P905_3 C9P905_4 C3P301D_1-C3P301D_5 C3P303_1-C3P303_3 C3P305
    C3P306 C4P408 C4P409 C4P410 C4P415 C5P502 C5P503_1 C5P506 C6P624 C9P904_7
    C9P907_T5 C6P626 C9P904_1 C9P904_2 C9P904_3 C9P904_7 C9P905_9 C9P905_2 C9P905_3
    C9P905_16 C9P905_20 C9P905_21 C9P905_26 C9P906_T4 sector2r4_2 SIC        sicproductdescription description durable_goods FACTOR_EXPANS E_FORZOSO_CD;
    #delimit cr

    sort ciiu
    distinct ciiu ubigeo, joint

    // (1) GPV (Gross Production Value) = total income (primary +  secondary)
    // (2) GVA (Gross Value Added) = GVP – intermediate consumption
    // (3) GDP (GDP) =  GVA + Taxes

    // GPV (Gross Production Value)= C9P904_7 Total ingresos (03-06)
    // GVA (Gross Value Added) = C9P904_7 - C9P905_9, where C9P905_9  Gastos de servicios prestados por terceros
    // GDP = C9P904_7 + C9P905_20 where C9P905_20  Tributos

    count //19548

    tempfile base_ene
    save `base_ene'

/// Dataset D: TivA
    /*
    cd "$base\TiVA OECD"
    import delimited using EXGR_FVA
    keep if v2=="PER"
    assert c(N)==606
    */
//Dataset E: EEA
/*
    use "D:\Documents\Data\ENE\2017\Base_ENE-2017_Final_mod", clear

    */

/*
    cd "$base"

/////////////////////////////////////////////////////////////
//// 2. Merge           ////
////////////////////////////////////////////////////////////
    //A) CIIU table ENE and ENAHO
    use "$base\ENAHO_2018\base_persons.dta", clear
    nmissing ciiu // 56379
    drop if ciiu==.

    merge m:m ciiu using `base_ene', gen(_mer)
    drop _merge*
    rename _mer _merge
    tab _merge

          gen lockdown_sectors = 0

      # delimit ;
        replace lockdown_sectors = 1 if inlist(ciiu, 1312, 1420, 1399, 1391, 1393,
        1392, 2220, 1512, 1394, 1311, 1313, 1410, 2811, 2814, 2790, 2910, 3091,
        2818, 2819, 2599, 2710, 2815, 2812, 2651, 2816, 2829, 3250, 2750, 2920,
        2930, 2813, 2740, 2399, 3011, 3020, 3030, 2591, 3315, 3012, 3100, 1622,
        2511, 2219, 1629, 2593, 2592, 3211, 3212, 3220, 3230, 3240, 2640, 3092,
        1701, 1709, 2022, 2817, 3290, 1811, 2826, 2023, 4510, 4530, 4540, 4659,
        4663, 4649, 4641, 4669, 4661, 4690, 4763, 4773, 4742, 4759, 4753, 9524,
        4752, 9522, 4711, 4721, 4722, 4771, 9529, 9523, 4764, 4751, 4761, 4719,
        4723, 2396, 4774, 5110, 5120, 4922, 5223, 5224, 8129, 5222, 3830, 5229,
        7729, 7722, 7721, 7730, 8620, 9000, 9329, 9312, 9311, 9319, 3319, 7420,
        9321, 9200, 7990, 5510, 5590, 5629, 5621, 5610, 5630, 9602, 9609, 5221,
        6190);
      # delimit cr
      //17,238 real changes made, based on 126 unique ciiu forvalues
      //label var  "lockdown_sectors"

      keep if lockdown_sectors==1

    keeporder region ciiu g_ciiu g_hl_ciiu p506r4 _merge
    label define _merge 1 "ENHO" 2 "ENE" 3 "BOTH", replace
    br
    export excel using "$base\Tabla_1h.xlsx", firstrow(variables) replace sheet("Sector_region")

    collapse (count) ciiu, by(region g_ciiu g_hl_ciiu _merge)
    drop ciiu

    export excel using "$base\Tabla_1h.xlsx", firstrow(variables) sheet("Region")
    */

/////////////////////////////////////////////////////////////
//// 3. Generating requested stats           ////
////////////////////////////////////////////////////////////

///1.General indications and suggestions
 *

///2. Lockdown shock
    use "$base\ENAHO_2018\base_persons.dta", clear
    assert c(N) == 130357

    nmissing p506r4 //56379 missing (minor aged, retired and unemployed)
    drop if p506r4==. // See ocu500!
    drop sector _merge*
    //gen ciiu_3d = int(ciiu/10)
    //format ciiu_3d %03.0f

    tab ocu500, miss
    keep if ocu500 == 1 // Only employed individuals!! 4,835 observations deleted
    decode region, g(region_names)

    ///Create lockdown_sectors variable
      //Convet NAICS 2017 to ISIC Rev. 4, //https://www.census.gov/eos/www/naics/concordances/concordances.html

      //NAICS Classification: Restaurants and bars: 7223-7225.--> 5629, 5621, 5610,
      //5630, 5610
      //Travel and Transportation: 4811, 4812, 4853, 4854, 4859, 4881, 4883, 7211.
      //--> 5110, 5120, 4922, 5223, 5224, 8129, 3315, 5222, 8129, 3315, 3830, 5229,
      // 5510, 5590, 9200
      //Personal Services: 6212, 8121, 8129. --> 8620, 9602, 9609, 7420, 5221, 6190, 9529
      //Entertainment: 7111, 7112, 7115, 7131, 7132, 7139. --> 9000, 9329, 9312,
      // 9311, 9319, 3290, 3319, 7420, 9321, 9200, 4922, 7990
      //Other sensitive retail: 4411, 4412, 4421, 4422, 4481, 4482, 4483, 4511,
      //4512, 4522, 4531, 4532, 4539, 5322, 5323, 4243, 4413, 4543. --> 4510, 4752,
      // 4510, 4530, 3315, 4753, 4763, 4510, 4540, 4773, 4759, 4752, 9522, 4773,
      // 4753, 9524, 4759, 4773, 4771, 4773, 9529, 9523, 4711, 4763, 4764, 4751,
      // 4759, 4761, 4719, 4721, 4722, 4761, 4773, 2396, 4752, 4759, 4774, 7722,
      // 7729, 7721, 7730, 4641, 4530, 4742, 4540, 4752
      //Sensitive Manufacturing: 3352, 3361, 3362, 3363, 3364, 3366, 3371, 3372,
      // 3379, 3399, 4231, 4232, 4239, 3132, 3141, 3149, 3152. --> 2750, 2910, 2811,
      // 2814, 2790, 3091, 2816, 2920, 2930, 2811, 2813, 2740, 2399, 2399, 1392,
      // 1399, 2220, 3011, 3020, 3030, 2591, 2819, 2930, 3030, 2813, 3011, 3315,
      // 3012, 3100, 3250, 3100, 1622, 2220, 2511, 2219, 2220, 3100, 1392, 1629,
      // 2593, 2599, 2592, 3211, 3212, 2219, 2829, 3220, 3230, 3240, 2640, 3092,
      // 3230, 1399, 1629, 1701, 1709, 2022, 2817, 2819, 3290, 1629, 1811, 2220,
      // 2819, 3220, 3240, 3290, 2818, 2599, 2710, 2790, 2815, 2812, 2651, 2599,
      // 2815, 2816, 2819, 2829, 3250, 2599, 2790, 1399, 1512, 1629, 1709, 2399,
      // 2819, 3220, 2599, 2826, 3290, 3290, 3290, 1410, 1629, 2023, 4510, 4530,
      // 4540, 4530, 4540, 4659, 4663, 4649, 4641, 4663, 4510, 4669, 4649, 4669,
      // 4659, 4661, 4663, 4690, 1312, 1420, 1399, 1391, 1420, 1393, 1392, 2220,
      // 1392, 1512, 2220, 1394, 1311, 1313, 1393, 1394, 1399, 1410, 1420
      //drop lockdown_sectors
      gen lockdown_sectors = 0

      # delimit ;
        replace lockdown_sectors = 1 if inlist(ciiu, 1312, 1420, 1399, 1391, 1393,
        1392, 2220, 1512, 1394, 1311, 1313, 1410, 2811, 2814, 2790, 2910, 3091,
        2818, 2819, 2599, 2710, 2815, 2812, 2651, 2816, 2829, 3250, 2750, 2920,
        2930, 2813, 2740, 2399, 3011, 3020, 3030, 2591, 3315, 3012, 3100, 1622,
        2511, 2219, 1629, 2593, 2592, 3211, 3212, 3220, 3230, 3240, 2640, 3092,
        1701, 1709, 2022, 2817, 3290, 1811, 2826, 2023, 4510, 4530, 4540, 4659,
        4663, 4649, 4641, 4669, 4661, 4690, 4763, 4773, 4742, 4759, 4753, 9524,
        4752, 9522, 4711, 4721, 4722, 4771, 9529, 9523, 4764, 4751, 4761, 4719,
        4723, 2396, 4774, 5110, 5120, 4922, 5223, 5224, 8129, 5222, 3830, 5229,
        7729, 7722, 7721, 7730, 8620, 9000, 9329, 9312, 9311, 9319, 3319, 7420,
        9321, 9200, 7990, 5510, 5590, 5629, 5621, 5610, 5630, 9602, 9609, 5221,
        6190);
      # delimit cr
      //17,238 real changes made, based on 126 unique ciiu forvalues
      label var lockdown_sectors "lockdown_sectors"

    assert c(N) == 69143
    /*
    drop if g_ciiu==15 //!!!!!TURN OFF!!!!!!
    count // 66,300
    */
    //------------------------------------------------------------------------//
   //svyset [pweight=fac500a], psu(conglome) strata(estrato) singleunit(certainty)

   ///Figure 1:
  //preserve

  ///Lockdown tables
    collapse (count) count_pers=id_pers [pw = fac500a], by(p505r4 p506r4 ciiu g_ciiu g_hl_ciiu ubigeo region_names lockdown_sectors)
    count //33,029
    /*
    collapse (count) count_pers=id_pers if lockdown_sectors==1 [pw = fac500a], by(ciiu p506r4 g_ciiu g_hl_ciiu)
    count //33,029
    decode g_hl_ciiu, g(ciiu_10cat)
    decode g_ciiu, g(ciiu_21cat)
    decode p506r4, g(ciiu_denomination)

    export excel using "$base\NAIC_ISIC.xlsx", firstrow(variables) nol sheet("NAIC_ISIC_lockdown_sectors_2", replace)
    */
    decode p506r4, g(sector)
    label values p506r4 .
    decode p505r4, g(ocupacion)
    label values p505r4 .
    format p506r4 p505r4 %04.0f

    sort p505r4 p506r4 ubigeo

    merge 1:m p505r4 p506r4 ubigeo using "$base\Gabriel and Aakash data\base_covid2"
    keep if _merge==3 //40,121 observations deleted

    drop _merge

    decode g_hl_ciiu, g(ciiu_10cat)
    decode g_ciiu, g(ciiu_21cat)

    tempfile base_merge
    save `base_merge'

    //Occupation weighted prox
    bysort region ciiu_21cat: egen tot_count_pers = total(count_pers)
    bysort region ciiu_21cat prox: gen p505r4_weight = count_pers/tot_count_pers

    collapse (mean) prox [pw = p505r4_weight], by(region ciiu_21cat)

     export excel using "$base\results.xlsx", firstrow(variables) nol sheet("New table-Proximity", modify)


    use `base_merge', clear

    collapse (sum) count_pers income (mean) prox, by(ciiu_10cat ciiu_21cat)

    export excel using "$base\results.xlsx", firstrow(variables) nol sheet("Figure 1-new version", modify)
    //367
   /*
   //Table 5. Employment by sector in Peru’s departments
    use `base_merge', clear

    collapse (sum) count_pers, by(region_names ciiu_21cat)

    export excel using "$base\results_new.xlsx", firstrow(variables) nol sheet("Table 5c", modify)
    */
   ///Map 1:

    use `base_merge', clear

    collapse (sum) count_pers income (mean) prox, by(region_names)

    export excel using "$base\results.xlsx", firstrow(variables) nol sheet("Map 1", modify)

   ///Figure 6b:

    use `base_merge', clear

    collapse (sum) income if lockdown_sectors==1, by(region_names)
    count //

    export excel using "$base\results.xlsx", firstrow(varlabels) sheet("Figure 6b", modify)


  restore
    //Figure 2: Use of ICT by department and national average. Percent. (Workers that use computers over total workers).
    //No uso internet en trabajo y en (computadora o laptop) casa, mes anterior
    //Para las personas de 3 años y mas de edad!!
    tab no_remote_infr
    //En el mes anterior, ¿ Ud. hizo uso del Servicio de Internet?
    tab p314a

    tab2xl region no_remote_infr using "$base\results.xlsx", sheet("Figure 2", replace) col(1) row(1)


   ///Figure 3: Employment in lockdown sectors by department and national average.
    //Using generic sectors!! (Hospitality, retail sector (excl. food & medical),
    //professional services, some sensitive manufacturing

  preserve

    collapse (count) count_pers=id_pers [pw = fac500a], by(region_names lockdown_sectors)
    count //3,858
    sort region_names lockdown_sectors
    distinct region_names

    export excel using "$base\results.xlsx", firstrow(varlabels) sheet("Figure 3")

  restore


  ///Figure 4: Informality by sector. Percent of total employment.
    //assert c(N)==69143

    tab ocupinf

    gen fac500a_r = round(fac500a)

    tab2xl g_ciiu ocupinf [fw = fac500a_r] using "$base\results.xlsx" , sheet("Figure 4") col(1) row(1)


  ///Map 2: Informality by department. Percent of total employment.

    tab2xl region ocupinf [fw = fac500a_r] using "$base\results.xlsx" , sheet("Map 2") col(1) row(1)

 *

  ///Figure 5: Value added in lockdown sectors by department and national average. ENE!

  ///Other tables
    // Employment for the 14 IO sectors by lockdown sectors, ENE and ENAHO
    svyset [pweight=fac500a], psu(conglome) strata(estrato) singleunit(certainty)

    egen io_sectors1 = anymatch(ciiu), values(0111/0116, 0119, 0121/0130, 0141/0146,   0149, 0150, 0161/0164, 0170, 0210, 0220, 0230, 0240)
    egen io_sectors2 = anymatch(ciiu), values(0311, 0312, 0321, 0322)
    replace io_sectors2 = 2 if io_sectors2 == 1
    egen io_sectors3 = anymatch(ciiu), values(0510, 0610, 0620, 0910, 0710, 0721, ///
    0729, 0810, 0891, 0892 ,0893, 0899, 0910, 0990)
    replace io_sectors3 = 3 if io_sectors3 == 1
    egen io_sectors4 = anymatch(ciiu), values(1010, 1020, 1030, 1040, 1050, 1061, ///
    1062, 1071/1075, 1079, 1080, 1101/1104, 1200, 1311/1313, 1391/1394, 1399, 1410, ///
    1420, 1430, 1511, 1512, 1520, 1610, 1621/1623, 1629, 1701, 1702, 1709, 1811, ///
    1812, 1820, 1910, 1920, 2011/2013, 2021/2023, 2029, 2030, 2100, 2211, 2219, ///
    2220, 2310, 2391/2396, 2399, 2410, 2420, 2431, 2432, 2511/2513, 2520, 2591/2593, ///
    2599, 2620, 2651, 2652, 2660, 2670, 2680, 2610, 2630, 2640, 2710, 2720, ///
    2731/2733, 2740, 2750, 2790, 2811, 2812, 2817, 2813/2816, 2818, 2819, ///
    821/2826, 2829, 2910, 2920, 2930, 3011, 3012, 3020, 3030, 3040, 3091, 3092, ///
    3099, 3100, 3211, 3212, 3311/3315, 3220, 3230, 3240, 3250, 3290, 3319, 3320)
    replace io_sectors4 = 4 if io_sectors4 == 1
    egen io_sectors5 = anymatch(ciiu), values(3510, 3520, 3530, 3600, 3700, 3811, ///
    3812, 3821, 3822, 3830, 3900)
    replace io_sectors5 = 5 if io_sectors5 == 1
    egen io_sectors6 = anymatch(ciiu), values(4100, 4311, 4321, 4322, 4329, 4330, ///
    4390, 4210, 4220, 4290, 4312)
    replace io_sectors6 = 6 if io_sectors6 == 1
    egen io_sectors7 = anymatch(ciiu), values(4510, 4530, 4540, 4610, 4620, 4630, ///
    4641, 4649, 4651, 4652, 4653, 4659, 4661, 4662, 4663, 4669, 4690, 4711, 4719, ///
    4721, 4722, 4723, 4730, 4741, 4742, 4751, 4752, 4753, 4759, 4761, 4762, 4763, ///
    4764, 4771, 4772, 4773, 4774, 4781, 4782, 4789, 4791, 4799, 4520)
    replace io_sectors7 = 7 if io_sectors7 == 1
    egen io_sectors8 = anymatch(ciiu), values(4911, 4912, 4921/4923, 4930, 5011, ///
    5012, 5021, 5022, 5110, 5120, 5210, 5221/5224, 5229, 5310, 5320)
    replace io_sectors8 = 8 if io_sectors8 == 1
    egen io_sectors9 = anymatch(ciiu), values(5510/5590, 5610, 5621/5630)
    replace io_sectors9 = 9 if io_sectors9 == 1
    egen io_sectors10 = anymatch(ciiu), values(5811/5813, 5819, 5820, 5911/5914, ///
    5920, 6010, 6020, 6110, 6120, 6130, 6190, 6201, 6202, 6209, 6311, 6312, 6391, ///
    6399)
    replace io_sectors10 = 10 if io_sectors10 == 1
    egen io_sectors11 = anymatch(ciiu), values(6419, 6411, 6430, 6491, 6492, 6499, ///
    6420, 6511, 6512, 6611, 6612, 6619/6630, 6520, 6530, 6621, 6622, 6629, 6630)
    replace io_sectors11 = 11 if io_sectors11 == 1
    egen io_sectors12 = anymatch(ciiu), values(6910, 6920, 7010, 7020, 7110, 7210, ///
    7120, 7220, 7410, 7420, 7490, 7500, 7310, 7320, 7710, 7730, 7721, 7722, 7729, ///
    7740, 7911, 7912, 7990, 7810, 7820, 7830, 8010, 8020, 8030, 8110, 8121, 8129, ///
    8130, 8219, 8211, 8220, 8230, 8291, 8292, 8299) //9411//
    replace io_sectors12 = 12 if io_sectors12 == 1
    egen io_sectors13 = anymatch(ciiu), values(8411, 8412, 8413, 8421, 8422, 8423, ///
    8430)
    replace io_sectors13 = 13 if io_sectors13 == 1
    egen io_sectors14 = anymatch(ciiu), values(8541, 8542, 8549, 8510, 8521, 8522, ///
    8530, 8541, 8542, 8550, 8610, 8620, 8690, 8710, 8720, 8730, 8790, 8810, 8890, ///
    9000, 9101, 9102, 9103, 9311, 9200, 9312, 9319, 9321, 9329, 9411, 9412, 9420, ///
    9491, 9492, 9499, 9511, 9512, 9521, 9522, 9523, 9524, 9529, 9602, 9609, 9601, ///
    9603, 9609, 9700, 6810, 6820, 9900)
    replace io_sectors14 = 14 if io_sectors14 == 1
    //Note: 9411 appearsin 12 AND 14, changed so it would only be in 14
    //Note: modified so matches ENAHO;
    /*0150	01
    0510	03
    0710	03
    0891	03
    0893	03
    0899	03
    0910	03
    0990	03
    2920	04
    4510	07
    5819	10
    5820	10
    9523	14
    9900	14
    */
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

    tab io_sectors, miss //NO missing

    gen employment = 1

    //Figure 14 ENAHO
    svy: total employment, over(ocupinf  io_sectors) cformat(%8.0f)  nofvlabel
    svy: total employment if lockdown_sectors == 1, over(ocupinf io_sectors) cformat(%8.0f) nofvlabel

    use `base_ene', clear

        /*
    drop if g_ciiu==15 //!!!!!TURN OFF!!!!!!
    count // 19,546
    */

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
    //drop lockdown_sectors
    gen lockdown_sectors = 0

    # delimit ;
    replace lockdown_sectors = 1 if inlist(ciiu, 1312, 1420, 1399, 1391, 1393,
    1392, 2220, 1512, 1394, 1311, 1313, 1410, 2811, 2814, 2790, 2910, 3091, 2818,
    2819, 2599, 2710, 2815, 2812, 2651, 2816, 2829, 3250, 2750, 2920, 2930, 2813,
    2740, 2399, 3011, 3020, 3030, 2591, 3315, 3012, 3100, 1622, 2511, 2219, 1629,
    2593, 2592, 3211, 3212, 3220, 3230, 3240, 2640, 3092, 1701, 1709, 2022, 2817,
    3290, 1811, 2826, 2023, 4510, 4530, 4540, 4659, 4663, 4649, 4641, 4669, 4661,
    4690, 4763, 4773, 4742, 4759, 4753, 9524, 4752, 9522, 4711, 4721, 4722, 4771,
    9529, 9523, 4764, 4751, 4761, 4719, 4723, 2396, 4774, 5110, 5120, 4922, 5223,
    5224, 8129, 5222, 3830, 5229, 7729, 7722, 7721, 7730, 8620, 9000, 9329, 9312,
    9311, 9319, 3319, 7420, 9321, 9200, 7990, 5510, 5590, 5629, 5621, 5610, 5630,
    9602, 9609, 5221, 6190);
    # delimit cr
    //8,777 real changes made, based on 126 unique ciiu forvalues
    label var lockdown_sectors "lockdown_sectors"

    gen FACTOR_EXPANS_r = round(FACTOR_EXPANS) //13 missing values

   //bysort lockdown_sectors: tab C9P904_3  [fw=FACTOR_EXPANS_r]
    sum C9P904_7 C9P905_9 C9P905_20 //C9P904_7 has negative values (76)
    nmissing C9P904_7 C9P905_9 C9P905_20 // have 299, 325 and 325 missing values

    gen GVA = C9P904_7 - C9P905_9 //326 missing values and negative values!
    label var GVA "Gross Value Added"
    count if GVA < 0 //1035 negative values!
    replace GVA = 0 if GVA < 0
    sum GVA

        /*
    #delimit ;
    gen firm_size =
    cond(C3P301A_T1<10,                 1,
    cond(C3P301A_T1>=10&C3P301A_T1<=49, 2,
    cond(C3P301A_T1>=50&C3P301A_T1<=99, 3,
    cond(C3P301A_T1>=100,               4,
                                        .
                                     ))));
    #delimit cr
    */
    #delimit ;
    gen firm_size =
    cond(C3P301A_T1<=49,                1,
    cond(C3P301A_T1>=50,                2,
                                        .
                                      ));
    #delimit cr

    label var firm_size "Firm size by employment"
    label define firm_size 1 "Micro and small (<49)" 2 "Medium and large (>50)", replace
    label values firm_size firm_size

    /*
    gen digit = mod(ciiu, 10)
    gen ciiu_3digit = .
    replace ciiu_3digit = ciiu if digit == 0
    drop digit

    replace description = "Computer programming, consultancy and related activities" if ciiu_3digit == 620
    replace description = "Libraries, archives, museums and other cultural activities" if ciiu_3digit == 910
    replace description = "Activities of extraterritorial organizations and bodies" if ciiu_3digit == 990
    replace description = "Manufacture of fabricated metal products, except machinery and equipment" if ciiu_3digit == 2510
    replace description =  "Extraction of crude petroleum" if ciiu_3digit == 6100
    */

   preserve
    import delimited using ISIC_Rev_4_structure, varname(1) clear
    rename code ciiu_3digit
    gen length = length(ciiu_3digit)
    keep if length == 3
    destring ciiu_3digit, replace
    format ciiu_3digit %03.0f
    drop length
    rename description description3digits
    tempfile isic_3digits
    save `isic_3digits'
   restore

    gen ciiu_3digit = floor(ciiu/10)
    format ciiu_3digit %03.0f

    merge m:1 ciiu_3digit using `isic_3digits'
    drop if _merge == 2
    assert c(N) == 19548

  preserve
    collapse (count) ID, by(ciiu_3digit description3digits)
    export excel using "$base\ciiu_3digit.xlsx", firstrow(varlabels) replace
  restore

    labmask ciiu_3digit, values(description3digits)
    replace ciiu_3digit = 619 if ciiu_3digit == 610 //Error in ISIC coding!!!

    tab ciiu_3digit

    //------------------------------------------------------------------------//

  ///GDP
  preserve
    collapse (sum) GVA C9P905_20 [fw=FACTOR_EXPANS_r], by(region)
    export excel using "$base\results.xlsx", firstrow(varlabels) sheet("GDP", replace)
  restore

  /// GVA by sector
   preserve

   collapse (sum) GVA if lockdown_sectors==1 [fw=FACTOR_EXPANS_r], by(region)
   export excel using "$base\results.xlsx", firstrow(varlabels) sheet("Figure 5", modify)

   restore

    collapse (sum) GVA if lockdown_sectors==0 [fw=FACTOR_EXPANS_r], by(region)
    export excel using "$base\results.xlsx", firstrow(varlabels) sheet("Figure 5", modify) cell(K1)


///Descriptive statistics

    //Table 1. Employment by firm size. Percent of total employment

    total C3P301A_T1 [pw = FACTOR_EXPANSION], over(firm_size) cformat(%6.0f)
    svy: total C3P301A_T1, over(firm_size) cformat(%6.0f)

    //Table 2. Employment by firm size by department. Percent of total

        //total C3P301A_T1 [pw = FACTOR_EXPANSION], over(region firm_size) cformat(%8.0f)
    svy: total C3P301A_T1, over(region firm_size) cformat(%8.0f)
    /*
   preserve

    collapse (sum) employment = C3P301A_T1 [fw=FACTOR_EXPANS_r], by(region firm_size)
    egen id = group(region)
    reshape wide employment, i(id) j(firm_size)
    export excel using "$base\results_new.xlsx", firstrow(varlabels) sheet("Table 2", modify)

   restore
    */
    //Table 3. Employment by sector. Percent of total

    svy: total C3P301A_T1, over(g_ciiu) cformat(%8.0f)

    //Table 4. Employment by department. Percent of total

    svy: total C3P301A_T1, over(region) cformat(%8.0f)

    //Table 5. Employment by sector in Peru’s departments

    svy: total C3P301A_T1, over(region g_ciiu) cformat(%8.0f)

    //Table 6. Gross value added (GVA) by sector. Percent of total.

    svy: total GVA, over(g_ciiu) cformat(%10.0f)
   preserve

    collapse (sum) GVA C9P905_20 [fw=FACTOR_EXPANS_r], by(g_ciiu)
    export excel using "$base\results_new.xlsx", firstrow(varlabels) sheet("Table 6", modify)

   restore

    //Table 7. Gross value added (GVA) by department. Percent of GDP.
    svy: total GVA, over(region) cformat(%10.0f)

   preserve

    collapse (sum) GVA C9P905_20 [fw=FACTOR_EXPANS_r], by(region)
    export excel using "$base\results_new.xlsx", firstrow(varlabels) sheet("Table 7", modify)

   restore

    //Table 8. Gross value added (GVA) by sector in Peru’s departments.
    svy: total GVA, over(region g_ciiu) cformat(%10.0f)

   preserve

    collapse (sum) GVA [fw=FACTOR_EXPANS_r], by(region g_ciiu)
    export excel using "$base\results_new.xlsx", firstrow(varlabels) sheet("Table 8", modify)

   restore

    //Table 9. Summary statistics of firms. Entire sample
    gen renumeraciones_pc = (C9P905_3 + C9P905_4) / C3P301A_T1 /12 // Wage bill/total employees/12
    sum renumeraciones_pc

    sumstats ///
    (ID GVA if ID !=.) ///
    (C3P301A_T1 if C3P301A_T1 !=. ) ///
    (C9P904_7 if C9P904_7 !=.) /// *ingresos_totales*
    (renumeraciones_pc if renumeraciones_pc !=.) ///
    (C9P906_T4 if C9P906_T4 !=.) /// *total ventas y/o retiros*
    [fw=FACTOR_EXPANS_r] ///
    using "$base\results_ENE_sumstats.xls", replace stats(n mean median sd cv max min)

    //Wage bill
    sum C9P905_3 C9P905_4 // Wage bill 19,223 observations
    gen wage_bill = C9P905_3 + C9P905_4

    svy: total wage_bill, over(firm_size) cformat(%8.0f)
    svy: total wage_bill if C6P624 == 1 | (C6P624 == 2 & durable_goods == 1) & lockdown_sectors != 1, over(firm_size) cformat(%9.0f)
    svy: total wage_bill if (C6P624 == 2 & C4P408 == 1 & durable_goods != 1) & lockdown_sectors != 1, over(firm_size) cformat(%10.0f)
    svy: total wage_bill if lockdown_sectors == 1, over(firm_size) cformat(%8.0f)


    svy: total wage_bill, over(region) cformat(%8.0f)
    svy: total wage_bill if C6P624 == 1 | (C6P624 == 2 & durable_goods == 1) & lockdown_sectors != 1, over(region) cformat(%9.0f)
    svy: total wage_bill if lockdown_sectors == 1, over(region) cformat(%8.0f)


    //GVA
    svy: total GVA, over(firm_size) cformat(%10.0f)
    svy: total GVA if C6P624 == 1 | (C6P624 == 2 & durable_goods == 1) & lockdown_sectors != 1, over(firm_size) cformat(%10.0f)
    svy: total GVA if (C6P624 == 2 & C4P408 == 1 & durable_goods != 1) & lockdown_sectors != 1, over(firm_size) cformat(%10.0f)
    svy: total GVA if lockdown_sectors == 1, over(firm_size) cformat(%10.0f)

    svy: total GVA if C6P624 == 1 | (C6P624 == 2 & durable_goods == 1) & lockdown_sectors != 1, over(region) cformat(%9.0f)
    svy: total C9P905_20 if C6P624 == 1 | (C6P624 == 2 & durable_goods == 1) & lockdown_sectors != 1, over(region) cformat(%8.0f)
    svy: total GVA if lockdown_sectors == 1, over(region) cformat(%9.0f)
    svy: total C9P905_20 if lockdown_sectors == 1, over(region) cformat(%8.0f)

    //Number of firms
    svy: tab firm_size, missing count format(%9.1g)
    svy: tab firm_size if C6P624 == 1 | (C6P624 == 2 & durable_goods == 1) & lockdown_sectors != 1, missing count format(%9.1g)
    svy: tab firm_size if (C6P624 == 2 & C4P408 == 1 & durable_goods != 1) & lockdown_sectors != 1, missing count format(%9.1g)
    svy: tab firm_size if lockdown_sectors == 1, missing count format(%9.1g)


///2.	Lockdown shock
    //Figure 3a. Employment in lockdown sectors by firm size.
    svy: total C3P301A_T1, over(firm_size lockdown_sectors) cformat(%8.0f)

    //Figure 3b. Employment in lockdown by sector.
    svy: total C3P301A_T1, over(lockdown_sectors g_ciiu) cformat(%8.0f)

    //Employment in lockdown by sector by region_names
    svy: total C3P301A_T1, over(lockdown_sectors region) cformat(%8.0f)


    //Table 1_new. Summary statistics of firms in lockdown sectors.
    gen renumeraciones_pc = (C9P905_3 + C9P905_4) / C3P301A_T1 /12 // Wage bill/total employees/12
    label var renumeraciones_pc "Monthly wage bill per capita"
    sum renumeraciones_pc

    sumstats ///
    (ID GVA if lockdown_sectors == 0) ///
    (C3P301A_T1 if lockdown_sectors == 0) ///
    (C9P904_7 if lockdown_sectors == 0) /// *ingresos_totales*
    (renumeraciones_pc if lockdown_sectors == 0) ///
    (C9P906_T4 if lockdown_sectors == 0) /// *total ventas y/o retiros*
    using "$base\results_ENEa_sumstats.xls", replace stats(n mean median sd cv max min)

    sumstats ///
    (ID GVA if lockdown_sectors == 1) ///
    (C3P301A_T1 if lockdown_sectors == 1) ///
    (C9P904_7 if lockdown_sectors == 1) /// *ingresos_totales*
    (renumeraciones_pc if lockdown_sectors == 1) ///
    (C9P906_T4 if lockdown_sectors == 1) /// *total ventas y/o retiros*
    [fw=FACTOR_EXPANS_r] ///
    using "$base\results_ENEb_sumstats.xls", replace stats(n mean median sd cv max min)

///3.	Demand shock
    // durable_goods == 1 & C6P624 == 1 (ha realizado exportaciones de productos)
    // --> exporters of durable goods (86)
    // durable_goods == 1 & C6P624 == 2--> durable goods producers (exclude exporters) (355)

    // C4P408 == 1 (pedido de insumos internacionales) & sector2r4_2 == 3 (manufactura) & C6P624 == 2 (no ha realizado exportaciones de productos) --> importers in manufacturing, that exclude exporters

    //exporters and producers of durable goods!!!!
    //C6P624 == 1 | (C6P624 == 2 & durable_goods == 1) & lockdown_sectors != 1

    //Importers of manufacturing goods: manufactura + mining + agricultura + fishing
    //(g_ciiu == 1|g_ciiu == 2|g_ciiu == 3) & (C6P624 == 2 & C4P408 == 1 )
    //(C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1

    //Verifying no double counting
    gen exp = cond((C6P624 == 1 | C6P624 == 2 & durable_goods == 1) & lockdown_sectors!= 1, 1, 0)
    gen imp = cond((C6P624 == 2 & C4P408 == 1 & durable_goods != 1) & (g_ciiu == 1|g_ciiu == 2|g_ciiu == 3) & lockdown_sectors != 1, 1, 0) // if not by io_sector
    tab exp imp

    //Table 6a. Employment in exporters and producers of durable goods by firm size
    svy: total C3P301A_T1 if C6P624 == 1 | (C6P624 == 2 & durable_goods == 1) & lockdown_sectors != 1, over(firm_size) cformat(%8.0f)

    //Map 3.a. Employment in exporters by sector. Percent of total.
    svy: total C3P301A_T1 if C6P624 == 1, over(g_ciiu) cformat(%8.0f)

    //Map 3.b. Employment in producers of durable goods by sector (excluding exporters)
    svy: total C3P301A_T1 if durable_goods == 1 & C6P624 == 2, over(g_ciiu) cformat(%8.0f)

    //Map 3.c. Employment in exporters and producers of durable goods by firm size and department
    svy: total C3P301A_T1 if C6P624 == 1 | (C6P624 == 2 & durable_goods == 1) & lockdown_sectors != 1, over(firm_size region) cformat(%8.0f)

    //Figure 6c. Gross value added (GVA) in exporters and producers of durable goods. Percent of GDP
    svy: total GVA if C6P624 == 1 | (C6P624 == 2 & durable_goods == 1) & lockdown_sectors != 1, cformat(%11.0f)

    //Table 2. Gross value added (GVA) in exporters and producers of durable goods by firm size
    svy: total GVA if C6P624 == 1 | (C6P624 == 2 & durable_goods == 1) & lockdown_sectors != 1, over(firm_size) cformat(%11.0f)

    //Table 3. Summary statistics of exporters and producers of durable goods
    gen renumeraciones_pc = (C9P905_3 + C9P905_4) / C3P301A_T1 /12 // Wage bill/total employees/12
    sum renumeraciones_pc

    sumstats ///
    (ID GVA if C6P624 == 1 | (C6P624 == 2 & durable_goods == 1) & lockdown_sectors != 1) ///
    (C3P301A_T1 if C6P624 == 1 | (C6P624 == 2 & durable_goods == 1) & lockdown_sectors != 1) ///
    (C9P904_7 if C6P624 == 1 | (C6P624 == 2 & durable_goods == 1) & lockdown_sectors != 1) /// *ingresos_totales*
    (renumeraciones_pc if C6P624 == 1 | (C6P624 == 2 & durable_goods == 1) & lockdown_sectors != 1) ///
    (C9P906_T4 if C6P624 == 1 | (C6P624 == 2 & durable_goods == 1) & lockdown_sectors != 1) /// *total ventas y/o retiros*
    [fw=FACTOR_EXPANS_r] ///
    using "$base\results_ENE_sumstats3.xls", replace stats(n mean median sd cv max min)

  //3.3. Import supply
    // Figure 11b. Employment in importing manufacturing firms by sector. Percent of total.
    sort ciiu_3digit
    svy: total C3P301A_T1 if (C6P624 == 2 & C4P408 == 1 & durable_goods != 1) & lockdown_sectors != 1, over(ciiu_3digit) cformat(%8.0f) //nofvlabel

    gen marker = 1 if (C6P624 == 2 & C4P408 == 1 & durable_goods != 1) & lockdown_sectors != 1
    label var marker "Importing manufacturing firms"
    //Dont forget to install xfill!!! See line 44.
    xfill marker, i(ciiu_3digit)

    svy: total C3P301A_T1 if marker == 1, over(ciiu_3digit) cformat(%8.0f)

    //Map 3b. Employment in importing manufacturing firms by firm size and department
    svy: total C3P301A_T1 if (C6P624 == 2 & C4P408 == 1 & durable_goods != 1) & lockdown_sectors != 1, over(firm_size region) cformat(%8.0f) //nofvlabel

    svy: total C3P301A_T1 if marker == 1, over(firm_size region) cformat(%8.0f) nofvlabel

    //Table 1. Summary statistics of importing manufacturing firms
    //gen renumeraciones_pc = (C9P905_3 + C9P905_4) / C3P301A_T1 /12 // Wage bill/total employees/12
    sum renumeraciones_pc

    sumstats ///
    (ID GVA if marker == 1) ///
    (C3P301A_T1 if marker == 1) ///
    (C9P904_7 if marker == 1) /// *ingresos_totales*
    (renumeraciones_pc if marker == 1) ///
    (C9P906_T4 if marker == 1) /// *total ventas y/o retiros*
    [fw=FACTOR_EXPANS_r] ///
    using "$base\results_ENE_sumstats4.xls", replace stats(n mean median sd cv max min)

    //Table 2b. Gross value added (GVA) in importing manufacturing firms by firm size
    svy: total GVA if (C6P624 == 2 & C4P408 == 1 & durable_goods != 1) & lockdown_sectors != 1, over(firm_size) cformat(%11.0f)


///5.   Other tables
    // Employment for the 14 IO sectors by lockdown sectors, ENE and ENAHO

    egen io_sectors1 = anymatch(ciiu), values(0111/0116, 0119, 0121/0130, 0141/0146,   0149, 0150, 0161/0164, 0170, 0210, 0220, 0230, 0240)
    egen io_sectors2 = anymatch(ciiu), values(0311, 0312, 0321, 0322)
    replace io_sectors2 = 2 if io_sectors2 == 1
    egen io_sectors3 = anymatch(ciiu), values(0510, 0610, 0620, 0910, 0710, 0721, ///
    0729, 0810, 0891, 0892 ,0893, 0899, 0910, 0990)
    replace io_sectors3 = 3 if io_sectors3 == 1
    egen io_sectors4 = anymatch(ciiu), values(1010, 1020, 1030, 1040, 1050, 1061, ///
    1062, 1071/1075, 1079, 1080, 1101/1104, 1200, 1311/1313, 1391/1394, 1399, 1410, ///
    1420, 1430, 1511, 1512, 1520, 1610, 1621/1623, 1629, 1701, 1702, 1709, 1811, ///
    1812, 1820, 1910, 1920, 2011/2013, 2021/2023, 2029, 2030, 2100, 2211, 2219, ///
    2220, 2310, 2391/2396, 2399, 2410, 2420, 2431, 2432, 2511/2513, 2520, 2591/2593, ///
    2599, 2620, 2651, 2652, 2660, 2670, 2680, 2610, 2630, 2640, 2710, 2720, ///
    2731/2733, 2740, 2750, 2790, 2811, 2812, 2817, 2813/2816, 2818, 2819, ///
    821/2826, 2829, 2910, 2920, 2930, 3011, 3012, 3020, 3030, 3040, 3091, 3092, ///
    3099, 3100, 3211, 3212, 3311/3315, 3220, 3230, 3240, 3250, 3290, 3319, 3320)
    replace io_sectors4 = 4 if io_sectors4 == 1
    egen io_sectors5 = anymatch(ciiu), values(3510, 3520, 3530, 3600, 3700, 3811, ///
    3812, 3821, 3822, 3830, 3900)
    replace io_sectors5 = 5 if io_sectors5 == 1
    egen io_sectors6 = anymatch(ciiu), values(4100, 4311, 4321, 4322, 4329, 4330, ///
    4390, 4210, 4220, 4290, 4312)
    replace io_sectors6 = 6 if io_sectors6 == 1
    egen io_sectors7 = anymatch(ciiu), values(4510, 4530, 4540, 4610, 4620, 4630, ///
    4641, 4649, 4651, 4652, 4653, 4659, 4661, 4662, 4663, 4669, 4690, 4711, 4719, ///
    4721, 4722, 4723, 4730, 4741, 4742, 4751, 4752, 4753, 4759, 4761, 4762, 4763, ///
    4764, 4771, 4772, 4773, 4774, 4781, 4782, 4789, 4791, 4799, 4520)
    replace io_sectors7 = 7 if io_sectors7 == 1
    egen io_sectors8 = anymatch(ciiu), values(4911, 4912, 4921/4923, 4930, 5011, ///
    5012, 5021, 5022, 5110, 5120, 5210, 5221/5224, 5229, 5310, 5320)
    replace io_sectors8 = 8 if io_sectors8 == 1
    egen io_sectors9 = anymatch(ciiu), values(5510/5590, 5610, 5621/5630)
    replace io_sectors9 = 9 if io_sectors9 == 1
    egen io_sectors10 = anymatch(ciiu), values(5811/5813, 5819, 5820, 5911/5914, ///
    5920, 6010, 6020, 6110, 6120, 6130, 6190, 6201, 6202, 6209, 6311, 6312, 6391, ///
    6399)
    replace io_sectors10 = 10 if io_sectors10 == 1
    egen io_sectors11 = anymatch(ciiu), values(6419, 6411, 6430, 6491, 6492, 6499, ///
    6420, 6511, 6512, 6611, 6612, 6619/6630, 6520, 6530, 6621, 6622, 6629, 6630)
    replace io_sectors11 = 11 if io_sectors11 == 1
    egen io_sectors12 = anymatch(ciiu), values(6910, 6920, 7010, 7020, 7110, 7210, ///
    7120, 7220, 7410, 7420, 7490, 7500, 7310, 7320, 7710, 7730, 7721, 7722, 7729, ///
    7740, 7911, 7912, 7990, 7810, 7820, 7830, 8010, 8020, 8030, 8110, 8121, 8129, ///
    8130, 8219, 8211, 8220, 8230, 8291, 8292, 8299) //9411//
    replace io_sectors12 = 12 if io_sectors12 == 1
    egen io_sectors13 = anymatch(ciiu), values(8411, 8412, 8413, 8421, 8422, 8423, ///
    8430)
    replace io_sectors13 = 13 if io_sectors13 == 1
    egen io_sectors14 = anymatch(ciiu), values(8541, 8542, 8549, 8510, 8521, 8522, ///
    8530, 8541, 8542, 8550, 8610, 8620, 8690, 8710, 8720, 8730, 8790, 8810, 8890, ///
    9000, 9101, 9102, 9103, 9311, 9200, 9312, 9319, 9321, 9329, 9411, 9412, 9420, ///
    9491, 9492, 9499, 9511, 9512, 9521, 9522, 9523, 9524, 9529, 9602, 9609, 9601, ///
    9603, 9609, 9700, 6810, 6820, 9900)
    replace io_sectors14 = 14 if io_sectors14 == 1
    //Note: 9411 appearsin 12 AND 14, changed so it would only be in 14
    //Note: modified so matches ENAHO;
    /*0150	01
    0510	03
    0710	03
    0891	03
    0893	03
    0899	03
    0910	03
    0990	03
    2920	04
    4510	07
    5819	10
    5820	10
    9523	14
    9900	14
    */
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

    tab io_sectors, miss //3 missing

    svydescribe
    svy: total C3P301A_T1, over(lockdown_sectors io_sectors) cformat(%8.0f) nofvlabel


///4.	Financial vulnerability (code from Karly)
    g FixedCosts    = C9P905_9 + C9P905_16 + C9P905_20 + C9P905_21 + C9P905_26
    g Variablecosts = C9P905_1 + C9P905_2
    g CashBuffer    = (C9P904_7 - Variablecosts )/FixedCosts

    sort io_sectors
    gen IO_COshare = .
    replace IO_COshare = 0     if io_sectors == 1
    replace IO_COshare = 0     if io_sectors == 2
    replace IO_COshare = 0     if io_sectors == 3
    replace IO_COshare = 0.209 if io_sectors == 4
    replace IO_COshare = 0.001 if io_sectors == 5
    replace IO_COshare = 0     if io_sectors == 6
    replace IO_COshare = 0.375 if io_sectors == 7
    replace IO_COshare = 0.077 if io_sectors == 8
    replace IO_COshare = 0.143 if io_sectors == 9
    replace IO_COshare = 0.017 if io_sectors == 10
    replace IO_COshare = 0     if io_sectors == 11
    replace IO_COshare = 0.035 if io_sectors == 12
    replace IO_COshare = 0     if io_sectors == 13
    replace IO_COshare = 0.143 if io_sectors == 14

    g a =0.5
    g SB = CashBuffer * (1-a*IO_COshare)

    svy: total SB, over(io_sectors) cformat(%9.2f)
    svy: total SB, over(ciiu ) cformat(%9.2f)

    * SB= CB*(1-a*CO)/Fixed costs
    *in ENE fix costs are in question 905 in the following PNGE categories: 631, 632, 633, 634, 635, 636, 6364+6365+6367, 637, 638, 639, 64, 65, 653, 654, 658 and "otros gastos" (651+652+655+656+659)

    bysort io_sectors: centile (SB ), centile (25 )
    centile (SB ), centile (25 )
    bysort io_sectors:  centile (SB ), centile (100 )
    summarize SB, detail

    egen p25 = pctile(SB), p(25) //using the whole sample
    //drop if SB==. // !!!!!!!!
    g bottomq=1 if SB<=p25 & SB !=.

    svy: total C3P301A_T1 if bottomq==1 , over(lockdown_sectors io_sectors) cformat(%9.0f)
    svy: tab io_sectors if bottomq==1, missing count format(%9.1g) col
    svy: tab io_sectors , missing count format(%9.1g) col

    svy: tab io_sectors firm_size if bottomq==1, missing count format(%9.1g)
    svy: tab io_sectors firm_size, missing count format(%9.1g)

    gen wage_bill = C9P905_3 + C9P905_4 // Wage bill 19,223 observations


    svy: tab io_sectors wage_bill if bottomq==1, missing count format(%9.1g)
    svy: tab io_sectors wage_bill, missing count format(%9.1g)


///6. Aggregate COVID-19 shock

    // Map 6b. Aggregate COVID-19 shock by department. Percent of employment in that department.
    sort ciiu_3digit

    svy: total C3P301A_T1 if (C6P624 == 2 & C4P408 == 1 & durable_goods != 1) & lockdown_sectors != 1, over(region) cformat(%8.0f) //nofvlabel

    svy: total C3P301A_T1 if bottomq==1, over(region) cformat(%8.0f) nofvlabel

    // Map 6c. Aggregate COVID-19 shock by department. Percent of wage bill in that department.
    gen wage_bill = C9P905_3 + C9P905_4

    svy: total wage_bill if (C6P624 == 2 & C4P408 == 1 & durable_goods != 1) & lockdown_sectors != 1, over(region) cformat(%8.0f) //nofvlabel

    svy: total wage_bill if bottomq==1, over(region) cformat(%8.0f) nofvlabel

    // Map 7. Aggregate COVID-19 shock by department. Percent of gross value added in that department.
    svy: total GVA if C6P624 == 1 | (C6P624 == 2 & durable_goods == 1) & lockdown_sectors != 1, over(region) cformat(%8.0f) nofvlabel
    svy: total GVA if (C6P624 == 2 & C4P408 == 1 & durable_goods != 1) & lockdown_sectors != 1, over(region) cformat(%8.0f) nofvlabel
    svy: total GVA if bottomq==1, over(region) cformat(%8.0f) nofvlabel

    //Figure 16. Aggregate COVID-19 shock. Percent of GDP.
    svy: total C9P905_20 if C6P624 == 1 | (C6P624 == 2 & durable_goods == 1) & lockdown_sectors != 1, over(region) cformat(%8.0f) nofvlabel
    svy: total C9P905_20 if (C6P624 == 2 & C4P408 == 1 & durable_goods != 1) & lockdown_sectors != 1, over(region) cformat(%8.0f) nofvlabel
    svy: total C9P905_20 if bottomq == 1, over(region) cformat(%8.0f) nofvlabel
    svy: total C9P905_20 if lockdown_sectors == 1, over(region) cformat(%9.0f)

    //Figure 18
    svy: tab io_sectors firm_size if (marker!= 1 & marker2!= 1) & lockdown_sectors!= 1 &  bottomq==1, missing count format(%9.1g)
    svy: tab io_sectors ,  count format(%9.1g) col

    svy: tab io_sectors firm_size if (C6P624 == 1 | C6P624 == 2 & durable_goods == 1) & lockdown_sectors!= 1, missing count format(%9.1g)
     svy: tab io_sectors firm_size if (C6P624 == 2 & C4P408 == 1 & durable_goods != 1) & lockdown_sectors != 1, missing count format(%9.1g)

    svy: tab io_sectors firm_size if imp == 1, missing count format(%9.1g)


    //Aditional tables
    svy: total C3P301A_T1 if bottomq == 1, over(firm_size) cformat(%8.0f)
    svy: total C3P301A_T1 if bottomq == 1, over(io_sectors) cformat(%8.0f)
    svy: total C3P301A_T1, over(firm_size) cformat(%8.0f)

    svy: total GVA if imp == 1, over(firm_size) cformat(%8.0f) nofvlabel

    ///**********************************************************///

    svy: total GVA, over(io_sectors) cformat(%9.0f) nofvlabel
    svy: total GVA  if (C6P624 == 1 | C6P624 == 2 & durable_goods == 1) & lockdown_sectors!= 1, over(io_sectors) cformat(%9.0f) nofvlabel
    svy: total GVA  if (C6P624 == 2 & C4P408 == 1 & durable_goods != 1) & lockdown_sectors != 1, over(io_sectors) cformat(%8.0f) nofvlabel
    svy: total GVA  if lockdown_sectors == 1, over(io_sectors) cformat(%9.0f) nofvlabel
    //svy: total GVA  if bottomq == 1 , over(io_sectors) cformat(%8.0f) nofvlabel
    gen marker2 = 1 if (C6P624 == 1 | C6P624 == 2 & durable_goods == 1) & lockdown_sectors!= 1
    label var marker2 "Exporters and producers of durables goods"

    //Final tables for financial vulnerable firms
    svy: total wage_bill if (marker!= 1 & marker2!= 1) & lockdown_sectors!= 1 ///
& bottomq == 1, over(firm_size region) cformat(%8.0f) nofvlabel
    svy: total GVA , over(io_sectors) cformat(%8.0f) nofvlabel
    ///**********************************************************///


///7. Summary tables
    //ONLY USE tabout 3 beta version available http://tabout.net.au/docs/home.php

    tabout lockdown_sectors using sumstats01.xls, replace style(xlsx) ///
    font(italic) sum f(1) ///
    c(N C3P301A_T1 mean C3P301A_T1 sd C3P301A_T1 min C3P301A_T1 max C3P301A_T1)

    svyset [pw=FACTOR_EXPANSIO], strata(E_FORZOSO_CD)
    tabout lockdown_sectors using sumstats02.txt, replace ///
    sum svy f(2 2) c(mean C3P301A_T1 se) clab(mean_employment SE) ///
    npos(lab)

    gen renumeraciones_pc = (C9P905_3 + C9P905_4) / C3P301A_T1 /12 // Wage bill/total employees/12
    label var renumeraciones_pc "Monthly wage bill per capita"
    sum renumeraciones_pc

    svydescribe

    foreach var of var GVA C3P301A_T1 C9P904_7 renumeraciones_pc C9P906_T4 {
    sum `var' if bottomq == 1
    local a1 `r(N)'
    local a2 `r(min)'
    local a3 `r(max)'
    matrix define A = A \ (`a1', `a2', `a3')
    }
    matrix list A
    putexcel set "$base\tables_sumstats", sheet(missing) modify
    putexcel R2 = matrix(A) // A, E, J, N, R

    //E: if C6P624 == 1 | (C6P624 == 2 & durable_goods == 1) & lockdown_sectors != 1
    //J: if (C6P624 == 2 & C4P408 == 1 & durable_goods != 1) & lockdown_sectors != 1
    //N: if lockdown_sectors == 1
    //R: if bottomq == 1

    local varlist "GVA C3P301A_T1 C9P904_7 renumeraciones_pc C9P906_T4"
    sum `varlist' if imp == 1
    svy: mean `varlist' if marker == 1
    estat sd
    //One by one is different than all variable together!!! dohh
    //GVA C3P301A_T1 C9P904_7 renumeraciones_pc C9P906_T4
    svy: mean C9P906_T4 if imp == 1
    estat sd

  //size summary
    gen l_prod = C9P906_T4/C3P301A_T1
    label var l_prod "Sales per employee"
    sum l_prod

    gen l_prod2 = GVA/C3P301A_T1
    label var l_prod2 "GVA per employee"
    sum l_prod2

   ///Whole sample
    svy: tab firm_size, missing count format(%9.1g)
    svy: total C3P301A_T1, over(firm_size) cformat(%9.0f)
    svy: total renumeraciones_pc, over(firm_size) cformat(%9.0f)
    svy: mean C3P301A_T1, over(firm_size) cformat(%9.0f)
    svy: mean C3P301A_T1, cformat(%9.0f)
    svy: mean C9P906_T4, over(firm_size) cformat(%9.0f)
    svy: mean C9P906_T4, cformat(%9.0f)
    svy: total C9P906_T4, over(firm_size) cformat(%9.0f)
    svy: total C9P906_T4, cformat(%9.0f)
    svy: mean renumeraciones_pc, over(firm_size) cformat(%9.0f)
    svy: mean renumeraciones_pc, cformat(%9.0f)
    svy: mean l_prod, over(firm_size) cformat(%9.0f)
    svy: mean l_prod, cformat(%9.0f)
    svy: mean l_prod2, over(firm_size) cformat(%9.0f)
    svy: mean l_prod2, cformat(%9.0f)

   ///Firms in exporters and producers of durable goods
    svy: tab firm_size if (C6P624 == 1 | C6P624 == 2 & durable_goods == 1) & lockdown_sectors!= 1, missing count format(%9.1g)
    svy: total C3P301A_T1 if (C6P624 == 1 | C6P624 == 2 & durable_goods == 1) & lockdown_sectors!= 1 , over(firm_size) cformat(%9.0f)
    svy: total renumeraciones_pc if (C6P624 == 1 | C6P624 == 2 & durable_goods == 1) & lockdown_sectors!= 1 , over(firm_size) cformat(%9.0f)
    svy: mean C3P301A_T1 if (C6P624 == 1 | C6P624 == 2 & durable_goods == 1) & lockdown_sectors!= 1, over(firm_size) cformat(%9.0f)
    svy: mean C3P301A_T1 if (C6P624 == 1 | C6P624 == 2 & durable_goods == 1) & lockdown_sectors!= 1, cformat(%9.0f)
    svy: mean C9P906_T4 if (C6P624 == 1 | C6P624 == 2 & durable_goods == 1) & lockdown_sectors!= 1, over(firm_size) cformat(%9.0f)
    svy: total C9P906_T4 if (C6P624 == 1 | C6P624 == 2 & durable_goods == 1) & lockdown_sectors!= 1, over(firm_size) cformat(%9.0f)
    svy: mean C9P906_T4 if (C6P624 == 1 | C6P624 == 2 & durable_goods == 1) & lockdown_sectors!= 1, cformat(%9.0f)
    svy: mean renumeraciones_pc if (C6P624 == 1 | C6P624 == 2 & durable_goods == 1) & lockdown_sectors!= 1, over(firm_size) cformat(%9.0f)
    svy: mean renumeraciones_pc if (C6P624 == 1 | C6P624 == 2 & durable_goods == 1) & lockdown_sectors!= 1, cformat(%9.0f)
    svy: mean l_prod if (C6P624 == 1 | C6P624 == 2 & durable_goods == 1) & lockdown_sectors!= 1, over(firm_size) cformat(%9.0f)
    svy: mean l_prod if (C6P624 == 1 | C6P624 == 2 & durable_goods == 1) & lockdown_sectors!= 1, cformat(%9.0f)
    svy: mean l_prod2 if (C6P624 == 1 | C6P624 == 2 & durable_goods == 1) & lockdown_sectors!= 1, over(firm_size) cformat(%9.0f)
    svy: mean l_prod2 if (C6P624 == 1 | C6P624 == 2 & durable_goods == 1) & lockdown_sectors!= 1, cformat(%9.0f)

    ///Firms Importers of manufacturing goods  (All sectors!)
    svy: tab firm_size if (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, missing count format(%9.1g)
    svy: total C3P301A_T1 if (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, over(firm_size) cformat(%9.0f)
    svy: total renumeraciones_pc if (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, over(firm_size) cformat(%9.0f)
    svy: mean C3P301A_T1 if (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, over(firm_size) cformat(%9.0f)
    svy: mean C3P301A_T1 if (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, cformat(%9.0f)
    svy: mean C9P906_T4 if (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, over(firm_size) cformat(%9.0f)
    svy: total C9P906_T4 if (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, over(firm_size) cformat(%9.0f)
    svy: mean C9P906_T4 if (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, cformat(%9.0f)
    svy: mean renumeraciones_pc if (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, over(firm_size) cformat(%9.0f)
    svy: mean renumeraciones_pc if (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, cformat(%9.0f)
    svy: mean l_prod if (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, over(firm_size) cformat(%9.0f)
    svy: mean l_prod if (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, cformat(%9.0f)
    svy: mean l_prod2 if (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, over(firm_size) cformat(%9.0f)
    svy: mean l_prod2 if (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, cformat(%9.0f)

    ///Firms Importers of manufacturing goods (Only sector A, B, C)
    svy: tab firm_size if (g_ciiu == 1|g_ciiu == 2|g_ciiu == 3) & (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, missing count format(%9.1g)
    svy: total C3P301A_T1 if (g_ciiu == 1|g_ciiu == 2|g_ciiu == 3) & (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, over(firm_size) cformat(%9.0f)
    svy: total renumeraciones_pc if (g_ciiu == 1|g_ciiu == 2|g_ciiu == 3) & (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, over(firm_size) cformat(%9.0f)
    svy: mean C3P301A_T1 if (g_ciiu == 1|g_ciiu == 2|g_ciiu == 3) & (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, over(firm_size) cformat(%9.0f)
    svy: mean C3P301A_T1 if (g_ciiu == 1|g_ciiu == 2|g_ciiu == 3) & (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, cformat(%9.0f)
    svy: mean C9P906_T4 if (g_ciiu == 1|g_ciiu == 2|g_ciiu == 3) & (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, over(firm_size) cformat(%9.0f)
    svy: total C9P906_T4 if (g_ciiu == 1|g_ciiu == 2|g_ciiu == 3) & (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, over(firm_size) cformat(%9.0f)
    svy: mean C9P906_T4 if (g_ciiu == 1|g_ciiu == 2|g_ciiu == 3) & (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, cformat(%9.0f)
    svy: mean renumeraciones_pc if (g_ciiu == 1|g_ciiu == 2|g_ciiu == 3) & (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, over(firm_size) cformat(%9.0f)
    svy: mean renumeraciones_pc if (g_ciiu == 1|g_ciiu == 2|g_ciiu == 3) & (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, cformat(%9.0f)
    svy: mean l_prod if (g_ciiu == 1|g_ciiu == 2|g_ciiu == 3) & (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, over(firm_size) cformat(%9.0f)
    svy: mean l_prod if (g_ciiu == 1|g_ciiu == 2|g_ciiu == 3) & (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, cformat(%9.0f)
    svy: mean l_prod2 if (g_ciiu == 1|g_ciiu == 2|g_ciiu == 3) & (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, over(firm_size) cformat(%9.0f)
    svy: mean l_prod2 if (g_ciiu == 1|g_ciiu == 2|g_ciiu == 3) & (C6P624 == 2 & C4P408 == 1) & durable_goods != 1 & lockdown_sectors != 1, cformat(%9.0f)

    ///Firms in lockdown sector
    svy: tab firm_size if lockdown_sectors == 1, missing count format(%9.1g)
    svy: total C3P301A_T1 if lockdown_sectors == 1, over(firm_size) cformat(%9.0f)
    svy: total renumeraciones_pc if lockdown_sectors == 1, over(firm_size) cformat(%9.0f)
    svy: mean C3P301A_T1 if lockdown_sectors == 1, over(firm_size) cformat(%9.0f)
    svy: mean C3P301A_T1 if lockdown_sectors == 1, cformat(%9.0f)
    svy: mean C9P906_T4 if lockdown_sectors == 1, over(firm_size) cformat(%9.0f)
    svy: total C9P906_T4 if lockdown_sectors == 1, over(firm_size) cformat(%9.0f)
    svy: mean C9P906_T4 if lockdown_sectors == 1, cformat(%9.0f)
    svy: mean renumeraciones_pc if lockdown_sectors == 1, over(firm_size) cformat(%9.0f)
    svy: mean renumeraciones_pc if lockdown_sectors == 1, cformat(%9.0f)
    svy: mean l_prod if lockdown_sectors == 1, over(firm_size) cformat(%9.0f)
    svy: mean l_prod if lockdown_sectors == 1, cformat(%9.0f)
    svy: mean l_prod2 if lockdown_sectors == 1, over(firm_size) cformat(%9.0f)
    svy: mean l_prod2 if lockdown_sectors == 1, cformat(%9.0f)

    ///Firm with financial vulnerability (all)
    svy: tab firm_size if bottomq == 1 , missing count format(%9.1g)
    svy: total C3P301A_T1 if bottomq == 1 , over(firm_size) cformat(%9.0f)
    svy: total renumeraciones_pc if bottomq == 1 , over(firm_size) cformat(%9.0f)
    svy: mean C3P301A_T1 if bottomq == 1 , over(firm_size) cformat(%9.0f)
    svy: mean C3P301A_T1 if bottomq == 1 , cformat(%9.0f)
    svy: mean C9P906_T4 if bottomq == 1 , over(firm_size) cformat(%9.0f)
    svy: total C9P906_T4 if bottomq == 1 , over(firm_size) cformat(%9.0f)
    svy: mean C9P906_T4 if bottomq == 1 , cformat(%9.0f)
    svy: mean renumeraciones_pc if bottomq == 1 , over(firm_size) cformat(%9.0f)
    svy: mean renumeraciones_pc if bottomq == 1 , cformat(%9.0f)
    svy: mean l_prod if bottomq == 1, over(firm_size) cformat(%9.0f)
    svy: mean l_prod if bottomq == 1, cformat(%9.0f)
    svy: mean l_prod2 if bottomq == 1, over(firm_size) cformat(%9.0f)
    svy: mean l_prod2 if bottomq == 1, cformat(%9.0f)

    ///Firm with financial vulnerability (not in other sectors)
    svy: tab firm_size if (marker!= 1 & marker2!= 1) & lockdown_sectors!= 1 ///
& bottomq == 1, missing count format(%9.1g)
    svy: total C3P301A_T1 if (marker!= 1 & marker2!= 1) & lockdown_sectors!= 1 ///
& bottomq == 1, over(firm_size) cformat(%9.0f)
    svy: total renumeraciones_pc if (marker!= 1 & marker2!= 1) & lockdown_sectors!= 1 ///
    & bottomq == 1, over(firm_size) cformat(%9.0f)
    svy: mean C3P301A_T1 if (marker!= 1 & marker2!= 1) & lockdown_sectors!= 1 ///
& bottomq == 1, over(firm_size) cformat(%9.0f)
    svy: mean C3P301A_T1 if (marker!= 1 & marker2!= 1) & lockdown_sectors!= 1 ///
& bottomq == 1, cformat(%9.0f)
    svy: mean C9P906_T4 if (marker!= 1 & marker2!= 1) & lockdown_sectors!= 1 ///
& bottomq == 1, over(firm_size) cformat(%9.0f)
    svy: total C9P906_T4 if (marker!= 1 & marker2!= 1) & lockdown_sectors!= 1 ///
& bottomq == 1, over(firm_size) cformat(%9.0f)
    svy: mean C9P906_T4 if (marker!= 1 & marker2!= 1) & lockdown_sectors!= 1 ///
& bottomq == 1, cformat(%9.0f)
    svy: mean renumeraciones_pc if (marker!= 1 & marker2!= 1) & lockdown_sectors!= 1 & bottomq == 1, over(firm_size) cformat(%9.0f)
    svy: mean renumeraciones_pc if (marker!= 1 & marker2!= 1) & lockdown_sectors!= 1 & bottomq == 1, cformat(%9.0f)
    svy: mean l_prod if (marker!= 1 & marker2!= 1) & lockdown_sectors!= 1 & bottomq == 1, over(firm_size) cformat(%9.0f)
    svy: mean l_prod if (marker!= 1 & marker2!= 1) & lockdown_sectors!= 1 & bottomq == 1, cformat(%9.0f)
    svy: mean l_prod2 if (marker!= 1 & marker2!= 1) & lockdown_sectors!= 1 & bottomq == 1, over(firm_size) cformat(%9.0f)
    svy: mean l_prod2 if (marker!= 1 & marker2!= 1) & lockdown_sectors!= 1 & bottomq == 1, cformat(%9.0f)
    /*
   //svy: mean and descriptive tables. Code from: https://www.stata.com/statalist/archive/2007-07/msg00581.html
   ***** BEGIN:
    program mean_sd_table1
        syntax varlist

        tempname v
        quietly svy: mean `varlist'
        matrix `v' = e(N)*vecdiag(e(V_srs))

        local k : list sizeof varlist
        display as txt %12s "Variable"		///
            as txt %10s "N"			///
            as txt %10s "Mean"		///
            as txt %12s "Std. Dev."
        forval i = 1/`k' {
            local var : word `i' of `varlist'
            display	      as txt %12s "`var'"	///
                " "   as res %9.0g e(N)		///
                " "   as res %9.0g _b[`var']	///
                "   " as res %9.0g sqrt(`v'[1,`i'])
        }
    end

   mean_sd_table1 GVA C3P301A_T1 C9P904_7 renumeraciones_pc C9P906_T4
    pr drop mean_sd_table1
    */
/// Close the log, end the file
    //log close
    //exit
