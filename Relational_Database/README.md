# Bird Strikes on Aircraft Database Practicum

## Overview

This practicum involved building a relational database to analyze bird strike incidents on aircraft using an existing dataset from the FAA. The project encompassed the entire database development lifecycle, including logical data modeling, schema design, data loading, SQL querying, and basic data analysis using R.

## Project Components

### 1. **Database Setup**

- **MySQL Server Configuration**: A MySQL Server was configured on a cloud platform to host the database.
- **R Notebook Creation**: An R Notebook was established to manage the connection to the database, execute SQL queries, and document the process.

### 2. **Schema Design and Implementation**

- **Relational Schema**: Designed and implemented a relational schema to store bird strike data, including tables for flights, airports, conditions, and strikes.
- **Primary and Foreign Keys**: Defined primary and foreign keys to establish relationships between tables, ensuring data integrity.

### 3. **Data Loading and Manipulation**

- **CSV Data Import**: Loaded data from a CSV file into the MySQL database using R. The data was cleansed and normalized within R before insertion.
- **Data Integrity**: Synthetic keys and default values were used to handle missing data and ensure the integrity of the dataset.

### 4. **SQL Query Execution**

- **Top 10 States by Bird Strikes**: Queried the database to find the top 10 states with the most bird strike incidents.
- **Airlines with Above-Average Incidents**: Executed a query to identify airlines with a higher-than-average number of bird strikes.
- **Monthly Bird Strikes**: Analyzed the number of bird strikes by month and visualized the results with a column chart.

### 5. **Stored Procedure Development**

- **New Strike Insertion**: Created a MySQL stored procedure to add new bird strike records, accounting for potential new entries in related tables (e.g., airports, conditions).
- **Procedure Testing**: Validated the stored procedure's functionality through R.

## Skills Demonstrated

- **Database Design**: Creation of a robust relational schema for complex data.
- **SQL Proficiency**: Execution of advanced SQL queries to analyze the dataset.
- **Data Integration**: Loading and manipulating large datasets using R in conjunction with MySQL.
- **Stored Procedures**: Development and testing of stored procedures to manage database operations.

## Technologies Used

- **MySQL/MariaDB**: Relational database management system for data storage and querying.
- **R and R Notebooks**: Used for data manipulation, SQL query execution, and data visualization.
- **Cloud Hosting**: Configured and managed a MySQL database on a cloud platform.

## Summary

This practicum showcases proficiency in database design, SQL querying, and data analysis, demonstrating the ability to work with complex datasets in a structured and efficient manner.
