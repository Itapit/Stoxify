-- Most Traded Stock
-- Shows the stock with the highest total volume traded
SELECT 
    o.ticker,
    format_big_number(SUM(t.quantity)) AS total_volume
FROM transactions t
JOIN orders o ON t.order_id = o.order_id
WHERE o.trader_id != 1
GROUP BY o.ticker
ORDER BY SUM(t.quantity) DESC
LIMIT 1;

-- Most Profitable Trader
-- Calculates total sell income - total buy cost per trader
SELECT 
    o.trader_id,
    t1.trader_name,
    format_big_number(SUM(CASE WHEN t.transaction_type = 'SELL' THEN t.price_per_share * t.quantity ELSE 0 END) -
                      SUM(CASE WHEN t.transaction_type = 'BUY' THEN t.price_per_share * t.quantity ELSE 0 END)) AS net_profit
FROM transactions t
JOIN orders o ON t.order_id = o.order_id
JOIN traders t1 ON o.trader_id = t1.trader_id
WHERE o.trader_id != 1
GROUP BY o.trader_id
ORDER BY net_profit DESC
LIMIT 1;

-- Stocks That Have Never Been Traded
-- Lists stocks with no associated orders
SELECT s.ticker, c.company_name
FROM stocks s
LEFT JOIN (
    SELECT DISTINCT ticker FROM orders WHERE trader_id != 1
) o ON s.ticker = o.ticker
LEFT JOIN companies c ON s.company_id = c.company_id
WHERE o.ticker IS NULL;

-- Traders With No Orders
-- Finds traders who never placed a BUY or SELL order
SELECT t.trader_id, t.trader_name
FROM traders t
LEFT JOIN orders o ON t.trader_id = o.trader_id AND o.trader_id != 1
WHERE o.order_id IS NULL AND t.trader_id != 1;

-- Traders With ≥ 3 Orders
-- Lists traders who have placed 3 or more orders
SELECT t.trader_id, t.trader_name, COUNT(o.order_id) AS num_orders
FROM traders t
JOIN orders o ON t.trader_id = o.trader_id
WHERE t.trader_id != 1
GROUP BY t.trader_id
HAVING COUNT(o.order_id) >= 3;

-- Deposit to Trader
-- Simulates a trader depositing money to their account
UPDATE traders
SET balance = balance + 5000
WHERE trader_name = 'Alice';

-- Withdraw from Trader
-- Simulates a trader withdrawing money from their account
UPDATE traders
SET balance = balance - 3000
WHERE trader_name = 'Bob';

-- List All Open / Partially Filled Orders
-- Shows all orders that are not yet filled
SELECT order_id, trader_id, ticker, order_type, quantity, price, status
FROM orders
WHERE status IN ('OPEN', 'PARTIALLY_FILLED') AND trader_id != 1
ORDER BY order_date DESC;

-- Active BUY and SELL Orders Combined
-- Uses UNION to combine all active BUY and SELL orders
SELECT order_id, trader_id, ticker, 'BUY' AS order_type, quantity, price, status
FROM orders
WHERE status IN ('OPEN', 'PARTIALLY_FILLED') AND order_type = 'BUY' AND trader_id != 1
UNION
SELECT order_id, trader_id, ticker, 'SELL' AS order_type, quantity, price, status
FROM orders
WHERE status IN ('OPEN', 'PARTIALLY_FILLED') AND order_type = 'SELL' AND trader_id != 1
ORDER BY ticker;

-- Show each trader and the stocks they currently hold using the current_holdings view
SELECT 
  t.trader_name,
  ch.ticker,
  ch.quantity
FROM current_holdings ch
JOIN traders t ON ch.trader_id = t.trader_id;

-- Show each trader's total portfolio value including cash holdings and current stock value
SELECT 
  t.trader_id,
  t.trader_name,
  format_big_number(t.balance) AS cash_holdings,
  format_big_number(SUM(ch.quantity * get_last_price(ch.ticker)) + t.balance) AS total_holdings
FROM traders t
LEFT JOIN current_holdings ch ON t.trader_id = ch.trader_id
GROUP BY t.trader_id, t.trader_name, t.balance;

-- List of all companies and their market capitalization based on total_shares * last traded price.
SELECT 
  c.company_id,
  c.company_name,
  s.ticker,
  format_big_number(s.total_shares) AS total_shares,
  format_big_number(s.total_shares * get_last_price(s.ticker)) AS market_cap
FROM Companies c
JOIN Stocks s ON c.company_id = s.company_id;
