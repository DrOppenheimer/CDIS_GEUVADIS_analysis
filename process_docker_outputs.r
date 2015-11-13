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

# install and source R packages and functions if option is true - must be done for the other functions to work

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


# process_docker_outputs <- function(list_file, my_dataype="FPKM", paths_file="stuti_results.done_11-10-15", load_prereqs=FALSE){ 
combine_docker_outputs <- function(paths_file="test_list", my_dataype="FPKM", load_prereqs=FALSE, debug=FALSE){

    # option to load prereqs
    if( load_prereqs==TRUE ){
        source("~/git/install_r_prereqs.r")
        install_r_prereqs()
    }

    my_ids <- readIDs(paths_file)  
    
    # names for log and output
    log_file <- paste("R_compile.", my_dataype, ".log.txt", sep="")
    output_name <- paste(output_prefix, ".combined_", my_dataype, ".txt", sep ="")

    # import list of ids
    # my_ids <- readIDs("stuti_results.done_11-10-15")
    # my_ids <- readIDs("test_list")

    # create matrix to hold data and vector to hold colnames
    FPKM_matrix <- matrix()
    FPKM_colnames <- vector(mode="character")
  
    for (i in 1:length(my_ids)){
  
        if(debug==TRUE){print(paste("made it here (0)"))}

        if(debug==TRUE){print(paste(my_ids[i]))}  
  
        if( file.exists(paste(".", my_ids[i], sep="")) != FALSE ){
            if(debug==TRUE){print(paste("FILE_STATUS: ", file.exists(paste(".", my_ids[i], sep=""))))}
            ### shell version of check:
            ### for i in `cat stuti_results.done_11-10-15`; do if [ -f ".$i" ];then echo ".$i exists"; fi; done
        
            my_data_temp <- import_metadata(paste(".", my_ids[i], sep=""))
            
            if(debug==TRUE){print(paste(".", my_ids[i], sep=""))}

            if(debug==TRUE){print(paste("made it here (0.1)"))}
            # Add name of current file to the colnames vector
            split_path_string <- unlist(strsplit(my_ids[i], split="/"))
            my_data_name <- split_path_string[2]

            if(debug==TRUE){print(paste("made it here (0.2)"))}
            my_rownames <- row.names(my_data_temp) # NOT HUMAN READABLE
            # my_rownames <- my_data_temp[,"gene_short_name"] # NOT UNIQUE
            # COMPROMISE - UNIQUE AND CAN GET READABLE NAME EASILY
            unique_rownames <- vector(mode="character")
            for ( j in 1:length(my_rownames) ){
                unique_rownames <- c(unique_rownames, paste(my_data_temp[j,"gene_short_name"], "_", my_rownames[j], sep=""))
            }

            if(debug==TRUE){print(paste("made it here (0.3)"))}
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



  
  
  
  
  
  