-- Create a view that shows the current holdings of each trader per stock.
-- This view is calculated based on transactions (not a stored table),
-- and reflects all buy/sell activity that has occurred up to this point.
CREATE VIEW current_holdings AS
SELECT 
  o.trader_id,
  o.ticker,
  SUM(
    CASE t.transaction_type
      WHEN 'BUY' THEN t.quantity
      WHEN 'SELL' THEN -t.quantity
    END
  ) AS quantity
FROM Transactions t
JOIN Orders o ON t.order_id = o.order_id
GROUP BY o.trader_id, o.ticker
HAVING quantity > 0;
