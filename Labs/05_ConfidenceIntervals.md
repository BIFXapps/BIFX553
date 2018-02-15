Introduction
------------

In this lab we will practice what we've learned so far about linear
regression and generate some confidence intervals from our model. Divide
into groups of 2 or 3 and develop a model together. At the end of class
we will share the results of our efforts:

-   What was your final model?
-   Why did you pick this for your final model?
-   What models did you try that didn't work out?

When you are comparing two models, you may find the `AIC()` and
`anova()` functions useful. `AIC()` provides a measure of how well your
model fits the data, but this measure is only relative to another model
that was fit using the same data. More variables will tend to fit the
data better, but could lead to overfitting.

The `anova()` function will give you an idea of whether a larger model
results in statistically significantly better model. Comparisons using
`anova()` are best when one model is a subset of the other model.

Save two Rmd files for sharing with the class:

-   one with your exploratory analysis, and
-   one with your final solution and discussion of the results.

Problem
-------

Develop a model to predict the expected height of Loblolly pine trees
using the `Loblolly` data set. I've also grouped the different seed
sources into three "varieties" and given them names based on artificial
gene variants of some immaginary gene and created a few other variables.
You may use these variables or not depending on what you decide is the
best model.

    data("Loblolly")

    require(dplyr)
    Loblolly <- mutate(Loblolly,
                       seed = log(as.numeric(Seed)),
                       short = seed < 1.5,
                       tall = seed > 2.3,
                       variety = {ifelse(short, 'A799',
                                  ifelse(tall, 'G103', 'Wt')) %>%
                                  factor(levels = c('Wt', 'A799', 'G103'))})

Bonus Challenge Problem
-----------------------

Analyze the fish data set and develop a model to predict the number of
fish caught by a group. Include two files:

-   one with your exploratory analysis that includes all of the gory
    details of all the models you explored, and
-   one with your final solution and discussion of the results.

The fish data set has the following variables:

-   fish\_caught: total number of fish caught by the group
-   livebait: binary flag indicating that the group used live bait
-   camper: binary flag indicating that the group was camping at the
    lake
-   persons: the number of people in the group
-   child: the number of children in the group
-   hours: the numer of hours the group spent fishing

<!-- -->

    require(readr)
    fish <- read_delim('https://raw.githubusercontent.com/rmcelreath/rethinking/master/data/Fish.csv', delim = ';')
