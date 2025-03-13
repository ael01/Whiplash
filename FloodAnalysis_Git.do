/*
NOTE: Interpretation is different for binary and continuous variables with ihs or log transformation.
To calculate the estimated % impact of a change from 0 to 1 (ie the DID coefficient turned on), use
100*(exp(beta-(0.5*(SE^2)))-1) where SE is standard error on the DID coefficient (beta). It isn't wildly different from 100(exp(beta)-1), or even 100*beta, but is more accurate. 
See https://davegiles.blogspot.com/2011/03/dummies-for-dummies.html for a basic discussion or https://web.uvic.ca/~dgiles/downloads/working_papers/ewp1101.pdf for more details

May need to install several packages:
ssc install reghdfe, replace
ssc install outreg2, replace
ssc install coefplot, replace
ssc install estout, replace
*/


capture log close 
set more off 
eststo clear 
*change to working directory ie folder with data
cd /Users/...
log using FloodAnalysis.log, text replace 

import delimited FloodingAnalysisDID.csv, varnames(1) case(preserve) clear

***************************
*Summary statistics and SI figures:
***************************

******
*Summary statistics table.
*2023
eststo summstats23: estpost summ KgHaAIPest KgHaAIInsectOnly KgHaAIHerbOnly KgHaAIFungOnly KgHaAIInsectFung FieldSizeHa FarmSizeHa  HaFlood23   if year==2023
*2022
eststo summstats22: estpost summ KgHaAIPest KgHaAIInsectOnly KgHaAIHerbOnly KgHaAIFungOnly KgHaAIInsectFung FieldSizeHa FarmSizeHa if year==2022
*output
esttab summstats22 summstats23 using Table1_SummaryStats.doc, replace main(mean %6.2f) aux(sd) coeflabel( KgHaAIPest "Pesticide AI (Kg/Ha)" KgHaAIInsectOnly "Insecticide AI (Kg/Ha)" KgHaAIHerbOnly "Herbicide AI (Kg/Ha)" KgHaAIFungOnly "Fungicide AI (Kg/Ha)" KgHaAIInsectFung "Insect./Fungicide AI (Kg/Ha)" FieldSizeHa "Field Size (Ha)" FarmSizeHa "Farm Size (Ha)" HaFlood23 "Flooded Area (Ha)"  ) nonotes nostar

******
*Dates Active, FIgure S1
twoway (bar TotActiveHaK Month_wOffset if year==2022, barwidth(0.4)) (bar TotActiveHaK Month_wOffset if year==2023, barwidth(0.4) bcolor(black)), scheme(s1mono) xlabel(1 (2) 12) legend(label(1 2022) label(2 2023) order(1 2))
graph export FigureS1_Flood_ActiveFieldsMo.png, replace


*************************
*Diff in Diff- Fig 3,4. Table S2
*treatment is Water. 
***************
gen After = (year==2023)
gen DiD = Water23*After

reghdfe ihsKgHaAIInsectOnly DiD Water23 FieldSizeHa ib2022.year , absorb(permit rcommShort trsFields) cluster(trsFields)
eststo InsectOnly
outreg2 using TableS2_DiDMain.doc, se nolabel nonotes title("`out'") dec(3) 2aster alpha(0.01, 0.05, 0.1) symbol(**,*, ~) ctitle("Insect-Only") replace

reghdfe ihsKgHaAIHerbOnly DiD FieldSizeHa Water23 ib2022.year, absorb(permit rcommShort trsFields) cluster(trsFields)
eststo HerbOnly
outreg2 using TableS2_DiDMain.doc, se nolabel nonotes title("`out'") dec(3) 2aster alpha(0.01, 0.05, 0.1) symbol(**,*, ~) ctitle("Herb-Only") 

reghdfe ihsKgHaAIFungOnly DiD FieldSizeHa Water23 ib2022.year, absorb(permit rcommShort trsFields) cluster(trsFields)
eststo FungOnly
outreg2 using TableS2_DiDMain.doc, se nolabel nonotes title("`out'") dec(3) 2aster alpha(0.01, 0.05, 0.1) symbol(**,*, ~) ctitle("Fung-Only") 

reghdfe ihsKgHaAIInsectFung DiD FieldSizeHa Water23 ib2022.year, absorb(permit rcommShort trsFields) cluster(trsFields)
eststo InsFung
outreg2 using TableS2_DiDMain.doc, se nolabel nonotes title("`out'") dec(3) 2aster alpha(0.01, 0.05, 0.1) symbol(**,*, ~) ctitle("Insect/Fung") 


*Year/whiplash Figure 3
*all epsticides, seperate y axes.
coefplot InsectOnly, bylabel(Insecticide) msymbol(O) mcolor(black) ciopts(color(black)) ||,  keep(*.year) rename(*.year = "") vertical yline(0,lcolor(black)) norecycle nooffsets msize(vlarge) xlabel(,labsize(large) angle(0)) ylabel(,labsize(large)) ylabel(-0.5  0.5, nogrid) yscale(range(-0.5 0.5) noextend) ytitle("IHS Insecticide (kg/ha)", size(large)) legend(off) scheme(s1mono) xline(3.5, lcolor(gray))
graph save InsectYr.gph, replace

coefplot HerbOnly, bylabel(Herbicide) msymbol(D) mcolor(black) ciopts(color(black)) ||,  keep(*.year) rename(*.year = "") vertical yline(0,lcolor(black)) norecycle nooffsets msize(vlarge) xlabel(,labsize(large) angle(0)) ylabel(-0.5  0.5, nogrid) yscale(range(-0.5 0.5) noextend) ytitle("IHS Herbicide (kg/ha)", size(large)) legend(off) scheme(s1mono) xline(3.5, lcolor(gray))
graph save HerbYr.gph, replace

coefplot FungOnly, bylabel(Fungicide) msymbol(S) mcolor(black) ciopts(color(black)) ||,  keep(*.year) rename(*.year = "") vertical yline(0,lcolor(black)) norecycle nooffsets msize(vlarge) xlabel(,labsize(large) angle(0)) ylabel(,labsize(large)) ylabel(-0.5  0.5, nogrid) yscale(range(-0.5 0.5) noextend) ytitle("IHS Fungicide (kg/ha)", size(large)) legend(off) scheme(s1mono) xline(3.5, lcolor(gray))
graph save FungYr.gph, replace

coefplot InsFung, bylabel(InsFung) msymbol(T) mcolor(black) ciopts(color(black)) ||,  keep(*.year) rename(*.year = "") vertical yline(0,lcolor(black)) norecycle nooffsets msize(vlarge) xlabel(,labsize(large) angle(0)) ylabel(,labsize(large)) ylabel(-0.5  0.5, nogrid) yscale(range(-0.5 0.5) noextend) ytitle("IHS Insect/Fungicide (kg/ha)", size(large)) legend(off) scheme(s1mono) xline(3.5, lcolor(gray))
graph save InsFungYr.gph, replace

graph combine InsectYr.gph HerbYr.gph  FungYr.gph InsFungYr.gph, scheme(s1mono)
graph export Figure3_AllPesticides_year.png, replace

*DiD figure, Figure 4
coefplot InsectOnly, bylabel(Insect.) msymbol(O) mcolor(black) ciopts(color(black)) || HerbOnly, bylabel(Herb.) msymbol(D) mcolor(black) ciopts(color(black)) ||  FungOnly, bylabel(Fung.) msymbol(S) mcolor(black) ciopts(color(black)) ||InsFung, bylabel(Ins/Fung.) msymbol(T) mcolor(black) ciopts(color(black)) ||, bycoefs keep(DiD) vertical yline(0,lcolor(black)) norecycle nooffsets msize(vlarge) xlabel(,labsize(large) angle(0)) ylabel(,labsize(large)) ylabel(-0.5  0.5, nogrid) yscale(range(-0.5 0.5) noextend) ytitle("IHS Pesticide Use (kg/ha)", size(large)) legend(off) scheme(s1mono)
graph save Figure4_Flood_All.gph, replace
graph export Figure4_Flood_All.png, replace

**********************
*Pretreatment Trends- Fig S3
**********************

gen DiD21 = (Water23==1 & year==2021)
label var DiD21 "2021"
gen DiD20 = (Water23==1 & year==2020)
label var DiD20 "2020"
gen DiD19 = (Water23==1 & year==2019)
label var DiD19 "2019"

reghdfe ihsKgHaAIInsectOnly DiD19 DiD20 DiD21  FieldSizeHa if After==0, absorb(permit rcommShort trsFields year Water23) cluster(trsFields)
eststo InsectOnly

reghdfe ihsKgHaAIHerbOnly DiD19 DiD20 DiD21  FieldSizeHa if After==0, absorb(permit rcommShort trsFields year Water23) cluster(trsFields)
eststo HerbOnly

reghdfe ihsKgHaAIFungOnly DiD19 DiD20 DiD21  FieldSizeHa if After==0, absorb(permit rcommShort trsFields year Water23) cluster(trsFields)
eststo FungOnly

reghdfe ihsKgHaAIInsectFung DiD19 DiD20 DiD21  FieldSizeHa if After==0, absorb(permit rcommShort trsFields year Water23) cluster(trsFields)
eststo InsFung


*Year figure
*all pesticides, seperate y axes.
coefplot InsectOnly, bylabel(Insecticide) msymbol(O) mcolor(black) ciopts(color(black)) ||,  keep(DiD*) rename(*.year = "") vertical yline(0,lcolor(black)) norecycle nooffsets msize(vlarge) xlabel(,labsize(large) angle(0)) ylabel(,labsize(large)) ylabel(-0.5  0.5, nogrid) yscale(range(-0.5 0.5) noextend) ytitle("IHS Insecticide (kg/ha)", size(large)) legend(off) scheme(s1mono) xline(3.5, lcolor(gray))
graph save InsectPretreat.gph, replace

coefplot HerbOnly, bylabel(Herbicide) msymbol(D) mcolor(black) ciopts(color(black)) ||,  keep(DiD*) rename(*.year = "") vertical yline(0,lcolor(black)) norecycle nooffsets msize(vlarge) xlabel(,labsize(large) angle(0)) ylabel(-0.5  0.5, nogrid) yscale(range(-0.5 0.5) noextend) ytitle("IHS Herbicide (kg/ha)", size(large)) legend(off) scheme(s1mono) xline(3.5, lcolor(gray))
graph save HerbPretreat.gph, replace

coefplot FungOnly, bylabel(Fungicide) msymbol(S) mcolor(black) ciopts(color(black)) ||,  keep(DiD*) rename(*.year = "") vertical yline(0,lcolor(black)) norecycle nooffsets msize(vlarge) xlabel(,labsize(large) angle(0)) ylabel(,labsize(large)) ylabel(-0.5  0.5, nogrid) yscale(range(-0.5 0.5) noextend) ytitle("IHS Fungicide (kg/ha)", size(large)) legend(off) scheme(s1mono) xline(3.5, lcolor(gray))
graph save FungPretreat.gph, replace

coefplot InsFung, bylabel(InsFung) msymbol(T) mcolor(black) ciopts(color(black)) ||,  keep(DiD*) rename(*.year = "") vertical yline(0,lcolor(black)) norecycle nooffsets msize(vlarge) xlabel(,labsize(large) angle(0)) ylabel(,labsize(large)) ylabel(-0.5  0.5, nogrid) yscale(range(-0.5 0.5) noextend) ytitle("IHS Insect/Fungicide (kg/ha)", size(large)) legend(off) scheme(s1mono) xline(3.5, lcolor(gray))
graph save InsFungPretreat.gph, replace

graph combine InsectPretreat.gph HerbPretreat.gph  FungPretreat.gph InsFungPretreat.gph, scheme(s1mono)
graph export FigureS3_AllPesticides_Pretreat.png, replace

*************************
**Split sample -Fig S4
*************************
local outcome "InsectOnly HerbOnly FungOnly InsectFung"
	foreach out in `outcome'{

*DiD 
quietly reghdfe ihsKgHaAI`out' DiD FieldSizeHa Water23 , absorb(permit rcommShort trsFields year) cluster(trsFields)
eststo `out'

quietly reghdfe ihsKgHaAI`out' DiD FieldSizeHa Water23 if MonthMinWater23<=2, absorb(permit rcommShort trsFields year) cluster(trsFields)
eststo `out'JF

quietly reghdfe ihsKgHaAI`out' DiD FieldSizeHa Water23 if MonthMinWater23>2 & MonthMinWater23!=., absorb(permit rcommShort trsFields year) cluster(trsFields)
eststo `out'JD

	}

coefplot (InsectOnly, msymbol(O) mcolor(black) ciopts(color(black))) || (InsectOnlyJF, msymbol(Oh) mcolor(black) ciopts(color(black))) || (InsectOnlyJD, msymbol(O) mcolor(gray) ciopts(color(gray)))|| (HerbOnly, msymbol(D) mcolor(black) ciopts(color(black)))|| (HerbOnlyJF, msymbol(Dh) mcolor(black) ciopts(color(black))) || (HerbOnlyJD, msymbol(D) mcolor(gray) ciopts(color(gray))) || (FungOnly, msymbol(S) mcolor(black) ciopts(color(black))) || (FungOnlyJF, msymbol(Sh) mcolor(black) ciopts(color(black))) || (FungOnlyJD, msymbol(S) mcolor(gray) ciopts(color(gray)))||(InsectFung, msymbol(T) mcolor(black) ciopts(color(black)))|| (InsectFungJF, msymbol(Th) mcolor(black) ciopts(color(black)))|| (InsectFungJD, msymbol(T) mcolor(gray) ciopts(color(gray)))||, bycoefs keep(DiD) vertical yline(0,lcolor(black)) norecycle  msize(vlarge) xlabel("",labsize(large) angle(0)) ylabel("",labsize(large)) ylabel(-.5  1, nogrid) yscale(range(-.5  1) noextend) ytitle("IHS Pesticides (kg/ha)")  legend(off) scheme(s1mono) title("", size(large) position(2) ring(0)) xlabel(2 "Insect. Only" 5 "Herb. Only" 8 "Fung. Only" 11 "Insect./Fung.")
graph save FigureS4_AllYrSplit.gph, replace
graph export FigureS4_AllYrSplit.png, replace

**********************
*Spin through top crops by area.
*Figure S5-S8
**********************
*see labels  InsectFung
*label list
*Almond (2), Pistachio (123), Uncultivated Ag (163), Grape (66), Alfalfa (1), Orange (108), Wheat Fot/Fod (168), Carrot (31), Tangerine/SDLS (156), Corn for/fod (41)
local commNum "2 123 163 66 1 108 168 31 156 41"
	foreach com in `commNum'{

	quietly reghdfe ihsKgHaAIInsectOnly DiD FieldSizeHa Water23 if rcommShort == `com', absorb(permit trsFields year) cluster(trsFields)
	eststo Insect`com'

	quietly reghdfe ihsKgHaAIHerbOnly DiD FieldSizeHa Water23 if rcommShort == `com', absorb(permit trsFields year) cluster(trsFields)
	eststo Herb`com'
	
	quietly reghdfe ihsKgHaAIFungOnly DiD FieldSizeHa Water23 if rcommShort == `com', absorb(permit trsFields year) cluster(trsFields)
	eststo Fung`com'

	quietly reghdfe ihsKgHaAIInsectFung DiD FieldSizeHa Water23 if rcommShort == `com', absorb(permit trsFields year) cluster(trsFields)
	eststo InsFung`com'

	}
	
coefplot (Insect2, msymbol(O) mcolor(black) ciopts(color(black))) || (Insect123, msymbol(Oh) mcolor(black) ciopts(color(black))) || (Insect163, msymbol(O) mcolor(gray) ciopts(color(gray)))||(Insect66, msymbol(D) mcolor(black) ciopts(color(black))) ||(Insect1, msymbol(Dh) mcolor(black) ciopts(color(black))) ||(Insect108, msymbol(D) mcolor(gray) ciopts(color(gray))) ||(Insect168, msymbol(S) mcolor(black)  ciopts(color(black))) ||(Insect31, msymbol(Sh) mcolor(black) ciopts(color(black))) ||(Insect156, msymbol(S) mcolor(gray) ciopts(color(gray)))||(Insect41, msymbol(T) mcolor(black) ciopts(color(black)))||, bycoefs keep(DiD) vertical yline(0,lcolor(black)) norecycle  msize(vlarge) xlabel("",labsize(large) angle(0)) ylabel(,labsize(large)) ylabel(-3  2, nogrid) yscale(range(-3  2) noextend) ytitle("")  legend(off) scheme(s1mono) title("Insect Only", size(large) position(11) ring(0)) xlabel(1 "Almond" 2 "Pistachio" 3 "Uncultivated" 4 "Grape" 5 "Alfalfa" 6 "Orange" 7 "Wheat Fod" 8 "Carrot" 9 "Tang SDLS" 10 " Corn Fod", angle(45))
graph save InsectCrops.gph, replace
graph export FigureS5_InsectCrops.png, replace

coefplot (Herb2, msymbol(O) mcolor(black) ciopts(color(black))) || (Herb123, msymbol(Oh) mcolor(black) ciopts(color(black))) || (Herb163, msymbol(O) mcolor(gray) ciopts(color(gray)))||(Herb66, msymbol(D) mcolor(black) ciopts(color(black))) ||(Herb1, msymbol(Dh) mcolor(black) ciopts(color(black))) ||(Herb108, msymbol(D) mcolor(gray) ciopts(color(gray))) ||(Herb168, msymbol(S) mcolor(black)  ciopts(color(black))) ||(Herb31, msymbol(Sh) mcolor(black) ciopts(color(black))) ||(Herb156, msymbol(S) mcolor(gray) ciopts(color(gray)))||(Herb41, msymbol(T) mcolor(black) ciopts(color(black)))||, bycoefs keep(DiD) vertical yline(0,lcolor(black)) norecycle  msize(vlarge) xlabel("",labsize(large) angle(0)) ylabel(,labsize(large)) ylabel(-3  2, nogrid) yscale(range(-3  2) noextend) ytitle("")  legend(off) scheme(s1mono) title("Herb Only", size(large) position(11) ring(0)) xlabel(1 "Almond" 2 "Pistachio" 3 "Uncultivated" 4 "Grape" 5 "Alfalfa" 6 "Orange" 7 "Wheat Fod" 8 "Carrot" 9 "Tang SDLS" 10 " Corn Fod", angle(45))
graph save HerbCrops.gph, replace
graph export FigureS6_HerbCrops.png, replace

coefplot (Fung2, msymbol(O) mcolor(black) ciopts(color(black))) || (Fung123, msymbol(Oh) mcolor(black) ciopts(color(black))) || (Fung163, msymbol(O) mcolor(gray) ciopts(color(gray)))||(Fung66, msymbol(D) mcolor(black) ciopts(color(black))) ||(Fung1, msymbol(Dh) mcolor(black) ciopts(color(black))) ||(Fung108, msymbol(D) mcolor(gray) ciopts(color(gray))) ||(Fung168, msymbol(S) mcolor(black)  ciopts(color(black))) ||(Fung31, msymbol(Sh) mcolor(black) ciopts(color(black))) ||(Fung156, msymbol(S) mcolor(gray) ciopts(color(gray)))||(Fung41, msymbol(T) mcolor(black) ciopts(color(black)))||, bycoefs keep(DiD) vertical yline(0,lcolor(black)) norecycle  msize(vlarge) xlabel("",labsize(large) angle(0)) ylabel(,labsize(large)) ylabel(-3  2, nogrid) yscale(range(-3  2) noextend) ytitle("")  legend(off) scheme(s1mono) title("Fung Only", size(large) position(11) ring(0)) xlabel(1 "Almond" 2 "Pistachio" 3 "Uncultivated" 4 "Grape" 5 "Alfalfa" 6 "Orange" 7 "Wheat Fod" 8 "Carrot" 9 "Tang SDLS" 10 " Corn Fod", angle(45))
graph save FungCrops.gph, replace
graph export FigureS7_FungCrops.png, replace

*Crop #1, 168 don't have this type.
coefplot (InsFung2, msymbol(O) mcolor(black) ciopts(color(black))) || (InsFung123, msymbol(Oh) mcolor(black) ciopts(color(black))) || (InsFung163, msymbol(O) mcolor(gray) ciopts(color(gray)))||(InsFung66, msymbol(D) mcolor(black) ciopts(color(black))) ||(InsFung108, msymbol(D) mcolor(gray) ciopts(color(gray)))  ||(InsFung31, msymbol(Sh) mcolor(black) ciopts(color(black))) ||(InsFung156, msymbol(S) mcolor(gray) ciopts(color(gray)))||(InsFung41, msymbol(T) mcolor(black) ciopts(color(black)))||, bycoefs keep(DiD) vertical yline(0,lcolor(black)) norecycle  msize(vlarge) xlabel("",labsize(large) angle(0)) ylabel(,labsize(large)) ylabel(-3  2, nogrid) yscale(range(-3  2) noextend) ytitle("")  legend(off) scheme(s1mono) title("Insect/Fung", size(large) position(11) ring(0)) xlabel(1 "Almond" 2 "Pistachio" 3 "Uncultivated" 4 "Grape" 5 "Orange"  6 "Carrot" 7 "Tang SDLS" 8 " Corn Fod", angle(45))
graph save InsFungCrops.gph, replace
graph export FigureS8_InsFungCrops.png, replace

*Robustness tests mentioned but not shown in main text.
*************************
*Diff in Diff
*>1ha water robustness test
***************
gen Water23B = (Water23 >=1 & HaFlood23>=1)
replace Water23B = . if Water23B ==0 & Water23 ==1

reghdfe ihsKgHaAIInsectOnly DiD Water23B FieldSizeHa ib2022.year , absorb(permit rcommShort trsFields) cluster(trsFields)
eststo InsectOnlyWater1

reghdfe ihsKgHaAIHerbOnly DiD FieldSizeHa Water23B ib2022.year, absorb(permit rcommShort trsFields) cluster(trsFields)
eststo HerbOnlyWater1

reghdfe ihsKgHaAIFungOnly DiD FieldSizeHa Water23B ib2022.year, absorb(permit rcommShort trsFields) cluster(trsFields)
eststo FungOnlyWater1

reghdfe ihsKgHaAIInsectFung DiD FieldSizeHa Water23B ib2022.year, absorb(permit rcommShort trsFields) cluster(trsFields)
eststo InsFungWater1

*DiD figure drop fields w 1ha of water
coefplot InsectOnlyWater1, bylabel(Insect.) msymbol(O) mcolor(black) ciopts(color(black)) || HerbOnlyWater1, bylabel(Herb.) msymbol(D) mcolor(black) ciopts(color(black)) ||  FungOnlyWater1, bylabel(Fung.) msymbol(S) mcolor(black) ciopts(color(black)) ||InsFungWater1, bylabel(Ins/Fung.) msymbol(T) mcolor(black) ciopts(color(black)) ||, bycoefs keep(DiD) vertical yline(0,lcolor(black)) norecycle nooffsets msize(vlarge) xlabel(,labsize(large) angle(0)) ylabel(,labsize(large)) ylabel(-0.5  0.5, nogrid) yscale(range(-0.5 0.5) noextend) ytitle("IHS Pesticide Use (kg/ha)", size(large)) legend(off) scheme(s1mono)
graph export Flood_All_1ha.png, replace

*************************
*Diff in Diff
*<25ha water robustness test
***************
gen Water23C = (Water23 ==1 & HaFlood23<=25)
replace Water23C = . if Water23C ==0 & Water23 ==1

reghdfe ihsKgHaAIInsectOnly DiD Water23C FieldSizeHa ib2022.year , absorb(permit rcommShort trsFields) cluster(trsFields)
eststo InsectOnlyWater25

reghdfe ihsKgHaAIHerbOnly DiD FieldSizeHa Water23C ib2022.year, absorb(permit rcommShort trsFields) cluster(trsFields)
eststo HerbOnlyWater25

reghdfe ihsKgHaAIFungOnly DiD FieldSizeHa Water23C ib2022.year, absorb(permit rcommShort trsFields) cluster(trsFields)
eststo FungOnlyWater25

reghdfe ihsKgHaAIInsectFung DiD FieldSizeHa Water23C ib2022.year, absorb(permit rcommShort trsFields) cluster(trsFields)
eststo InsFungWater25

**DiD figure drop fields w >25ha of water
coefplot InsectOnlyWater25, bylabel(Insect.) msymbol(O) mcolor(black) ciopts(color(black)) || HerbOnlyWater25, bylabel(Herb.) msymbol(D) mcolor(black) ciopts(color(black)) ||  FungOnlyWater25, bylabel(Fung.) msymbol(S) mcolor(black) ciopts(color(black)) ||InsFungWater25, bylabel(Ins/Fung.) msymbol(T) mcolor(black) ciopts(color(black)) ||, bycoefs keep(DiD) vertical yline(0,lcolor(black)) norecycle nooffsets msize(vlarge) xlabel(,labsize(large) angle(0)) ylabel(,labsize(large)) ylabel(-0.5  0.5, nogrid) yscale(range(-0.5 0.5) noextend) ytitle("IHS Pesticide Use (kg/ha)", size(large)) legend(off) scheme(s1mono)
graph save Flood_All_25ha.gph, replace
graph export Flood_All_25ha.png, replace

***************
*Diff in Diff
*Removing late dates active
***************
gen Late = (MonthActive>=11)

reghdfe ihsKgHaAIInsectOnly DiD Water23 FieldSizeHa ib2022.year if Late!=1, absorb(permit rcommShort trsFields) cluster(trsFields)
eststo InsectOnlyLate

reghdfe ihsKgHaAIHerbOnly DiD FieldSizeHa Water23 ib2022.year if Late!=1, absorb(permit rcommShort trsFields) cluster(trsFields)
eststo HerbOnlyLate

reghdfe ihsKgHaAIFungOnly DiD FieldSizeHa Water23 ib2022.year if Late!=1, absorb(permit rcommShort trsFields) cluster(trsFields)
eststo FungOnlyLate

reghdfe ihsKgHaAIInsectFung DiD FieldSizeHa Water23 ib2022.year if Late!=1, absorb(permit rcommShort trsFields) cluster(trsFields)
eststo InsFungLate

**DiD figure drop fields w >25ha of water
coefplot InsectOnlyLate, bylabel(Insect.) msymbol(O) mcolor(black) ciopts(color(black)) || HerbOnlyLate, bylabel(Herb.) msymbol(D) mcolor(black) ciopts(color(black)) ||  FungOnlyLate, bylabel(Fung.) msymbol(S) mcolor(black) ciopts(color(black)) ||InsFungLate, bylabel(Ins/Fung.) msymbol(T) mcolor(black) ciopts(color(black)) ||, bycoefs keep(DiD) vertical yline(0,lcolor(black)) norecycle nooffsets msize(vlarge) xlabel(,labsize(large) angle(0)) ylabel(,labsize(large)) ylabel(-0.5  0.5, nogrid) yscale(range(-0.5 0.5) noextend) ytitle("IHS Pesticide Use (kg/ha)", size(large)) legend(off) scheme(s1mono)
graph save Flood_All_Late.gph, replace
graph export Flood_All_Late.png, replace

***************
*Diff in Diff
*Level outcome
***************
reghdfe KgHaAIInsectOnly DiD Water23 FieldSizeHa ib2022.year , absorb(permit rcommShort trsFields) cluster(trsFields)
eststo InsectOnly_Level

reghdfe KgHaAIHerbOnly DiD FieldSizeHa Water23 ib2022.year, absorb(permit rcommShort trsFields) cluster(trsFields)
eststo HerbOnly_Level

reghdfe KgHaAIFungOnly DiD FieldSizeHa Water23 ib2022.year, absorb(permit rcommShort trsFields) cluster(trsFields)
eststo FungOnly_Level

reghdfe KgHaAIInsectFung DiD FieldSizeHa Water23 ib2022.year, absorb(permit rcommShort trsFields) cluster(trsFields)
eststo InsFung_Level


*DiD figure, level term
coefplot InsectOnly_Level, bylabel(Insect.) msymbol(O) mcolor(black) ciopts(color(black)) || HerbOnly_Level, bylabel(Herb.) msymbol(D) mcolor(black) ciopts(color(black)) ||  FungOnly_Level, bylabel(Fung.) msymbol(S) mcolor(black) ciopts(color(black)) ||InsFung_Level, bylabel(Ins/Fung.) msymbol(T) mcolor(black) ciopts(color(black)) ||, bycoefs keep(DiD) vertical yline(0,lcolor(black)) norecycle nooffsets msize(vlarge) xlabel(,labsize(large) angle(0)) ylabel(,labsize(large)) ylabel(-4  2, nogrid) yscale(range(-4 2) noextend) ytitle("Pesticide Use (kg/ha)", size(large)) legend(off) scheme(s1mono)
graph export DiD_Level.png, replace


**********************
*Stats mentioned in paper
*pesticide use for almonds and pistachios
summ KgHaAIInsectOnly KgHaAIHerbOnly KgHaAIFungOnly KgHaAIInsectFung if rcommShort ==2
summ KgHaAIInsectOnly KgHaAIHerbOnly KgHaAIFungOnly KgHaAIInsectFung if rcommShort ==123
 
*# of uncultivated fields don't change
count if commShort == "UNCULTIVATED AG" & year==2023
count if commShort == "UNCULTIVATED AG" & year==2022
*amount doesn't change much either
gen UncultHa = FieldSizeHa if comm == "UNCULTIVATED AG"


bysort year: egen TotYrUncultHa = sum(UncultHa)
bysort year: egen TotKgAI = sum(KgAIPest)
bysort year: egen TotHaPrmt = sum(FieldSizeHa)
*Kg pesticides, ha permitted
bysort year: summ TotHaPrmt TotKgAI TotYrUncultHa

***Crops that increased/decreased
collapse (sum) FieldSizeHa (first) commShort, by(rcommShort year)
keep if year==2023|year==2022
reshape wide FieldSizeHa, i(rcommShort) j(year)
gen diff2322Raw = (FieldSizeHa2023-FieldSizeHa2022)
gsort -diff2322Raw
list in 1/10
gsort diff2322Raw
list in 1/10
*Pistachios in different years
list FieldSizeHa2022 FieldSizeHa2023 if rcomm==123
*approx 70k pistachios, and reduced by 42%. 
display 70000*(5.6*0.42)

log close
