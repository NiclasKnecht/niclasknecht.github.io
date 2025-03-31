********************************************************************************
** Description: Tutorial 3
** Author log 
** 2024-01-25 v01 NK - Initial version
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
            global root        "C:/Users/nknecht/Dropbox/Teaching/2025/Econometrics/TD3/NK"
            global input_orig  "$root/01 Input data/01 Original raw data"
            global input_mod   "$root/01 Input data/02 Modified raw data"
            global scripts     "$root/02 Scripts"
            global clean       "$root/03 Cleaned Data"
            global graphs      "$root/04 Output/01 Graphs"
            global tables      "$root/04 Output/02 Tables"
            global other       "$root/04 Output/03 Other"
            global logs        "$root/05 Logs"
            global temp        "$root/06 Temp"
            global doc         "C:/Users/nknecht/Dropbox"
 

* Current date and time macro
            local c_date = c(current_date)
            local c_time = c(current_time)
            local c_time_date = "`c_date'"+"_"+"`c_time'"
            display "`c_time_date'"
            local time_string = subinstr("`c_time_date'", ":", "_", .)
            local time_string = subinstr("`time_string'", " ", "_", .)
 
               
* Start logging
			log using "$logs/Tutorial 3.log", replace
 
* Set a timer
			timer on 1
 
 
********************************************************************************
*** Table of content
*** 	01. Problem 2
*** 	02. Problem 3
*** 	03. Problem 4
*** 	04. Problem 5
*** 	05. Problem 6
*** 	06. Problem 7
***		99. Notes
********************************************************************************
 
********************************************************************************
***		01. Problem 1 
********************************************************************************
/*
Use the data in td3 lf.dta to investigate the determinants of labour force participation among
married women during 1975:
inlf = β0 + β1 nwif einc + β2 educ + β3 exper + β4 exper2 + β5 age + β6 kidslt6 + β7 kidsge6 + u,
where inlf is a dummy equal to one if the woman reports working for a wage outside the home
at some point during the year, and zero otherwise, nwifeinc is husband's earnings (measured in
thousands of dollars), educ years of education, exper past years of labour market experience, kidslt6
is the number of children less than six years old, and kidsge6 is the number of kids between 6 and
18 years of age.
*/

use "$clean/td3_lf", replace

* a) Estimate the model using LPM. What is the effect of one more small child (kidslt6 ) on the probability of labour force participation?
reg inlf nwifeinc educ exper expersq age kidslt6 kidsge6
di "The effect is that a married woman is " %2.1f _b[kidslt6]*(-100) "% less likely to be in work."

* b) Check if all fitted values are strictly between zero and one.
predict inlf_hat, xb
count if inlf_hat> 1 | inlf_hat < 0
di "There are " r(N) " fitted values that lie outside those bounds. Other than interpretation of coefficients or a first pass to modeling, there are NO GOOD REASONS TO USE THE LPM model"

* c) Estimate the same model using logit. Compare your results to LPM
logit inlf nwifeinc educ exper expersq age kidslt6 kidsge6
margins
di "Discussion of logit - you had this in class."

* d) Take a woman with nwif einc = 20.13, educ = 12.3, exper = 10.6, and age = 42.5 — which are roughly the sample averages and kidsge6 = 1. What is the estimated effect on the probability of working in going from zero to one small child? What would be the effect of going from one child to two small children?
logit inlf nwifeinc educ exper expersq age i.kidslt6 kidsge6
margins kidslt6, atmeans at(kidsge6 = 1) post
di "The estimated probability of being in work from zero to one child decreases from " %3.2f e(b)[1,1]*100 "% to " %3.2f e(b)[1,2]*100 "% and this probability decreases even further to " %3.2f e(b)[1,3]*100 "% for two children."

* e) Repeat c) and d) using probit
probit inlf nwifeinc educ exper expersq age kidslt6 kidsge6
margins
di "Discussion of probit"
logit inlf nwifeinc educ exper expersq age i.kidslt6 kidsge6
margins kidslt6, atmeans at(kidsge6 = 1) post
di "The estimated probability of being in work from zero to one child decreases from " %3.2f e(b)[1,1]*100 "% to " %3.2f e(b)[1,2]*100 "% and this probability decreases even further to " %3.2f e(b)[1,3]*100 "% for two children."
 
 
********************************************************************************
***		02. Problem 2
********************************************************************************
/*
Use the data td4 card.dta for this exercise. Card (1995) used wage and education data for a sample
of men in 1976 to estimate the return to education. He used a dummy variable for whether someone
grew up near a four-year college (nearc4 ) as an instrumental variable for education. In a log(wage)
equation, he included other standard controls: experience (exper ), a black dummy variable (black ),
dummy variables for living in an SMSA (smsa) and living in the south (south), and a full set of
regional dummy variables and an SMSA dummy for where the man was living in 1966 (smsa66 ).
*/

use "$clean/td3_card", replace

* a) Estimate the log(wage) equation using OLS. Interpret results.
local regdum 	reg662 reg663 reg664 reg665 reg666 reg667 reg668 reg669 // list of region dummies
reg lwage 		educ exper expersq black smsa south smsa66 `regdum'
di "Here, we have a coefficient of " _b[educ] " for educ, which means an additional year of education is associated with " %3.2f _b[educ]*100 "% higher wage. With this model, we can't say, for example, if the effect is due to education or due to ability which is an omitted variable (unobserved)"

* b) In order for nearc4 to be a valid instrument, it must be uncorrelated with the error term in the wage equation — we assume this — and it must be partially correlated with educ. To check the latter requirement, regress educ on nearc4 and all of the exogenous variables appearing in the equation as in Card (1995) (that is, we estimate the reduced form for educ.)
reg educ 		nearc4 exper expersq black smsa south smsa66 `regdum'
di "Growing up near fouryear college has strong effect on education, growing up near a four-year college is associated with " _b[nearc4] " higher years of education compared to those who did not grow up near a four-year college. We have shown that in this model Cov(Z,X)!=0, because the coefficient on nearc4 is statistically significant"

* c) Estimate the log(wage) equation using nearc4 as an IV for educ as in Card (1995). Compare results with OLS estimates from a). 
ivreg2 lwage 	(educ=nearc4) exper expersq black smsa south smsa66 `regdum'
di "Now, with IV, we have an estimate of " _b[educ] " for returns to education, which means additional year of education tends to lead to " %3.2f _b[educ]*100 "% higher wage. As we see, we are losing in terms of efficiency, because SE is much larger now. Compared to OLS results, IV estimates of returns to education is much larger."

* d) The difference between the IV and OLS estimates of the return to education are economically important. Obtain the reduced form residuals from a). Use these to test whether educ is exogenous; that is, determine if the difference between OLS and IV is statistically significant.
reg educ 		nearc4 exper expersq black smsa south smsa66 `regdum'
predict v2, resid				// Obtain residuals from first-stage reduced form regression from part (2)

/*
We plug this v2 into the first OLS equation and if we find statistically significant coefficient for v2 then it means educ is endogenous, and IV method is preferred
*/
reg lwage 		educ exper expersq black smsa south smsa66 `regdum' // u = b*v2
scalar educ_ols = _b[educ]
reg lwage 		educ exper expersq black smsa south smsa66 `regdum' v2 
scalar educ_iv = _b[educ]
di "Here we see that coefficient on v2 is not statistically significant which implies that educ is exogenous, or in other words, the difference between OLS and IV is not statistically significant. But, from economic sense, we see that this difference in the estimates of returns to education is still large (" educ_ols " vs. " educ_iv "). And in this scenario, it should still be safe to use IV."

* e) In order for IV to be consistent, the IV for educ (nearc4 ) must be uncorrelated with u. Could nearc4 be correlated with things in the error term, such as unobserved ability? Explain.
di "It is indeed possible that regional/geographical differences (unobserved) in ability might be corrlated to nearc4. For example, people living near four year college might have higher ability/intelligence than those who live far from four year college. Cov(Z,u)=0? "

* f) For a subsample of the men in the data set, an IQ score is available. Regress IQ on nearc4 to check whether average IQ scores vary by whether the man grew up near a four-year college. What do you conclude?
reg IQ 			nearc4 
di "Here, we find that those who grew up near fouryear college is associated with higher IQ."

* g) Now regress IQ on nearc4, smsa66, and the 1966 regional dummy variables reg662,. . . , reg669. Are IQ and nearc4 related after the geographic dummy variables have been partialled out? Reconcile this with your findings from c).
reg IQ 			nearc4 smsa66 `regdum'
di "Here we do not see significant coefficient for nearc4, which implies that the relationship between IQ and nearc4 that we estimated before is mainly due to regional differences in IQ, not because of man grew up close to fouryear college."

* h) From c) and d), what do you conclude about the importance of controlling for smsa66 and the 1966 regional dummies in the log(wage) equation? 
di "These results show that it is important to include regional dummies in the logwage equation to capture all differences across regions, which might be affecting our estimates of returns to education."

 

********************************************************************************
***		03. Problem 4
********************************************************************************
/*
Use the dataset td3 gpa.dta on 4,137 college students and estimate the following equation by OLS:
colgpa = β0 + β1 hsperc + β2 sat + u,
where colgpa is the grade point average (GPA) after the fall semester measured on a four-point scale,
hsperc is the percentile in the high school graduating class (e.g. if a student is in the top-5% of their
class, hsperc = 5), and sat is the combined maths and verbal score on the Student Achievement
Test
*/

use "$clean/td3_gpa", replace

reg colgpa hsperc sat

* a) Why does it make sense for the coefficient on hsperc to be negative?
di "The coefficient on hsperc is " _b[hsperc] ", which makes sense, as hsperc is a variable that decreases in how good a student is, whereas colgpa increases in the student's performance."

* b) What is the predicted college GPA when hsperc = 20 and sat = 1050?
di "The predicted college GPA is " _b[_cons] + _b[hsperc]*20 + _b[sat]*1050

* c) Suppose that two high school graduates, A and B, graduated in the same percentile from highschool, but student A's SAT schore was 140 points higher (about one standard deviation in the sample). What is the predicted difference in college GPA for these two students? Is the difference large?
di "The predicted difference is equal to " _b[sat]*140

* d) Holding hsperc fixed, what difference in SAT scores leads to a predicted colgpa difference of 0.50, or one half of a grade point? Comment on your answer.
di "The required difference is equal to " 0.5 / _b[sat] ". Perhaps not surprisingly, a large ceteris paribus difference in SAT score – almost two and one-half standard deviations – is needed to obtain a predicted difference in college GPA or a half a point."


********************************************************************************
***		04. Problem 5
********************************************************************************
/*
Consider a model where the return to education depends upon the amount of work experience:
log(wage) = β0 + β1 educ + β2 exper + β3 educ · exper + u
*/

* b) State the null hypothesis that the return to education does not depend on the level of exper. What do you think is the appropriate alternative? Use the data in td3 wage.dta to test the null hypothesis against your stated alternative
use "$clean/td3_wage", replace

gen educ_exper = educ*exper
reg lwage educ exper educ_exper
di "The estimated effect of the interaction is equal to " _b[educ_exper] ". Due to the p-value being " (ttail(e(df_r), abs(_b[educ_exper]/_se[educ_exper]))) " we can reject the null hypothesis at the 5% level."

* c) Let θ1 denote the return to education, when exper = 10: θ1 = β1 + 10β3. Obtain ˆθ1 and a 95% confidence interval for θ1. (Hint: Write β1 = θ1 − 10β3 and plug into the equation; then, rearrange. This gives the regression for obtaining the confidence interval for θ1.) 
lincom educ+educ_exper*10
di "We obtain the coefficient equal to " r(estimate) ". This means that if a person has 10 years of experience, one more year of education would increase the wage by 7.6%. The standard error is equal to " r(se) ", with an upper bound of the CI of " r(ub) " and a lower bound of " r(lb)

/* 
We rewrite the equation as
log(wage) = 0β + 1θeduc + 2βexper + 3βeduc(exper – 10) + u,
and run the regression log(wage) on educ, exper, and educ(exper – 10). We want the coefficient on educ. We obtain 1ˆθ≈ .0761 and se(1
ˆθ)≈ .0066. The 95% CI for 1θ is about .063 to .089.
*/


********************************************************************************
***		05. Problem 6
********************************************************************************
/*
Consider the data in td3 sleep.dta. The variable sleep is total minutes per week spent sleeping at
work, totwrk is total weekly minutes spent working, educ and age are measured in years, and male
is a gender dummy. Estimate the following equation with OLS
*/

use "$clean/td3_sleep", replace

reg sleep totwrk educ age agesq male

* a) All other factors being equal, is there evidence that men sleep more than women? How strong is the evidence?
di "Men sleep on average "  %9.2f _b[male] " minutes per week more than women. This is statistically significant. However, as this is only weekly minutes, this corresponds to "  %9.2f _b[male] /7 " minutes per day, or " %9.2f _b[male] /(7*60) " hours per day."

* b) Is there a statistically significant trade-off between working and sleeping? What is the estimated trade-off?
di "There is a tradeoff: for every 10 minutes of extra work, sleep decreases by about " %9.0f _b[totwrk]*(-10) " minutes."


********************************************************************************
***		06. Problem 7
********************************************************************************
/*
Using data from td3 sat.dta consider the following equation:
sat = β0 + β1 hsize + β2 hsize2 + β3 f emale + β4 black + β5 f emale · black + u,
where the variable sat is the combined SAT score, hsize is the size of the student's high school
graduating class (in hundreds), f emale is a gender dummy variable equal to one for women, and
black is a race dummy variable equal to one for black people, and zero otherwise.
*/

use "$clean/td3_sat", replace

* a) Estimate the equation. Is there strong evidence that hsize2 should be included in the model? From this equation, what is the optimal (for student's SAT scores) high school size?
gen fem_black = female*black
reg sat hsize hsizesq female black fem_black
di "The estimated effect is " _b[hsizesq] ", which is statistically significant at the 5% level as the p-value is equal to " (ttail(e(df_r), abs(_b[hsizesq]/_se[hsizesq]))) ". The optimal high school size is (by some algebra [the turning point of the parabola is the maximum]) " %4.0f _b[hsize]*100 / (-2*_b[hsizesq]) ". Of course, the very small R-squared shows that class size explains only a tiny amount of the variation in SAT score."

* b) Holding hsize fixed, what is the estimated difference in SAT score between non-black women and non-black men? Is this estimated difference statistically significant?
di "We need to look at coefficient female. We have statistically significant difference of " _b[female] "which means that SAT score of non-black female students is " %3.1f _b[female] " points lower than non-black male students."

* c) What is the estimated difference in SAT score between non-black men and black men? Test the null-hypothesis that there is no difference between their scores.
di "We need to look at coefficient black. We have stiatsically significant difference of " _b[black] " which means that SAT score of black male students is" %3.1f _b[black] " points lower than non-black male students, on average."

* d) What is the estimated difference in SAT score between black women and non-black women? What would you need to do to test whether the difference is statistically significant?
scalar difference = -(_b[fem_black] +_b[black])
di "For this, we can look at female_black interaction term and the term on black. We have statistically significant difference of which means that SAT score of female black studets is " %3.2f difference " points lower than non-black female students, on average. (we fix female=1, and then female*black + black will show the difference between black and non-black female students)"


********************************************************************************
***    	99. Notes
********************************************************************************

			timer off 1
