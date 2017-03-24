# testAssumptions.R
# This function tests assumptions

require(ggplot2)
require(broom)
require(car)
require(survival)
require(cowplot)

# to do: add titles to figures, include model identifier as well
testAssumptions <- function(model, allPlots = FALSE)
{
  violations <- ""

  survModel <- 'coxph' %in% class(model)

  # Linear Relationship
  if(allPlots & !survModel) ###### add martingale plot for coxph
      crPlots(model)

  if(survModel)
  {
      aug <- augment(model)

      classes <- map(aug, class)
      to_plt <- names(classes)[!substr(names(classes), 1, 1) == '.' &
                                   !classes == 'Surv']

      plots <- NULL

      for(p in to_plt)
      {
          # do violin/box plot for factors
          if(classes[p] == 'factor')
          {
              plots[[p]] <- ggplot(aug, aes_string(p, '.resid')) +
                            geom_violin(fill = 'grey80') +
                            geom_boxplot(width = .1)
          }else{
          # regular martingale plot for numeric
              if(dim(aug)[1] > 1000)
              {
                  plots[[p]] <- ggplot(aug, aes_string(p, '.resid')) +
                                geom_jitter() +
                                geom_smooth(method = 'gam', formula = y ~ s(x, bs = "cs"),
                                            linetype = 2, se = FALSE)
              }else{
                  plots[[p]] <- ggplot(aug, aes_string(p, '.resid')) +
                                geom_jitter() +
                                geom_smooth(method = 'loess',
                                            linetype = 2, se = FALSE)
              }
          }
      }

      martingale_plots <- suppressWarnings(plot_grid(plotlist = plots))
  }else{
      martingale_plots <- NULL
  }

  # Multivariate Normality
  GLMmodel <- !is.null(model$family) # model$family is null for lm
  if(GLMmodel)
    GLMmodel <- model$family$family != 'gaussian'

  if(GLMmodel | survModel)
  {
    ShapiroWilks <- NULL
    qqplot <- NULL
    resid_dist <- NULL
  }else{
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
  }

  # Multicollinearity
  if(length(attributes(terms(model))$term.labels) > 1)
  {
    vifs <- suppressWarnings(vif(model))

    if(is.null(dim(vifs))) # this may return a matrix
    {
        if(any(vifs > 2))
            violations <- paste0(violations, "Multicollinearity violation (",
                                 paste0(names(vifs[vifs> 2]), ": ", round(vifs[vifs > 2], 1),
                                       collapse = ', '), ")\n")
    }else{
        if(any(vifs[,1] > 2))
            violations <- paste0(violations, "Multicollinearity violation (",
                                 paste0(rownames(vifs)[vifs[,1]> 2], ": ", round(vifs[vifs[,1] > 2,1], 1),
                                       collapse = ', '), ")\n")
    }

  }else{
    # will throw an error if there is only one term
    vifs <- NULL
  }

  # Autocorrelation
  if(!survModel)
  {
    DW <- durbinWatsonTest(model)

    if(DW$p < 0.05)
        violations <- paste0(violations, "Autocorrelation violation (p = ",
                             signif(DW$p, 2), ")\n")
  }else{
    DW <- NULL
  }


  # Homoscedasticity
  if(GLMmodel | survModel)
  {
    ncv <- NULL
  }else{
    ncv <- ncvTest(model)

    if(ncv$p < 0.05)
      violations <- paste0(violations, "Homoscedasticity violation (p = ",
                           signif(ncv$p, 2), ")\n")
  }

  if(survModel)
  {
    spreadLevel <- NULL
  }else{
    spreadLevel <- augment(model) %>%
      ggplot(aes(.fitted, abs(.std.resid))) +
      geom_point(alpha = 0.3) +
      geom_smooth(se = FALSE, color = 'gold3', linetype = 2, size = 1.5) +
      geom_smooth(method = 'lm', se = FALSE)
  }


  # Outliers/Leverage
  if(survModel)
  {
    outliers <- NULL
    outlier_leverage <- NULL
  }else{
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
  }


  # Cox Proportionality
  if(survModel)
  {
    cox_proportionality <- cox.zph(model)

    if(cox_proportionality$table['GLOBAL', 'p'] < 0.05)
      violations <- paste0(violations, "Proportional hazards assumption violated (p = ",
                        signif(cox_proportionality$table['GLOBAL', 'p'], 2),
                        ")\n")
  }else{
    cox_proportionality <- NULL
  }

  # Predictor Influence
  if(allPlots & !survModel)
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
                 martingale_plots = martingale_plots,
                 violations = violations))
}
