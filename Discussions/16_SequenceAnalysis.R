# RNA seq lab
# BIFX 553
# Hood College

# For this lab we will be following the rnaseqGene workflow found at https://www.bioconductor.org/help/workflows/rnaseqGene/
# some parts have been skipped, but you can follow along on the webpage.


######### load/install packages where we want them #########
# start by resetting the default library path for installation and loading packages
# this will load and install packages to the removable thumb drive
.libPaths(c("/Volumes/KINGSTON/MacLibs", .libPaths())) # for OS X
# .libPaths(c("F:/WinLibs", .libPaths())) # for Windows

source("https://bioconductor.org/biocLite.R")

install.required <- function(pkg, bioc = FALSE)
{
    failedLoad <- eval(parse(text = paste0("!require(", pkg, ")")))

    if(failedLoad & !bioc)
    {
        install.packages(pkg)
        eval(parse(text = paste0('library(', pkg, ')')))
    }

    if(failedLoad & bioc)
    {
        biocLite(pkg, suppressAutoUpdate = TRUE)
        eval(parse(text = paste0('library(', pkg, ')')))
    }
}

install.required("airway", bioc = TRUE)
install.required("Rsamtools", bioc = TRUE)
install.required("GenomicAlignments", bioc = TRUE)
install.required("GenomicFeatures", bioc = TRUE)
install.required("DESeq2", bioc = TRUE)
install.required("AnnotationDbi", bioc = TRUE)
install.required("org.Hs.eg.db", bioc = TRUE)
install.required("ReportingTools", bioc = TRUE)
install.required("Gviz", bioc = TRUE)
install.required("sva", bioc = TRUE)
install.required("fission", bioc = TRUE)
install.required("genefilter", bioc = TRUE)
install.required("tidyverse")
install.required("magrittr")
install.required("ggplot2")
install.required("pheatmap")
install.required("RColorBrewer")


######### Now run the tutorial #########

# skip parts that depend on STAR and samtools

########################
# Load and format Data #
########################

# Figure out where our data files are stored
indir <- system.file("extdata", package="airway", mustWork=TRUE)
