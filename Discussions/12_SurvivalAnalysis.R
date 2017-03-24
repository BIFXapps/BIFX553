# 12_SurvivalAnalysis.R
# In class practice for survival analysis
# BIFX 553
# Hood College

library(survival)
library(tidyverse)

# add events line by line
cgd0 <- tmerge(cgd0[,1:13], cgd0, id = id, tstop = futime,
               infect = event(etime1),
               infect = event(etime2),
               infect = event(etime3),
               infect = event(etime4),
               infect = event(etime5),
               infect = event(etime6),
               infect = event(etime7))

cgd0 <- mutate(cgd0,
               sex = as.factor(sex),
               inherit = as.factor(inherit),
               steroids = as.factor(steroids),
               propylac = as.factor(propylac),
               hos.cat = as.factor(hos.cat))

cgd0$surv <- Surv(cgd0$tstart, cgd0$tstop, cgd0$infect)

cgd0$bmi <- with(cgd0, weight / (height/100)^2)

# full model
model0 <- coxph(surv ~ treat + hos.cat + sex + age +
                    height + weight + inherit + steroids +
                    propylac, data = cgd0)

assmp0 <- testAssumptions(model0)

# replace height and weight with bmi
model1 <- update(model0, . ~ . - height - weight + bmi)

assmp1 <- testAssumptions(model1)

# remove bmi, hos.cat
model2 <- update(model1, . ~ . - hos.cat - bmi)

assmp2 <- testAssumptions(model2)

# review Project 1 data
load('../project1/dat1.RData')
