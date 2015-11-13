# This R file includes scripts to do three different things

# (1) Install the required packages etc.

# (2) Produce visualizations from precomputed results (results are included in the repo)
#     - These scripts run fairly quickly

# (3) Perform the analysees that produce the results used for the analysis
#     - These scripts take a while to run, and require the output from Stuti's docker for two or more samples


### General notes
# Precalculated data represeent 41 samples (there were problems processing 9 of the original 50 selected)

### (1) Install required packages etc.

# This document assumes that you have cloned this repository into ~/git/
# You need to run the most recent version of R - if you do a apt-get install r-base in LTS 14.04 you will not
# install the most current version.
# To install the most current version - you can follow the recipe in this file:
#      https://github.com/DrOppenheimer/Kevin_Installers/blob/master/Install_updated_R.sh
# Note that this script is not fully functional - You'll have to enter lines manually to perform the installation
# of R

### (1) Instal required packages etc. 

# set the working directory to the directory that contains the precomputed data
setwd("~/git/CDIS_GEUVADIS_analysis/GEUVADIS_demo_data/")
# Note - this is where all of the outputs will be created.
# To work on as many platforms as possible, scripts that create visualizations write
# them directly to file (as *.png)


source("~/git/CDIS_GEUVADIS_analysis/install_r_prereqs.r")
install_r_prereqs()

### (2) Produce visualizations from precomputed results

# (2.a) place file names into varibales
combined_FPKM                <- "combined_FPKM.txt"
combined_FPKM_normalized     <- "combined_FPKM.txt.quantile.PREPROCESSED.txt"
FPKM_pcoa                    <- "combined_FPKM.txt.quantile.PREPROCESSED.txt.euclidean.PCoA"
FPKM_metadata                <- "combined_FPKM_metadata.txt"
population_stats_subselected <- "combined_FPKM.txt.quantile.PREPROCESSED.txt.population.p_lte_e-4.txt"
performer_stats_subselected  <- "combined_FPKM.txt.quantile.PREPROCESSED.txt.performer.p_lte_e-4.txt"

# (2.b) source scripts from this repository
source("~/git/CDIS_GEUVADIS_analysis/import_data.r")
source("~/git/CDIS_GEUVADIS_analysis/export_data.r")
source("~/git/CDIS_GEUVADIS_analysis/import_metadata.r")
source("~/git/CDIS_GEUVADIS_analysis/preprocessing_tool.r")
source("~/git/CDIS_GEUVADIS_analysis/calculate_pco.r")
source("~/git/CDIS_GEUVADIS_analysis/render_calculated_pcoa.r")
source("~/git/CDIS_GEUVADIS_analysis/render_calculated_pcoa.r")
source("~/git/CDIS_GEUVADIS_analysis/heatmap_dendrogram.r")
source("~/git/CDIS_GEUVADIS_analysis/calc_stats.r")

# (2.c) Normalize the data (quantile normalization)
# EXAMPLE TO RECREATE RESULTS:
preprocessing_tool(data_in=combined_FPKM, norm_method="quantile", produce_boxplots=TRUE)
# NOTES:
# This will create three files:
# (1) The quantile normalized data ( combined_FPKM.txt.quantile.PREPROCESSED.txt )
# (2) A log detailing the normalization ( combined_FPKM.txt.quantile.PREPROCESSED.txt.log )
# (3) And a figure that presents boxplots of the samples before and after normalization ( combined_FPKM.txt.boxplots.png )

# (2.d) Calculate raw (flat file) PCoA
# EXAMPLE TO RECREATE RESULTS:
calculate_pco(file_in=combined_FPKM_normalized)
# NOTES:
# This will create two files:
# (1) A distance matrix ( combined_FPKM.txt.quantile.PREPROCESSED.txt.euclidean.DIST )
# (2) A flat file formatted PCoA ( combined_FPKM.txt.quantile.PREPROCESSED.txt.euclidean.DIST ), "normalized" eigen values are at the top, eigen vectors at the bottom

# (2.e) Render calculated PCoA with metadata -- this will generat two PCoA images, one for each column in the metadata file (population and "performer")
# EXAMPLE TO RECREATE RESULTS:
render_calcualted_pcoa(PCoA_in=FPKM_pcoa, metadata_table=FPKM_metadata, use_all_metadata_columns=TRUE, figure_symbol_cex=6,  vert_line="blank")
# NOTES:
# This will create two files (both are png images)
# The PCoA calculated above rendered with the "Population" metadata ( combined_FPKM.txt.quantile.PREPROCESSED.txt.euclidean.PCoA.Population.pcoa.png )
# The PCoA calculated above rendered with the "Performer" metadata ( combined_FPKM.txt.quantile.PREPROCESSED.txt.euclidean.PCoA.Performer.pcoa.png )
#

# (2.f) Calculate stats
# EXAMPLES TO RECREATE RESULTS:
calc_stats(data_table=combined_FPKM_normalized, metadata_table=FPKM_metadata, metadata_column=1, stat_test="Kruskal-Wallis")
calc_stats(data_table=combined_FPKM_normalized, metadata_table=FPKM_metadata, metadata_column=2, stat_test="Kruskal-Wallis")
# NOTES:
# This function has to run once for each metadata column considered. It useses the values in the selected metadata column to automatically
# separate the samples into groups. As an example, the first columne in the metadata file has 5 unique values (the populations). The samples
# are split accordingly into these five groups. The statistic is applied (in this case KW, i.e. non-parametric ANOVA)
# Each time this function is used, it creates a single file that contains the input abundance values as well as the stat value, p, and FDR.
# The files created will be:
# ( combined_FPKM.txt.quantile.PREPROCESSED.txt.Kruskal-Wallis.Population.STATS_RESULTS.txt )
# ( combined_FPKM.txt.quantile.PREPROCESSED.txt.Kruskal-Wallis.Performer.STATS_RESULTS.txt )


# (2.g) Heatmap dendrogram (just on a statistically subselected portions of the data)
# EXAMPLES TO RECREATE RESULTS:
heatmap_dendrogram(file_in=population_stats_subselected, metadata_table=FPKM_metadata, metadata_column=1) # population subselected data
heatmap_dendrogram(file_in=performer_stats_subselected, metadata_table=FPKM_metadata, metadata_column=2) # "performer" subselected data
# NOTES:
# This function has to run once for each metadata column considered. It useses the values in the selected metadata column to automatically
# color the samples (legend and color bar at the top of the generated figure). Each time it is run, this function creates 2 files
# The png image as well as copy of the input data reordered exactly as it appears in the png (useful for finding data labels when 
# the function is applied to large matrices. The files generated from above will be:
# ( combined_FPKM.txt.quantile.PREPROCESSED.txt.population.p_lte_e-4.txt.HD.png )        # image
# ( combined_FPKM.txt.quantile.PREPROCESSED.txt.population.p_lte_e-4.txt.HD_sorted.txt ) # resorted input
# ( combined_FPKM.txt.quantile.PREPROCESSED.txt.performer.p_lte_e-4.txt.HD.png )         # image
# ( combined_FPKM.txt.quantile.PREPROCESSED.txt.performer.p_lte_e-4.txt.HD_sorted.txt )  # resorted input


# (3) Analyze the docker ouputs to produce outputs like those useed above

# All of the analyses above start with the file combined_FPKM.txt.
# This is simply a table created from the FPKM values generated from Stuti's docker.
# The only input it requires is a file that contains a list of folders created by Stuti's Docker
# I have include an example that will work with the examples on your test VM

# Create table from docker outputs

# (3.a) Move to the directory that contains the output directories produced by Stuti's Docker tool:
setwd("/opt/gdc/")

# (3.b) Place name of the list file in a variable
paths_list = "~/git/CDIS_GEUVADIS_analysis/GEUVADIS_demo_data/test_paths_list.txt" # each path is the path to an output directory produced from Stuti's docker -
                                                                                   # this list references the 4 example outputs in /opt/gdc/ on the 202.169.169.33 VM
# (3.c) Source two functions from this repository
# source scripts from this repository
source("~/git/CDIS_GEUVADIS_analysis/readIDs.r")
source("~/git/CDIS_GEUVADIS_analysis/combine_docker_outputs.r")

# (3.d) Combine the FPKM values from all samples listed in the paths_list file (creates file formatted like combined_FPKM.txt, with just the 4 samples in the list)
# EXAMPLES TO RECREATE RESULTS - in this case, a subset of the results, 4/41 samples with results on your VM:
combine_docker_outputs(paths_file=paths_list, my_dataype="FPKM", output_prefix="my_data")
# NOTES:
# assume that you start in 
#   /PATH/
# and that all of the file paths follow this pattern:
#   /PATH/ERRXXXXXX/star_2_pass/genes.fpkm_tracking
# XXXXXX is unique, thes rest is not so use the ERR portion of the path to name the data
# and that the ids file looks like this
#   /ERR1234/star_2_pass/genes.fpkm_tracking
#   /ERR5678/star_2_pass/genes.fpkm_tracking


combine_docker_outputs(paths_file=paths_list, my_dataype="FPKM", output_prefix="my_data", debug=TRUE)

