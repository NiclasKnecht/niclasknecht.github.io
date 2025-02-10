********************************************************************************
** Description: Econometrics of Causality TD2 - Fertilizers
** Author log 
** 2025-02-01 NK - Initial version
** QC log
** [not QC'ed yet, enter notes on QC here]
********************************************************************************
timer clear
timer on 1

**#******************************************************************** COMMENTS


**#************************************************************************ HEAD

global ROOT "C:\Users\nknecht\Dropbox\Teaching\2025\Econometrics of Causality\TD 2 - RCT"


**#***************************************************************** INFORMATION

/*
For this exercise, we will be replicating and exploring some of the results of Carter, Laajaj and Yang's (CLY) "The Impact of Voucher Coupons on the Uptake of Fertilizer and Improved Seeds: Evidence From a Randomized Trial in Mozambique" (American Journal of Agricultural Economics 2013)  using a subset of the total data used from the published study. The full project targeted 15,000 maize farmers during the 2009-10 and 2010-11 crop years. 

The dataset is called "HH_Mozambique.dta" and the observational unit is the household with UNQ_ID serving as the unique identifier.  The administrative units are village being the smallest and district being the largest.  Also, unless specified, quantity measurements are in kilograms (KG), area is measured in hectares, and prices are in Mozambican Metical (MZN).   

Furthermore, we have adopted the following conventions in labeling variables to help ease in the use of this dataset:
•	*prev : "Previous" value (2009)
•	*cur : "Current" value (2011)
•	*99* :  Variable has been Winsorized at the 99% level 
(note that for each variable with *99* there is also a variable in the set that has not been Winsorized which will have the same name without *99*.)  
Finally, as part of the instructions we use bold to indicate (parts of) Stata commands and italics for variable names.  

As a bit of background on the study design, all farmers were entered into a "lottery" from which 50% were selected as "winners" who won the right to collect a voucher good for a package designed for ½ hectare of improved maize cultivation.  Specifically, the voucher was good for covering 73% (85 USD) of the total costs of a package containing 100kg of fertilizer and 12.5kg of improved maize seeds (117 USD) with winning farmers required to provide the remaining 27% (32 USD) as a cost share.  A winning farmer had to go to a nearby office to receive his/her voucher and then take that voucher to a local depot to redeem it in combination with the farmer's 32 USD contribution. 

*/


**#***************************************************************** LOAD DATA
use "$ROOT\td2.dta", clear

// 2. Explore the data and familiarize yourself with its various elements.

desc 

sum 

/*
We can see that 48% won the voucher while only 28% (so 52% of those who won the lottery) received the voucher. This means that treatment compliance is not perfect, as only a subsample of the treated farmers received the treatment. On top, 11% of those who lost the lottery still ended up with one - maybe distributed among family & friends?
Planted area : average of 3.28 Ha but large variation (min = 0.12 ; max = 41)
*/

hist plantedArea, percent

tab wonvoucherlot 
*proportion of treated and non-treated
tab vouchereceived
*proportion of individuals that actually received a voucher
tab voucheredeemeddummy
*proportion of individuals that used the voucher


/*
Description of hh and farm characteristics with a distinction between treated and non-treated
*/

global HH_CHAR male educ age hhhlit hhsize
global FARM_CHAR plantedArea improvedseeds99prev fertmaiz99prev

bysort wonvoucherlot: sum $HH_CHAR $FARM_CHAR

foreach var in $HH_CHAR $FARM_CHAR{ 
	ttest `var', by(wonvoucherlot)
	reg `var' wonvoucherlot, robust // clustering of errors is crucial in some designs, where some of the variability in outcome is due to underlying factors of the villages, e.g., the weather or geography (-> below we do areg to capture these differences) - for the standard errors to not represent these differences, we use robust 
}

/*
Check if there are significant differences in the hh characteristics between treated and non-treated
-> No = Randomisation well done, however here the adopters have a ssmaller surface and are more educated -> need to include as control variable

In regression: constant is the mean of the control group, and constant + coefficient is the mean of the treatment group.

If we do not use robust standard errors, the CI decreases, however we would draw wrong conclusions from this.
*/


// 3. Intention To Treat Estimates – let's begin by separately estimating the effect of winning the lottery on the use of fertilizer and improved seeds using regress.

/*
Do we need all participants to participate or we want to see the effect on those who choose to participate?

What we can say about the potential treatment effects? We can underestimate the true effect of the interventions.
The estimates using "receiving the voucher" will be necessarily larger than the effects "being treated" since using 
the voucher is only imperfectly correlated with being treated. Some contaminaton effects: lost voucher lottery but received it
*/

sum vouchereceived wonvoucherlot

tab  wonvoucherlot vouchereceived

/// a. Regress current fertilizer use on winning the voucher lottery, previous fertilizer use and previous improved seed use with village fixed effects and robust standard errors using the Winsorized data.

areg fertmaiz99cur wonvoucherlot, robust ab(village_ID) // ab() = fixed effects and more efficient from a calculation pov than using individual dummies or xtreg etc.
areg fertmaiz99cur wonvoucherlot $HH_CHAR $FARM_CHAR, robust ab(village_ID)
eststo ITT
/*
The treated individuals (treated: won the lottery) use on average close to 17kg more of fertilizer than the control group ceteris paribus.

Can again check for multicollinearity with estat vif.
*/


// 4. First Stage – The estimates in 3 raise interesting questions as to how winning the lottery is effecting farmers' use of fertilizer and seeds.  As explained in the introduction, after winning the lottery, there are still a couple of intermediate steps a farmer must complete before 
/// a. Estimate the effect of winning the lottery on redeeming a voucher with robust standard errors.  

areg fertmaiz99cur vouchereceived, robust ab(village_ID)
areg fertmaiz99cur vouchereceived $HH_CHAR $FARM_CHAR, robust ab(village_ID)

/* 
Positive effects of being treated on fertilizer use; The effect becomes larger when considering whether the farmers received and used the voucher
*/

// 5. Treatment on the Treated (Local Average Treatment Effect)– We are primarily interested in estimating the effect of redeeming the voucher on those who were experimentally induced to do so.  For this reason, we need to instrument for redeeming the voucher with winning the lottery using ivregress.
/// a. Separately estimate the effect of the instrumented voucher redemption dummy on fertilizer usage using the winsorized data.  As in question 1, control for previous fertilizer use and previous improved seed use, include village fixed effects and estimate robust standard errors.
 
areg fertmaiz99cur voucheredeemeddummy, robust ab(village_ID) // for the ATE
eststo ATE

ivreg2 fertmaiz99cur i.village_ID (voucheredeemeddummy = wonvoucherlot), robust first // here can't use areg so need to add all the villages as dummies - for the LATE
eststo LATE

/* 
(It usually suffices to calculate ITT/(proportion affected by lottery)= 16,5/0,28=58,9 kg, this is not the same here as we didn't do the exact same regressions and us using different (winsorized) variables.)

Using the assignment (won voucher) as an IV for voucher redemption, we get a significantly higher effect, too. With the IV we don't consider the always takers, i.e., the participants who did not win the voucher but still managed to get their hands on one. 

The LATE is 56.16kg - using the voucher increases the amount of fertilizer significantly compared to the ITT effect. This is due to 48% of the voucher winners not using their voucher. However also, some individuals who did not win the voucher used them, this could have biased our ITT downwar.
*/

/// b. Analysis
//// i. How do your results differ from what you found in question 3?  Interpret both results.

esttab, keep(wonvoucherlot voucheredeemeddummy) mtitles

/*
ITT: 16.6 kg
LATE (TOT): 56.2 kg
ATE: 59.2 kg 
*/

//// ii. Can you infer from this what would be the average treatment effect of voucher in the whole population?  Give arguments that could suggest that the LATE is higher or lower than the average treatment effect.  

/*
The effect of voucher redemption in the LATE regression (iv) is 56.2 kg, whereas in the ATE (OLS) the effect is bigger: 59.2 kg. This implies that there is a positive and significant effect of winning and even more receiving the lottery on redeemed vouchers. The reason for the LATE effect being smaller in size is likely due to the different populations treated (see above who complies and who always takes): Always-takers may be more motivated and thus use more fertilizer. There could have also been other spill-over effects of voucher redemption across the whole population.

If the effect for the always-takers would have been been smaller than for the compliers, the LATE could have been higher.
*/



