# testAssumptions.R
# This function tests assumptions

require(ggplot2)
require(broom)
require(car)

# to do: add titles to figures, include model identifier as well
testAssumptions <- function(model, allPlots = FALSE)
{
  violations <- ""
  
  # Linear Relationship
  if(allPlots)
      crPlots(model)
  
  # Multivariate Normality
  ShapiroWilks <- with(augment(model),
                       shapiro.test(.std.resid))
  if(ShapiroWilks$p.value < 0.05)
    violations <- paste0(violations, "Multivariate normality violation (p = ", 
                         signif(ShapiroWilks$p.value, 2), ")\n")
  
  qqplot <- augment(model) %>%
    ggplot(aes(sample = .std.resid)) +
    stat_qq() +
    geom_abline(intercept = 0, slope = 1, color = 'gold3', size = 1)
  
  resid_dist <- augment(model) %>%
    ggplot(aes(.std.resid)) +
    geom_histogram(aes(y = ..density..)) +
    stat_function(fun = dnorm, color = 'gold3', size = 2)
  
  # Multicollinearity
  if(length(attributes(terms(model))$term.labels) > 1)
  {
    vifs <- vif(model)
  
    if(any(vifs > 2))
      violations <- paste0(violations, "Multicollinearity violation (",
                           paste(names(vifs[vifs> 2]), ":", round(vifs[vifs > 2], 1),
                                 collapse = ', '), ")\n")
  }else{
    # will throw an error if there is only one term
    vifs <- NULL
  }
  
  # Autocorrelation
  DW <- durbinWatsonTest(model)
  
  if(DW$p < 0.05)
    violations <- paste0(violations, "Autocorrelation violation (p = ", 
                         signif(DW$p, 2), ")\n")
  
  # Homoscedasticity
  ncv <- ncvTest(model)
  
  if(ncv$p < 0.05)
    violations <- paste0(violations, "Homoscedasticity violation (p = ",
                         signif(ncv$p, 2), ")\n")
  
  spreadLevel <- augment(model) %>%
    ggplot(aes(.fitted, abs(.std.resid))) +
    geom_point(alpha = 0.3) +
    geom_smooth(se = FALSE, color = 'gold3', linetype = 2, size = 1.5) +
    geom_smooth(method = 'lm', se = FALSE)
  
  
  # Outliers/Leverage
  tmp <- augment(model) %>%
    mutate(id = 1:length(.fitted),
           .p = 2*pnorm(abs(.std.resid), lower.tail = FALSE),
           outlier = .p < 0.05 / sum(!is.na(.fitted)))
  
  outliers <- filter(tmp, outlier) %>%
    select(id, .std.resid, .p, .cooksd, .hat) %>%
    arrange(.p)
  
  if(dim(outliers)[1] > 0)
    violations <- paste0(violations, dim(outliers)[1], " outliers detected\n")
  
  outlier_leverage <- ggplot(tmp, aes(.hat, .std.resid, size = .cooksd)) +
    geom_point(alpha = 0.3) +
    geom_text(aes(label = ifelse(outlier, id, '')))
  
  # Predictor Influence
  if(allPlots)
      avPlots(model)
  
  if(nchar(violations) > 0)
    warning(violations)
  
  invisible(list(ShapiroWilks = ShapiroWilks,
                 qqplot = qqplot,
                 resid_dist = resid_dist,
                 vifs = vifs,
                 DW = DW,
                 ncv = ncv,
                 spreadLevel = spreadLevel,
                 outliers = outliers,
                 outlier_leverage = outlier_leverage,
                 violations = violations))
}
