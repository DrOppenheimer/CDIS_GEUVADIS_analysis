#!/bin/bash
####!/bin/bash -ex

# This is a script that will
# downnload the two FASTQ for a mate pair
# tar them
# get md5 and size of the FASTQ and tar for ARKs
# analyze the tar with Stuti's docker
# save the genes.fpkm_tracking in a path suitable for subsequent processing with
# R script combine_docker_outputs.r

# variables
my_list="";
my_fastq_log=$my_list.FASTQ_log.txt;
my_tar_log=$my_list.tar_log.txt;
my_error_log=$my_list.error_log.txt;
my_save_dir="/mnt/saved_docker_outputs/";

# expects list to be in this format
# url_mate_1:url_mate_2

# write header for logs
echo "original_url\tbasename\tmd5\tsize" > $my_fastq_log;
echo "original_url\tbasename\tmd5\tsize" > $my_tar_log;
echo "### Error log for processing of $my_list ###" > $my_error_log;
echo "save_dir:        $my_save_dir"       >> $my_error_log;

# create a directory for the outputs

mkdir -p $my_save_dir;

# move to /mnt/SCRATCH - where Stuti's docker expects the data to be
cd /mnt/SCRATCH/;

for i in `cat $my_list`;

# retireve targets from list - generate local filenames	 
do mate_1=`echo $i | cut -f 1 -d ":"`;
   mate_2=`echo $i | cut -f 2 -d ":"`;
   mate_1_basename=`basename $mate_1`;
   mate_2_basename=`basename $mate_2`;
   pair_name=`echo $mate_1_basename | cut -f 1 -d "_"`;
   tar_name=$pair_name.fastq.tar.gz;
   echo "processing:      $pair_name"       >> $my_error_log;
   echo "pair_name:       $pair_name"       >> $my_error_log;
   echo "mate_1:          $mate_1"          >> $my_error_log;
   echo "mate_1_basename: $mate_1_basename" >> $my_error_log;
   echo "mate_2:          $mate_2"          >> $my_error_log;
   echo "mate_1_basename: $mate_2_basename" >> $my_error_log;
   echo "tar_name:        $tar_name"        >> $my_error_log;

   # download both members of the mate pair
   echo "downloading $mate_1 and $mate_2" >> $my_error_log;
   wget $mate_1 2 >> $my_error_log;
   echo "download of $mate_1 complete" >> $my_error_log;
   wget $mate_2 2 >> $my_error_log;
   echo "download of $mate_2 complete" >> $my_error_log;

   # create tar from individual mates
   echo "downloading $mate_1_basename and $mate_2_basename to $pair_name.fastq.tar.gz" >> $my_error_log;
   tar -zcvf $tar_name $mate_1_basename $mate_2_basename 2 >> $my_error_log;
   echo "tar creation of $tar_name complete" >> $my_error_log;

   # get md5s
   md5_mate1=`md5sum $mate_1_basename` 2>> $my_error_log;
   md5_mate2=`md5sum $mate_2_basename` 2>> $my_error_log;
   md5_tar=`md5sum $tar_name` 2>> $my_error_log;

   # get sizes
   size_mate1=`stat -c%s $mate_1_basename` 2>> $my_error_log;
   size_mate2=`stat -c%s $mate_2_basename` 2>> $my_error_log;
   size_tar=`stat -c%s $tar_name` 2>> $my_error_log;

   # print values to logs
   echo $mate_1\t$mate_1_basename\t$md5_mate1\t$size_mate1 >> $my_fastq_log; # mate_1 FASTQ;
   echo "FASTQ stats of $mate_1_basename complete" >> $my_error_log;
   echo $mate_2\t$mate_2_basename\t$md5_mate2\t$size_mate2 >> $my_fastq_log; # mate_2 FASTQ;
   echo "FASTQ stats of $mate_2_basename complete" >> $my_error_log;
   echo "NA"\t$pair_name\t$md5_tar\t$size_tar >> $my_tar_log; # tar created from mate_1 and mate_2
   echo "FASTQ stats of $tar_name complete" >> $my_error_log;

   # Run Stuti's tool
   ## populate the filenames_1.txt file with a single jobname
cat >filenames_1.txt<<EOF
$pair_name.fastq.tar.gz
EOF
   ## run load and run the docker tool
   echo "running the docker..." >> $my_error_log;
   sudo su;
   docker load -i /mnt/star_cuff_docker_1.8.tar;
   python run_docker.py;
   sudo -k;
   echo "Docker processing complete" >> $my_error_log;
   # get the output
   ## mkdir for output that my R script can use to combine outputs later
   mkdir -p $my_save_dir$pair_name/star_2_pass/;
   ## move the genes.fpkm_tracking file to the save location
   sudo cp /mnt/SCRATCH/geuvadis_results/$pair_name/star_2_pass/genes.fpkm_tracking $my_save_dir$pair_name/star_2_pass/;
   echo "Saving Docker output complete" >> $my_error_log;
   
   
   # copy current logs to the output directory
   cp $my_fastq_log $my_save_dir/;
   cp $my_tar_log $my_save_dir/;
   cp $my_error_log $my_save_dir/;
    echo "Done with cleanup" >> $my_error_log;
   
   # cleanup
   sudo rm -R /mnt/SCRATCH/geuvadis_results/$pair_name;
   sudo rm $mate_1_basename;
   sudo rm $mate_2_basename;
   echo "Done with cleanup" >> $my_error_log;

   echo "DONE WITH  $pair_name" >> $my_error_log;
   
done;
