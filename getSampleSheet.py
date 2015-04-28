#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
from optparse import OptionParser

def getSampleSheet(input_f, center, level, package, base):

    """
    Return the SampleSheet.csv (following the format by minfi package) from file_manifest.txt (TCGA)
    The stdout header is [Sample_Name,Barcode,Center,Level,Array,Slide,Basename]
    Sample_Group for either tumor, normal, or control is described by TCGA
    Ref: https://wiki.nci.nih.gov/display/TCGA/TCGA+barcode
    """

    with open(input_f) as in_f:
        next(in_f)
        # Header of the output (stdout)
        if package == 'minfi':
            sys.stdout.write("Sample_Name,Sample_Group,Sample_Id,Center,Level,Array,Slide,Basename\n")
        if package == 'lumi':
            # note TCGA == Sample_Name
            sys.stdout.write("SENTRIX_BARCODE,SENTRIX_POSITION,Sample_Group,Center,Level,TCGA,Sample_Id,Basename\n")

        for line in in_f:
            fields = line.rstrip().split('\t')
            # PlatformType Center  Platform    Level   Sample  Barcode FileName
            # DNA Methylation   JHU_USC HumanMethylation450 1   TCGA-AA-3495-01 TCGA-AA-3495-01A-01D-1407-05    5775041007_R01C01_Grn.idat

            Barcode = fields[5]
            if '/' in Barcode:continue
            if Barcode.startswith('TCGA'): 
                Sample_label = int(Barcode.split('-')[3][:2])
                if Sample_label in xrange(1,10):
                    Sample_group = 'Tumor'
                elif Sample_label in xrange(10,20):
                    Sample_group = 'Normal'
                elif Sample_lable in xrange(20,30):
                    Sample_group = 'Control'
            else: 
                Sample_group = 'NA'

            Sample_name = Barcode
            Center = fields[1]
            Level = fields[3]
            Filename = fields[6] #'823182139_R023_Red.idat'
            Filename_parts = Filename.split("_")
            Array = Filename_parts[1]
            Slide = Filename_parts[0]
            Sample_Id= Slide + "_" + Array
            if Filename.endswith('.idat') and Level == level and Center == center:
                if package == 'minfi':
                    result = "%s,%s,%s,%s,%s,%s,%s,%s\n" %\
                             (Sample_name, Sample_group, Sample_Id, Center, Level, Array, Slide, base)
                if package == 'lumi':
                    result = "%s,%s,%s,%s,%s,%s,%s,%s\n" %\
                             (Slide, Array, Sample_group, Center, Level, Sample_name, Sample_Id, base)
                sys.stdout.write(result)
            else: continue

def parse_options():
    parser = OptionParser(usage="""\
        get SampleSheet.csv from file_manifest.txt
        Usage: %prog [options]
        e.g:
        ./getSampleSheet.py -f file_manifest.txt -l '1' -c 'JHU_USC' -b '/home/data' > SampleSheet_level1_JHU__USC.csv
    """)
    parser.add_option('-l', '--level',
        type = 'string', action = 'store', dest = "level",
        default = '1',
        help = 'level of file processings. 1,2,3 mean raw, preprocessed, and post-processed, respectively')
    parser.add_option('-c', '--center', 
        type = 'string', action = 'store', dest = "center",
        help = 'center where the studies were carried out')
    parser.add_option('-b', '--base',
        type = 'string', action = 'store', dest = "base", 
        default = '',
        help = 'basename')
    parser.add_option('-p', '--package', 
        type = 'string', action = 'store', dest = "package",
        default = 'lumi',
        help = 'package for the analysis')
    parser.add_option("-f", "--file",
        type = 'string', action = "store", dest = "filename",
        help = 'input file (file_manifest.txt)')

    (options, args) = parser.parse_args()
    return options

def main():
    options = parse_options()
    getSampleSheet(input_f= options.filename,
                   center = options.center,
                   level= options.level,
                   package = options.package,
                   base = options.base)

if __name__ == "__main__":
    main()
