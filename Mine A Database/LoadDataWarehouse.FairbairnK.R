

installPackages <- function() {
  
  # Name: installPackages
  # Description: Installs Packages
  # Parameters: N/A
  # Returns: N/A
  
  # Packages used for Practicum II 
  packages <- c("RMySQL","RSQLite", "DBI", "lubridate")
  
  # Install packages not yet installed
  installed_packages <- packages %in% rownames(installed.packages())
  if (any(installed_packages == FALSE)) {
    install.packages(packages[!installed_packages])
  }
  
  # Packages loading
  invisible(lapply(packages, library, character.only = TRUE))
  options(warn = 0)
  
}

connectToRemoteDb <- function () {
  
  # Name: connectToRemoteDb
  # Description: Connects to remote MySql server
  # Parameters: N/A
  # Returns: N/A
  
  db_name_fh <- "sql9637031"
  db_user_fh <- "sql9637031"
  db_host_fh <- "sql9.freemysqlhosting.net"
  db_pwd_fh <- "Password"
  db_port_fh <- 3306
  
  # 3. Connect to remote server database
  mydb.fh <-  dbConnect(RMySQL::MySQL(), user = db_user_fh, password = db_pwd_fh,
                        dbname = db_name_fh, host = db_host_fh, port = db_port_fh)
  
  mydb <- mydb.fh
  
  return(mydb)
}

connectToLocalDb <- function() {
  
  # Name: connectToLocalDb
  # Description: Connects to local SqlLite server
  # Parameters: N/A
  # Returns: N/A
  
  mydb <- dbConnect(RSQLite::SQLite(), dbname = "sales.db")
  return (mydb)
}

getQuery <- function(query, db) {
  
  # Name: getQuery
  # Description: Gets result of query and returns it
  # Parameters: query:String, db: database 
  # Returns: the result of query
  
  result <- dbGetQuery(db, query)
  return(result)
}

getProductNameById<- function(product_id) {
  
  # Name: getProductNameById
  # Description: Gets name of product by its PK
  # Parameters: product_id:String, 
  # Returns: the name of product
  
  query <- sprintf("SELECT productName FROM Product WHERE pid = %d", product_id)
  result <- dbGetQuery(sqlLiteDb, query)
  return (result$productName[1])
}

getTotalSalesByProductId <- function(product_id) {
  
  # Name: getTotalSalesByProductId
  # Description: Gets total sales by product PK
  # Parameters: product_id:String, 
  # Returns: total sales of a product
  
  query <- sprintf("SELECT SUM(quantity) AS total_sales FROM SalesTxn WHERE product = %d", product_id)
  result <- dbGetQuery(sqlLiteDb, query)
  return (result$total_sales[1])
}

getSalesYearsByProductId <- function(product_id) {
  
  # Name: getSalesYearsByProductId
  # Description: Gets the number of years the product was sold
  # Parameters: product_id:String, 
  # Returns: Gets the number of years a product was sold
  
  query <- sprintf("SELECT DISTINCT strftime('%%Y', date) AS year FROM SalesTxn WHERE product = %d", product_id)
  result <- dbGetQuery(sqlLiteDb, query)
  return(result$year)
}

getQuarterOneSalesProduct <-function(product_id,year) {
  
  # Name: getQuarterOneSalesProduct
  # Description: Gets number of sales for Q1
  # Parameters: product_id:String, year: the year  
  # Returns: Gets Q1 sales for a year
  

  start_date <- paste0(year, "-01-01")
  end_date <- paste0(year, "-03-31")
  
  query <- "
    SELECT
      SUM(quantity) AS total_sold
    FROM SalesTxn
    WHERE product = ? AND date BETWEEN ? AND ?;
  "
  result <- dbGetQuery(sqlLiteDb, query, params = c(product_id, start_date, end_date))
  return(result$total_sold[1]) 
}

getQuarterTwoSalesProduct <-function(product_id,year) {
  
  # Name: getQuarterTwoSalesProduct
  # Description: Gets number of sales for Q2
  # Parameters: product_id:String, year: the year  
  # Returns: Gets Q2 sales for a year
  
  start_date <- paste0(year, "-04-01")
  end_date <- paste0(year, "-06-03")
  
  query <- "
    SELECT
      SUM(quantity) AS total_sold
    FROM SalesTxn
    WHERE product = ? AND date BETWEEN ? AND ?;
  "
  result <- dbGetQuery(sqlLiteDb, query, params = c(product_id, start_date, end_date))
  return(result$total_sold[1]) 
}

getQuarterThreeSalesProduct <-function(product_id,year) {
  
  # Name: getQuarterThreeSalesProduct
  # Description: Gets number of sales for Q3
  # Parameters: product_id:String, year: the year  
  # Returns: Gets Q3 sales for a year
  
  start_date <- paste0(year, "-07-01")
  end_date <- paste0(year, "-09-30")

  query <- "
    SELECT
      SUM(quantity) AS total_sold
    FROM SalesTxn
    WHERE product = ? AND date BETWEEN ? AND ?;
  "
  result <- dbGetQuery(sqlLiteDb, query, params = c(product_id, start_date, end_date))
  return(result$total_sold[1]) 
}

getQuarterFourSalesProduct <-function(product_id,year) {
  
  # Name: getQuarterFourSalesProduct
  # Description: Gets number of sales for Q4
  # Parameters: product_id:String, year: the year  
  # Returns: Gets Q4 sales for a year
  
  start_date <- paste0(year, "-10-01")
  end_date <- paste0(year, "-12-31")
  
  query <- "
    SELECT
      SUM(quantity) AS total_sold
    FROM SalesTxn
    WHERE product = ? AND date BETWEEN ? AND ?;
  "
  result <- dbGetQuery(sqlLiteDb, query, params = c(product_id, start_date, end_date))
  return(result$total_sold[1]) 
}

dropProductFact <- function() {
  
  # Name: dropProductFact
  # Description: Drops Product Facts Table
  # Parameters: N/A 
  # Returns: N/A
  
  
  query <- "DROP TABLE IF EXISTS product_facts;"
  dbExecute(mysqlDb, query)
}

createProductFacts <- function() {
  
  # Name: createProductFacts
  # Description: Creates Product Facts Table
  # Parameters: N/A 
  # Returns: N/A
  
  createProductFacts <- "
CREATE TABLE IF NOT EXISTS product_facts (
    product_id INTEGER AUTO_INCREMENT PRIMARY KEY, 
    product_name VARCHAR(255),
    total_sold INT,
    year INT,
    quarterOneSold INT,
    quarterTwoSold INT,
    quarterThreeSold INT,
    quarterFourSold INT
);"
  
  dbExecute(mysqlDb, createProductFacts)
}

getDistinctYears <- function() {
  
  # Name: getDistinctYears
  # Description: Gets Distinct Years from Sales Data
  # Parameters: N/A 
  # Returns: Return the distinct years 
  
  years <- dbGetQuery(sqlLiteDb, "SELECT DISTINCT strftime('%Y', date) AS year FROM SalesTxn")
  return(years$year)
}

populateProductFacts <- function() {
  
  # Name: populateProductFacts
  # Description: Populate Product Facts Table 
  # Parameters: N/A 
  # Returns: N/A
  
  dropProductFact()
  createProductFacts()
  
  # Query distinct product IDs from the SalesTxn table
  product_ids <- dbGetQuery(sqlLiteDb, "SELECT DISTINCT product FROM SalesTxn")
  
  years <- getDistinctYears()
  
  for (year_val in years) {  
    # for every distinct year
    for (pid in product_ids$product) {
      # get the product and query for attributes 
      
      product_name_val <- getProductNameById(pid)
      total_sold_val <- getTotalSalesByProductId(pid)
      quarterOneSold_val <- getQuarterOneSalesProduct(pid, year_val)
      quarterTwoSold_val <- getQuarterTwoSalesProduct(pid, year_val)
      quarterThreeSold_val <- getQuarterThreeSalesProduct(pid, year_val)
      quarterFourSold_val <- getQuarterFourSalesProduct(pid, year_val)
      
      product_facts_data <- data.frame(
        product_name = product_name_val,
        total_sold = total_sold_val,
        year = year_val,
        quarterOneSold = quarterOneSold_val,
        quarterTwoSold = quarterTwoSold_val,
        quarterThreeSold = quarterThreeSold_val,
        quarterFourSold = quarterFourSold_val
      )
      dbWriteTable(mysqlDb, "product_facts", product_facts_data, row.names = FALSE, append = TRUE)
    }
  }
}

getTotalSalesBySalesRepIdAndYear <- function(sid, year_val) {
  # Name: getTotalSalesBySalesRepIdAndYear
  # Description: Gets the total sales amount by the PK of sales rep and the year
  # Parameters: sid: PK of sale rep, year_val: year
  # Returns: The total sales amount by sales rep and year
  
  
  query_check_sales <- sprintf("
    SELECT total_sold AS total_sales
    FROM rep_facts
    WHERE sales_rep_id = %s AND year = %s;
  ", sid, year_val)
  
  result_check_sales <- dbGetQuery(mysqlDb, query_check_sales)
  
  if (!is.na(result_check_sales$total_sales[1]) && result_check_sales$total_sales[1] > 0) {
    return(result_check_sales$total_sales[1])
  }
  
  
  # Query to get the total amount
  query_amount <- sprintf("
    SELECT SUM(amount) AS total_amount
    FROM SalesTxn
    WHERE salesRep = %s AND strftime('%%Y', date) = '%s';
  ", sid, year_val)
  

  
  # # Execute the queries
  result_amount <- dbGetQuery(sqlLiteDb, query_amount)

  total_amount <- ifelse(is.na(result_amount$total_amount[1]), 0, result_amount$total_amount[1])

  # Calculate the total sales amount
  
  return(total_amount)
  
}

getQuarterOneSalesBySalesRepIdAndYear <- function(sid, year_val) {
  
  # Name: getQuarterOneSalesBySalesRepIdAndYear
  # Description: Gets the sales for Q1
  # Parameters: sid: PK of sale rep, year_val: year
  # Returns: The total sales for Q1
  
  start_date <- sprintf("%s-01-01", year_val)
  end_date <- sprintf("%s-03-31", year_val)
  
  query <- sprintf("
    SELECT SUM(quantity) AS quarterOneSales
    FROM SalesTxn
    WHERE salesRep = %s AND date BETWEEN '%s' AND '%s';
  ", sid, start_date, end_date)
  
  result <- dbGetQuery(sqlLiteDb, query)
  return(result$quarterOneSales[1])
}

getQuarterTwoSalesBySalesRepIdAndYear <- function(sid, year_val) {
  
  # Name: getQuarterTwoSalesBySalesRepIdAndYear
  # Description: Gets the sales for Q2
  # Parameters: sid: PK of sale rep, year_val: year
  # Returns: The total sales for Q2
  
  start_date <- sprintf("%s-04-01", year_val)
  end_date <- sprintf("%s-06-30", year_val)
  
  query <- sprintf("
    SELECT SUM(quantity) AS quarterTwoSales
    FROM SalesTxn
    WHERE salesRep = %s AND date BETWEEN '%s' AND '%s';
  ", sid, start_date, end_date)
  
  result <- dbGetQuery(sqlLiteDb, query)
  return(result$quarterTwoSales[1])
}

getQuarterThreeSalesBySalesRepIdAndYear <- function(sid, year_val) {
  
  # Name: getQuarterThreeSalesBySalesRepIdAndYear
  # Description: Gets the sales for Q3
  # Parameters: sid: PK of sale rep, year_val: year
  # Returns: The total sales for Q3
  
  start_date <- sprintf("%s-07-01", year_val)
  end_date <- sprintf("%s-09-30", year_val)
  
  query <- sprintf("
    SELECT SUM(quantity) AS quarterThreeSales
    FROM SalesTxn
    WHERE salesRep = %s AND date BETWEEN '%s' AND '%s';
  ", sid, start_date, end_date)
  
  result <- dbGetQuery(sqlLiteDb, query)
  return(result$quarterThreeSales[1])
}

getQuarterFourSalesBySalesRepIdAndYear <- function(sid, year_val) {
  
  # Name: getQuarterFourSalesBySalesRepIdAndYear
  # Description: Gets the sales for Q4
  # Parameters: sid: PK of sale rep, year_val: year
  # Returns: The total sales for Q4
  
  start_date <- sprintf("%s-10-01", year_val)
  end_date <- sprintf("%s-12-31", year_val)
  
  query <- sprintf("
    SELECT SUM(quantity) AS quarterFourSales
    FROM SalesTxn
    WHERE salesRep = %s AND date BETWEEN '%s' AND '%s';
  ", sid, start_date, end_date)
  
  result <- dbGetQuery(sqlLiteDb, query)
  return(result$quarterFourSales[1])
}

getTotalSalesByRegion <- function(sid, year_val) {
  # Name: getTotalSalesByRegion
  # Description: Gets total sales by region
  # Parameters: sid: PK of sale rep, year_val: year
  # Returns: gets total sales by region
  
  query <- sprintf("
    SELECT SUM(quantity * amount) AS totalSalesByRegion
    FROM SalesTxn
    WHERE salesRep = %s AND strftime('%%Y', date) = '%s';
  ", sid, year_val)
  
  result <- dbGetQuery(sqlLiteDb, query)
  return(result$totalSalesByRegion[1])
}

getSalesRepNameById <- function(sid) {
  
  # Name: getSalesRepNameById
  # Description: Gets sale reps name
  # Parameters: sid: PK of sale rep
  # Returns: the sales reps name
  
  query <- sprintf("
    SELECT firstname, lastname
    FROM SalesReps
    WHERE sid = %d;
  ", sid)
  
  result <- dbGetQuery(sqlLiteDb, query)
  return(paste(result$firstname[1], result$lastname[1], sep = " "))
}

getRegion <- function(sid) {
  
  # Name: getRegion
  # Description: Gets sale reps region
  # Parameters: sid: PK of sale rep
  # Returns: the sales reps region
  
  query <- sprintf("
    SELECT t.territory
    FROM SalesReps s
    INNER JOIN Territory t ON s.territory = t.tid
    WHERE s.sid = %d;
  ", sid)
  
  result <- dbGetQuery(sqlLiteDb, query)
  return(result$territory[1])
}

createRepFactsTable <- function() {
  
  # Name: createRepFactsTable
  # Description: Creates Rep Facts Table
  # Parameters: N/A
  # Returns: N/A

createRepFacts <- "
CREATE TABLE IF NOT EXISTS rep_facts (
    sales_rep_id INTEGER AUTO_INCREMENT PRIMARY KEY,
    sales_rep_name VARCHAR(255),
    total_sold NUMERIC,
    year INT,
    total_monthly_sales NUMERIC,
    month INT,
    quarter INT,
    region VARCHAR(255)
);"

dbExecute(mysqlDb, createRepFacts)

}

dropRepFactsTable <- function(){
  
  # Name: dropRepFactsTable
  # Description: Drops Rep Facts Table
  # Parameters: N/A
  # Returns: N/A
  
  query <- "DROP TABLE IF EXISTS rep_facts;"
  dbExecute(mysqlDb, query)
}

getQuarterFromMonth <- function(month) {

  # Name: getQuarterFromMonth
  # Description: Determines quarter by month 
  # Parameters: N/A
  # Returns: the quarter
  
    if(length(month) == 0 || is.na(month)){
      return(0)
    } else if (month >= 1 && month <= 3) {
      return(1)
    } else if (month >= 4 && month <= 6) {
      return(2)
    } else if (month >= 7 && month <= 9) {
      return(3)
    } else if (month >= 10 && month <= 12) {
      return(4)
    } else {
      return(0)
    }
  }

processTotalMonthValue <- function(year_val, month_val, sid) {
  # Name: processTotalMonthValue
  # Description: Processes monthly total 
  # Parameters: N/A
  # Returns: the month total 
  
  formatted_month <- sprintf("%02d", month_val)
  
  # format strings so error goes away
  year_str <- as.character(year_val)
  month_str <- sprintf("%02d", month_val)
  
  # Calculate the sum of amount for the month and sales rep
  query <- sprintf("SELECT SUM(amount) as total_amount FROM SalesTxn WHERE substr(date, 1, 7) = '%s-%s' AND salesRep = %d", year_str, month_str, sid)
  result <- dbGetQuery(sqlLiteDb, query)
  
  # If not null or 0 
  if (nrow(result) > 0 && !is.na(result$total_amount)) {
    total_monthly_sales <- as.numeric(result$total_amount)
    
    return(total_monthly_sales)
  } else {
    total_monthly_sales <- 0
    # If no records found, NA or 0
  }
  
  return(total_monthly_sales)
}

populateRepFactsTable <-function(){
  
  # Name: populateRepFactsTable
  # Description: Populates Rep Facts Table
  # Parameters: N/A
  # Returns: N/A
  
  dropRepFactsTable()
  createRepFactsTable()
  
  # Query distinct sales_rep_ids from the SalesReps table
  sales_rep_ids <- dbGetQuery(sqlLiteDb, "SELECT DISTINCT sid FROM SalesReps")
  
  
  for (sid in sales_rep_ids$sid) {
    # get sales rep
    sales_rep_name_val <- getSalesRepNameById(sid)
    
    year_month_data <- dbGetQuery(sqlLiteDb, paste("SELECT DISTINCT strftime('%Y', date) as year, strftime('%m', date) as month FROM SalesTxn WHERE salesRep =", sid))
    
    for (row in 1:nrow(year_month_data)) {
      year_val <- ifelse(is.na(year_month_data$year[row]), 0, as.integer(year_month_data$year[row]))
      month_val <- ifelse(is.na(year_month_data$month[row]), 0, as.integer(year_month_data$month[row]))
      
      if (year_val == 0 || month_val == 0) {
        break 
      }
      
      quarter_val <- getQuarterFromMonth(month_val)
      total_monthly_val <- processTotalMonthValue(year_val, month_val, sid)
      total_sold_val <- getTotalSalesBySalesRepIdAndYear(sid, year_val)
      #region_sales_val <- getTotalSalesByRegion(sid,year_val)
      region_val <- getRegion(sid)
      
      # make a data frame 
      rep_facts_data <- data.frame(
        sales_rep_name = sales_rep_name_val,
        total_sold = total_sold_val,
        total_monthly_sales = total_monthly_val,
        year = year_val,
        month = month_val,
        quarter = quarter_val,
        region = region_val
        )
    
      #print(rep_facts_data)
      
      dbWriteTable(mysqlDb, "rep_facts", rep_facts_data, row.names = FALSE, append = TRUE)
    }
  }
  
}

createRequiredQueryOne <- function(){
  
  # Name: createRequiredQueryOne
  # Description: Demonstrates schema to required query one 
  # Parameters: N/A
  # Returns: N/A
  
  query <- "SELECT 
    product_name,
    year,
    quarterOneSold,
    quarterTwoSold,
    quarterThreeSold,
    quarterFourSold 
FROM
    product_facts
WHERE
    year = 2020;"

  result <- dbGetQuery(mysqlDb,query)    
  print(result)
}

createRequiredQueryTwo <-function() {
  
  # Name: createRequiredQueryTwo
  # Description: Demonstrates schema to required query two
  # Parameters: N/A
  # Returns: N/A
  
  query <- "SELECT 
    product_name,
    year,
    quarterOneSold,
    quarterTwoSold,
    quarterThreeSold,
    quarterFourSold 
FROM
    product_facts
WHERE
    year = 2020 AND 
    product_name = 'Alaraphosol'
  ;"
  
  result <- dbGetQuery(mysqlDb,query)    
  print(result)
  
}

createRequiredQueryThree <- function() {
  
  # Name: createRequiredQueryThree
  # Description: Demonstrates schema to required query three
  # Parameters: N/A
  # Returns: N/A
  
  query <- "SELECT 
    product_name,
    year,
    total_sold
FROM
    product_facts
WHERE
    year = 2020
GROUP BY
    product_name
ORDER BY 
  total_sold DESC
LIMIT 1
  ;"
  
  result <- dbGetQuery(mysqlDb,query)    
  print(result)
  
}

createRequiredQueryFour <- function() {
  
  # Name: createRequiredQueryFour
  # Description: Demonstrates schema to required query four
  # Parameters: N/A
  # Returns: N/A
  
  query <- "SELECT 
    sales_rep_name,
    total_sold
FROM
    rep_facts
WHERE
    year = 2020
GROUP BY
    sales_rep_name;
  ;"
  
  result <- suppressWarnings(dbGetQuery(mysqlDb, query)) 
  print(result)
  
}

createRequiredQueryFive <- function() {
  
  # Name: createRequiredQueryFive
  # Description: Demonstrates schema to required query five
  # Parameters: N/A
  # Returns: N/A
  
  query <- "SELECT 
    sales_rep_name,
    total_sold,
    region
    
FROM
    rep_facts
WHERE
    year = 2020 AND
    region = 'EMEA'
GROUP BY
    sales_rep_name
ORDER BY 
  total_sold DESC
LIMIT 1
  ;"
  
  result <- dbGetQuery(mysqlDb,query)    
  print(result)
}

showProductTable <- function() {
  
  # Name: showProductTable
  # Description: Shows table 
  # Parameters: N/A
  # Returns: N/A
  
  query <- "SELECT * FROM product_facts"
  result <- dbGetQuery(mysqlDb, query)
  print(result)
}

showRepsTable <- function() {
  
  # Name: showRepsTable
  # Description: Shows table 
  # Parameters: N/A
  # Returns: N/A
  
  query <- "SELECT * FROM rep_facts"
  result <- suppressWarnings(dbGetQuery(mysqlDb, query)) 
  print(result)
}

# Install packages 
installPackages()

# Create DB connections 
mysqlDb <- connectToRemoteDb()
sqlLiteDb <- connectToLocalDb()

# Populate Fact Tables 
populateProductFacts()
populateRepFactsTable()

# Show Tables Populated 
showProductTable()
showRepsTable()

# Demonstrating Schema meets criteria 
createRequiredQueryOne()
createRequiredQueryTwo()
createRequiredQueryThree()
createRequiredQueryFour()


dbDisconnect(mysqlDb)
dbDisconnect(sqlLiteDb)

