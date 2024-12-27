# SQL Scripts for Reservation Management and Reporting

## Overview
This repository contains SQL scripts for managing and analyzing reservation data. The scripts support functionality such as cancellation management, reservation availability analysis, ingredient forecasting, and generating various reports to aid in restaurant operations.



## Features
1. **Cancellation Management**
   - Manages cancellation records and generates relevant cancellation reports.

2. **Reservation Availability Analysis**
   - Analyzes reservation data to optimize table availability.

3. **Ingredient Forecasting**
   - Forecasts ingredient usage based on past reservation and menu data.

4. **Menu and Reservation Reporting**
   - Generates reports on top-rated menu items and reservation trends.



## Directory Structure
```
project-directory/
|-- Data/                     # Configuration files for database tables
|-- Reports/
    |-- CancellationManagement.sql        # Script for managing cancellations
    |-- CancellationReport.sql            # Script to generate cancellation reports
    |-- IngredientForecastReport.sql      # Forecasting script for ingredient usage
    |-- ReservationAvailabilityAnalysis.sql # Reservation availability analysis
    |-- ReservationsManagement.sql        # General reservation management script
    |-- Top10MenuRating.sql               # Script to identify top-rated menu items
|-- run_all.txt                       # A text file to run all scripts sequentially
|-- tables.sql                        # Database schema definitions
```


## Prerequisites
1. A relational database system (e.g., MySQL, PostgreSQL).
2. SQL client tool (e.g., MySQL Workbench, pgAdmin).



## Setup Instructions
1. Clone the repository:
   ```bash
   git clone https://github.com/sereneooi/sql-scripts.git
   ```

2. Navigate to the project directory:
   ```bash
   cd sql-scripts
   ```

3. Set up the database schema:
   - Run `tables.sql` to create the necessary tables.

4. Execute individual scripts as needed:
   - Use scripts such as `CancellationManagement.sql` or `Top10MenuRating.sql` based on the required functionality.

5. (Optional) Automate script execution:
   - Use `run_all.txt` as a reference to execute all scripts in sequence.


## Usage
1. **Managing Cancellations**
   - Run `CancellationManagement.sql` to update cancellation records.
   - Use `CancellationReport.sql` to generate a summary report of cancellations.

2. **Reservation Analysis**
   - Execute `ReservationAvailabilityAnalysis.sql` to identify reservation trends and availability.

3. **Menu Insights**
   - Use `Top10MenuRating.sql` to retrieve the top-rated menu items.

4. **Ingredient Forecasting**
   - Run `IngredientForecastReport.sql` to predict ingredient requirements based on historical data.


