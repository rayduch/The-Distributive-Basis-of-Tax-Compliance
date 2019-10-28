clear all
cd "/Users/aslicansunar/Dropbox/_Papers for publication/Tax compliance/Draft/Graphs"
use "/Users/aslicansunar/Dropbox/_Papers for publication/Tax compliance/master sept032018.dta", clear

set scheme s1mono
gen declare=declared/profitret


tab treatment, gen(treat)
sort treatment


gen benefits = 0
replace benefits=1 if session == 13 | session==14 | session==15 | session==16 | session==17 | session==18 |session==22 | session==23 | session==24 | session==19 | session==20 | session==21


encode treatment, generate(treatment2)
describe
label define treatmentl 1 "Progressive benefits,proportional taxation" 2 "Progressive benefits,progressive taxation" 3 "Proportional benefits,proportional taxation" 4 "Proportional benefits,progressive taxation"
label values treatment2 treatmentl

gen taxregime=0
replace taxregime=1 if session == 13 | session==14 | session==15 | session==1 | session==2 | session==3 | session==16 |session==17 | session==18 | session==4| session==5 | session==6 

egen s1 = concat(auditrate session period group), punct(-)
by s1, sort: egen rank=rank(profitret), unique 
by s1, sort: gen size = _N
drop if size>4
label variable rank "Income rank of the subject"
label define rankl 1 "1" 2 "2" 3 "3" 4 "4"
label values rank rankl

egen subject_unique_no = concat(session subject), punct(-)
gen income_level=0
replace income_level=1 if rank==3 | rank==4
label define incomel 0 "Poor" 1 "Rich"
label values income_level incomel

gen tax=0
replace tax=1 if taxratetoshow==50
label define taxl 0 "Low tax" 1 "High tax"
label values tax taxl

gen audit=0
replace audit=1 if auditrate==10
label define auditl 0 "No audits" 1 "0.1 probability of being audited"
label values audit auditl


gen altruism=offerdg/1000
**Tax rate
cibar declare, over1(audit) over2(income_level) graphopts(yti("") l2title("Ratio of declared earnings")) ciopts(lcolor(black))
graph export audit1.png, replace

cibar declare, over1(tax) over2(income_level) graphopts(yti("") l2title("Ratio of declared earnings")) ciopts(lcolor(black))
graph export tax1.png, replace

cibar declare,   over1(treatment2) over2(income_level) graphopts(yti("") l2title("Ratio of declared earnings") legend(cols(1))) ciopts(lcolor(black))
graph export explain1.png, replace

***APSA regressions
preserve
keep if treatment2==1
reg declare c.rank##c.ind_alt, robust
estimates store t1_1, title(Model 1)
reg declare c.rank##c.ind_alt i.tax i.audit, robust
estimates store t1_2, title(Model 2)
reg declare c.rank##c.ind_alt i.tax i.audit ideology jgender age_subject safechoices, robust
estimates store t1_3, title(Model 3)
restore

preserve
keep if treatment2==2
reg declare c.rank##c.ind_alt, robust
estimates store t2_1, title(Model 1)
reg declare c.rank##c.ind_alt i.tax i.audit, robust
estimates store t2_2, title(Model 2)
reg declare c.rank##c.ind_alt i.tax i.audit ideology jgender age_subject safechoices, robust
estimates store t2_3, title(Model 3)
restore

preserve
keep if treatment2==3
reg declare c.rank##c.ind_alt, robust
estimates store t3_1, title(Model 1)
reg declare c.rank##c.ind_alt i.tax i.audit, robust
estimates store t3_2, title(Model 2)
reg declare c.rank##c.ind_alt i.tax i.audit ideology jgender age_subject safechoices, robust
estimates store t3_3, title(Model 3)
restore

preserve
keep if treatment2==4
reg declare c.rank##c.ind_alt, robust
estimates store t4_1, title(Model 1)
reg declare c.rank##c.ind_alt i.tax i.audit, robust
estimates store t4_2, title(Model 2)
reg declare c.rank##c.ind_alt i.tax i.audit ideology jgender age_subject safechoices, robust
estimates store t4_3, title(Model 3)
restore

esttab t1_1 t1_2 t1_3 t2_1 t2_2 t2_3 t3_1 t3_2 t3_3 t4_1 t4_2 t4_3 using tableapsa.tex, replace varwidth(25) label nobaselevels interaction(" $\times$ ") style(tex) star(* 0.1 ** .05 *** .01) cells(b(star fmt(2)) se(par fmt(2))) 

preserve
keep if treatment2==2
reg declare i.income_level##c.ind_alt i.tax i.audit ideology jgender age_subject safechoices, robust
margins if tax==1, at(income_level=(0 1) ind_alt=(1 3))
marginsplot,recast(scatter) legend(cols(1) label(1 "Altruism=1" 2 "Altruism=3")) xtitle("")
graph export treatment2_result.png, replace
restore

preserve
keep if treatment2==3
reg declare i.income_level##c.ind_alt i.tax i.audit ideology jgender age_subject safechoices, robust
margins if tax==0, at(income_level=(0 1) ind_alt=(1 3))
marginsplot,recast(scatter) legend(cols(1) label(1 "Altruism=1" 2 "Altruism=3")) xtitle("")
graph export treatment3_result.png, replace
restore

***Treatment effects - 3 way interactions"
reg declare i.rank##i.treatment2##i.ind_alt taxratetoshow auditrate, robust
margins, at(rank=(1 2 3 4) treatment2=(2) ind_alt=(1 3))
marginsplot,recast(scatter) legend(cols(1))xtitle("")
graph export treatment2_alt.png, replace

margins, at(rank=(1 2 3 4) treatment2=(3) ind_alt=(1 3))
marginsplot,recast(scatter) legend(cols(1))xtitle("")
graph export treatment3_alt.png, replace

margins i.rank, over(i.treatment2)
marginsplot,recast(scatter) legend(cols(1))xtitle("")
graph export treatment_income_benefits.png, replace

reg declare i.income_level##i.treatment2##i.ind_alt taxratetoshow auditrate, robust
margins, at(income_level=(0 1) treatment2=(2) ind_alt=(1 3))
marginsplot,recast(scatter) legend(cols(1))xtitle("")
graph export treatment2_alt_2.png, replace

margins, at(income_level=(0 1) treatment2=(3) ind_alt=(1 3))
marginsplot,recast(scatter) legend(cols(1))xtitle("")
graph export treatment3_alt_2.png, replace

margins i.income_level, over(i.treatment2)
marginsplot,recast(scatter) legend(cols(1))xtitle("")
graph export treatment_income_benefits.png, replace

reg declare i.income_level##i.treatment2##i.ind_alt, robust
estimates store n1_1, title(Model 1)
reg declare i.income_level##i.treatment2##i.ind_alt taxratetoshow auditrate, robust
estimates store n1_2, title(Model 2)
reg declare i.income_level##i.treatment2##i.ind_alt taxratetoshow auditrate ideology jgender age_subject safechoices, robust
estimates store n1_3, title(Model 3)
esttab n1_1 n1_2 n1_3 using tablen1.texvarwidth(25) label nobaselevels interaction(" $\times$ ")style(tex),replace varwidth(25) label nobaselevels interaction(" $\times$ ") style(tex) star(* 0.1 ** .05 *** .01) cells(b(star fmt(2)) se(par fmt(2))) 


reg declare i.rank##i.treatment2##i.ind_alt, robust
estimates store k1_1, title(Model 1)
reg declare i.rank##i.treatment2##i.ind_alt taxratetoshow auditrate, robust
estimates store k1_2, title(Model 2)
reg declare i.rank##i.treatment2##i.ind_alt taxratetoshow auditrate ideology jgender age_subject safechoices, robust
estimates store k1_3, title(Model 3)
esttab k1_1 k1_2 k1_3 using tablek1.tex,replace star(* 0.1 ** .05 *** .01) cells(b(star fmt(2)) se(par fmt(2))) 





















*******************************
**Treatment effect - 2 way interactions
reg declare i.income_level##i.treatment2##altruism taxratetoshow auditrate ideology jgender age_subject safechoices, robust
margins i.income_level if treatment2==1|treatment2==3, over(i.treatment2)
marginsplot,recast(scatter) legend(cols(1))xtitle("")
graph export treatment_income_benefits.png, replace

margins i.income_level if treatment2==3|treatment2==4, over(i.treatment2)
marginsplot,recast(scatter) legend(cols(1))xtitle("")
graph export treatment_income_tax.png, replace

margins i.income_level if treatment2==2|treatment2==4, over(i.treatment2)
marginsplot,recast(scatter) legend(cols(1))xtitle("")
graph export treatment_income_tax2.png, replace

reg declare i.income_level##i.treatment2, robust
estimates store m1_1, title(Model 1)
reg declare i.income_level##i.treatment2 taxratetoshow auditrate, robust
estimates store m1_2, title(Model 2)
reg declare i.income_level##i.treatment2 taxratetoshow auditrate ideology jgender age_subject safechoices altruism, robust
estimates store m1_3, title(Model 3)
esttab m1_1 m1_2 m1_3 using table1.tex,replace star(* 0.1 ** .05 *** .01) cells(b(star fmt(2)) se(par fmt(2))) 


***Logistic regressions 
logit cheat i.income_level##i.treatment2 taxratetoshow auditrate ideology jgender age_subject safechoices altruism, robust
margins i.income_level if treatment2==1|treatment2==3, over(i.treatment2)
marginsplot,recast(scatter) legend(cols(1))xtitle("")
graph export treatment_income_logit_benefits.png, replace

margins i.income_level if treatment2==3|treatment2==4, over(i.treatment2)
marginsplot,recast(scatter) legend(cols(1))xtitle("")
graph export treatment_income_logit_tax.png, replace


logit cheat i.income_level##i.treatment2, robust
estimates store ml1_1, title(Model 1)
reg declare i.income_level##i.treatment2 taxratetoshow auditrate, robust
estimates store ml1_2, title(Model 2)
reg declare i.income_level##i.treatment2 taxratetoshow auditrate ideology jgender age_subject safechoices altruism, robust
estimates store ml1_3, title(Model 3)
esttab ml1_1 ml1_2 ml1_3 using table1_l.tex,replace star(* 0.1 ** .05 *** .01) cells(b(star fmt(2)) se(par fmt(2))) 



mean declare if taxratetoshow==50, over(taxregime benefits)

mean declare if taxratetoshow==25, over(taxregime benefits)

mean declare if taxratetoshow==50, over(rich treatment2)

mean declare if taxratetoshow==25, over(rich treatment2)

regr declare treat2 treat3 treat4 if taxratetoshow==25 & rich==1

regr declare treat2 treat3 treat4 if taxratetoshow==50 & rich==1

restore

