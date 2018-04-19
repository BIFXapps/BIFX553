Introduction
============

This week we will start with the use of Principal Components Analysis to
measure population substructure and use our population substructure
measures to cluster our samples into populations. We will also revisit
our discussion of power from last week and create a power plot suitable
for a grant proposal.

PCA and Population Substructure
===============================

Selecting markers for analysis
------------------------------

I've included this code for you to see, but don't bother running it in
class. To run this code, you'll first need to install my
[ALDdata](https://github.com/johnsonra/ALDdata) package.

    ##### Pull a subset of data from HapMap #####
    require(magrittr)
    library(ALDdata)

    # load hapmap data
    data(hapmap)

    ### pull the rs numbers with the greatest frequency difference between Europeans and Africans ###

    require(dplyr)
              # filter chromosomes 23 and 24 out, since sex chromosome admixture is different than for the autosomes
    hapmap <- filter(hapmap, chr < 23) %>%
        
              # order by frequency differences
              arrange(desc(abs(f.yri - f.ceu))) %>%
            
              # pull top 1000 markers from the genome
              head(n = 1000) %>%
        
              # reorder by genomic position
              arrange(chr, pos)

Now that we have picked 1000 markers, we probably want to be sure that
we haven't picked too many that are tightly linked. If they all fall in
the same small region of the genome, for example, we might not be
capturing as much information as we would like.

It does appear that we have good representation from each autosome (i.e.
larger chromosomes generally have more markers, and each chromosome has
some markers in the set).

![](13_Clustering_Power_files/figure-markdown_strict/marker%20dist-1.png)

From the figure below we can see that a little less than 20% of markers
are within 0.1 cM of each other. This should give us plenty of unlinked
markers for our PCA.

![](13_Clustering_Power_files/figure-markdown_strict/check%20genetic%20distance-1.png)

Data set creation
-----------------

Now we will pull the genotypes for these markers from the HapMap data
stored in the ALDdata package.

    # data are stored by chromosome
    for(i in unique(hapmap$chr))
    {
        # get European data
        eval(parse(text = paste0("data('ceu", i, "')")))
        tmp <- with(hapmap, phased[,rs[chr == i]])
        nceu <- dim(phased)[1]
        
        # get African data
        eval(parse(text = paste0("data('yri", i, "')")))
        tmp <- rbind(tmp, 
                     with(hapmap, phased[,rs[chr == i]]))
        nyri <- dim(phased)[1]
        
        # get African American data
        eval(parse(text = paste0("data('asw", i, "')")))
        tmp <- rbind(tmp, 
                  with(hapmap, phased[,rs[chr == i]]))
        nasw <- dim(phased)[1]

        # get Chinese data
        eval(parse(text = paste0("data('chb", i, "')")))
        tmp <- rbind(tmp, 
                     with(hapmap, phased[,rs[chr == i]]))
        nchb <- dim(phased)[1]
        
        # get Japanese data
        eval(parse(text = paste0("data('jpt", i, "')")))
        tmp <- rbind(tmp, 
                     with(hapmap, phased[,rs[chr == i]]))
        njpt <- dim(phased)[1]
        
        # add markers to the full data set (or create dat on the first time around) 
        if(!exists('dat'))
        {
            dat <- as_data_frame(tmp) %>%
                   mutate(id = rownames(tmp),
                          pop = c(rep('CEU', nceu),
                                  rep('YRI', nyri),
                                  rep('ASW', nasw),
                                  rep('CHB', nchb),
                                  rep('JPT', njpt)),
                          col = c(rep(cbbPalette[1], nceu),
                                  rep(cbbPalette[2], nyri),
                                  rep(cbbPalette[3], nasw),
                                  rep(cbbPalette[4], nchb),
                                  rep(cbbPalette[5], njpt))) %>%
                   select(id, pop, col, everything())
        }else{
            dat <- bind_cols(dat, as_data_frame(tmp))
        }
    }

    # save dat to disk
    save(dat, file = 'hapmap_data_for_pca.RData')

Principal Component Analysis
----------------------------

For this section, copy the starter code in this code chunk into your
browser to fetch the data set created in the previous section.

    load(url('https://raw.githubusercontent.com/BIFXapps/BIFX553/master/Data/hapmap_data_for_pca.RData'))

Now we are ready to perform a PCA! The steps are as follows:

-   Calculate the correlation matrix for the genetic marker data.
-   Calculate eigenvalues and eigenvectors from the correlation matrix.
-   Calculate principal components from the correlation matrix.

<!-- -->

    # we don't have any missing data, but 'pairwise.complete.obs' will work if some data are missing
    cormat <- select(dat, -id, -pop, -col) %>%
              cor(use = 'pairwise.complete.obs')

    # calculate eigen vectors
    eig <- eigen(cormat)

    # calculate principal components for our data
    pcs <- as.matrix(select(dat, -id, -pop, -col)) %*% eig$vectors

    dat <- mutate(dat,
                  pc1 = pcs[,1],
                  pc2 = pcs[,2])

These figures give us a graphical representation of the population
substructure information we just summarized.

![](13_Clustering_Power_files/figure-markdown_strict/population%20substructure%20graph-1.png)![](13_Clustering_Power_files/figure-markdown_strict/population%20substructure%20graph-2.png)

Now, lets use `kmeans()` to cluster these individuals by population.

    clstr3 <- kmeans(pcs[,1:2], 3)
    clstr4 <- kmeans(pcs[,1:2], 4)

Power Plot
==========

Create a power curve... You may find these functions helpful:

    source('https://raw.githubusercontent.com/johnsonra/Rtools/master/Rtools/R/power.cont.tab.R')
    source('https://raw.githubusercontent.com/johnsonra/Rtools/master/Rtools/R/p.disease.R')
