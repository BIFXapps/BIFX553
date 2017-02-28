# clt.R
# function for exploring the Central Limit Theorem
# Randy Johnson

# distn = any function returning random numbers
#         the first argument is assumed to be sample size!
#         Sample size argument should be 'n'
# sample_size = number of random variables to draw for each mean
# ... = arguments to be passed to distn
clt.test <- function(distn, sample_size, seed=NULL, ...)
{
  # set random seed
  if(!is.null(seed))
    set.seed(seed)
  
  # show underlying ditribution
  underlying_distn = data_frame(x = distn(n = 100000, ...))
  
  g <- ggplot(underlying_distn, aes(x), environment = environment()) +
       geom_density() +
       xlab("Underlying Distribution")
  print(g)
  
  print("Hit <enter> to draw the first 10 samples:")
  readLines(stdin(), 1) %>%
    invisible()
  n_draws <- 10
  
  # initialize sampling distribution
  sampling_distn = data_frame(means = numeric())
  
  # keep going until user requests no more draws
  while(n_draws != '')
  {
    # check that we got numeric input
    n_draws = as.numeric(n_draws)
    if(!is.na(n_draws))
    {
      # draw new samples of size "sample_size"
      tmp <- distn(n = sample_size*n_draws, ...) %>%
             matrix(nrow = sample_size) %>%
             apply(2, mean)
      
      # add them to sampling_distn
      sampling_distn <- 
        data_frame(means = tmp) %>%
        bind_rows(sampling_distn)
    
      # plot updated distribution
      g <- ggplot(sampling_distn, aes(means), environment = environment()) +
           geom_density() +
           xlab("Sampling Distribution")
      print(g)
    }else{
      print("Bad input")
    }
    
    # ask for more input
    print("Number of additional samples (leave blank to quit):")
    n_draws <- readLines(stdin(), 1)
  }
  
  # return our samples invisibly in case we want them
  invisible(sampling_distn)
}
