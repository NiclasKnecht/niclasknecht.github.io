********************************************************************************
** Description: Tutorial 4 - RDD
** Author log 
** 2024-01-15 v01 NK - Initial version
** QC log
** [not QC'ed yet, enter notes on QC here]
********************************************************************************
 
********************************************************************************
*** Initialisation
********************************************************************************
 
* Settings
            clear all
            capture log close
            set more off
            set varabbrev off
            set type double
            set dp period
            version 17
 
* Directory globals             
            global ROOT        "C:\Users\nknecht\Dropbox\Teaching\2025\Econometrics of Causality\TD 4 - RDD"

* Current date and time macro
            local c_date = c(current_date)
            local c_time = c(current_time)
            local c_time_date = "`c_date'"+"_"+"`c_time'"
            display "`c_time_date'"
            local time_string = subinstr("`c_time_date'", ":", "_", .)
            local time_string = subinstr("`time_string'", " ", "_", .)

* Set a timer
			timer on 1
 
 
********************************************************************************
*** Table of content
*** 	00. Introduction
***		01. - 07. Questions
***		99. Notes
********************************************************************************
 
********************************************************************************
***		00. Introduction 
********************************************************************************
/*
A large literature investigates the relationship between government policies and voters' choices. Many studies for instance have found that economic conditions around election time have predictive power for the incumbent's re-election success. However, there is less evidence on the effect of household economic conditions, and especially in targeted government transfers, on the evolution of voter preferences. Manacordan, Miguel, and Vigorito (2011) investigate whether being a recipient of a cash transfer program has an impact on political support for the government that implemented it. In March 2005, the Uruguayan government launched a large anti-poverty program, PANES. Household eligibility for the program was determined by a predicted income score based on various pre-program covariates. Thus, only households with scores below a predetermined threshold were eligible for PANES. The data for this exercise, which is the same as those used by Manacordan, Miguel, and Vigorito (2011), are located in the Donnees.dta file. They contain socioeconomic characteristics and political preferences for a sample of 1,942 Households. Eligibility to the program is measured by the variable called newtreat.
*/

use "$ROOT/td4", replace

describe

********************************************************************************
***		01. 
********************************************************************************\
/*
To get an understanding of the characteristics of the Households present in the sample create a table that gives the mean and standard deviation of Household socioeconomic characteristics. Do this separately for eligible and non-eligible Households, and then compare the means across these groups. Comment on the similarities and differences between eligible and non-eligible Households. 
*/

local keyvars	hh_educ hhsize avage female educ ln_income 

foreach var in `keyvars'{
    di as error "`var'"
	sum `var'
	reg `var' newtreat, robust
	reg `var' i.newtreat##c.ind_reest, robust
}

/*
The problem is that the treated individuals are poor and the individuals in the control group are rich, which would introduce selection bias. One would have to control for the distance to the threshold as well. 

Distance from threshold taken into account (ind_reest=predicted income). The only remaining difference is household size
*/

********************************************************************************
***		02. 
********************************************************************************\
/*
Following Manacordan, Miguel, and Vigorito (2011), the measure of political support that we will use is the support to the current left-wing government Frente Amplio during the program. The variable for this is called support07. Compare the mean of this variable across eligible and non-eligible households. Is the difference statistically significant? Is it large when compared to the mean value? What does it suggest about the power of social policies on support to the government? 
*/

sum support07
reg support07 newtreat, robust

/*
Comparison of means: political support is greater among PANES recipients - recipients of social policies tend to be in favour of the government that gave them this
*/


********************************************************************************
***		03. 
********************************************************************************\
/*
To determine program allocation, the government used a predicted income score that depended only on household socioeconomic characteristics collected in the baseline survey. Only households with predicted income scores below a predetermined threshold were assigned to program treatment. An important element to be considered in such a program is to know whether the eligible population received the program. Estimate the share of the eligible household which received PANES. Next, use a graphic to show whether the eligible households were enrolled in the program. What can you conclude about the implementation of the program? How can you define the threshold used? 
*/

tab newtreat aprobado, row

rdplot newtreat ind_reest, c(0) p(1)	// c(#) specifies the RD cutoff in indepvar
										// p(#) specifies the order of the (global) polynomial fit used to approximate the population conditional expectation functions for control and treated units.

twoway (scatter newtreat ind_reest), xline(0)

/*
Good allocation: 99.47% of eligible households actually received the pension and we see a sharp discontinuity 
*/ 


********************************************************************************
***		04. 
********************************************************************************\
/*
The authors use a regression discontinuity design to make sure they are comparing similar households. To do this, they consider that program assignment around the eligibility threshold was nearly "as good as random". As a check for non-random assignment, the authors estimated whether pre-treatment covariates vary discontinuously at the eligibility threshold. Based on your previous answers, what can you conclude regarding the validity of their identification assumption? What does it imply on the 1 household assignment to PANES? 
*/

local keyvars	hh_educ hhsize avage female educ ln_income 

pause on

foreach var in `keyvars'{
    rdplot `var' ind_reest, c(0) p(1) graph_options(title(`"`: var label `var''"')) // press 'end' to continue
	pause
	/*
	twoway 	(lfitci `var' ind_reest if ind_reest<0) ///
			(lfitci `var' ind_reest if ind_reest>0), ///
				legend(off) xline(0) title(`"`: var label `var''"')	
	pause
	*/
}

pause off

/*
Covariates appear to be similar around the threshold.
*/


********************************************************************************
***		05. 
********************************************************************************\
/*
Let us now measure the impact of receiving PANES on government support. The estimated equation is : 

support = alpha + beta*newstreat + f1[N_1] + newstreat*f_2[N_i] + epsilon 

s=β_0+β_1 〖newtreat〗_i+f_1 N_i+〖newtreat〗_i×f_2 N_i+ε_i

where newtreat is a dummy equal to 1 if the normalized income score of household i is negative, i.e. it receives PANES. N_i is the normalized income score of household i ; f1 and f2 are parametric polynomials in the normalized income score on either side of the eligible threshold. Estimate the regression without and with the following controls : pre-program characteristics of household members, log per-capita income, age, education, and gender of the household head, as well as localidad fixed-effects. Compare this to a simple comparison of mean in government support. Were there big changes in the estimated difference ? What happens if you add and interacted the eligibility status with a polynomial in the standardized score of degrees 1, and 2 ? Does this suggest that the program has a robust effect on government support ? 
*/

* No controls
reg support07 newtreat ind_reest, robust
display _b[_cons] + _b[newtreat]

rdplot support07 ind_reest, c(0) p(1) graph_options(title("Government support during program"))

/*
twoway 	(lfitci  support07 ind_reest if ind_reest<0) ///
		(lfitci support07 ind_reest if ind_reest>0), ///
			legend(off) xline(0)
*/

* Full regression 
reg support07 i.newtreat##c.ind_reest, robust  

* Regression with another polynomial
gen ind_reest2=ind_reest^2
reg support07 i.newtreat##c.ind_reest i.newtreat##c.ind_reest2, robust

* Add controls 
reg support07 newtreat ind_reest hh_educ hhsize avage female educ ln_income, robust  
reg support07 i.newtreat##c.ind_reest hh_educ hhsize avage female educ ln_income, cluster(ind_reest)  
reg support07 i.newtreat##c.ind_reest i.newtreat##c.ind_reest2 hh_educ hhsize avage female educ ln_income, robust  

/*
Without any control = mean comparison: Households receiving PANES are significantly more supportive of the government. Eligibility for the program implies an 11 percentage point increase in support for the government compared to the opposition (89% compared to 78%). 

With controls: increases the proportion of people in favor of the government, but not the difference between C and T: 94% of those eligible versus 85% of those ineligible.
*/


********************************************************************************
***		06. 
********************************************************************************\
/*
Lastly, two important questions arise: did the program have persistent impacts on government support? To do this, we measure the political support in 2008, 1 year after the program. You should use the variable called support08. Did the program induce higher support on other political institutions and organizations than the current government? 
*/

reg support08 newtreat ind_reest, robust 

rdplot support08 ind_reest, c(0) p(1) graph_options(title("Government support after program"))

/*
twoway 	(lfitci  support08 ind_reest if ind_reest<0) ///
		(lfitci support08 ind_reest if ind_reest>0), ///
			legend(off) xline(0)
*/
 
* Robustness checks
* Different polynomials
eststo: quietly reg support08 i.newtreat##c.ind_reest, robust  
eststo: quietly reg support08 i.newtreat##c.ind_reest i.newtreat##c.ind_reest2, robust  

* Add controls
eststo: quietly reg support08 newtreat ind_reest hh_educ hhsize avage female educ ln_income, robust  
eststo: quietly reg support08 i.newtreat##c.ind_reest hh_educ hhsize avage female educ ln_income, robust  
eststo: quietly reg support08 i.newtreat##c.ind_reest i.newtreat##c.ind_reest2 hh_educ hhsize avage female educ ln_income, robust

esttab, b(a2) se(a1) r2 label nomtitles 

eststo clear

/*
We obtain similar results. The impact of the program persists on the political preferences. 73% of the individuals in the control group are in favour of the government (in 2008) compared to 83% among the eligible individuals. This is a 10% point difference.
*/


********************************************************************************
***		07. 
********************************************************************************\
/*
To conclude, what is the strength of the evidence that government economic policies impact beneficiaries' political preferences? Does this give rise to a clear policy implication for future economic policies?
*/

reg mdes newtreat ind_reest hh_educ hhsize avage female educ ln_income, robust  
reg president newtreat ind_reest hh_educ hhsize avage female educ ln_income, robust  
reg political_parties newtreat ind_reest hh_educ hhsize avage female educ ln_income, robust  

/*
We see higher trust only in the institutions that are directly involved in the implementation of the PANES (mdes and president). Nevertheless we see less support than in the government.
*/


********************************************************************************
***    	99. Notes
********************************************************************************

			timer off 1

		