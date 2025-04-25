-- Disable SQL safe updates temporarily
SET SQL_SAFE_UPDATES = 0;

-- Clear data 
DELETE FROM Transactions;
DELETE FROM Orders;
DELETE FROM Traders;
DELETE FROM Stocks;
DELETE FROM Companies;

--  Reset AUTO_INCREMENT counters
ALTER TABLE Transactions AUTO_INCREMENT = 1;
ALTER TABLE Orders AUTO_INCREMENT = 1;
ALTER TABLE Traders AUTO_INCREMENT = 1;
ALTER TABLE Companies AUTO_INCREMENT = 1;

SET SQL_SAFE_UPDATES = 1;


SELECT 'Companies' AS table_name, COUNT(*) AS row_count FROM Companies
UNION ALL
SELECT 'Stocks', COUNT(*) FROM Stocks
UNION ALL
SELECT 'Traders', COUNT(*) FROM Traders
UNION ALL
SELECT 'Orders', COUNT(*) FROM Orders
UNION ALL
SELECT 'Transactions', COUNT(*) FROM Transactions