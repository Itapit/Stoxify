-- ================================
-- SIMPLE SELECT QUERIES
-- ================================

-- 1. All biotech companies
SELECT * FROM companies WHERE industry = 'Biotech';

-- 2. All stocks with more than 900,000 shares
SELECT * FROM stocks WHERE total_shares > 900000;

-- 3. All traders with over 100,000 balance
SELECT * FROM traders WHERE balance > 100000;

-- 4. All companies based in Zurich or Basel
SELECT * FROM companies WHERE headquarters IN ('Zurich', 'Basel');

-- 5. Show Snapshot Times
SELECT snapshot_id, snapshot_time
FROM snapshot_metadata
ORDER BY snapshot_time DESC;

-- ================================
-- SIMPLE AGGREGATE FUNCTIONS
-- ================================

-- 1. Count how many AI or Cybersecurity companies exist
SELECT COUNT(*) AS num_companies
FROM companies
WHERE industry IN ('AI', 'Cybersecurity');

-- 2. Average shares issued for biotech companies
SELECT AVG(s.total_shares) AS avg_biotech_shares
FROM stocks s
JOIN companies c ON s.company_id = c.company_id
WHERE c.industry = 'Biotech';

-- 3. Max balance among traders
SELECT MAX(balance) AS richest_balance FROM traders;

-- 4. Total shares for 'SolarNova Energy'
SELECT SUM(s.total_shares) AS total_sne_shares
FROM stocks s
JOIN companies c ON s.company_id = c.company_id
WHERE c.company_name = 'SolarNova Energy';

-- ================================
-- SIMPLE JOINS
-- ================================

-- 1. Join each stock with its company name
SELECT s.ticker, c.company_name
FROM stocks s
JOIN companies c ON s.company_id = c.company_id;

-- 2. Join each trader with their orders (if any)
SELECT t.trader_name, o.order_id, o.ticker
FROM traders t
LEFT JOIN orders o ON t.trader_id = o.trader_id;

-- 3. Join stocks and companies where total shares > 800,000
SELECT s.ticker, c.company_name, format_big_number(s.total_shares) AS total_shares
FROM stocks s
JOIN companies c ON s.company_id = c.company_id
WHERE s.total_shares > 800000;

-- 4. Show a Trader’s Holdings at a Specific Snapshot
SELECT t.trader_name, h.ticker, h.quantity
FROM holdings_history h
JOIN traders t ON h.trader_id = t.trader_id
WHERE snapshot_id = 1 AND t.trader_name = 'Alice';  -- replace with desired par

-- 5. Most Owned Stocks at a Snapshot
SELECT h.ticker, format_big_number(SUM(h.quantity)) AS total_held
FROM holdings_history h
WHERE h.snapshot_id = 1  -- replace with desired snapshot_id
GROUP BY h.ticker
ORDER BY total_held asc;

-- 6. Detect Inactive Traders (No Change Between Snapshots)
SELECT DISTINCT t.trader_name
FROM holdings_history h1
JOIN holdings_history h2 
  ON h1.trader_id = h2.trader_id AND h1.ticker = h2.ticker
JOIN traders t ON t.trader_id = h1.trader_id
WHERE h1.snapshot_id = 1 AND h2.snapshot_id = 2
  AND h1.quantity = h2.quantity;

-- ================================
-- SIMPLE GROUP BY + HAVING
-- ================================

-- 1. Total traders per balance range
SELECT 
  CASE 
    WHEN balance >= 100000 THEN 'High'
    WHEN balance >= 50000 THEN 'Medium'
    ELSE 'Low'
  END AS balance_level,
  COUNT(*) AS count
FROM traders
GROUP BY balance_level;

-- 2. Number of companies per industry (only if more than 1)
SELECT industry, COUNT(*) AS company_count
FROM companies
GROUP BY industry
HAVING COUNT(*) > 1;

-- 3. Average shares per industry
SELECT c.industry, format_big_number(AVG(s.total_shares)) AS avg_shares
FROM companies c
JOIN stocks s ON c.company_id = s.company_id
GROUP BY c.industry;

-- ================================
-- SIMPLE INSERT / UPDATE / DELETE
-- ================================

-- 1. Insert a new trader
INSERT INTO traders (trader_name, email, balance)
VALUES ('Karen', 'karen@example.com', 90000);

-- 2. Update Eli's balance to 75,000
UPDATE traders
SET balance = 75000
WHERE trader_name = 'Eli';

-- 3. Delete test trader Ian
DELETE FROM traders
WHERE trader_name = 'Ian';

-- ================================
-- SIMPLE SUBQUERIES
-- ================================

-- 1. Get companies with more shares than average
SELECT c.company_name
FROM companies c
JOIN stocks s ON c.company_id = s.company_id
WHERE s.total_shares > (
  SELECT AVG(total_shares) FROM stocks
);

-- 2. Traders with the same balance as Judy
SELECT trader_name
FROM traders
WHERE balance = (
  SELECT balance FROM traders WHERE trader_name = 'Judy'
);

-- ================================
-- UNION 
-- ================================

-- Combine active BUY and SELL orders into a single list
SELECT trader_id, ticker, 'BUY' AS type, quantity, price
FROM orders
WHERE order_type = 'BUY' AND status IN ('OPEN', 'PARTIALLY_FILLED') AND trader_id != 1
UNION
SELECT trader_id, ticker, 'SELL' AS type, quantity, price
FROM orders
WHERE order_type = 'SELL' AND status IN ('OPEN', 'PARTIALLY_FILLED') AND trader_id != 1
ORDER BY trader_id;

-- Union between all traders with a high balance and all traders with a high number of orders
SELECT trader_id, trader_name, 'High Balance' AS reason
FROM traders
WHERE balance > 100000
UNION
SELECT t.trader_id, t.trader_name, 'Many Orders' AS reason
FROM traders t
JOIN orders o ON t.trader_id = o.trader_id
GROUP BY t.trader_id
HAVING COUNT(o.order_id) >= 5
ORDER BY trader_name;

-- ================================
-- CROSSTAB  
-- ================================

-- Show for each trader the total BUY and SELL quantities
SELECT 
    t.trader_name,
    SUM(CASE WHEN o.order_type = 'BUY' THEN o.quantity ELSE 0 END) AS total_buy,
    SUM(CASE WHEN o.order_type = 'SELL' THEN o.quantity ELSE 0 END) AS total_sell
FROM traders t
LEFT JOIN orders o ON t.trader_id = o.trader_id
WHERE t.trader_id != 1
GROUP BY t.trader_id;

-- ================================
-- TRANSFORM  
-- ================================

-- Pivot-like: Quantity of each ticker per trader
SELECT 
    trader_id,
    SUM(CASE WHEN ticker = 'NTR' THEN quantity ELSE 0 END) AS NTR,
    SUM(CASE WHEN ticker = 'MCR' THEN quantity ELSE 0 END) AS MCR,
    SUM(CASE WHEN ticker = 'QBL' THEN quantity ELSE 0 END) AS QBL,
    SUM(CASE WHEN ticker = 'BYF' THEN quantity ELSE 0 END) AS BYF
FROM current_holdings
WHERE trader_id != 1
GROUP BY trader_id;