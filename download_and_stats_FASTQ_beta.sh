#!/bin/bash
####!/bin/bash -ex

# bash -x download_and_stats_FASTQ.sh > debug.log 2>&1 # run like this for verbose debugging

# use "-c" to clean

# This is a script that will
# downnload the two FASTQ for a mate pair
# tar them
# get md5 and size of the FASTQ and tar for ARKs
# analyze the tar with Stuti's docker
# save the genes.fpkm_tracking in a path suitable for subsequent processing with
# R script combine_docker_outputs.r

# Provide usage if help -h etc is the first argument

if echo $1 | grep -e "h"; then
    echo "DESCRIPTION: download_and_stats_FASTQ.sh";
    echo "Script to run Stuti's docker analysis on a list of urls and save output";
    echo "for post-processing of the docker outputs. It expects a list of urls,";
    echo "two urls per line (\":\" separated), each representing one member of a";
    echo "mate pair. These are tar'ed, analyzed with the docker, and selected results";
    echo "are saved. Creates output for combine_docker_outputs.r";
    echo "";
    echo "OPTIONS:";
    echo "     -l|--list          (string) Required - filename of list that contains the url list";
    echo "     -s|--savedir       (string) Required - path for output";
    echo "     -t|--tempdir       (string) Required - path for tempdir (dowload and docker processing location)"
    echo "                                            should include file \"star_cuff_docker_1.8.tar\" "
    echo "                                            as well as dir with ref genome (e.g. \"\")"
    #echo "     -g|--genomedir     (string) Required - location of ref genome, default = \" /mnt/SCRATCH/geuvadis_genome\""
    echo "     -c|--clean         (flag)   Optional - option to wipe non-saved results for each mate pair";
    echo "     -p|--useparcel     (flag)   Optional - use parcel for download (OPTION NOT FUNCTIONAL YET)";
    echo "     -h|--help          (flag)   Optional - display this help/usage text"
    echo "     -d|--debug         (flag)   Optional - run in debug mode";
    echo "";
    echo "USAGE";
    echo "     download_and_stats_FASTQ.sh -l <filename> -s <savedir> [other options]";
    echo "";
    echo "EXAMPLES:";
    echo "Perform default analysis on test list";
    echo "     download_and_stats_FASTQ.sh -l err_list_1_of_4.11-18-15.txt.test -s ./";
    echo ""
    echo "Kevin P. Keegan, 2015";
    echo ""
    exit 1;
fi

#echo "num_args: "$#;
#echo "all_args: "$@;
#echo "arg0    : "$0;
#echo "arg1    : "$1;

# Parse input options
while getopts ":l:s:t:cpd" opt; do
    
    case $opt in
	l)
	    echo "-l was triggered, Parameter: $OPTARG" >&2
	    LIST=$OPTARG
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 1
	    ;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1
	    ;;
	s)
	    echo "-s was triggered, Parameter: $OPTARG" >&2
	    SAVEDIR=$OPTARG
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 1
	    ;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1
	    ;;
	t)
	    echo "-t was triggered, Parameter: $OPTARG" >&2
	    TEMPDIR=$OPTARG
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 1
	    ;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1
	    ;;
	# g)
	#     echo "-g was triggered, Parameter: $OPTARG" >&2
	#     GENOMEDIR=$OPTARG
	#     ;;
	# \?)
	#     echo "Using Default" >&2
	#     GENOMEDIR="/mnt/SCRATCH/geuvadis_genome/"
	#     exit 1
	#     ;;
	# :)
	#     echo "Option -$OPTARG requires an argument." >&2
	#     exit 1
	#     ;;
	c)
	    echo "-c was triggered, Parameter: $OPTARG" >&2
	    ;;
	p)
	    echo "-p was triggered, Parameter: $OPTARG" >&2
	    ;;
	d)
	    echo "-d was triggered, Parameter: $OPTARG" >&2
	    ;;
	h)
	    #echo "-h was triggered, Parameter: $OPTARG" >&2 # Show the help 
	    echo "DESCRIPTION: download_and_stats_FASTQ.sh";
	    echo "Script to run Stuti's docker analysis on a list of urls and save output";
	    echo "for post-processing of the docker outputs. It expects a list of urls,";
	    echo "two urls per line (\":\" separated), each representing one member of a";
	    echo "mate pair. These are tar'ed, analyzed with the docker, and selected results";
	    echo "are saved. Creates output for combine_docker_outputs.r";
	    echo "";
	    echo "OPTIONS:";
	    echo "     -l|--list          (string) Required - filename of list that contains the url list";
	    echo "     -s|--savedir       (string) Required - path for output";
	    echo "     -t|--tempdir       (string) Dir to run Docker tool"; 
	    echo "     -c|--clean         (flag)   Optional - option to wipe non-saved results for each mate pair";
	    echo "     -p|--useparcel     (flag)   Optional - use parcel for download (OPTION NOT FUNCTIONAL YET)";
	    echo "     -h|--help          (flag)   Optional - display this help/usage text"
	    echo "     -d|--debug         (flag)   Optional - run in debug mode";
	    echo "";
	    echo "USAGE";
	    echo "     download_and_stats_FASTQ.sh -l <filename> -s <savedir> [other options]";
	    echo "";
	    echo "EXAMPLES:";
	    echo "Perform default analysis on test list";
	    echo "     download_and_stats_FASTQ.sh -l err_list_1_of_4.11-18-15.txt.test -s ./";
	    echo "Kevin P. Keegan, 2015";
	    exit 1;
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

# create a directory for the outputs
mkdir -p $SAVEDIR;

# create filenames for log files 
my_fastq_log=$SAVEDIR/$LIST.FASTQ_log.txt;
my_tar_log=$SAVEDIR/$LIST.tar_log.txt;
my_run_log=$SAVEDIR/$LIST.run_log.txt;
my_error_log=$SAVEDIR/$LIST.error_log.txt;

# write headers for log files
# error log
echo "### Error log for processing of $LIST ###"    > $my_error_log;
echo ""                                             >> $my_error_log;
# fastq log
echo "file_name\toriginal_url\tbasename\tmd5\tsize" > $my_fastq_log;
echo ""                                             >> $my_fastq_log;
# tar log
echo "file_name\toriginal_url\tbasename\tmd5\tsize" > $my_tar_log;
echo ""                                             >> $my_tar_log;
# run log
echo "### Run log for processing of $LIST ###"      > $my_run_log;
echo ""                                             >> $my_run_log;
echo "list:            "$LIST                       >> $my_run_log;
if [[ $2 = "-c" ]]; then
     echo "clean:           ON"                     >> $my_run_log;
else
     echo "clean:           OFF"                    >> $my_run_log;
fi
if [[ $2 = "-p" ]]; then
     echo "parcel:          ON"                     >> $my_run_log;
else
     echo "parcel:          OFF"                    >> $my_run_log;
fi
echo "save_dir:        $SAVEDIR"                    >> $my_run_log;
echo "" >> $my_run_log;

# move to /mnt/SCRATCH - where Stuti's docker expects the data to be
mkdir -p $TEMPDIR
cd $TEMPDIR;

for i in `cat $LIST`;

# retireve targets from list - generate local filenames	 
do mate_1=`echo $i | cut -f 1 -d ":"`;
   mate_2=`echo $i | cut -f 2 -d ":"`;
   mate_1_basename=`basename $mate_1`;
   mate_2_basename=`basename $mate_2`;
   pair_name=`echo $mate_1_basename | cut -f 1 -d "_"`;
   tar_name=$pair_name.fastq.tar.gz;
   echo "processing:      $pair_name"       >> $my_run_log;
   echo "pair_name:       $pair_name"       >> $my_run_log;
   echo "mate_1:          $mate_1"          >> $my_run_log;
   echo "mate_1_basename: $mate_1_basename" >> $my_run_log;
   echo "mate_2:          $mate_2"          >> $my_run_log;
   echo "mate_1_basename: $mate_2_basename" >> $my_run_log;
   echo "tar_name:        $tar_name"        >> $my_run_log;

   # download both members of the mate pair
   echo "downloading $mate_1" >> $my_run_log;
   #wget $mate_1 2 >> $my_error_log 1 >> $my_run_log; # this causes an error
   #####wget $mate_1;
   echo "DONE downloading $mate_1" >> $my_run_log;
   echo "downloading $mate_2" >> $my_run_log;
   #####wget $mate_2;
   echo "DONE downloading $mate_2" >> $my_run_log;

   # create tar from individual mates
   echo "creating tar $tar_name" >> $my_run_log;
   #####tar -zcf $tar_name $mate_1_basename $mate_2_basename;
   echo "DONE creating tar $tar_name" >> $my_run_log;

   # get md5s
   echo "calculating md5's" >> $my_run_log;
   md5_mate1=`md5sum $mate_1_basename | cut -f1 -d " "`; # 2>> $my_error_log 1 >> $my_run_log;
   md5_mate2=`md5sum $mate_2_basename | cut -f1 -d " "`; # 2>> $my_error_log 1 >> $my_run_log;
   md5_tar=`md5sum $tar_name | cut -f1 -d " "`; # 2>> $my_error_log 1 >> $my_run_log;
   echo "DONE calculating md5's" >> $my_run_log;
   
   # get sizes
   echo "calculating sizes" >> $my_run_log;
   size_mate1=`stat -c%s $mate_1_basename`; # 2>> $my_error_log 1 >> $my_run_log;
   size_mate2=`stat -c%s $mate_2_basename`; # 2>> $my_error_log 1 >> $my_run_log;
   size_tar=`stat -c%s $tar_name`; # 2>> $my_error_log 1 >> $my_run_log;
   echo "DONE calculating sizes" >> $my_run_log;
   
   # print values to logs
   echo "printing calculated values to logs" >> $my_run_log;
   echo $mate_1_basename\t$mate_1\t$mate_1_basename\t$md5_mate1\t$size_mate1 >> $my_fastq_log; # mate_1 FASTQ;
   echo "DONE printing stats of $mate_1_base" >> $my_run_log;
   echo $mate_2_basename\t$mate_2\t$mate_2_basename\t$md5_mate2\t$size_mate2 >> $my_fastq_log; # mate_2 FASTQ;
   echo "DONE printing stats of $mate_2_basename" >> $my_run_log;
   echo $tar_name\t"NA"\t$pair_name\t$md5_tar\t$size_tar >> $my_tar_log; # tar created from mate_1 and mate_2
   echo "DONE printing calculated values to logs" >> $my_run_log;
   
   # Run Stuti's tool
   ## populate the filenames_1.txt file with a single jobname
cat >filenames_1.txt<<EOF
$pair_name.fastq.tar.gz
EOF
   ## run load and run the docker tool
   echo "running the Docker..." >> $my_run_log;

   # start sudo su
   # tmux;
   # sudo su;
   #####sudo docker load -i /mnt/star_cuff_docker_1.8.tar;
   #####sudo python /home/ubuntu/git/CDIS_GEUVADIS_analysis/run_docker.py;
   #sudo -k;
   echo "DONE with Docker processing" >> $my_run_log;
   # get the output
   echo "saving Docker output" >> $my_run_log;
   ## mkdir for output that my R script can use to combine outputs later
   sudo mkdir -p $SAVEDIR$pair_name/star_2_pass/;
   ## move the genes.fpkm_tracking file to the save location
   echo "DOING THIS:" >> $my_run_log;
   echo "sudo cp /mnt/SCRATCH/geuvadis_results/$pair_name/star_2_pass/genes.fpkm_tracking $SAVEDIR$pair_name/star_2_pass/" >> $my_run_log;
   sudo cp /mnt/SCRATCH/geuvadis_results/$pair_name/star_2_pass/genes.fpkm_tracking $SAVEDIR$pair_name/star_2_pass/genes.fpkm_tracking
   echo "DONE saving Docker output" >> $my_run_log;
   
   # cleanup (if flag is used)
   if [[ $2 = "-c" ]]; then
       echo "cleanup" >> $my_run_log;
       sudo rm -R /mnt/SCRATCH/geuvadis_results/$pair_name;
       sudo rm $mate_1_basename;
       sudo rm $mate_2_basename;
       echo "Done with cleanup" >> $my_run_log;
   else
       echo "No cleanup" >> $my_run_log;
   fi

   # # copy current logs to the output directory
   # echo "copying logs" >> $my_run_log;
   # sudo cp $my_fastq_log $SAVEDIR/;
   # sudo cp $my_tar_log $SAVEDIR/;
   # sudo cp $my_error_log $SAVEDIR/;
   # sudo cp $my_run_log $SAVEDIR/;
   # echo "Done copying logs" >> $my_run_log;
   
   echo "ALL DONE WITH  $pair_name" >> $my_run_log;

   # close sudo su
   # sudo -k;
   # close tmux session
   # exit;
   
done;

echo "" >> $my_run_log
echo "ALL DONE PROCESSING $LIST" >> $my_run_log


# Notes:
# SCRATCH/
# case $key in
#     -e|--extension)
#     EXTENSION="$2"
#     shift # past argument
#     ;;
#     -s|--searchpath)
#     SEARCHPATH="$2"
#     shift # past argument
#     ;;
#     -l|--lib)
#     LIBPATH="$2"
#     shift # past argument
#     ;;
#     --default)
#     DEFAULT=YES
#     ;;
#     *)
#             # unknown option
#     ;;
# esac
# shift # past argument or value
# done
# echo FILE EXTENSION  = "${EXTENSION}"
# echo SEARCH PATH     = "${SEARCHPATH}"
# echo LIBRARY PATH    = "${LIBPATH}"
# echo "Number files in SEARCH PATH with EXTENSION:" $(ls -1 "${SEARCHPATH}"/*."${EXTENSION}" | wc -l)
# if [[ -n $1 ]]; then
#     echo "Last line of file specified as non-opt/last argument:"
#     tail -1 $1
# fi


