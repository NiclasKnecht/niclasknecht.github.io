********************************************************************************
** Description: Tutorial 2
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
            global root        "C:/Users/nknecht/Dropbox/Teaching/2025/Econometrics/TD2/NK"
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
			log using "$logs/Tutorial 2.log", replace
 
* Set a timer
			timer on 1
 
 
********************************************************************************
*** Table of content
*** 	01. Problem 2
***		02. Problem 5
***		03. Problem 8
***		99. Notes
********************************************************************************
 
********************************************************************************
***		01. Problem 2 
********************************************************************************
/*
Use the data set td2 wages.dta from Blackburn and Neumark (1992) for this exercise. It contains
information on monthly earnings, education, several demographic variables, and IQ scores for 935
men in 1980. To account for omitted variable bias, we add IQ and KWW ("Knowledge of the world
of work", a test score) to a standard log-wage (in the data as lwage) equation.
Our primary interest is in what happens to the estimated return to education:
log(wage) = β0 + β1 educ + β2 exper + β3 tenure + β4 ability + u
*/

use "$clean/td2_wages", replace

* a) Estimate by OLS the wage equation without controlling for ability. What is the estimated return to education in this case?
reg lwage educ exper tenure
estimates store No_control
display "The estimated return to education is " _b[educ]*100 "%"

* b) Use the variable IQ as a proxy for ability. What is the estimated return to education in this case? Is it necessary to control for it?
reg lwage educ exper tenure IQ
estimates store IQ
display "The estimated return to education with IQ is " _b[educ]*100 "%. The low p-value makes it appear necessary to control for it."

* c) Use the variable KWW as a proxy for ability instead of IQ. What is the estimated return to education in this case?
reg lwage educ exper tenure KWW
estimates store KWW
display "The estimated return to education with KWW is " _b[educ]*100 "%."

* d) Now use IQ and KWW together as proxy variables. What happens to the estimated return to education? What do you conclude?
reg lwage educ exper tenure IQ KWW
estimates store IQ_KWW
display "The estimated return to education with IQ and KWW is " _b[educ]*100 "%."

estout *
eststo clear 
display "The estimated return to education is lowest (more than one percentage point less than with KWW alone) when including IQ and KWW. Due to initial OVB we had an upward bias in the estimated returns to education."


********************************************************************************
***		02. Problem 5 
********************************************************************************
/*
Use the data in td2 price.dta and the following model of house prices:
price = β0 + β1 lotsize + β1 sqrf t + β3 bdrms + u,
where lotsize is the size of the lot (land) in square feet, sqrft is the size of the house in square feet,
and bdrm is the number of bedrooms
*/

use "$clean/td2_price.dta", replace

* a) Estimate the equation with heteroskedasticity-robust standard errors and discuss any important differences with the usual standard errors.
// Usual standard errors
reg price lotsize sqrft bdrms
predict price_hat1, xb // fitted values
predict u_hat1, resid

// Robust standard errors
reg price lotsize sqrft bdrms, robust
predict price_hat2, xb // fitted values
predict u_hat2, resid
display "The robust standard error on lotsize is almost twice as large as the usual standard error, making lotsize much less significant (the t statistic falls from about 3.23 to about 1.70). The t statistic on sqrft also falls, but it is still very significant. The variable bdrms actually becomes somewhat more significant, but it is still barely significant. The most important change is in the significance of lotsize."

* b) Create a scatterplot between the residuals and the fitted values. What can we infer from the graph?
twoway (scatter u_hat1 price_hat1)
twoway (scatter u_hat2 price_hat2)
display "The errors do not appear homoskedastic, thus using robust standard errors appears to be the right way."

* c) Repeat a) but transforming the continuous variables into logarithms, such that the elasticities of price with respect to lotsize and sqrft are constant. Report your results
// Log transformation
gen logprice = log(price)
gen loglotsize = log(lotsize)
gen logsqrft = log(sqrft)
reg logprice loglotsize logsqrft bdrms
di "Here, the heteroskedasticity-robust standard error is always slightly greater than the corresponding usual standard error, but the differences are relatively small. In particular, log(lotsize) and log(sqrft) still have very large t statistics, and the t statistic on bdrms is not significant at the 5% level against a one-sided alternative using either standard error."

* d) What does this example suggest about heteroskedasticity and the transformation used for the dependent variable?
di "Using the logarithmic transformation of the dependent variable often mitigates, if not entirely eliminates, heteroskedasticity. This is certainly the case here, as no important conclusions in the model for log(price) depend on the choice of standard error."

* e) Apply the full White's test for heteroskedasticity (Note: you cannot use robust standard errors). Use the chi-square form of the statistic and obtain the p-value. What do you conclude?
reg logprice loglotsize logsqrft bdrms
estat imtest, white
di "The null hypothesis of homoskedastic standard errors can not be reject at a p-value of " r(p)

* f) Apply the Breusch-Pagan test for heteroskedasticity to the same equation. What do you infer?
reg logprice loglotsize logsqrft bdrms
estat hettest
di "The null hypothesis of homoskedastic standard errors can not be reject at a p-value of " r(p)



********************************************************************************
***		03. Problem 8 
********************************************************************************
/*
Using the dataset td2 sales.dta estimate the following model:
rdintens = β0 + β1 sales + β2sales2 + u,
where the variable rdintens is expenditures on research and development (R&D) as a percentage of
sales. Sales are measured in millions of dollars.
*/

use "$clean/td2_sales", replace
reg rdintens sales salessq

* a) At what point does the marginal effect of sales on rdintens become negative?
di "By simple algebra (maximising the function) we get the FOC which tells us that the marginal effect becomes negative at " %6.2f _b[sales]/(-2*_b[salessq])/1000 " billion." 

* b) Would you keep the quadratic term in the model? Explain.
di "Probably. Its t statistic is about –1.86, which is significant against the one-sided alternative H0: 1β < 0 at the 5% level (cv ≈ –1.70 with df = 29). In fact, the p-value is about .036."

* c) Define salesbil as sales measured in billions of dollars: salesbil = sales/1000. Rewrite the estimated equation with salesbil and salesbil2 as independent variables instead of sales and sales2. Report your results, including standard errors and R-squared. (Hint: Note that salesbil2 = sales2/10002.)
gen salesbil = sales/1000
gen salesbilsq = salesbil^2
eststo: reg rdintens sales salessq
eststo: reg rdintens salesbil salesbilsq
di "Because sales gets divided by 1,000 to obtain salesbil, the corresponding coefficient gets multiplied by 1,000: (1,000)(.00030) = .30. The standard error gets multiplied by the same factor. As stated in the hint, salesbil2 = sales/1,000,000, and so the coefficient on the quadratic gets multiplied by one million: (1,000,000)(.0000000070) = .0070; its standard error also gets multiplied by one million. Nothing happens to the intercept (because rdintens has not been rescaled) or to the R2:"

* d) For the purpose of reporting the results, which equation do you prefer?
esttab, nomtitles
eststo clear
di "The equation in c) is easier to read because it contains fewer zeros to the right of the decimal. Of course the interpretation of the two equations is identical once the different scales are accounted for."

********************************************************************************
***    	99. Notes
********************************************************************************

			timer off 1