# ModelBuilding.R
# Review of building a linear model using the GBSG dataset
# BIFX-553


library(gmodels)
library(car)
library(tidyverse)
library(broom)

# my preferred ggplot2 theme
theme_set(theme_classic() +
            theme(axis.line.x = element_line(color = 'black'),
                  axis.line.y = element_line(color = 'black'),
                  text = element_text(size = 15)))

# load data
load("../Data/gbsg.RData")

# data transformations
gbsg <- mutate(gbsg,
               lnodes = log(nodes))

# function to test model assumptions
source('../Scripts/testAssumptions.R')


##### full model #####
(model_full <- lm(lnodes ~ age + meno + size + grade + pgr + er + hormon, data = gbsg)) %>%
  summary()

tmp <- testAssumptions(model_full)

tmp$qqplot      # Multivariate normality
tmp$resid_dist  # Multivariate normality

tmp$vifs        # Multicollinearity

tmp$spreadLevel # Homoscedasticity
