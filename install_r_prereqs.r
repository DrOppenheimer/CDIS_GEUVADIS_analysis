# install and soure R packages
install_r_prereqs <- function(
    install.packages("RCurl")
    install.packages("devtools")
    install.packages("RJSONIO")
    library(devtools)
    install_github(repo="MG-RAST/matR", dependencies=FALSE, ref="early-release")
    library(RCurl)
    library(RJSONIO)
    library(matR)
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
    source_https("https://raw.githubusercontent.com/DrOppenheimer/CDIS_GEUVADIS_analysis/master/calc_stats.r")

    # install and soure R packages
    install.packages("RCurl")
    install.packages("devtools")
    install.packages("RJSONIO")
    library(devtools)
    install_github(repo="MG-RAST/matR", dependencies=FALSE, ref="early-release")
    library(RCurl)
    library(RJSONIO)
    library(matR)
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
