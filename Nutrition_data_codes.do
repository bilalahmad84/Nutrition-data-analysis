 
* setting up the working Directory
cd "D:\da"
* Importing Latest data set of Central Asia Stunting Initiative(CASI) Shared by DHRC of AKU
import excel "D:\da\child.xlsx", sheet("Sheet1") firstrow
* cleaning and dropping 
rename member_uuid m_uid
rename dateofassessment doa
rename heightcm height
rename weightkg weight
rename muaccm muac
rename unioncouncil uc
drop zscorelw zscorela zscorewa
* identifying and dropping duplicates
duplicates tag m_uid doa, generate(dup)
drop if dup > 0
* Cleaning Gender variable
replace gender = "Boy" if gender == "Male"
replace gender = "Girl" if gender == "Female"
replace gender = "male" if gender == "Boy"
replace gender = "female" if gender == "Girl"
* Creating and Labelling Sex Variable
gen sex =.
replace sex = 1 if gender == "male"
replace sex = 2 if gender == "female"
label define xenhii 1 "male" 2 "female"
label val sex xenhii
* Converting string to numerical variable the anthro data 
 gen cht = real( height)
 format cht %9.2f
gen chw = real(weight)
format chw %9.2f
gen muac2 = real(muac)
format muac2 %9.2f
gen bmi2 = real(bmi)
format bmi2 %9.2f
* Generating BMI without texts 
// Extract the numeric part of the BMI
gen numeric_bmi = real(regexs(0)) if regexm(bmi, "^[0-9.]+")
replace numeric_bmi = real(substr(bmi, 1, strpos(bmi, " ") - 1)) if missing(numeric_bmi)
// List the results
list bmi numeric_bmi
* Formatting date of assessment as it is in string format
generate date2 = date(doa, "DMY")
format %td date2
* Formatting dob as it is in string format
gen dob_date = date(dob, "YMDhms")
format %td dob_date
* formatting dob in different formats
generate dob_date = date(substr(dob, 1, strpos(dob, " ") - 1), "MDY")
format dob_date %td
* resolving date format issue for dob_date
// Split the date into month, day, and year parts
gen month = substr(dob, 1, strpos(dob, "/") - 1)
gen temp = substr(dob, strpos(dob, "/") + 1, .)
gen day = substr(temp, 1, strpos(temp, "/") - 1)
gen year = substr(temp, strpos(temp, "/") + 1, .)
// Ensure day and month have leading zeros if necessary
replace day = substr("0" + day, -2, 2)
replace month = substr("0" + month, -2, 2)
// Combine the parts into a normalized date string
gen normalized_dob = day + "/" + month + "/" + year
// Convert the normalized date string to Stata date format
gen dob_date = date(normalized_dob, "DMY")
// Format the date to ddMMMyyyy
format dob_date %tdDDmonCCYY
// Drop intermediate variables
drop month temp day year
// List the results
list dob normalized_dob dob_date
* Generating age in months variable 
gen age_m = floor(doa - dob) / 30.4375
generate age_rounded = round(age_m)
replace age_m = round(age_m)
* Generating age in Year
gen age_y = floor(doa - dob) /365.25
generate age_rounded = round(age_y)
replace age_y = round(age_y)
* Generating age in year categoreis for woman data
gen agcate = .
replace agcate = 1 if age_y >= 15 & age_y <= 24
replace agcate = 2 if age_y >= 25 & age_y <= 34
replace agcate = 3 if age_y >= 35 & age_y <= 44
replace agcate = 4 if age_y >= 45 & age_y <= 49
label define acts 1 "15-24" 2 "25-34" 3 "35-44" 4 "45-49"
label val agcate acts
* Making categories of age 
gen agcat = .
replace agcat = 1 if age_m >= 0 & age_m <= 5
replace agcat = 2 if age_m >= 6 & age_m <= 23
replace agcat = 3 if age_m >= 24 & age_m <= 59
replace agcat = 4 if age_m >= 60
label define ars 1 "0-5" 2 "6-23" 3 "24-59" 4 "overage"
label val agcat ars
* labelling Districts
gen district2 = .
replace district2 = 1 if district == "Upper Chitral"
replace district2 = 2 if district == "Lower Chitral"
label define dem 1 "Upper Chitral" 2 "Lower Chitral"
label val district2 dem
 * Generating visit Numbers and assigning values 
bys m_uid: gen vn = _n
recode vn (0/1=1) (2/1000= 2), gen (viscategory)
label define assigni 1 `""Registration""' 2 `""Followup""'
label values viscategory assigni
* Generatig total visits for each of the child/woman
bys m_uid: gen total_visits = _N
* Generating different date types
* Monthly data
gen mdate=mofd(date2)
format mdate %tm
gen month_num = month(doa)
* Getting the month number 
gen month = real(substr( date2, 4, 2))
* Quarterly Data 
gen qdate=qofd(date2)
format qdate %tq
* Yealry Data 
gen ydate=year(doa)
format ydate %ty
* Generating Z scores for height weight and MUac 
 zscore06, a(age_m) h(height) w(weight) s(sex) male(1) female(2)
 
 * Making categories of flagged cases 
 
 gen whzflag = 0
replace whzflag = 1 if whz06 < -5 | whz06 > 5
label define lilwhzflagt 0 "0 - not flagged" 1 "1 - whz <-5 or Whz > 5"
label val whzflag lilwhzflagt
gen wazflag = 0
replace wazflag = 1 if waz06 < -6 | waz06 > 5
label define aiawazflag 0 "0 -not flagged" 1 "1 - waz < -6 or waz > 5"
label val wazflag aiawazflag
 
gen hazflag = 0
replace hazflag = 1 if haz06 < -6 | haz06 > 6
label define liahazflag 0 "0 - not flagged" 1 "1 -haz < -6 or haz > 6"
label val hazflag liahazflag
gen bmiflag = 0
replace bmiflag = 1 if bmiz06 < -5 | bmiz06 > 5
label define liabmi 0 "0 - not flagged" 1 "1 -bmiz06 < -5 or bmiz06 > 5"
label val bmiflag liabmi
 * categorization of stunting and Growth falter
gen consec_count = cond(haz06 >= -2 & haz06 <= -1, 1, 0)
by m_uid: egen consec_group = sum(consec_count)
gen category = "Normal"
replace category = "Stunted" if haz06 < -2
replace category = "Growth Falter" if consec_group >= 3
drop consec_count consec_group
rename category hfa
gen hfa2 = .
replace hfa2 = 1 if hfa == "Stunted"
replace hfa2 = 2 if hfa == "Growth Falter"
replace hfa2 = 3 if hfa == "Normal"
label define lihff 1 "Stunted" 2 "Growth Falter" 3 "Normal"
label val hfa2 lihff
* Categorization of weight for age
gen wfa = .
replace wfa = 1 if waz06 >=-2
replace wfa = 2 if waz06 < -2
label define liwen 1 "normal" 2 "under weight"
label val wfa liwen
*Categorizaton of weight for height 
gen wfh = .
replace wfh = 1 if whz06 <= -2 & whz06 >= -3
replace wfh = 2 if whz06 < -3
replace wfh = 3 if whz06 > -2
label define liwhen 1 "MAM" 2 "SAM" 3 "Normal"
label val wfh liwhen
** Dropping the irrelvant years From Child data
drop if ydate == 2001 | ydate == 2002 | ydate == 2014 | ydate == 2017 | ydate == 2025
* Dropping irrelvatn years from woman data
drop if ydate == 1983 | ydate == 1991 | ydate == 1996 | ydate == 1998 | ydate == 2000
* Dropping irrelavant UCs
drop if uc == "Ashrait" | drop if uc == "Chitral 1" | drop if uc == "Kosht" | drop if uc == "Terich" 
* We want to get cleaned villages for village based analysis 
replace village = trim(village)
* working on Low Birth Weight (LBW) data
gen bw = real(birth_weight)
format bw %9.2f
 gen lbw =.
 replace lbw = 0 if bw >= 2.5
 replace lbw = 1 if bw < 2.5
label define lbw_status 0 "normal" 1 "LBW"
label values lbw lbw_status
* plausible LBW data
 gen pbw =.
 replace pbw = 0 if bw >= 0.9 & bw <= 5.5
 replace pbw = 1 if bw < 0.9 | bw > 5.5
label define pbws 0 "plausible" 1 "implausible"
label values pbw pbws
* Identifying the Lost to follow up cases
* Ensure data is sorted and days_between_assessments is calculated
sort m_uid date2
by m_uid: gen date2_lag = date2[_n-1]
gen days_between_assessments = date2 - date2_lag
* Generate the new variable 'ltf' and assign values based on the condition
gen ltf = ""
replace ltf = "lost to followup" if days_between_assessments > 60
replace ltf = "no" if days_between_assessments <= 60
* generating new bmi which includes numeric only
gen bmi_numeric = real(regexs(1)) if regexm(bmi, "([0-9.]+)")
* Village Wise improved cases calculation 
* Improvement from Stunted to Normal
* Sort the data by m_uid and date2
sort m_uid doa
* Create lagged versions of hfa2 to compare previous values
by m_uid: gen lag_hfa2 = hfa2[_n-1]
* Identify the improvements from "Stunted" to "Normal"
gen stunted_to_normal = (lag_hfa2 == 1 & hfa2 == 3)
* Ensure each unique child is counted only once per village
bysort m_uid: gen improvement_sequence = sum(stunted_to_normal)
by m_uid: gen first_improvement = (stunted_to_normal & improvement_sequence == 1)
* Summarize the number of unique improved cases by village
bysort district: egen district_improved_cases = total(first_improvement)
* Display the tabulation of improved cases by village
tabulate district district_improved_cases if first_improvement == 1
** Improvement from MAM to Normal
* sorting the data
sort m_uid date2
* Creating a lagged version of wfh to compare previous values
by m_uid: gen lag_wfh = wfh[_n-1]
* Identify the improvements from "MAM" to "Normal"
gen MAM_to_normal = (lag_wfh == 1 & wfh == 3)
* Ensure each unique child is counted only once per village
bysort m_uid: gen improvement_sequencem = sum(MAM_to_normal)
by m_uid: gen first_improvementm = (MAM_to_normal & improvement_sequencem == 1)
* Summarize the number of unique improved cases by village
bysort village_name: egen village_improved_casesm = total(first_improvementm)
* Display the tabulation of improved cases by village
tabulate village_name village_improved_casesm if first_improvementm == 1
* improvement from SAM to Normal
* sorting the data
sort m_uid date2
* Creating a lagged version of wfh to compare previous values
by m_uid: gen lag_wfhs = wfh[_n-1]
* Identify the improvements from "SAM" to "Normal"
gen SAM_to_normal = (lag_wfhs == 2 & wfh == 3)
* ...........................................District wise Analysis ...............................
* Generating a unique Id for analysis purpose 
egen ids = tag(m_uid)
* District wise improvement of stunting 
 * Sort the data by m_uid and date2
. sort m_uid date2
* Create lagged versions of hfa2 to compare previous values
. by m_uid: gen lag_hfa2 = hfa2[_n-1]
* Identify the improvements from "Stunted" to "Normal"
gen stunted_to_normal = (lag_hfa2 == 1 & hfa2 == 3)
* Ensure each unique child is counted only once per village
bysort m_uid: gen improvement_sequence = sum(stunted_to_normal)
by m_uid: gen first_improvement = (stunted_to_normal & improvement_sequence == 1)
* Summarize the number of unique improved cases by village
bysort district: egen district_improved_cases = total(first_improvement)
* Display the tabulation of improved cases by village
tabulate district district_improved_cases if first_improvement == 1
* working on defaulted children
* Filter for January 2024 and create a flag for presence in January
gen in_january_2024 = (month == 1 & year(date2) == 2024)
* Filter for June 2024 and create a flag for presence in June
gen in_june_2024 = (month == 6 & year(date2) == 2024)
* Identify unique children in January 2024
bysort m_uid: egen max_january = max(in_january_2024)
* Identify unique children in June 2024
bysort m_uid: egen max_june = max(in_june_2024)
* Determine children in January but not in June
gen in_january_not_june = (max_january == 1 & max_june == 0)
* Count the number of unique children in January but not in June
egen tag = tag(m_uid)
count if in_january_not_june == 1 & tag == 1