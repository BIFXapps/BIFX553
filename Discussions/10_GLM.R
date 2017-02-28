# 09_GLM.R
# GLM examples


library(tidyverse)

source('../Scripts/testAssumptions.R')


##### Log-Linear Regression #####

load("../Data/gbsg.RData")

## with family = poisson
(model0 <- glm(nodes ~ size + grade + lpgr + hormon, data = gbsg,
               family = poisson)) %>%
  summary()

asm0 <- testAssumptions(model0)
asm0$outlier_leverage

## with family = quasipoisson
(model1 <- glm(nodes ~ size + grade + lpgr + hormon, data = gbsg,
               family = quasipoisson)) %>%
  summary()

asm1 <- testAssumptions(model1)
asm1$outlier_leverage

ci(model1)


##### Logistic Regression #####

n <- 500
set.seed(234987)
dat <- data_frame(x1 = rnorm(n),
                  x2 = rnorm(n),
                  x3 = rbinom(n, 1, .5),
                  lod = 2*x1 - x2 + 5*x3 + .5*x1*x3,
                  py = exp(lod) / (1 + exp(lod)),
                  y = rbinom(n, 1, py))

(model2 <- glm(y ~ x1 + x2 + x3 + x1:x3, data = dat,
               family = binomial)) %>%
  summary()

asm2 <- testAssumptions(model2)


##### Log-binomial Regression #####

(model3 <- logbin(y ~ x1 + x2 + x3, data = dat)) %>%
  summary()

(model4 <- logbin(y ~ x2, data = dat)) %>%
  summary()

##### Project 1 - Group 4 #####

load('../project1/dat4.RData')

dat4
