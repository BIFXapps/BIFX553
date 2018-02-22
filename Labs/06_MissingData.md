Practice with Fish
------------------

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
    require(dplyr)
    # I'm purposely leaving out set.seed to see what different outcomes we get during class
    fish <- read_delim('https://raw.githubusercontent.com/rmcelreath/rethinking/master/data/Fish.csv', delim = ';') %>%
            mutate(hours = ifelse(rbinom(length(hours), 1, 0.1), NA, hours), # missing completely at random
                   child = ifelse(rbinom(length(child), 1, ifelse(persons > 1, .13, 0)), NA, child)) # not MCAR -- possibly informative
