# Discussion1.R
# R code from January 19, 2017
# BIFX 553

library(tidyverse)

#### Pretest #####

# Question 2
s <- 0
for(i in 1:100)
  s <- s + i


# Question 3
sum(1:100)


# Question 8
thresh <- 0.05 / 20


##### Vector Calculations #####

# these are vectors
x <- 1:10
y <- rnorm(10)

# adding vectors
x + y

# a data frame
dat <- data.frame(x = rnorm(100),
                  y = rnorm(100))

# lets add a new variable to our data.frame
dat$sex <- sample(c('M', 'F'), 
                  size = 190, 
                  replace = TRUE)



# this is a matrix
mat <- cbind(x, y)

# The apply family "applys" a function to vectors or lists of data
# compute column sum of mat
apply(mat, 2, sum)

# compute row sum of mat
apply(mat, 1, sum)

# this is a list
lst <- list(x = rnorm(100),
            y = rnorm(100, 5),
            z = rnorm(100, 5, 10))

# apply the mean function to each element in our list
sapply(lst, mean) # sapply returns a vector if possible

lapply(lst, mean) # lapply returns a list


# ifelse
ifelse(dat$y > 0, 1, -1)


##### Control Structures #####

# if else (note the space)
test <- TRUE
if(test)
{
  print("This is executed when test is true.")
}else{
  print("This is executed when test is false.")
}


# for loop
for(i in 1:3)
{
  hist(lst[[i]])
}


##### Functions #####

fx <- function(x)
{
  # do something here and return a value
  return(5 + 2*x - 4*x^2 + x^3/5)
}

plot(lst[[3]], fx(lst[[3]]))


#############
# Tidyverse #
#############

##### tibble #####

tdf <- tibble(x = 1:1e4, 
              y = rnorm(1e4))   # == data_frame(x = 1:1e4, y = rnorm(1e4))
class(tdf)

# the print nicely
tdf

# strings_as_factors
dfs <- list(df = data.frame(abc = letters[1:3], xyz = letters[24:26]),
            tbl = data_frame(abc = letters[1:3], xyz = letters[24:26]))
sapply(dfs, function(d) class(d$abc))

# partial matching of names works for data.frames, not tibbles
sapply(dfs, function(d) d$a)

# type consistency when subsetting
sapply(dfs, function(d) class(d[, "abc"]))

# can store lists in columns
tibble(ints = 1:5,
       powers = lapply(1:5, function(x) x^(1:x)))

# use pipes to make your code more readable!
sum(1:8) %>%
  sqrt()

# less readable
sqrt(sum(1:8))

##### dplyr #####

library(ggplot2movies)
str(movies)

# 4 main actions: filter, select, group_by + summarize, arrange
filter(movies, length > 360) %>%
  select(title, rating, votes)

filter(movies, Animation == 1, votes > 1000) %>%
  select(title, rating) %>%
  arrange(desc(rating))

filter(movies, mpaa != "") %>%
  group_by(year, mpaa) %>%
  summarize(avg_budget = mean(budget, na.rm = TRUE),
            avg_rating = mean(rating, na.rm = TRUE)) %>%
  arrange(desc(year), mpaa)

# other convenience functions (e.g. count vs table)
filter(movies, mpaa != "") %>%
  count(year, mpaa, Animation, sort = TRUE)

basetab <- with(movies[movies$mpaa != "", ], table(year, mpaa, Animation))
basetab[1:5, , ]

# table joins for those who are familar with SQL
t1 <- data_frame(alpha = letters[1:6],
                 num = 1:6)
t2 <- data_frame(alpha = letters[4:10],
                 num = 4:10)
full_join(t1, t2, by = "alpha", suffix = c("_t1", "_t2"))


##### tidyr #####

# for expanding and collapsing tibbles
who  %>%  # Tuberculosis data from the WHO
  gather(group, cases, -country, -iso2, -iso3, -year)


##### readr #####

# make a big tibble
bigdf <- data_frame(int = 1:1e6, 
                    squares = int^2, 
                    letters = sample(letters, 1e6, replace = TRUE))

# readr is faster than base R
system.time(
  write.csv(bigdf, "base-write.csv")
)

system.time(
  write_csv(bigdf, "readr-write.csv")
)

system.time(
  bigdf <- read.csv("base-write.csv")
)
str(bigdf)

system.time(
  bigdf <- read_csv("readr-write.csv")
)
bigdf

# clean up your directory (system specific - specifically, Linux/UNIX)
system('rm base-write.csv')
system('rm readr-write.csv')


##### purrr #####

# see how long equivalent lapply and map take to run
df <- data_frame(fun = rep(c(lapply, map), 2),
                 n = rep(c(1e5, 1e7), each = 2),
                 comp_time = map2(fun, n, ~system.time(.x(1:.y, sqrt))))
df$comp_time

# map
map(1:4, log)

map(1:4, log, base = 2)

map(1:4, ~ log(4, base = .x))  # == map(1:4, function(x) log(4, base = x))

map_dbl(1:4, log, base = 2)

map_int(1:4, log, base = 2) # error, this is not an integer!

# map2
fwd <- 1:10
bck <- 10:1
map2_dbl(fwd, bck, `^`)

# map_if
data_frame(ints = 1:5, 
           lets = letters[1:5], 
           sqrts = ints^.5) %>%
  map_if(is.numeric, ~ .x^2) 

# a few examples
movies %>% 
  filter(mpaa != "") %>%
  split(.$mpaa) %>% # str()
  map(~ lm(rating ~ budget, data = .)) %>%
  map_df(tidy, .id = "mpaa-rating") %>%
  arrange(term)

d <- data_frame(dist = c("normal", "poisson", "chi-square"),
                funs = list(rnorm, rpois, rchisq),
                samples = map(funs, ~.(100, 5)),
                mean = map_dbl(samples, mean),
                var = map_dbl(samples, var)
)
d$median <- map_dbl(d$samples, median)
d

train <- sample(nrow(diamonds), floor(nrow(diamonds) * .67))
setdiff(names(diamonds), "price") %>%
  combn(2, paste, collapse = " + ") %>%
  structure(., names = .) %>%
  map(~ formula(paste("price ~ ", .x))) %>%
  map(lm, data = diamonds[train, ]) %>%
  map_df(augment, newdata = diamonds[-train, ], .id = "predictors") %>%
  group_by(predictors) %>%
  summarize(rmse = sqrt(mean((price - .fitted)^2))) %>%
  arrange(rmse)


##### stringr #####

library(stringr)  # not attached with tidyverse
fishes <- c("one fish", "two fish", "red fish", "blue fish")
str_detect(fishes, "two")

str_replace_all(fishes, "fish", "banana")

str_extract(fishes, "[a-z]\\s")

# putting it to work
who2 <- who %>%
  select(-iso2, -iso3) %>%
  gather(group, cases, -country, -year) %>%
  mutate(group = str_replace(group, "new_*", ""),
         method = str_extract(group, "[a-z]+"),
         gender = str_sub(str_extract(group, "_[a-z]"), 2, 2),
         age = str_extract(group, "[0-9]+"),
         age = ifelse(str_length(age) > 2,
                      str_c(str_sub(age, 1, -3), str_sub(age, -2, -1), sep = "-"),
                      str_c(age, "+"))) %>%
  group_by(year, gender, age, method) %>%
  summarize(total_cases = sum(cases, na.rm = TRUE))

who2


##### ggplot2 #####

# first stab at ggplot
ggplot(who2, aes(x = year, y = total_cases, linetype = gender)) +
  geom_line() +
  facet_grid(method ~ age,
             labeller = labeller(.rows = label_both, .cols = label_both)) +
  theme_light() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) +
  scale_y_log10()

# combining what we learned above
who %>%
  select(-iso2, -iso3) %>%
  gather(group, cases, -country, -year) %>%
  count(country, year, wt = cases) %>%
  # with ggplot  
  ggplot(aes(x = year, y = n, group = country)) +
  geom_line(size = .2) 

# lets drop the countries with incident cases over 250K
who %>%
  select(-iso2, -iso3) %>%
  gather(group, cases, -country, -year) %>%
  count(country, year, wt = cases) %>%
  group_by(country) %>%
  mutate(maxCases = max(n)) %>%
  filter(maxCases < 100000) %>%
  # with ggplot  
  ggplot(aes(x = year, y = n, group = country)) +
  geom_line(size = .2)

