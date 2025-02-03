---
title: "Tutorial Econometrics of Causality (SS25)" 
date: 2025-01-10
location: ["Universite de Bordeaux"]
url: /teaching/econ_causality_2025
aliases:
    - /old_url.html
tags: ["causality","econometrics"]
author: ["Tanguy Bernard", "Niclas Knecht"]
description: "Econometrics of Causality" 
summary: "This course will present the basics of the “treatment effect” literature which focuses on issues of causal relationships. In tutorials, students will learn how to implement policy evaluations using data from recent economic policies."
cover:
    image: "/course_figure.png"
    alt: "Causality"
    relative: false
disableAnchoredHeadings: false
showToc: false

---

## Content

Using simple OLS specifications, the course will first cover issues of endogeneity arising from selection bias or reverse causality. The course will then cover the basics of various evaluation designs addressing endogeneity issues, namely randomized control trials, difference-in-difference, and regression discontinuity approaches. Lecture classes will cover the main concepts developed in this literature, and will present a set key research papers that rely on these approaches. During tutorial classes, students will be provided with data-based exercise, reproducing results from recent evaluations of public policies. Topic of tutorial class will include issues of development economics, international economics and finance (according to students’ main Master specialisation).

### Cheat Sheet

1) What is the outcome variable? What is the treatment variable?
2) Why would a simple OLS not work? (residual not truly independent from treatment: cov(T, e) != 0; explain why! - in what direction does the bias go?)
3) What could a possible solution be (in this course: RDD, RCT, Diff-in-Diff)? Write the equation for it. Which one is the variable of interest and what does it measure?
4) What assumption(s) does this solution rely on? (continuity, randomisation, ...)
5) Are there ethical concerns (RCT: maybe, others, no) and why (RCT: you exclude some people; others: rely on already existing data)? If yes, need to go to ethical committee
6) What is the external validity? (Usually small: limited to one city / village ..., if run at national level could have external validity; talk about heterogeneous treatment effect: then know, which population type exactly is impacted)


---
## Tutorial 1

RCT.

##### Problem Set

- [Problem Set 1](/teaching/econ_causality_2025_td1.do)




## Tutorial 2

RCT.

##### Problem Set

- [Problem Set 2](/teaching/econ_causality_2024_ps2.pdf)


##### Data

- [Data Problem Set 2](/teaching/econ_causality_2024_td2_data.zip)


## Tutorial 3

Difference-in-Difference.

##### Problem Set

- [Problem Set 3](/teaching/econ_causality_2024_ps3.pdf)


##### Data

- [Data Problem Set 3](/teaching/econ_causality_2024_td3_data.dta)


## Tutorial 4

Regression Discontinuity Design.

##### Problem Set

- [Problem Set 4](/teaching/econ_causality_2024_ps4.pdf)


##### Data

- [Data Problem Set 4](/teaching/econ_causality_2024_td4_data.dta)
