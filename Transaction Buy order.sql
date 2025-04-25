-- Create a procedure to submit a BUY order and try to match it with existing SELL orders.

DELIMITER //

CREATE PROCEDURE BuyStock (
  IN p_trader_id INT,
  IN p_ticker VARCHAR(10),
  IN p_quantity INT,
  IN p_max_price FLOAT
)
BEGIN
  DECLARE v_buy_order_id INT;
  DECLARE v_remaining_to_buy INT;
  DECLARE v_seller_order_id INT;
  DECLARE v_seller_id INT;
  DECLARE v_sell_price FLOAT;
  DECLARE v_seller_filled INT;
  DECLARE v_seller_order_quantity INT;
  DECLARE v_to_transfer INT;

  START TRANSACTION;

  -- Insert the BUY order
  INSERT INTO Orders (
    ticker, trader_id, order_type, quantity, price, status, order_date
  ) VALUES (
    p_ticker, p_trader_id, 'BUY', p_quantity, p_max_price, 'OPEN', CURRENT_TIMESTAMP
  );

  SET v_buy_order_id = LAST_INSERT_ID();
  SET v_remaining_to_buy = p_quantity;

  -- Try to match against open SELL orders
  WHILE_LOOP: WHILE v_remaining_to_buy > 0 DO
    SELECT o.order_id, o.trader_id, o.price, o.quantity,
           IFNULL(SUM(t.quantity), 0) AS filled_quantity
    INTO v_seller_order_id, v_seller_id, v_sell_price, v_seller_order_quantity, v_seller_filled
    FROM Orders o
    LEFT JOIN Transactions t ON o.order_id = t.order_id
    WHERE o.ticker = p_ticker
      AND o.order_type = 'SELL'
      AND o.status IN ('OPEN', 'PARTIALLY_FILLED')
      AND o.price <= p_max_price
    GROUP BY o.order_id
    ORDER BY o.price ASC, o.order_date ASC
    LIMIT 1;

    IF v_seller_order_id IS NULL THEN
      LEAVE WHILE_LOOP;
    END IF;

    SET v_to_transfer = LEAST(v_remaining_to_buy, v_seller_order_quantity - v_seller_filled);

    -- Record transactions for both buyer and seller
    INSERT INTO Transactions (order_id, quantity, price_per_share, transaction_type, transaction_date)
    VALUES 
      (v_buy_order_id, v_to_transfer, v_sell_price, 'BUY', CURRENT_TIMESTAMP),
      (v_seller_order_id, v_to_transfer, v_sell_price, 'SELL', CURRENT_TIMESTAMP);
	
    -- Update the trader balance to account for his purchase
    UPDATE Traders
	SET balance = balance - (v_to_transfer * v_sell_price)
	WHERE trader_id = p_trader_id;
    
    -- Update SELL order status
    UPDATE Orders
    SET status = CASE
      WHEN (v_seller_filled + v_to_transfer) = v_seller_order_quantity THEN 'FILLED'
      ELSE 'PARTIALLY_FILLED'
    END
    WHERE order_id = v_seller_order_id;

    SET v_remaining_to_buy = v_remaining_to_buy - v_to_transfer;
  END WHILE;

  -- Update BUY order status
  UPDATE Orders
  SET status = CASE
    WHEN v_remaining_to_buy = p_quantity THEN 'OPEN'
    WHEN v_remaining_to_buy = 0 THEN 'FILLED'
    ELSE 'PARTIALLY_FILLED'
  END

  
  WHERE order_id = v_buy_order_id;

  COMMIT;
END;
//
DELIMITER ;

-- DROP PROCEDURE IF EXISTS BuyStock;


