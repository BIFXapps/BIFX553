Introduction
------------

We will be doing more modeling practice this week, including some more
complicated interactions and data transformations.

Puromycin data set
------------------

From the documentation of the `Puromycin` data set (see `?Puromycin` for
more details):

> The Puromycin data frame has 23 rows and 3 columns of the reaction
> velocity versus substrate concentration in an enzymatic reaction
> involving untreated cells or cells treated with Puromycin.

> Data on the velocity of an enzymatic reaction were obtained by Treloar
> (1974). The number of counts per minute of radioactive product from
> the reaction was measured as a function of substrate concentration in
> parts per million (ppm) and from these counts the initial rate (or
> velocity) of the reaction was calculated (counts/min/min). The
> experiment was conducted once with the enzyme treated with Puromycin,
> and once with the enzyme untreated.

Load the Puromycin data set and model `rate` as a function of the data.

    data('Puromycin')

After you have settled on a final model, look at `?Puromycin` and
discuss their solution in the *Examples* section.

-   How does it compare?
-   What are the advantages of your model versus their model?

More Practice
-------------

[This
gist](https://gist.github.com/johnsonra/8166c3893dce5f943bf2a159b58babbb)
will load three additional data sets (`dat1`, `dat2`, and `dat3`).
Practice fitting the best model to the first two data sets.

    source('https://tinyurl.com/y6wgmojw')

Bonus Challenge Problem
-----------------------

Fit the best model to the third data set, `dat3`, sourced above.
