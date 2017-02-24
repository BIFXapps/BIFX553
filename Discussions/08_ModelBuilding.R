# ModelBuilding.R
# Review of building a linear model using the GBSG and homework datasets
# BIFX-553


library(gmodels)
library(car)
library(tidyverse)
library(broom)
library(splines)

# my preferred ggplot2 theme
theme_set(theme_classic() +
            theme(axis.line.x = element_line(color = 'black'),
                  axis.line.y = element_line(color = 'black'),
                  text = element_text(size = 15)))

#############
# GBSG Data #
#############

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

tmp1 <- testAssumptions(model_full)

tmp1$qqplot      # Multivariate normality
tmp1$resid_dist  # Multivariate normality

tmp1$vifs        # Multicollinearity

tmp1$spreadLevel # Homoscedasticity

# try fixing the Collinearity assumption first

### Model without meno
(model2 <- update(model_full, . ~ . - meno))
tmp2 <- testAssumptions(model2, TRUE)

# looks a little better. 
# er and pgr don't look so great in Component-Residual plot - try log transformation

### Model with log transformation of er and pgr
gbsg <- mutate(gbsg,
               ler = log(er + 0.1),
               lpgr = log(pgr + 0.1))

(model3 <- lm(lnodes ~ age + size + grade + lpgr + ler + hormon, data = gbsg)) %>%
  summary()

tmp3 <- testAssumptions(model3, TRUE)
tmp3$vifs

# better, but VIFs look a little high for lpgr and ler
# model coefficients look more reasonable for lpgr, so drop ler
# take a look at interaction between size and grade?

### Smaller model + interaction
(model4 <- lm(lnodes ~ size*grade + lpgr + hormon, data = gbsg)) %>%
  summary()

tmp4 <- testAssumptions(model4)
tmp4$vifs
tmp4$ncv

# nice idea, but the VIFs are pretty bad for size:grade - drop it

### Smaller model without interaction
(model5 <- update(model4, . ~ . - size:grade)) %>%
  summary()

tmp5 <- testAssumptions(model5)

# best model so far.
# Still looks like we are violating MVN assumption - not sure we are going to be able to fix that
# Also appears to be significant Heteroscedasticity...

### looking at model5 -- replace lpgr with ler
(model6 <- lm(lnodes ~ size + grade + ler + hormon, data = gbsg)) %>%
  summary()

tmp6 <- testAssumptions(model6)

# heteroscedasticity is quite a bit better, but still bad
# MVN didn't improve
# ler looks less significantly associated than lpgr

# We picked model5 over model6 because ler looks less significantly associated than lpgr
# Most assumptions are met, but still significant multivariate normality and homoscedasticity violations
# lnodes ~ size + grade + lpgr + hormon

#################
# Homework Data #
#################

# load data
load('../Data/06_NonLinearVariables.RData')

##### dat1 #####

dat1 <- mutate(dat1,
               x3 = x1*x2,
               x2 = as.factor(x2))

# start with a visual inspection of each data set
ggplot(dat1, aes(x1, y, color = x2)) +
  geom_point() + 
  geom_smooth(method = 'lm')

# looks like we have significant association between x1 and y
# regression lines have different slopes and intercepts, so an interaction between x1 and x2 is probably in order

(model1.1 <- lm(y ~ x1*x2, data = dat1)) %>%
  summary()

tmp1.1 <- testAssumptions(model1.1)

# everything checks out just great.

# use x3 dummy variable to check out interaction in CR Plots
model1.2 <- lm(y ~ x1 + x2 + x3, data = dat1)

tmp1.2 <- testAssumptions(model1.2, TRUE)

# some funny wiggle along x1 in the CR plot, but nothing so bad that it would worry me too much
# other assumptions are fine
# final model: y ~ x1*x2


##### dat 2 #####

# start with visual inspection
ggplot(dat2, aes(x1, y)) +
  geom_point() +
  geom_smooth(method = 'lm') +
  scale_y_log10()

# definitely looks like a log-linear model
# beautiful association between x1 and log(y)

dat2 <- mutate(dat2,
               ly = log(y))

(model2.0 <- lm(ly ~ x1, data = dat2)) %>%
  summary()

tmp2.0 <- testAssumptions(model2.0, TRUE)

# all assumptions check out
# final model: log(y) ~ x1


##### dat 3 #####

# visual inspection
g <- ggplot(dat3, aes(x1, y)) + 
     geom_point()

g + geom_smooth(method = 'lm')
g + geom_smooth() # switched to loess, as lm seemed wrong

# looks like a spline would be best here -- there appears to be a knot near x == 0

# add a knot at x1 == 0
dat3 <- mutate(dat3,
               gt0 = x1 > 0)

# two ways we can model these data:
# manual creation of spline
(model3.0 <- lm(y ~ x1 + x1:gt0, data = dat3)) %>%
  summary()
# 1st degree spline using bs()
(model3.1 <- lm(y ~ bs(x1, knots = 0, degree = 1), data = dat3)) %>%
  summary()

# visualizing our linear model using two different formulas:
g + geom_smooth(method = 'lm', formula = y ~ x + x*(x>0))

g + geom_smooth(method = 'lm', formula = y ~ bs(x, knots=0, degree=1))

# don't forget to test assumptions, but the plots look beautiful
tmp3.0 <- testAssumptions(model3.0)

# multicollinearity violation between x1 and x1:gt0 -- not surprising, since x1:gt0 == x1 when x1 > 0
# I think we are safe ignoring this

# tried running model3.1 through our assumptions test out of curiosity
# something wrong with our function, specifically with the outlier part
# tmp3.1 <- testAssumptions(model3.1)
# traceback()

# final choice: 
# If we want to make inferences about slopes before and after knot: y ~ x + x:gt0
# If we are more interested in prediction, this one is easier to code: y ~ bs(x, knots=0, degree=1)
# these are really the same model and end up generating the exact same predictions, but interpretation of the coefficients is harder for the second option
