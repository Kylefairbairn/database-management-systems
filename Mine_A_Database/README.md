# Pharmaceutical Sales Data Warehousing Practicum

## Overview

This practicum involved the creation of both a transactional and an analytical database to manage and analyze pharmaceutical sales data. The project was divided into three parts: building a normalized OLTP (Online Transaction Processing) database from XML data, transforming the data into an OLAP (Online Analytical Processing) star schema, and performing analytical queries on the OLAP database.

## Project Components

### 1. **Data Extraction and OLTP Database Creation**

- **XML Data Parsing**: Extracted data from multiple XML files containing pharmaceutical sales transactions and sales representatives' information.
- **Normalized Relational Schema Design**: Designed and implemented a relational schema in SQLite to store the extracted data, with tables representing products, sales reps, customers, and sales transactions.
- **Data Loading**: Loaded and transformed the XML data into the SQLite database using R. The data was normalized to ensure consistency and reduce redundancy.

### 2. **Star Schema and OLAP Database Creation**

- **Star Schema Design**: Designed a star schema in MySQL to support efficient analytical queries. The schema included fact tables that summarized sales data by product and sales rep, with dimensions such as time and region.
- **ETL Process**: Extracted data from the SQLite OLTP database, transformed it into a format suitable for OLAP, and loaded it into the MySQL database. The ETL process was optimized for scalability, ensuring that the code could handle large datasets efficiently.

### 3. **Data Analysis and Reporting**

- **Analytical Queries**: Executed SQL queries against the OLAP database to generate reports on sales performance, including:
  - **Top Sales Reps**: Identified the top five sales representatives with the highest sales, broken down by year.
  - **Monthly Sales Trends**: Analyzed and visualized total sales per month, providing insights into sales patterns over time.
- **Data Visualization**: Used R to create a line graph visualization of monthly sales trends, making the data accessible and easy to interpret for stakeholders.

## Skills Demonstrated

- **Data Extraction and Transformation**: Proficiently extracted and transformed XML data into relational and analytical databases using R.
- **Database Design**: Developed both normalized and denormalized schemas to support transactional processing and analytical queries.
- **SQL Proficiency**: Executed complex SQL queries across two different databases (SQLite and MySQL) to derive meaningful insights from the data.
- **ETL Process Implementation**: Implemented an ETL pipeline that efficiently handled data extraction, transformation, and loading between databases.
- **Data Analysis and Visualization**: Analyzed data using SQL and visualized results in R, providing actionable insights.

## Technologies Used

- **R and RStudio**: Used for data extraction, transformation, and interaction with databases.
- **SQLite**: Implemented as the OLTP database for storing normalized transactional data.
- **MySQL**: Used to create and query the OLAP star schema for analytical purposes.
- **XML**: Source format for the initial data, requiring careful parsing and transformation.

## Summary

This practicum showcases expertise in data warehousing, including the ability to design and implement both transactional and analytical databases. The project highlights proficiency in database design, data transformation, SQL querying, and data visualization, demonstrating a comprehensive approach to managing and analyzing complex datasets.
