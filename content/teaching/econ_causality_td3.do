********************************************************************************
** Description: Econometrics of Causality TD3 - Schools in Tanzania
** Author log 
** 2025-02-02 NK - Initial version
** QC log
** [not QC'ed yet, enter notes on QC here]
********************************************************************************
timer clear
timer on 1

**#******************************************************************** COMMENTS


**#************************************************************************ HEAD

global ROOT "C:\Users\nknecht\Dropbox\Teaching\2025\Econometrics of Causality\TD 3 - DID"


**#***************************************************************** INFORMATION

/*
The data we are using come a household survey in the region of Kangera, in Tanzania. We would like to assess the effect of new secondary school construction in Tanzania in the 1980's, on educational outcomes. At this time, secondary schools were constructed in some villages of the region of Kangera while in other villages, no schools were constructed. We want to know if individuals who lived in areas with new secondary schools completed more schooling than those living in areas without.
Preliminaries
We will be looking at individuals who live in villages, so in some sense, there are two units of analysis. Individual level variables refer to individual characteristics, such as gender, age, education. Village level variables refer to characteristics of the village, such as access to clean water and electricity.

Villages where a new secondary school was built will be known as "treatment" villages. Villages where no secondary school as built will be known as "control" villages.

We will also look at two cohort groups. Young cohorts (aged 6-16 in 1985) and old cohorts (aged 21-41) in both treatment and control villages. The idea is that new secondary schools should only affect young people who are still in school. If one has completed one's studies, a new secondary school in one's village will not change how much education one gets. The idea is that the "treatment" or new secondary schools should only affect the young cohort living in treatment villages. This generates the difference-in-difference design.

Key Variables:
treat = 1 if a new secondary school is built in your village
cluster: the village identifier
ycohort = 1 if person is aged 6 to 16 in 1985
primary = 1 if person completed primary school
electric = 1 if electricity in village 
pipwater = 1 if piped water in village  
distcapital = distance of village from capital
ocohort = 1 if person is aged 21-41 in 1985
Age = age of the individual
Male=1 if individual is a man, 0 if a woman
Mother_Edu=years of completed schooling by individual's mother
Father_Edu= years of completed schooling by individual's father

*/


**#******************************************************************* LOAD DATA
use "$ROOT\td3.dta", clear


**#*************************************************************** SUMMARY STATS

/*
Let's first look at summary statistics for the full sample. This will give you an idea of the characteristics of our population of interest. Then we will examine whether there are differences between treatment and control villages.
*/	

// 1. Present individual summary statistics for the study sample. What is the average age? What percentage of males are in the study? What is the average education?

sum age male Mother_Edu Father_Edu primary

/*
The average age is 35 years (between 18 and 78), there are 46% men in the sample and 70% of the sample have completed primary education. 20% of the individuals in the sample are treated.
*/

// 2. Now present these same statistics for treatment villages vs. control villages. Are there any differences? 

bys treat: sum age male Mother_Edu Father_Edu primary

/*
There are no big differences but for the proportion of individuals finishing primary education (78% to 68%), and this difference is significant. This is not necessarily a causal effect of the construction on getting a primary education:
	1) This could be indicative of the villages in the control having less access to primary education in general.
	2) The social norms may be more (less) favourable to education in the treatment (control) villages.

So, if we were to find a significant effect of construction on primary education attainment, this could also be due to these factors.
*/

// 3. Assess whether differences in age, education, gender and other characteristics that you believe could be important in determining educational outcomes. Make sure you account for the fact that data is clustered at village level – you may think about using a regression instead of a ttest.

foreach var of varlist age male Mother_Edu Father_Edu primary {
	reg `var' treat, cluster(cluster) // can't cluster with ttest!
}

/*
Clustering is crucial in certain research designs, when some of the outcome variation comes from characteristics of the clustering variable (here, the villages). If we don't cluster, the computed standard errors will be too small.

The only relevant difference is in primary education attainment, where in the treatment group it is 10 percentage points (10/67 = 15%).
*/


// 4. Present community summary statistics for treatment villages vs. control villages. Are there any differences? Look at access to electricity, piped water, and distance from the capital. Note that you should only use one observation by cluster to do this – you can do this by running the following: bysort cluster: gen i=_n And then run your estimates adding "if i==1" at the end

bysort cluster: gen i=_n
sum electric pipwater distcapital if i==1
bys treat: sum electric pipwater distcapital if i==1

/*
We can see that the villages closer to the capital are better equipped when it comes to access to electricity.
*/

// 5. Assess whether these differences are significant using ttest or regression. Do you find significant differences?  
foreach var of varlist electric pipwater distcapital  {
	ttest `var' if i==1, by(treat)
	reg `var' treat if i==1
}
	
/*
The differences are not statistically significant, but that is not surprising given the size of the sample. 
*/
	
// 6. Based on your answer to either question 4 or 5, do you think that treatment villages are different from control villages? Why do you think secondary schools were built in treatment villages?

/*
The results so far give the impression of limited selection bias. However, we can note that the schools were built in already more favourable locations: closer to the capital (maybe better employment opportunities later on), better access to electricity... A simple comparison could thus lead to an upward bias in our estimate.
*/

**#********************************************************** SIMPLE DIFFERENCES
// 1. Now we can simply compare young cohorts in treatment vs. control villages. Run the following regression only for the young cohort group. 
/*
Primary=α+β(treat)+ε

What is your estimate of β? Is it statistically significant (at the 5% level)? Run the same regression, this time clustering the standard errors at the level of the village. What differences do you observe in the results? 
*/

reg primary treat if ycohort==1
reg primary treat if ycohort==1, cluster(cluster)

/*
We see a statistically significant difference between those in the treatment group and those in the control group in their rate of receiving primary education in the moment where they were of primary school age when the schools were being built. There is no big difference between clustered standard errors and no clustered standard errors.
*/


// 2. Based on this result from question 7, can we say that constructing new secondary schools has a direct impact on primary school completion? Or can we attribute this to other factors.

/*
The individuals are different. We cannot attribute the differences to the construction of the school as we have seen that there are inherent differences across the villages. There may thus be a (even if small) selection bias - omitted variable bias (as the treatment is probably correlated to non-included variables). 
*/


// 3. Do the regression from Q1 but add additional controls. Does your estimate of β change?

reg primary treat electric pipwater distcapital age male Mother_Edu Father_Edu if ycohort==1, cluster(cluster)

/*
The coefficient on treat is a bit smaller, but remains significant. There could thus be other characteristics and unobservables of the villages or individuals that we have not taken care of in the model (and which would thus bias the estimated effect).
*/

// 4. Do the regression from Q1 but this time limit it only to the older cohort group. What is your estimate of β ? Is it statistically significant (at the 5% level)? How does it compare to your answer in Q1?

reg primary treat if ocohort==1, cluster(cluster)
reg primary treat electric pipwater distcapital age male Mother_Edu Father_Edu if ocohort==1, cluster(cluster)

/*
There is no difference between the control and treatment group individuals, as the individuals were too old to benefit from the elementary schools being built. 
*/

**#**************************************************************** DIFF-in-DIFF
// 1. Generate an interaction variable named treat_ycohort = 1 if the individual is in treatment village and in the young cohort, and =0 otherwise
gen  treat_ycohort=treat*ycohort

// 2. We will now estimate the treatment effect using a standard diff-in-diff regression.
/*
Primary=α+β_1 (treat)+β_2 (Young Cohort)+β_3 (Treat ×Young Cohort)+ε

What is your estimate of β_3 ? Is it statistically significant (at the 5% level)? 
What happens if you add some control variables? Are you r results sensitive to the introduction of these variables? 
*/
reg primary treat ycohort treat_ycohort, cluster(cluster)
reg primary treat ycohort treat_ycohort electric pipwater distcapital age male Mother_Edu Father_Edu, cluster(cluster)
		
/*
Each coefficient corresponds to a particiular subgroup:
	1) The coefficient of the constant corresponds to the individuals in the old cohort who were not treated, and the average primary education level is 37.6%
	2) The coefficient on treat corresponds to the difference between the individuals who have finished primary education between the treatment and control group (supposed identical for old and young cohort due to parallel trend hypothesis), which is equal to 0 (as not statistically significant).
	3) The coefficient on ycohort corresponds to the difference between old and yound cohort in general, here 41.8 percentage points.
	4) The coefficient on treat_ycohort corresponds to the impact of the treatment on the 'susceptible' individuals. Here, 0, as the coefficient is not significant.
	
Outcome level of old cohort in control villages = β0
Outcome level of old cohort in treated villages = β0 + β1
Outcome level of young cohort in control villages = β0 + β2
Outcome level of young cohort in treated villages = β0 + β1 + β2 + β3

We note that diff-in-diff estimation no longer yields significant results, confirming that, when selection bias is neutralised by the double-difference, the program had no significant effect on children's school participation. These results are confirmed when control variables are added.
*/

		
// 3. Based on your analysis from Parts I, II, III, do you think building new secondary schools is effective at increasing primary school completion rates? What are some potential problems with the above analysis?

/*
We did not find that school construction had a significant impact on children's participation in elementary school. It was particularly important to use the double-difference method rather than a simple regression, as the results of the simple difference (inverse result) were misleading because they were biased. The double-difference results are based on the assumption that selection bias is constant over time. In other words, that the evolution over time of the share of individuals having completed primary school is the same in the treated and control villages. But this is not certain. This hypothesis (parallel trend hypothesis) should be tested, for example by comparing the evolution of enrolment rates between treatment and control villages for ocohort and for an even older cohort.

NB: in this TD, the parallel trend hypothesis could not be tested, as we have no data enabling us to do so. However, it should be borne in mind that compliance with this hypothesis is essential if the double-difference results are not to be biased.
*/

		