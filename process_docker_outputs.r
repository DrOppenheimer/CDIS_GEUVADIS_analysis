# R "workflow" to process the outputs from the the docker file processing to gnerate visualizations

# assume that you start in 
#   /PATH/
# and that all of the file paths follow this pattern:
#   /PATH/ERRXXXXXX/star_2_pass/genes.fpkm_tracking
# XXXXXX is unique, thes rest is not so use the ERR portion of the path to name the data
# and that the ids file looks like this
#   /ERR1234/star_2_pass/genes.fpkm_tracking
#   /ERR5678/star_2_pass/genes.fpkm_tracking
#   ...

############################################################################################################################
############################################################################################################################
### FIST IMPORT PACKAGES AND FUNCTIONS
############################################################################################################################
############################################################################################################################

#process_docker_outputs <- function(list_file, my_dataype="FPKM", paths_file="stuti_results.done_11-10-15", load_prereqs=FALSE){ 
combine_docker_outputs <- function(list_file, my_dataype="FPKM", paths_file="test_list", load_prereqs=FALSE){ 
    
  my_ids <- readIDs(paths_file)  
  
  if( load_prereqs==TRUE ){
  
    # install and soure R packages
    install.packages(c("RCurl","devtools", "RJSONIO"))
    install_github(repo="MG-RAST/matR", dependencies=FALSE, ref="early-release")
    library(RCurl, devtools, RJSONIO, matR)
    dependencies()
    ############################################################################################################################
    # Source this function to donwload accessory functions - in this example they are all hosted on github
    source_https <- function(url, ...) {
      require(RCurl)
      sapply(c(url, ...), function(u) {
        eval(parse(text = getURL(u, followlocation = TRUE, cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))), envir = .GlobalEnv)
      })
    }
    ############################################################################################################################
    # Source functions hosted on github
    # functionto import ids
    source_https("https://raw.githubusercontent.com/DrOppenheimer/CDIS_GEUVADIS_analysis/master/readIDs.r")

    # simple data import function
    source_https("https://raw.githubusercontent.com/DrOppenheimer/CDIS_GEUVADIS_analysis/master/import_data.r")

    # simple data export fuction
    source_https("https://raw.githubusercontent.com/DrOppenheimer/CDIS_GEUVADIS_analysis/master/export_data.r")

    # function for metadata and data import that supports numeric and strings in one file
    source_https("https://raw.githubusercontent.com/DrOppenheimer/CDIS_GEUVADIS_analysis/master/import_metadata.r")

    #function to normalize the data
    source_https("https://raw.githubusercontent.com/DrOppenheimer/CDIS_GEUVADIS_analysis/blob/master/preprocessing_tool.r")

    # function to calculate raw (flat file) PCoA   
    source_https("https://raw.githubusercontent.com/DrOppenheimer/CDIS_GEUVADIS_analysis/master/plot_pco.r")

    # function to render calculated PCoA, painted with metadata
    source_https("https://raw.githubusercontent.com/DrOppenheimer/CDIS_GEUVADIS_analysis/master/render_calculated_pcoa.r")

    # function to generate heatmap-dendrograms
    source_https("https://raw.githubusercontent.com/DrOppenheimer/CDIS_GEUVADIS_analysis/master/heatmap_dendrogram.r")

    # funtionto perform statistical tests
    source_https("")

  }
  ############################################################################################################################
  ############################################################################################################################

  ############################################################################################################################
  ############################################################################################################################
  ### IMPORT DATA INTO AN R MATRIX
  ############################################################################################################################
  ############################################################################################################################

  # NOTES
  #   - transfer
  #   - scripts(create CDIS repo)
  #   - do it (use first part of path)

  # dev dir with sample data
  # setwd("~/Documents/Projects/Taiwan")
  # setwd("/Users/kevin/Documents/Projects/Taiwan/sample_data")


  # select the type of data to compile from the results
  #my_dataype ="FPKM"
  # other possibilities are
  # tracking_id
  # class_code
  # nearest_ref_id
  # gene_id
  # gene_short_name
  # tss_id
  # locus
  # length
  # coverage
  # FPKM
  # FPKM_conf_lo
  # FPKM_conf_hi
  # FPKM_status

  # names for log and output
  log_file <- paste("R_compile.", my_dataype, ".log.txt", sep="")
  output_name <- paste("combined_", my_dataype, ".txt", sep ="")

  # import list of ids
  # my_ids <- readIDs("stuti_results.done_11-10-15")
  # my_ids <- readIDs("test_list")

  # create matrix to hold data and vector to hold colnames
  FPKM_matrix <- matrix()
  FPKM_colnames <- vector(mode="character")
  debug=TRUE

  for (i in 1:length(my_ids)){
  
    if(debug==TRUE){print(paste("made it here (0)"))}

    if(debug==TRUE){print(paste(my_ids[i]))}  
  
    if( file.exists(paste(".", my_ids[i], sep="")) != FALSE ){
  
      my_data_temp <- import_metadata(paste(".", my_ids[i], sep=""))
  
      if(debug==TRUE){print(paste(".", my_ids[i], sep=""))}
      
      # Add name of current file to the colnames vector
      split_path_string <- unlist(strsplit(my_ids[i], split="/"))
      my_data_name <- split_path_string[2]
  
      my_rownames <- row.names(my_data_temp) # NOT HUMAN READABLE
      #my_rownames <- my_data_temp[,"gene_short_name"] # NOT UNIQUE
      # COMPROMISE - UNIQUE AND CAN GET READABLE NAME EASILY
      unique_rownames <- vector(mode="character")
      for ( j in 1:length(my_rownames) ){
        unique_rownames <- c(unique_rownames, paste(my_data_temp[j,"gene_short_name"], "_", my_rownames[j], sep=""))
      }
 
      # replace original rownames with concatenated ones   
      row.names(my_data_temp) <- unique_rownames
    
      if(debug==TRUE){print(paste("made it here (1)"))}
  
      if( i==1 ){ # import first sample data
        FPKM_matrix <- my_data_temp[ , my_dataype, drop=FALSE] # matrix(my_data_temp[,my_dataype])
        row.names(FPKM_matrix) <- unique_rownames 
        FPKM_colnames <- my_data_name
        if(debug==TRUE){print(paste("made it here (2)"))}
        if(debug==TRUE){print(paste("i: ", i))}
        #cat("World",file="outfile.txt",append=TRUE)
        cat(paste(my_ids[i], "PROCESSED"), sep="\n", file=log_file, append=FALSE)
      }else{ # import all other datasets - subloop to take care of the last
        # Import the data into an R matrix
        if(debug==TRUE){print(paste("made it here (3)"))}
        #FPKM_matrix <- matrix(my_data_temp[,my_dataype])
        #row.names(FPKM_matrix) <- unique_rownames
        FPKM_matrix <- merge(FPKM_matrix, my_data_temp[, my_dataype], by="row.names", all=TRUE) # This does not handle metadata yet
        rownames(FPKM_matrix) <- FPKM_matrix$Row.names
        FPKM_matrix$Row.names <- NULL
        FPKM_colnames <- c(FPKM_colnames, my_data_name)
        if(debug==TRUE){print(paste("col_names:", FPKM_colnames))}
        # subloop to add the column names when on the last sample (make this a sub)
        cat(paste(my_ids[i], "PROCESSED"), sep="\n", file=log_file, append=TRUE)
        if( i == length(my_ids) ){ # take care of the last sample (add column headers)
          if(debug==TRUE){print(paste("made it here (4)"))}
          if(debug==TRUE){print(paste("col_names:", FPKM_colnames))}
          # add column names
          colnames(FPKM_matrix) <- FPKM_colnames
          # replace introduced NAs with 0
          FPKM_matrix[is.na(FPKM_matrix)] <- 0
          # order data by row name
          ordered_rownames <- order(rownames(FPKM_matrix))
          FPKM_matrix <- FPKM_matrix[ordered_rownames,]
          # export to flat file
          export_data(FPKM_matrix, output_name)
          # return data object here
        }
      }

    }else{
    
      cat(paste(my_ids[i], "DOES NOT EXIST"), sep="\n", file=log_file, append=TRUE)
      # subloop to add the column names when on the last sample (make this a sub)
      if( i == length(my_ids) ){ # take care of the last sample (add column headers)
        # add column names
        colnames(FPKM_matrix) <- FPKM_colnames
        # replace introduced NAs with 0
        FPKM_matrix[is.na(FPKM_matrix)] <- 0
        # order data by row name
        ordered_rownames <- order(rownames(FPKM_matrix))
        FPKM_matrix <- FPKM_matrix[ordered_rownames,]
        # export to flat file
        export_data(FPKM_matrix, output_name)
       # return data object here
      }
    
    }
  
  }

}
############################################################################################################################
############################################################################################################################
### PERFORM ANALYSES
############################################################################################################################
############################################################################################################################
analyze_combined_output <- function(data_file="", metadata_file=""){

  # norm & look at pre and post normalization distributios (select appropriate stat test for later)
  

  # raw PCoA
  plot_pco("")

  # render PCoA with metadata (population and lab) (all data)
  
  
  # heatmap dendrogram (all data)
  
  
  # statistical test
  
  
  # viz from stat subselecteddata
  
  
}

############################################################################################################################
############################################################################################################################






############################################################################################################################
# simple data import function
import_data <- function(file_name)
{
  data.matrix(read.table(file_name, row.names=1, header=TRUE, sep="\t", comment.char="", quote="", check.names=FALSE))
}
############################################################################################################################

############################################################################################################################
# simple data export function
export_data <- function(data_object, file_name){
  write.table(data_object, file=file_name, sep="\t", col.names = NA, row.names = TRUE, quote = FALSE, eol="\n")
}
############################################################################################################################

############################################################################################################################
# a function to download metadata from MG-RAST
source_https("https://raw.githubusercontent.com/DrOppenheimer/matR-apps/master/get_metadata.R")
############################################################################################################################

############################################################################################################################
# a function to import metadata that has already been downloaded and written to a flat file (using get_metadata and export_data)
source_https("https://raw.githubusercontent.com/DrOppenheimer/matR-apps/master/import_metadata.r")
############################################################################################################################

############################################################################################################################
# function to produce raw pco (performs the calculations and produces a flat file output but does not create images/vizualizations)
# PCoAs can be calculated from raw or normalized annotation abundance data with a variety of distance/dissimilarity metrics.
source_https("https://raw.githubusercontent.com/MG-RAST/AMETHST/master/plot_pco.r")
############################################################################################################################

############################################################################################################################
# Function to perform filtering (removal of singletons and extreme low abundance entries) and normalization (with a number
# different methods including log transformation and standardization, negative bionomial based variance stabiliation(with
# the DESeq package), and quantile normalization )
source_https("https://raw.githubusercontent.com/DrOppenheimer/matR-apps/master/normalize_fun.2-27-14/norm_redux.v5.r")
############################################################################################################################

############################################################################################################################
# function to perform calculations for and to generate heatmaps from raw or normalized annotation abundance data.
# The function can also use metadata to annotate the image automatically
source_https("https://raw.githubusercontent.com/DrOppenheimer/matR-apps/master/heatmap_fun/heatmap_dendrogram.from_file.3-18-14.r")
############################################################################################################################

############################################################################################################################
# function to read IDs from a list file - one file listed per line
readIDs <- function (filename, ...) 
{
  y <- read.table(filename, colClasses = "character", sep = "\t", 
                  ...)
  if (nrow(y) > 1) {
    if (ncol(y) > 1) {
      if (ncol(y) > 2) {
        warning("Your list has more than two columns, only the first two are used")
      }
      res <- as.character(y[, 1])
      names(res) <- as.character(y[, 2])
      res <- res[order(res)]
      res
    }
    else {
      res <- as.character(y[, 1])
      res <- res[order(res)]
      res
    }
  }
  else {
    warning("There was just one id in your list?")
    res <- unlist(y[1, ], use.names = FALSE)
    res
  }
}
############################################################################################################################


# sort the data (COLUMNWISE) by id
sample_names <- order(colnames(input_data))
input_data <- input_data[,sample_names]
  
  
  
  
  
  
  
  
  
      
    
  
  my_data <- merge(my_data, data.matrix(next_batch$count), by="row.names", all=TRUE) # This does not handle metadata yet
  rownames(my_data) <- my_data$Row.names
  my_data$Row.names <- NULL
  
  
  
  first_batch <- process_batch(batch_count, batch_start, batch_end, mgid_list, my_log, my_entry, my_annot, my_source, my_level, sleep_int, debug, num_batch, batch_remainder)
  my_data <- data.matrix(first_batch$count)
  
  
  
  
}





my_data_name <- character()
for(i in 1:length(split_path_string) ){
  if ( grep(pattern="ERR", split_path_string[i])  ){
    my_data_name <- split_path_string[i]
  }
}


# Read in the data files and create a matrix of the abundance values


# 





                                        # Function to import data from an individual results file




