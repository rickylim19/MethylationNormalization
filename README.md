# Added the annotation file to load data using MINFI

    ./getSampleSheets.sh -a sampleSheets_minfi.ls -l '1' -c 'JHU_USC' -p 'minfi' 2> sampleSheets_minfi.log
    
# Normalized the DNA methylation

    ricky@tblab-csi:/DAS/TBlab/Touati/TCGA/MethylationNormalization$ time cat cancers.ls | parallel -j 19 ./normalizeBetaScore.R --cancer_dir={} --output_dir="/DAS/TBlab/Touati/TCGA/MethylationNormalization/Output/Minfi/" 2> normalizeBetaScore_minfi.log
    
    real    177m24.126s
    user    866m12.493s
    sys     129m30.618s

## Files explained

    cancers.ls                   -> list of cancer directory
    getSampleSheet.py            -> script to parse the annotation file for minfi
    getSampleSheets.sh           -> script to batch parse the annotation file for minfi
    normalizeBetaScore.R         -> script to normalize the DNA methylation data from TCGA
    sampleSheets_minfi.log       -> log file from adding the annotation
    normalizeBetaScore_minfi.log -> log file from normalizing the DNA methylation
