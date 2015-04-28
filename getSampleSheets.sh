#! /bin/bash
#
# getSampleSheets.sh
#
#########################################################################################
#                                                                                       #
# Return samplesheets for minfi package                                                 #
#                                                                                       #
# This script is to run ./getSampleSheet.py (parsing the file_manifest.txt) in loops    #
#                                                                                       #
#########################################################################################

trap 'echo Keyboard interruption... ; exit 1' SIGINT

if [ $# -eq 0 ]; then
  echo "Usage ./getSampleSheets.sh -a [annot.file] -l [level] -c [center]"
  echo "[annot.file]: a csv file <input>,<basename>,<outputdir>"
  echo "e.g:"
  echo "time getSampleSheets.sh -a sampleSheets_minfi.ls -l '1' -c 'JHU_USC' -p 'minfi' 2> sampleSheets_minfi.log &"
  echo "Make sure you have the write permission on the directory"
exit 1
fi


while getopts ":a:l:c:p:" opt; do
  case $opt in
    a)
      echo "-a annotation file: $OPTARG" >&2
      annot="$OPTARG"
      ;;
    l)
      echo "-level of the files: $OPTARG" >&2
      level="$OPTARG"
      ;;
    c)
      echo "-center of the studies: $OPTARG" >&2
      center="$OPTARG"
      ;;
    p)
      echo "-bioconductor package: $OPTARG" >&2
      package="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1                                                
      ;;
  esac
done

cat $annot | while IFS=, read input_f basename output_f;
do
    python getSampleSheet.py -f $input_f -l $level -c $center -b $basename -p $package | uniq > $output_f && echo "SampleSheet $input_f:OK" >&2;  
done
