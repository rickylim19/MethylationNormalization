#!/usr/bin/env Rscript

options(options = 3)
suppressPackageStartupMessages(library("optparse"))
suppressPackageStartupMessages(library("minfi"))

temp03 <- "-*-courier-%s-%s-*-*-%d-*-*-*-*-*-*-*" #Assign courier string to temp variable
X11Fonts(Helvetica = temp03) ##Assign courier string to Helvetica (using temp variable)

writeColumn2File <- function(sample_info, package, input_df, output_dir){

    ####################################################################
    #                                                                  #
    # Write table for each column of a dataframe                       #
    #                                                                  #
    # > writeColumn2File(Beta.swan, package='minfi' 'Output/STAD/B/')  #
    #                                                                  #
    ####################################################################

    rownames_f <- rownames(input_df)   
    dir.create(output_dir, showWarnings = FALSE)

    for (i in 1:ncol(input_df)){
        output_df <- data.frame(input_df[, i])
            
        if (package == 'minfi'){
            filename <- sample_info$Sample_Name[sample_info$Sample_Id == colnames(input_df)[i]]
        }
        write.table(output_df, file = paste0(output_dir, filename, '.txt'),
                    col.names = filename, row.names = rownames_f, 
                    quote=FALSE, append = FALSE)
    }
}

minfiBetaNormalized <- function(cancer_dir, output_dir){

    ##################################################################################
    # Run minfi pipeline returns beta and normalized beta-scores                     #
    #                                                                                #
    # cancer_dir <- '/DAS/TBlab/Touati/TCGA/MethylationNormalization/Input/COAD/'    #
    # output_dir <- '/DAS/TBlab/Touati/TCGA/MethylationNormalization/Output/Minfi/'  #
    # >minfiBetaNormalized(cancer_dir, output_dir)                                   #
    #                                                                                #
    ##################################################################################

    cancer <- basename(cancer_dir)
    output <- paste0(output_dir, cancer)
    dir.create(output_dir, showWarnings = FALSE)
    dir.create(output, showWarnings = FALSE)

    # Load Data
    targets <- read.450k.sheet(cancer_dir)
    RGset <- read.450k.exp(base = cancer_dir, targets = targets) 
    pd <- pData(RGset)

    # QC
    qcReport(RGset, sampNames = pd$Sample_Name,
            sampGroups = pd$Sample_Group,
            pdf = paste0(output, '/qcReport_', cancer, '.pdf'))

    # Normalization
    MSet.raw <- preprocessRaw(RGset)
    ## Create a "MethylSet" with background subtraction and control normalization (As in genome studio)
    MSet.norm <- preprocessIllumina(RGset, bg.correct = TRUE, 
                                    normalize = "controls", reference = 2) 
    ## Create a "MethylSet" with SWAN normalization
    MSet.swan <- preprocessSWAN(RGset, MSet.norm) 
    pdf(paste0(output, '/NormalizationEffect_', cancer, '.pdf'), width = 10, height = 10, 
        useDingbats=FALSE)
    par(mfrow=c(1,3))
    plotBetasByType(MSet.raw[,2], main = "Raw") #beta score plot with raw data
    plotBetasByType(MSet.norm[,2], main = "Illumina Normalized") #beta score plot with raw data
    plotBetasByType(MSet.swan[,2], main = "Illumina + SWAN Normalized") #beta score plot with raw data
    dev.off()

    # Get and write the Beta scores
    dir.create(paste(output, '/B'), showWarnings = FALSE)
    Beta.raw <- getBeta(MSet.raw)
    writeColumn2File(targets, package='minfi', Beta.raw, paste0(output, '/B/'))

    # Get and write the Beta and M scores (Normalized)
    dir.create(paste(output, '/Bnormalized'), showWarnings = FALSE)
    Beta.swan <- getBeta(MSet.swan)
    writeColumn2File(targets, package='minfi', Beta.swan, paste0(output, '/Bnormalized/'))
}

### main arguments ###
option_list <- list(
    #make_option(c("-v", "--verbose"), action = "store_true", default = TRUE,
    #            help = "Print extra output [default]"),
    #make_option(c("-q", "--quietly"), action = "store_false",
    #            dest = "verbose", help = "Print little output"),
    make_option(c("-s", "--seed"), type = "integer", default = 1234,
                help = "set the seed number for reproducibility",
                metavar = "number"),
    make_option("--method", default="minfi",
                help = "library to normalize beta scores [default \"%default\"]"),
    make_option("--cancer_dir", action = "store", type = "character", 
                help = "cancer directory to be analysed",
                metavar = "character"),
    make_option("--output_dir", action = "store", type = "character", 
                help = "output directory",
                metavar = "character"),
    make_option("--example", action = "store_true", default = FALSE,
                help = "./normalizeBetaScore.R --cancer_dir=/DAS/TBlab/Touati/TCGA/MethylationNormalization/Input/COAD/ --output_dir=/DAS/TBlab/Touati/TCGA/MethylationNormalization/Output/Minfi/")
    )


opt <- parse_args(OptionParser(option_list = option_list))
# print some progress messages to stderr if "quietly" wasn't requested
#if ( opt$verbose ) {
#     write(paste0("Normalize beta score with ",opt$method, "\n"), stderr())
#}

# do some operations based on user input
if( opt$method == "minfi") {
    tryCatch(
        {
            minfiBetaNormalized(cancer_dir = opt$cancer_dir, 
                               output_dir = opt$output_dir)
            write(paste0(opt$cancer_dir, ":OK"), stderr())
        },
        error = function(cond){
            write(paste0(opt$cancer_dir, ":ERROR"), stderr())
            write("Here's the message:", stderr())
            write(paste0(cond), stderr())
        }
    )
    
} else {
    cat("It's a shame that your normalization method has not been implemented yet")
}
