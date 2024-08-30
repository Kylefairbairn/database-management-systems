
installPackages <- function() {
  
  # Name: installPackages
  # Description: Installs Packages
  # Parameters: N/A
  # Returns: N/A
  
  # Packages used for Practicum II 
  packages <- c("RMySQL","RSQLite", "DBI", "lubridate", "XML", "xml2")
  
  # Install packages not yet installed
  installed_packages <- packages %in% rownames(installed.packages())
  if (any(installed_packages == FALSE)) {
    install.packages(packages[!installed_packages])
  }
  
  # Packages loading
  invisible(lapply(packages, library, character.only = TRUE))
  
}

connectToLocalDb<- function(){
  
  # Name: connectToLocalDb
  # Description: Connects to DB
  # Parameters: N/A
  # Returns: N/A
  
  mydb <- dbConnect(RSQLite::SQLite(), dbname = "sales.db")
  return (mydb)
}

dropAllTables <- function () {
  
  # Name: dropAllTables
  # Description: Drops all tables in DB
  # Parameters: N/A
  # Returns: N/A
  
  dropSalesTxn <- "DROP TABLE IF EXISTS SalesTxn;"
  dropProduct <- "DROP TABLE IF EXISTS Product;"
  dropCountry <- "DROP TABLE IF EXISTS Country;"
  dropCustomers <- "DROP TABLE IF EXISTS Customer;"
  dropSalesReps <- "DROP TABLE IF EXISTS SalesReps;"
  dropTerritory <- "DROP TABLE IF EXISTS Territory;"
  
  dbExecute(mydb,dropSalesTxn)
  dbExecute(mydb,dropProduct)
  dbExecute(mydb,dropCountry)
  dbExecute(mydb,dropCustomers)
  dbExecute(mydb,dropSalesReps)
  dbExecute(mydb,dropTerritory)
  
}

createAllTables <- function() {
  
  # Name: createAllTables
  # Description: Creates all tables in DB
  # Parameters: N/A
  # Returns: N/A
  
  createTerritory <- "
    CREATE TABLE IF NOT EXISTS Territory(
      tid INTEGER PRIMARY KEY AUTOINCREMENT,
      territory TEXT
    );
  "
  
  createSalesReps <- "
    CREATE TABLE IF NOT EXISTS SalesReps(
      sid INTEGER PRIMARY KEY NOT NULL,
      firstname TEXT NOT NULL,
      lastname TEXT NOT NULL,
      territory INTEGER NOT NULL,
      FOREIGN KEY (territory) REFERENCES Territory(tid)
    );
  "
  
  createProduct <- "
    CREATE TABLE IF NOT EXISTS Product(
      pid INTEGER PRIMARY KEY AUTOINCREMENT,
      productName TEXT
    );
  "
  
  createCountry <- "
    CREATE TABLE IF NOT EXISTS Country(
      cid INTEGER PRIMARY KEY AUTOINCREMENT,
      countryName TEXT
    );
  "
  
  createCustomer <- "
    CREATE TABLE IF NOT EXISTS Customer(
      customerId INTEGER PRIMARY KEY AUTOINCREMENT,
      customerName TEXT
    );
  "
  
  createSalesTxn <- "
    CREATE TABLE IF NOT EXISTS SalesTxn(
      saleId INTEGER PRIMARY KEY AUTOINCREMENT,
      date DATE,
      customer INTEGER NOT NULL,
      product INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      amount INTEGER NOT NULL,
      country INTEGER NOT NULL,
      salesRep INTEGER NOT NULL, 
      FOREIGN KEY (customer) REFERENCES Customer(customerId),
      FOREIGN KEY (product) REFERENCES Product(pid),
      FOREIGN KEY (country) REFERENCES Country(cid),
      FOREIGN KEY (salesRep) REFERENCES SalesReps(sid)
    );
"
  
  dbExecute(mydb, createTerritory)
  dbExecute(mydb, createSalesReps)
  dbExecute(mydb, createProduct)
  dbExecute(mydb, createCountry)
  dbExecute(mydb, createCustomer)
  dbExecute(mydb, createSalesTxn)
}

process_pharmaReps_xml <- function(xml_data) {

  # Name: process_pharmaReps_xml
  # Description: Extracts info to create tables based on reps xml
  # Parameters: xml_data: .xml file
  # Returns: N/A 

  doc <- read_xml(xml_data)
  
  # Use XPath to select all rep elements
  reps <- xml_find_all(doc, ".//rep")
  
  # store the extracted data
  rID_c <- character()
  firstname_c <- character()
  lastname_c <- character()
  territory_c <- character()
  
  
  # Loop through each rep element and extract the attributes
  for (rep in reps) {
    rID <- c(rID_c, xml_attr(rep, "rID"))
    firstname <- c(firstname_c, xml_text(xml_find_first(rep, "firstName")))
    lastname <- c(lastname_c, xml_text(xml_find_first(rep, "lastName")))
    territory <- c(territory_c, xml_text(xml_find_first(rep, "territory")))
    tid <- checkTerritoryUniqueness(territory)
    createRep(rID,firstname,lastname,tid)
  }
  
}

createRep <- function(rID,firstname,lastname,tid){
  
  # Name: createRep
  # Description: Creates tables based on reps xml
  # Parameters: rID: the rep pk, firsname: TEXT, lastname: TEXT, tid: FK (Terriority)
  # Returns: N/A 
  
  # strip the r in xml
  formattedRId <- gsub("r", "", rID)
  formattedRId <- as.integer(formattedRId)
  
  result <- dbGetQuery(mydb, sprintf("SELECT sid FROM SalesReps WHERE sid = '%d'", formattedRId))
  
  if (nrow(result) == 0 && !is.null(tid)) {
    
    dbExecute(mydb, sprintf("INSERT INTO SalesReps (sid, firstname, lastname, territory) VALUES ('%d', '%s', '%s', '%d')",
                            formattedRId, firstname, lastname, tid))
  }
  
}

checkTerritoryUniqueness <- function(territory) {
  
  # Name: checkTerritoryUniqueness
  # Description: Helper function to create territory and ensures no dups for terriorty 
  # Parameters: territory: the name
  # Returns: PK of territory
  
  # Check if territory exists in the table
  query <- sprintf("SELECT tid FROM Territory WHERE territory = '%s'", territory)
  result <- dbGetQuery(mydb, query)
  
  if (nrow(result) == 0) {
    # Territory does not exist, create a new territory record
    query <- sprintf("INSERT INTO Territory (territory) VALUES ('%s')", territory)
    dbExecute(mydb, query)
    
    # Retrieve the new territory's tid
    query <- sprintf("SELECT tid FROM Territory WHERE territory = '%s'", territory)
    result <- dbGetQuery(mydb, query)
  } 
  
  return(as.integer(result$tid))
  
}

process_pharmaSales <- function(xmlFile) {
  
  # Name: process_pharmaSales
  # Description: Extracts data from xml and creates table
  # Parameters: territory: xmlFile: .xml file 
  # Returns: N/A
  
  doc <- read_xml(xmlFile)
  
  sales <- xml_find_all(doc, ".//txn")
  
  txnID <- character()
  date <- character()
  cust <- character()
  prod <- character()
  qty <- character()
  amount <- character()
  country <- character()
  repID <-character()
  
  for (sale in sales) {
    saleDate <- c(date, xml_text(xml_find_first(sale, "date")))
    saleCust <- c(cust, xml_text(xml_find_first(sale, "cust")))
    saleProd <- c(prod, xml_text(xml_find_first(sale, "prod")))
    saleQty <- c(qty, xml_text(xml_find_first(sale, "qty")))
    saleAmount <- c(amount, xml_text(xml_find_first(sale, "amount")))
    saleCountry <- c(country, xml_text(xml_find_first(sale, "country")))
    saleRepID <- c(repID, xml_text(xml_find_first(sale, "repID")))

  
    customerId <- createCustomerTable(saleCust)
    productionId <- createProductionTable(saleProd)
    countryId <- createCountryTable(saleCountry)
    salesRep <- findSalesRepId(saleRepID)
    
    #formatted_date <- format(as.Date(saleDate, format = "%m/%d/%Y"), "%m/%d/%Y")
    formatted_date <- format(as.Date(saleDate, format = "%m/%d/%Y"), "%Y-%m-%d")
    
   createSalesTxnTable(formatted_date,customerId,productionId,saleQty,saleAmount,countryId,saleRepID) 
  }
  
}

createSalesTxnTable <- function(formatted_date, customerId, productionId, saleQty, saleAmount, countryId, saleRepID) {
  
  # Name: createSalesTxnTable
  # Description: Inserts into SalesTxn
  # Parameters: SalesTxn Schema
  # Returns: N/A 
  
  query <- sprintf("INSERT INTO SalesTxn (date, customer, product, quantity, amount, country, salesRep) VALUES ('%s', %d, %d, %d, %d, %d, %d)",
                   formatted_date, as.integer(customerId), as.integer(productionId), as.integer(saleQty), as.integer(saleAmount),
                   as.integer(countryId), as.integer(saleRepID))
  dbExecute(mydb, query)
}

findSalesRepId <- function(saleRepId) {
  # Name: findSalesRepId
  # Description: finds sales rep id
  # Parameters: saleRepId: pk
  # Returns: pk
  
  # Check if Find Sale Rep exists in the table
  query <- sprintf("SELECT sid FROM SalesReps WHERE sid = '%s'", saleRepId)
  result <- dbGetQuery(mydb, query)
  return (as.integer(result))
}

createCountryTable <- function(saleCountry) {
  
  # Name: createCountryTable
  # Description: finds country
  # Parameters: saleCountry: country
  # Returns: pk
  
  query <- sprintf("SELECT countryName FROM Country WHERE countryName = '%s'", saleCountry)
  result <- dbGetQuery(mydb, query)

  if (nrow(result) == 0) {
    # Country does not exist, create a new Country record
    query <- sprintf("INSERT INTO Country (countryName) VALUES ('%s')", saleCountry)
    dbExecute(mydb, query)
    
    # Retrieve the new Customer customerID
    query <- sprintf("SELECT cid FROM Country WHERE countryName = '%s'", saleCountry)
    result <- dbGetQuery(mydb, query)
    return(as.integer(result$cid))
  
  } else {
    query <- sprintf("SELECT cid FROM Country WHERE countryName = '%s'", saleCountry)
    result <- dbGetQuery(mydb, query)
    return(as.integer(result$cid))
  }
  

}

createProductionTable <- function(saleProd){
  
  # Name: createProductionTable
  # Description: creates Production table
  # Parameters: saleProd: TEXT
  # Returns: pk
  
  # Check if product exists in the table
  query <- sprintf("SELECT productName FROM Product WHERE productName = '%s'", saleProd)
  result <- dbGetQuery(mydb, query)
  
  if (nrow(result) == 0) {
    # product does not exist, create a new product record
    query <- sprintf("INSERT INTO Product (productName) VALUES ('%s')", saleProd)
    dbExecute(mydb, query)
    
    # Retrieve the new Product pid
    query <- sprintf("SELECT pid FROM Product WHERE productName = '%s'", saleProd)
    result <- dbGetQuery(mydb, query)
    # Return the primary key as an integer
    return(as.integer(result$pid))    
  } else {
    query <- sprintf("SELECT pid FROM Product WHERE productName = '%s'", saleProd)
    result <- dbGetQuery(mydb, query)
    # Return the primary key as an integer
    return(as.integer(result$pid))  
  }


}

createCustomerTable <- function(saleCust) {
  
  # Name: createCustomerTable
  # Description: creates Customer table
  # Parameters: saleCust: TEXT
  # Returns: pk
  
  # Check if customer exists in the table
  query <- sprintf("SELECT customerName FROM Customer WHERE customerName = '%s'", saleCust)
  result <- dbGetQuery(mydb, query)
  
  if (nrow(result) == 0) {
    # customer does not exist, create a new customer record
    query <- sprintf("INSERT INTO Customer (customerName) VALUES ('%s')", saleCust)
    dbExecute(mydb, query)
    
    # Retrieve the new Customer customerID
    query <- sprintf("SELECT customerId FROM Customer WHERE customerName = '%s'", saleCust)
    result <- dbGetQuery(mydb, query)
    return(as.integer(result$customerId))
  
  } else {
    query <- sprintf("SELECT customerId FROM Customer WHERE customerName = '%s'", saleCust)
    result <- dbGetQuery(mydb, query)
    return(as.integer(result$customerId))
  }
}

driverToExtract <- function() {
  
  # Name: driverToExtract
  # Description: driver to process xml file based on the basename
  # Parameters: N/A
  # Returns: N/A
  
  xmlFolder <- "txn-xml"
  xmlFiles <- list.files(path = xmlFolder, pattern = "\\.xml$", full.names = TRUE)
  
  for (xmlFile in xmlFiles) {
    # Parse the XML file
    xmlData <- xmlParse(xmlFile)
    
    if (basename(xmlFile) == "pharmaReps.xml") {
      process_pharmaReps_xml(xmlFile)
    } else if (grepl("pharmaSalesTxn", basename(xmlFile))) {
      process_pharmaSales(xmlFile)
      
    } else {
      print("No matching file found.")
    }
    
  }
}

showFirstTenRecordsSalesTxn <- function() {

  query <- "SELECT * FROM SalesTxn LIMIT 10"
  data <- dbGetQuery(mydb, query)
  result <- dbGetQuery(mydb, query)
  print(result)
  
}

# install packages
installPackages()

# connect to db 
mydb <- connectToLocalDb()

# Create tables 
dropAllTables()
createAllTables()

# Extract tables 
driverToExtract()

# show SalesTxn table 10 records
showFirstTenRecordsSalesTxn()


dbDisconnect(mydb)
