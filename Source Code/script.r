# 'Cloudant' Source Node v1.0 for IBM SPSS Modeler

# Uses package 'R4CouchDB' 
# Dependencies : packages bitops, RCurl, RJSONIO
#Uses package 'plyr' : http://cran.r-project.org/web/packages/plyr/index.html
# Node developer: Antoine SACHET - IBM Extreme Blue 2014
# Description: This node allows you to import data from a cloudant/couchDB database into SPSS.

packages <- function(x){
  x <- as.character(match.call()[[2]])
  if (!require(x,character.only=TRUE)){
    install.packages(pkgs=x,repos="http://cran.r-project.org")
    require(x,character.only=TRUE)
  }
}

#installing plyr for rbind.list and llply, R4CouchDB now on CRAN
packages("plyr")
packages("R4CouchDB")

library(RCurl)
# Set SSL certs globally - issues with CA if this not set
options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")))

### USER INPUT 
### connection settings
serverName <- "%%host%%"
port <- %%port%%
  DBName="%%database%%"

uname <- "%%username%%"
pwd <- "%%password%%"

### advanced connection settings
operation <- %%operation%% # "dump" or "getDoc" or "queryView"
  filter_design_docs <- %%filter_design_docs%%    # filter_design_docs can be '&endkey="_"' (if checked) or an empty string
  
  prot <- %%protocol%%
  ssl.verifypeer <- ! %%bypass.ssl.verifypeer%%
  
  ### initializing cdb object
  cdb <- cdbIni(serverName=serverName, port=port, DBName=DBName, uname=uname, pwd=pwd, prot=prot)
# configuring ans saving Curl Options
opts <- cdb$opts(cdb) #cdb$opts returns a CURLoptions with the user credentials
opts <- c(opts, ssl.verifypeer=FALSE) #adding the "don't verify peer" option
cdb$curl <- getCurlHandle( .opts=opts) #building the Curlhandle object used by getURL

### now we are ready to query the database

### These functions are used to put the JSON data into a data.frame
# Takes a list with sublists and returns a list without sublists (they were turned into string)
flattenList <- function(list) {
  llply(list, function(y) if(typeof(y)=="list") toString(y) else y)
}

### There is necessarily a loss of structure : the data is "flattened" to fit in a table
### Only simple fields are easily accessible (without parsing) after this process
### To access complex fields, one should query the database for these fields only

### Performing the correct operation
if (operation == "dump") {
  # retrieving all the db
  # this accesses all_docs and retrieves their content (include_docs=true)
  # and filtering out the design docs (endkey='_')
  
  cdb$id <- paste('_all_docs?include_docs=true', filter_design_docs, sep="")
  cdb <- cdbGetDoc(cdb)
  ### turning the json received into a data.frame, with NAs for missing values
  modelerData <- # rbind.fill binds a list of dataframes, generating NAs if sizes don't match
    rbind.fill( 
      # this returns a list of one line dataframes
      llply(cdb$res[[3]], function(x) data.frame(flattenList(x$doc)))
    )
}else if (operation== "getDoc") {
  # retrieving one doc
  doc_id <- "%%doc_id%%"
  if(nchar(doc_id)==0) 
    stop("To query a single document, you must provide a document id")
  cdb$id <- doc_id
  cdb <- cdbGetDoc(cdb)
  modelerData <- data.frame(cdb$res)
} else if (operation == "queryView") {
  # executing a view
  cdb$design <- "%%design_doc%%"
  cdb$view <- "%%view%%"
  cdb$queryParams <- "%%query_params%%"
  cdb <- cdbGetView(cdb)
  modelerData <- rbind.fill(
    llply(cdb$res[[3]], function(x) data.frame(id=x$id, key=x$key, as.vector(flattenList(x$value))))
  )
}

#modelerData now contains the result of the operation

### This function automatically generates the dataModel
getMetaData <- function (data) {
  if(is.null(dim(data)))
    stop("Invalid data received: not a data.frame")
  if (dim(data)[1]<=0) {
    print("Warning : modelerData has no line, all fieldStorage fields set to strings")
    getStorage <- function(x){return("string")}
  } else {
    getStorage <- function(x) {
      x <- unlist(x)
      res <- NULL
      #if x is a factor, typeof will return 'integer' so we handle this case first
      if(is.factor(x)) {
        res <- "string"
      } else {
        res <- switch(typeof(x),
                      integer="integer",
                      double = "real",
                      "string")
      }
      return (res)
    }
  }
  col = vector("list", dim(data)[2])
  for (i in 1:dim(data)[2]) {
    col[[i]] <- c(fieldName=names(data[i]),
                  fieldLabel="",
                  fieldStorage=getStorage(data[i]),
                  fieldMeasure="",
                  fieldFormat="",
                  fieldRole="")
  }
  mdm<-do.call(cbind,col)
  mdm<-data.frame(mdm)
  return(mdm)
}

### Generating data model
modelerDataModel <- getMetaData(modelerData)

### Informative prints
print(head(modelerData))
print(modelerDataModel)
