********************************************************************************
** Description: Econometrics of Causality TD1 - Thornton (2008_)
** Author log 
** 2025-02-01 NK - Initial version
** QC log
** [not QC'ed yet, enter notes on QC here]
********************************************************************************
timer clear
timer on 1

**#******************************************************************** COMMENTS


**#************************************************************************ HEAD

global ROOT "C:\Users\nknecht\Dropbox\Teaching\2025\Econometrics of Causality\TD 1 - RCT"


**#***************************************************************** INFORMATION
/*
The goal of this problem set is to analyze data from a randomized impact evaluation. We will be using data from a paper by Thornton (AER 2008) titled, "The Demand and Impact of Learning HIV Status". HIV is an important issue in Malawi. To address it, one fundamental aspect is for individuals to learn whether they are infected or not by HIV. 

To do this, the government sends nurses to people's house to collect a blood sample. A few days later, individuals must go to the health center of their village, where they will meet with a doctor who will tell them whether they are infected or not. The problem is that many people do not ever go to the health center to find out whether they are infected. In a country where HIV-infected individuals are often discriminated against, one hypothesis is that people are scared that, when going to the health center, their neighbors may see him/her and suspect that they are HIV positive. 

To address this issue, Thornton (2008) examines whether cash payments to individuals who go to the health center to learn about their test results can limit this effect – one can now tell their neighbors that they're just going to the health center to get paid. This cash incentive was randomly assigned at the individual level. 

Key Variables:
any = 1 if randomly assigned any level of incentive to obtain HIV test result, zero otherwise

Ti = the randomly assigned value of the cash incentive (in Kwacha) to obtain HIV test results in discrete values

got = 1 if learned about HIV status, zero otherwise

Going forward, those who were assigned a cash incentive to get their test results are known as the "treatment" group and those who are not receiving a cash incentive are known as the "control" group.

*/

**#******************************************************************* LOAD DATA

use "$ROOT/td1.dta", clear


**#*************************************************************** SUMMARY STATS

/*
The first step is to look at summary statistics of your sample. This will tell you the sample population that you are analyzing. We will also see if there are differences between the treatment and control group.
*/

// 1. Present the simple means and SD for age, gender, HIV status in 2004, having had sex in 2004 and average years of education in 2004 (using all of the observations). What do you notice about the sample size for each variable?

local sumvars 	age male hiv2004 hadsex12 educ2004 mar

sum `sumvars' // missing values

/* 
The mean age of the population is 34 years. There are a bit more women than men (53% to 47%) in the sample. The mean years of education is 3.5 years and about 25% of the sample has never gone to school. More than 75% of the individuals in the sample reported to have had sexual relations in the previous 12 months. 
*/


// 2. Now, conduct a statistical test to determine whether there were pre-treatment differences in age, HIV status, marital status, sexual activity (in 2004) years of education and gender by treatment and control groups (using the entire sample). Do you see any differences between the treatment and control groups? If so, how could these affect the analysis?

foreach var in `sumvars' {
	di as error "`var'"
	ttest `var', by(any)
	reg `var' any
}

/* 
For a RCT to be valid, the randomisation has to have been done correctly on a sufficiently big sample (-> power analysis). To check this, we do test for equality of means (t-test) for the relevant variables across treatment. The variables to be chosen are those observables that we believe could have an impact (in theory!).

Normally we check this balance pre-treatment, however here we only have post-treatment balance tests. (This can also be done by a regression - it is even more important when we want to cluster our errors -> will be explained later). 
 
When the regression coefficient on any is statistically significant (or the p-value is < 0.05 in the t-test), there is a significant difference in means between the two groups.
 
Here, this is the case for age and level of education: the individuals in the treatment group are on average 1.2 years older than those in the control group (p-value: 0.035) and they have 1.1 less years of education as well (p-value: 0.0001). We reject the null hypothesis of equality of means. 

If this is a problem depends on the variable: 

1. For age: typically not, as the difference is relatively little in absolute terms and therefore our results should still remain relevant for the adult population.

2. For education: yes, as this is big compared to the average years of education and this could impact how well-informed individuals are about their own health, what has an effect on their health, etc. 
This is not a selection bias, as this was done by accident; however as this is a relevant mechanism for the HIV status, we should control for it in the regression (for now, sufficient to control, as no selection bias).
*/

**#********************************************************************** GRAPHS

/*
We can create simple graphs that can help us see the effects of the treatment.
*/

// 3. Generate a bar graph, where the X-axis represents the control and treatment group, and the Y-axis is the percentage in each group that learn their HIV status. Let the treatment group in this question be anyone who receives a cash incentive to obtain their HIV test results. How do you interpret these results?

graph bar got, 	over(any, relabel(1 "Control" 2 "Treatment") ) ///
				ytitle("Share of those who learned about HIV status") ///
				ylabel(, format(%2.1f))
				
/* The mean effect in the control group is 35% and in the treatment group is 80% - a big difference of 45 percentage points. This big difference lets us believe that the treatment worked well (to be checked with regressions.)
*/

				
				
// 4. Now, generate the same bar graph, but this time varying the amount of cash that people receive in treatment. (Note: Use the "Ti variable for the x-axis. First convert this variable into USD. You can do this by using the USD/Kwacha exchange rate in 2005: replace Ti = Ti *0.009456). How do you interpret these results?

generate Ti_kw = Ti
replace Ti = Ti *0.009456
graph bar got, 	over(Ti) ///
				ytitle("Share of those who learned about HIV status") ///
				ylabel(, format(%2.1f))	///
				b1title("Level of financial incentive") // note that xtitle() not allowed with graph bar
				
/*
For no incentive, the effect is the same as before (35%). 

One can see that any incentives leads to a significant increase in the uptake. This increases in the amount this levels out at 200 - 300 kwachas. This shows a trade-off between budget and uptake and indicates that one should stop at 200 kwachas.
*/

				
				
**#****************************************************************** REGRESSION

// 5. Now we will use OLS to estimate the impact of any incentive on learning one's HIV status.
/// a. Run an OLS regression, where getting your HIV test result is the dependent variable, and receiving any incentive as your treatment variable.
reg got any	

/*
The outcome variable is binary: different interpretation!

We look at three things:

1) The sign of the effect: positive.
2) The size of the effect: a difference of 45 percentage points between the control and treatment group.
3) The significance of the effect: 
	i) The p-value is smaller than 0.05 = significant
	ii) The confidence interval does not include 0 = significant

Having received any monetary incentive leads to an increase of 45 percentage point in the demand for HIV tests (We can speak of increase as this is a causal interpretation). As we have no controls, this corresponds to the graph.

The constant is the probability of an individual without treatment demands an HIV test. 
*/

/// b. Now include some additional control variables (age, male, education in 2004 and marital status in 2004) in the regression. Does your estimate of impact change? If so, what type of bias does this suggest might exist?
global CONTROLS age male mar educ2004
reg got any $CONTROLS
estat vif

/*
Introducing the controls has no impact on any. 
We check the individual variables:

1) Age: The coefficient is not significant, thus it is not a problem that there is a difference in means between the treatment and control group, because it is not relevant for the outcome variable. We should keep it as a control variable nonetheless unless there is high multicollinearity

2) Education: The coefficient is significant. As there was a difference in means across treatment, it is important to control for education. If we would not control for it, we would underestimate the effect of the treatment (the coefficient on education is negative, and the treatment group is less educated than the control group).

Multicollinearity: The VIF of each variable is smaller than 4, thus, there is no 'dangerous' multicollinearity.
*/


/// c. Other than OLS, what other estimator could you have used for this regression? Use that estimator to estimate the treatment effect and report the results (Hint: If this isn't immediately apparent to you, look at your dependent variable. What type of variable is it? Other than OLS, what other estimation strategy can we use to estimate a regression with this type of dependent variable?). How do you results compare with the OLS results?

logit got any $CONTROLS
margins, dydx(any)		
probit got any $CONTROLS		
margins, dydx(any)	

/*
The dependent variable is binary, why is this a problem?

OLS is BestLinearUnbiasedEstimator (BLUE) under the following assumptions:
	1) The relationship between the variables is really linear.
	2) Homoskedasticity
	3) The expectation of the errors is equal to 0
	4) The errors are normally distributed.
	
If the explained variable is binary however, the errors are Bernoulli distributed and not normally (as they are either 0 or 1), hence OLS is not BLUE -> it can be used, however just as an approximation. (More in Econometrics)
*/
	

// 6. Now we will estimate the effect of the amount of the incentive on the likelihood of getting one's HIV results.
/// a. Run a similar regression as in Question 5a, but include the value of the incentive instead of the binary variable. In order to assess the effect of each incentive level as compared to no-incentive, you will need to transform the TI variable into dummy variables.
reg got Ti
reg got i.Ti_kw

/*
Receiving 50 kwachas instead of 0 increases the probability of getting your results by 33.5 percentage points.

Receiving 100 kwachas instead of 0 increases the probability by 43.4 percentage points.

All is significant, and there is no significant difference between receiving 200 or 300 kwachas (lie in the same CI).
*/


**#*************************************************************** HETEROGENEITY

// 6. Suppose that we want to know whether the treatment effect (any incentive) is different for men and women.
/// a. Write down a simple equation to estimate the treatment effect described above.

* got = alpha + beta any + gamma male + delta any * male + e

/// b. Run an OLS regression of the equation that you wrote.
gen any_male = any*male
reg got any any_male 
reg got any any_male male
// reg got any any_male male Ti tb  if balaka==1

/*
There is seemingly no heterogeneity across gender. If any_male was positively significant, this would be evidence of men reacting stronger to the incentive than women and vice versa.
*/

/// c. Write one well-constructed sentence explaining the impact of any incentive on learning HIV status for men. Now write the same sentence explaining the impact on learning HIV status for women. Is there a (statistically significant) difference between the two?


// 8. Do the same as above but this time assessing heterogeneity with respect to whether the individual has any education (you first need to construct this variable)
gen anyeduc2004 = educ2004>0 if educ2004<.
gen any_anyeduc2004 = any*anyeduc2004
reg got any any_anyeduc2004 anyeduc2004
reg got any##i.educ2004

/*
We find a significant negative results of the level of education on the probability of getting your results - surprising! However, from before if we don't measure it in a binary fashion, we don't find a significant effect (but point estimate is still negative). 

This could mean two things:
	1) When education is expressed in a binary fashion, it captures less information than as a continuous variable, as it does not capture the different levels of education and thus limits the explanatory power.
	2) We do not have the same control variables.
*/

