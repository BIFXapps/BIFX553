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


# Here are our bam files (along with a few others)
list.files(indir)

# this table contains sample information
sampleTable <- read_csv(paste0(indir, "/sample_table.csv"))

# load bam files
bamfiles <- file.path(indir, paste0(sampleTable$Run, "_subset.bam")) %>%
            BamFileList(yieldSize=2000000)

str(bamfiles[1])
seqinfo(bamfiles[1])

# load our gene transcript model library
(txdb <- file.path(indir,"Homo_sapiens.GRCh37.75_subset.gtf") %>%
        makeTxDbFromGFF(format = "gtf", circ_seqs = character()))

# create GRangesList
(ebg <- exonsBy(txdb, by="gene"))


#################
# Read Counting #
#################

# this can be done in parallel, but we will skip that for now.

se <- summarizeOverlaps(features=ebg, reads=bamfiles,
                        mode="Union",
                        singleEnd=FALSE,
                        ignore.strand=TRUE,
                        fragments=TRUE )

######################
# Experiment Summary #
######################

# add sample information to colData slot
colData(se) <- DataFrame(sampleTable)

# make this into a factor with untrt as reference
se$dex %<>% factor(levels = c('untrt', 'trt'))


######### Pick up entire data set #########

data("airway")
se <- airway

# relevel factor such that untrt is the reference
se$dex %<>% relevel("untrt")

##########
# Counts #
##########

# including cell allows us to account for the fact that we have many observations from each sample
# including dex allows us look at the difference in expression by treatement
dds <- DESeqDataSet(se, design = ~ cell + dex)

# remove rows that have no information (1 or fewer counts)
dds <- dds[ rowSums(counts(dds)) > 1, ]

# normalize such that we get homoscedastic data -- use vst() on large samples
# this is good for PCA, but we will use something different for differential expression
rld <- rlog(dds, blind = FALSE)

vsd <- vst(dds, blind = FALSE)
# take a look at different transforms as shown in workflow

####################
# Sample Distances #
####################

sampleDists <- dist(t(assay(rld)))

# looks like untrt and trt are clustering together. That is a good thing.
# note faint off diagonal correlation (e.g. between untrt-N052611 and trt-N052611)
sampleDistMatrix <- as.matrix( sampleDists )
rownames(sampleDistMatrix) <- paste( rld$dex, rld$cell, sep = " - " )
colnames(sampleDistMatrix) <- NULL
colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
pheatmap(sampleDistMatrix,
         clustering_distance_rows = sampleDists,
         clustering_distance_cols = sampleDists,
         col = colors)

# take a look at first couple of principal components (another view of the same thing)
plotPCA(rld, intgroup = c("dex", "cell"))


dds <- DESeq(dds)
res <- results(dds)
