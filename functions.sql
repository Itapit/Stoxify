DELIMITER //
CREATE FUNCTION format_big_number(val DOUBLE) RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
  RETURN CASE
    WHEN val >= 1000000000 THEN CONCAT(ROUND(val / 1000000000, 2), 'B')
    WHEN val >= 1000000 THEN CONCAT(ROUND(val / 1000000, 2), 'M')
    WHEN val >= 1000 THEN CONCAT(ROUND(val / 1000, 2), 'K')
    ELSE ROUND(val, 2)
  END;
END;
//
DELIMITER ;

DELIMITER //


DELIMITER //

CREATE FUNCTION get_last_price(p_ticker VARCHAR(10)) RETURNS FLOAT
DETERMINISTIC
BEGIN
  DECLARE v_price FLOAT;

  SELECT t.price_per_share
  INTO v_price
  FROM Transactions t
  JOIN Orders o ON t.order_id = o.order_id
  WHERE o.ticker = p_ticker
  ORDER BY t.transaction_date DESC, t.transaction_id DESC
  LIMIT 1;

  RETURN v_price;  -- If no result, v_price remains NULL
END;
//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE TakeHoldingsSnapshot()
BEGIN
  DECLARE v_snapshot_id INT;

  -- Step 1: Insert new snapshot metadata
  INSERT INTO snapshot_metadata () VALUES ();
  SET v_snapshot_id = LAST_INSERT_ID();

  -- Step 2: Insert current holdings into history
  INSERT INTO holdings_history (snapshot_id, trader_id, ticker, quantity)
  SELECT v_snapshot_id, trader_id, ticker, quantity
  FROM current_holdings;

END;
//

DELIMITER ;

