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

source("~/git/GEUVADIS_demo_data/install_r_prereqs.r")
install_r_prereqs()

### (2) Produce visualizations from precomputed results

# place file names into varibales
combined_FPKM <- "~/git/GEUVADIS_demo_data/combined_FPKM.txt"
combined_FPKM_normalized <- "~/git/GEUVADIS_demo_data/combined_FPKM.txt.quantile.PREPROCESSED.txt"
FPKM_pcoa <- "~/git/GEUVADIS_demo_data/combined_FPKM.txt.quantile.PREPROCESSED.txt.euclidean.PCoA"
FPKM_metadata <- "~/git/GEUVADIS_demo_data/combined_FPKM_metadata.txt"
population_stats_subselected <- "~/git/GEUVADIS_demo_data/combined_FPKM.txt.quantile.PREPROCESSED.txt.population.p_lte_e-4.txt"
performer_stats_subselected <- "~/git/GEUVADIS_demo_data/combined_FPKM.txt.quantile.PREPROCESSED.txt.performer.p_lte_e-4.txt"

# source scripts from this repository
source("~/git/GEUVADIS_demo_data/import_data.r")
source("~/git/GEUVADIS_demo_data/export_data.r")
source("~/git/GEUVADIS_demo_data/import_metadata.r")
source("~/git/GEUVADIS_demo_data/preprocessing_tool.r")
source("~/git/GEUVADIS_demo_data/calculate_pco.r")
source("~/git/GEUVADIS_demo_data/render_calculated_pcoa.r")
source("~/git/GEUVADIS_demo_data/render_calculated_pcoa.r")
source("~/git/GEUVADIS_demo_data/heatmap_dendrogram.r")
source("~/git/GEUVADIS_demo_data/calc_stats.r")

# Normalize the data (quantile normalization)
preprocessing_tool(data_in=combined_FPKM, norm_method="quantile", produce_boxplots=TRUE)

# Calculate raw (flat file) PCoA
plot_pco(file_in=combined_FPKM_normalized)

# Render calculated PCoA with metadata -- this will generat two PCoA images, one for each column in the metadata file (population and "performer")
render_calcualted_pcoa(PCoA_in=FPKM_pcoa, metadata_table=FPKM_metadata, use_all_metadata_columns=TRUE, figure_symbol_cex=6,  vert_line="blank")

# Heatmap dendrogram (just on a statistically subselected portions of the data)
heatmap_dendrogram(file_in=population_stats_subselected, metadata_table=FPKM_metadata, metadata_column=1) # population subselected data
heatmap_dendrogram(file_in=performer_stats_subselected, metadata_table=FPKM_metadata, metadata_column=2) # "performer" subselected data

# Calculate stats
calc_stats(data_table=combined_FPKM_normalized, metadata_table=FPKM_metadata, metadata_column=1, stat_test="Kruskal-Wallis")
calc_stats(data_table=combined_FPKM_normalized, metadata_table=FPKM_metadata, metadata_column=2, stat_test="Kruskal-Wallis")


# (2) Analyze the docker ouputs to produce outputs like those useed above

# place file names into variables
paths_list = "~/git/GEUVADIS_demo_data/test_paths_list.txt" # each path is the path to an output directory produced from Stuti's docker -
                                                            # this list references the 4 example outputs in /opt/gdc/ on the 202.169.169.33 VM

# source scripts from this repository
source("~/git/GEUVADIS_demo_data/readIDs.r")
source("~/git/GEUVADIS_demo_data/process_docker_outputs.r")

# Combine the FPKM values from all samples listed in the paths_list file (creates file formatted like combined_FPKM.txt, with just the 4 samples in the list)
combine_docker_outputs(paths_file=paths_list, my_dataype="FPKM", output_prefix="my_data")
