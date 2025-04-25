-- Create a procedure to submit a SELL order and try to match it with existing BUY orders.

DELIMITER //

CREATE PROCEDURE SellStock (
  IN p_trader_id INT,
  IN p_ticker VARCHAR(10),
  IN p_quantity INT,
  IN p_min_price FLOAT
)
BEGIN
  DECLARE v_sell_order_id INT;
  DECLARE v_remaining_to_sell INT;
  DECLARE v_buyer_order_id INT;
  DECLARE v_buyer_id INT;
  DECLARE v_buyer_price FLOAT;
  DECLARE v_buyer_filled INT;
  DECLARE v_buyer_order_quantity INT;
  DECLARE v_to_transfer INT;
  DECLARE v_current_quantity INT;

  START TRANSACTION;

  -- Check if the trader has enough holdings using the view
  SELECT quantity INTO v_current_quantity
  FROM current_holdings
  WHERE trader_id = p_trader_id AND ticker = p_ticker;

  IF v_current_quantity >= p_quantity THEN
    -- Insert the SELL order
    INSERT INTO Orders (
      ticker, trader_id, order_type, quantity, price, status, order_date
    ) VALUES (
      p_ticker, p_trader_id, 'SELL', p_quantity, p_min_price, 'OPEN', CURRENT_TIMESTAMP
    );

    SET v_sell_order_id = LAST_INSERT_ID();
    SET v_remaining_to_sell = p_quantity;

    -- Try to match against open BUY orders
    WHILE_LOOP: WHILE v_remaining_to_sell > 0 DO
      SELECT o.order_id, o.trader_id, o.price, o.quantity,
             IFNULL(SUM(t.quantity), 0) AS filled_quantity
      INTO v_buyer_order_id, v_buyer_id, v_buyer_price, v_buyer_order_quantity, v_buyer_filled
      FROM Orders o
      LEFT JOIN Transactions t ON o.order_id = t.order_id
      WHERE o.ticker = p_ticker
        AND o.order_type = 'BUY'
        AND o.status IN ('OPEN', 'PARTIALLY_FILLED')
        AND o.price >= p_min_price
      GROUP BY o.order_id
      ORDER BY o.price DESC, o.order_date ASC
      LIMIT 1;

      IF v_buyer_order_id IS NULL THEN
        LEAVE WHILE_LOOP;
      END IF;

      SET v_to_transfer = LEAST(v_remaining_to_sell, v_buyer_order_quantity - v_buyer_filled);

      -- Record transactions for both buyer and seller
      INSERT INTO Transactions (order_id, quantity, price_per_share, transaction_type, transaction_date)
      VALUES 
        (v_buyer_order_id, v_to_transfer, v_buyer_price, 'BUY', CURRENT_TIMESTAMP),
        (v_sell_order_id, v_to_transfer, v_buyer_price, 'SELL', CURRENT_TIMESTAMP);
	  
	  -- Update the trader balance to account for his purchase
      UPDATE Traders
	  SET balance = balance + (v_to_transfer * v_buyer_price)
      WHERE trader_id = p_trader_id;
      
      -- Update BUY order status
      UPDATE Orders
      SET status = CASE
        WHEN (v_buyer_filled + v_to_transfer) = v_buyer_order_quantity THEN 'FILLED'
        ELSE 'PARTIALLY_FILLED'
      END
      WHERE order_id = v_buyer_order_id;

      SET v_remaining_to_sell = v_remaining_to_sell - v_to_transfer;
    END WHILE;

    -- Update SELL order status
    UPDATE Orders
    SET status = CASE
	  WHEN v_remaining_to_sell = p_quantity THEN 'OPEN'
      WHEN v_remaining_to_sell = 0 THEN 'FILLED'
      ELSE 'PARTIALLY_FILLED'
    END
    WHERE order_id = v_sell_order_id;

    COMMIT;
  ELSE
    ROLLBACK;
  END IF;
END;
//
DELIMITER ;


-- DROP PROCEDURE IF EXISTS SellStock;
