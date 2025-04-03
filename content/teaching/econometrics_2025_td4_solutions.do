********************************************************************************
** Description: Tutorial 4
** Author log 
** 2024-01-11 v01 NK - Initial version
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
            global root        "C:/Users/nknecht/Dropbox/Teaching/2025/Econometrics/TD4/NK"
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
			log using "$logs/Tutorial 4.log", replace
 
* Set a timer
			timer on 1
 
 
********************************************************************************
*** Table of content
*** 	01. Problem 1
*** 	02. Problem 2
*** 	03. Problem 3
*** 	04. Problem 6
*** 	05. Problem 7
***		99. Notes
********************************************************************************
 

********************************************************************************
***		01. Problem 2
********************************************************************************
/*
Use the data in td3 houseprices.dta to estimate the model
price = β0 + β1 sqrf t + β2 bdrms + u,
where price is the house price measured in thousands of dollars
*/

use "$clean/td4_houseprices", replace

reg price sqrft bdrms

* a) Write out the results in equation form.
di "price = " _b[_cons] " + " _b[sqrft] " sqrft + " _b[bdrms] " bdrms + u"

* b) What is the estimated increase in price for a house with one more bedroom, holding square footage constant?
di "The estimated increase in price is " _b[bdrms]*1000

* c) What is the estimated increase in price for a house with an additional bedroom that is 140 square feet in size? Compare this to your answer in b)
di "The estimated increase in price is " (_b[sqrft]*140 + _b[bdrms])*1000

* d) What percentage of the variation in price is explained by square footage and number of bedrooms?
di "The percentage of the variation explained is "e(r2)*100 "%"

* e) The first house in the sample has sqrf t = 2, 438 and bdrms = 4. What is the predicted selling price for this house from the OLS regression?
predict price_hat, xb
di price_hat[1]

scalar prd_price =  _b[_cons] + _b[sqrft]*2438 + _b[bdrms]*4
di "The predicted price would be " prd_price*1000

* f) The actual selling price of the first house in the sample was USD 300,000 (so price = 300). Find the residual for this house. Does it suggest that the buyer underpaid or overpaid for the house?
predict u_hat, residual
di u_hat[1]

scalar resid_price = (300-prd_price)*1000
di "As the residual is negative, the house was predicted to be worth more by " resid_price ". But, of course, there are many other features of a house (some that we cannot even measure) that affect price, and we have not controlled for these."


********************************************************************************
***		02. Problem 3
********************************************************************************
/*
The file td3 ceo.dta contains data on 177 chief executive officers, which can be used to examine
the effects of firm performance on CEO salary.
*/

use "$clean/td4_ceo", replace

* a) Estimate a model relating annual salary to firm sales and market values. Make the model of the constant elasticity variety for both independent variables. Write the results out in equation form. log(salary) = β0 + β1 log(sales) + β2 log(mktval) + u.
reg lsalary lsales lmktval
di "Lsales = " _b[_cons] " + " _b[lsales] "log(sales) + " _b[lmktval] "log(mktval) + u"

* b) Add profits to the model from a). Why can this variable not be included in logarithmitic form? Would you say that these firm performance variables explain most of the variation in CEO salaries?
count if profits < 0
di "Profits cannot be added in logarithmitic form, as " r(N) " are negative, for which the logarithm is not defined."
reg lsalary lsales lmktval profits
di "The coefficient on profits is very small. Here, profits are measured in millions, so if profits increase by $1 billion, which means Delta(profits) = 1,000 – a huge change – predicted salary increases by about only" _b[profits]*1000 "%. However, remember that we are holding sales and market value fixed. The firm performance variables explain "e(r2)*100 "% of the variation. This is certainly not most of the variation."

* c) Add the variable ceoten (years as CEO with this company) to the model from b). What is the estimated percentage return for another year of CEO tenure, holding other factors fixed?
reg lsalary lsales lmktval profits ceoten
di "The estimated percentage return is approximately " _b[ceoten]*100

* d) Find the sample correlation coefficient between the variables log(mktval) and prof its. Are these variables highly correlated? What does this say about the OLS estimators?
corr lmktval profits
di "The sample correlation coefficient is equal to " r(rho) ", which is fairly high. As we know, this causes no bias in the OLS estimators, although it can cause their variances to be large. Given the fairly substantial correlation between market value and firm profits, it is not too surprising that the latter adds nothing to explaining CEO salaries. Also, profits is a short term measure of how the firm is doing while mktval is based on past, current, and expected future profitability."


********************************************************************************
***		03. Problem 4
********************************************************************************
/*
Use td4 gpa.dta for this exercise. The data set is for 366 student athletes from a large university
for fall and spring semesters. Because you have two terms of data for each student, an unobserved
effects model is appropriate. The primary question of interest is this: Do athletes perform more
poorly in school during the semester their sport is in season?
*/

use "$clean/td4_gpa", replace

* a) Use pooled OLS to estimate a model with term GPA (trmgpa) as the dependent variable. The explanatory variables are spring, sat, hsperc, female, black, white, frstsem, tothrs, crsgpa, and season. Interpret the coefficient on season. Is it statistically significant?
xtset id term
reg trmgpa season spring sat hsperc female black white frstsem tothrs crsgpa 
di "For season, we don't have significant coefficient but the negative sign of the coefficient is signalling us that in term when sport is in season, athlete students tend to perform worse than in term when sport is off season: lower GPA of around " _b[season]

* b) Most of the athletes who play their sport only in the fall are football players. Suppose the ability levels of football players differ systematically from those of other athletes. If ability is not adequately captured by SAT score and high school percentile, explain why the pooled OLS estimators will be biased
di "This situation creates correlation between season variable the type of sport that students are engaged in. This may likely lead to omitted variable bias, because season variable might be capturing the differences in academic ability between football and non-football players. Hence, pooled OLS estimates might be biased."

* c) Now use the data differenced across the two terms. Which variables drop out? Now test for an in-season effect.
foreach var of varlist _all {
	bys id (term): gen d1_`var' = `var'[_n]-`var'[_n-1]
	gen d1a_`var' = D.`var' //only works if xtset is done before 
}

reg d1_trmgpa d1_season d1_spring d1_sat d1_hsperc d1_female d1_black d1_white d1_frstsem d1_tothrs d1_crsgpa

 		  
reg D.trmgpa D.season D.spring D.sat D.hsperc D.female D.black D.white D.frstsem D.tothrs D.crsgpa
di "Here all time-invariant variables dropped out. The effect of season is now larger, with " _b[D.season] " (not statistically significant). It signals us that there was probably omitted variable bias in pooled OLS estimation, which was coming from time-invariant factors. With first-differenced model, we control for these time-invariant unobserved and observed factors completely."

* d) Can you think of one or more potentially important, time-varying variables that have been omitted from the analysis?
di "One possibility is that athlete-students may take easier courses in their sport season. In these easier courses, they may get higher grades "




********************************************************************************
***		04. Problem 5 
********************************************************************************
/*
Use the data in td4 sleep.dta from Biddle and Hamermesh (1990) to study whether there is a
trade-off between the time spent sleeping per week and the time spent in paid work. We could use
either variable as the dependent variable. For concreteness, estimate the model
sleep = β0 + β1 totwrk + u,
where sleep is minutes spent sleeping at night per week and totwrk is total minutes worked during
the week.
*/

use "$clean/td4_sleep", replace

reg sleep totwrk

* a) Report your results in equation form along with the number of observations and R2. What does the intercept in this equation mean?
di "sleep = " _b[_cons] " + " _b[totwrk] " totwrk + u. The number of observations is equal to " e(N) " and the R-squared is equal to " e(r2)

* b) If totwrk increases by 2 hours, by how much is sleep estimated to fall? Do you find this to be a large effect?
di "Sleep is estimated to fall by " _b[totwrk]*(-2) "h, which is equal to " _b[totwrk]*(-120) " minutes, which is not a lot over the whole week."

********************************************************************************
***		05. Problem 6 
********************************************************************************
/*
A problem of interest to health officials (and others) is to determine the effects of smoking during
pregnancy on infant health. One measure of infant health is birth weight; a birth rate that is too low
can put an infant at risk for contracting various illnesses. Since factors other than cigarette smoking
that affect birth weight are likely to be correlated with smoking, we should take those factors into
account. For example, higher income generally results in access to better prenatal care, as well as
better nutrition for the mother. An equation that recognises this is
bwght = β0 + β1 cigs + β2 faminc + u.
*/

* a) What is the most likely sign for β2 and why?
di "Probably β_2 > 0, as more income typically means better nutrition for the mother and better prenatal care."

* b) Do you think cigs and faminc are likely to be correlated? Explain why the correlation might be positive or negative.
use "$clean/td4_cigs", replace
corr cigs faminc
di "On the one hand, an increase in income generally increases the consumption of a good, and cigs and faminc could be positively correlated. On the other, family incomes are also higher for families with more education, and more education and cigarette smoking tend to be negatively correlated. The sample correlation between cigs and faminc is about " r(rho) ", indicating a negative correlation."

* c) Now estimate the equation with and without faminc, using the data in td4 cigs.dta. Report the results in equation form, including the sample size and R-squared. Discuss your results, focusing on whether adding faminc substantially changes the estimated effect of cigs on bwght.
reg bwght cigs faminc
di "The effect of cigarette smoking is slightly smaller when faminc is added to the regression, but the difference is not great. This is due to the fact that cigs and faminc are not very correlated, and the coefficient on faminc is practically small. (The variable faminc is measured in thousands, so $10,000 more in 1988 income increases predicted birth weight by only " %3.2f _b[faminc]*10 " ounces.)"

********************************************************************************
***		07. Problem 7
********************************************************************************
/*
The data in td4 fertility.dta includes, for women in Botswana during 1988, information on number
of children, years of education, age, and religious and economic status variables.
children = β0 + β1 educ + β2 age + β3 age2 + u
*/

use "$clean/td4_fertility", replace
* a) Estimate this model by OLS and interpret the estimates. In particular, holding age fixed, what is the estimated effect of another year of education on fertility? If 100 women receive another year of education, how many fewer children are they expected to have?
reg children educ age agesq

di "Another year of education, holding age fixed, results in about " _b[educ] " fewer children. In other words, for a group of 100 women, if each gets another of education, they collectively are predicted to have about " abs(round(100*_b[educ])) " fewer children."

* b) Frsthalf is a dummy variable equal to one if the woman was born during the first six months of the year. Assuming that frsthalf is uncorrelated with the error term from a), show that frsthalf is a reasonable IV candidate for educ. (Hint: You need to do a regression.)

reg educ age agesq frsthalf

di "The reduced form for educ is educ = π0 + π1age + π2age2 + π3frsthalf + v, and we need π3≠ 0. When we run the regression we obtain π_frsthalf ="  _b[frsthalf] " and se(3ˆπ) = " _se[frsthalf]". Therefore, women born in the first half of the year are predicted to have almost one year less education, holding age fixed. The t statistic on frsthalf is over 7.5 in absolute value, and so the identification condition holds."

* c) Estimate the model from 1 by using frsthalf as an IV for educ. Compare the estimated effect of education with the OLS estimate from a).

ivreg2 children age agesq (educ = frsthalf)

di "The structural equation estimated by IV is = −3.388 − .1715 educ + .324 age − .00267 age􀀀children2 (0.548) (.0532) (.018) (.00028) n = 4.361, R2 = .550. The estimated effect of education on fertility is now much larger. Naturally, the standard error for the IV estimate is also bigger, about nine times bigger. This produces a fairly wide 95% CI for β1."


* d) Add the binary variables electric, tv, and bicycle to the model and assume these are exogenous. Estimate the equation by OLS and 2SLS and compare the estimated coefficients on educ. Interpret the coefficient on tv and explain why television ownership has a negative effect on fertility.

reg children educ age agesq electric tv bicycle 

ivreg2 children age agesq electric tv bicycle (educ = frsthalf)

di "When we add electric, tv, and bicycle to the equation and estimate it by OLS we obtain = −4.390 − .0767 educ + .340 age − .00271 age2 − .303 electric (.0240) (.0064) (.016) (.00027) (.076) - .253 tv + .318 bicycle (.091) (.049) n = 4,356, R2 = .576. The 2SLS (or IV) estimates are = −3.591 − .1640 educ + .328 age − .00272 age􀀀children2 − .107 electric (0.645) (.0655) (.019) (.00028) (.166) − .0026 tv + .332 bicycle (.2092) (.052) n = 4,356, R2 = .558. ""

"Adding electric, tv, and bicycle to the model reduces the estimated effect of educ in both cases, but not by too much. In the equation estimated by OLS, the coefficient on tv implies that, other factors fixed, four families that own a television will have about one fewer child than four families without a TV. Television ownership can be a proxy for different things, including income and perhaps geographic location. A causal interpretation is that TV provides an alternative form of recreation. Interestingly, the effect of TV ownership is practically and statistically insignificant in the equation estimated by IV (even though we are not using an IV for tv). The coefficient on electric is also greatly reduced in magnitude in the IV estimation. The substantial drops in the magnitudes of these coefficients suggest that a linear model might not be the functional form, which would not be surprising since children is a count variable."

********************************************************************************
***    	99. Notes
********************************************************************************

			timer off 1