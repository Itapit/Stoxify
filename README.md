# Stoxify - SQL Stock Exchange Simulation

Stoxify is a simulated stock exchange system built using MySQL.  
The project models a real-world trading environment where users can issue, buy, and sell stocks, manage their holdings, and track transaction history over time.

## Project Overview

The system enables:
- Registering companies and issuing stocks.
- Adding traders (users) with balances.
- Placing buy and sell orders.
- Matching orders automatically based on price and time priorities.
- Executing transactions when orders match.
- Taking periodic snapshots of trader holdings for historical tracking.
- Performing financial analysis and statistics through advanced SQL queries.

## System Structure

- **Companies**: Store company information whose stocks are available for trading.
- **Stocks**: Represent tradeable securities associated with companies.
- **Traders**: Represent users who can place buy and sell orders.
- **Orders**: Store active or completed buy/sell requests by traders.
- **Transactions**: Record every completed buy, sell, or issuance.
- **Snapshot Metadata**: Keep track of when snapshots of current holdings were taken.
- **Holdings History**: Store historical records of trader holdings at each snapshot.

Additionally, the system uses:
- **Stored Procedures** for trading operations (buy, sell, issue shares, snapshot creation).
- **User-defined Functions** for data formatting and price retrieval.
- **Views** for calculating real-time holdings dynamically.

## Technologies Used

- **MySQL 8.0+**
- **Workbench Forward Engineering** for schema generation
- **Stored Procedures**, **Functions**, **Views**, **Joins**, **Aggregations**, **Subqueries**, **Unions**

## License

This project is licensed under the [MIT License](LICENSE).

---

*Developed as part of a final academic project focused on SQL database design and implementation.*
