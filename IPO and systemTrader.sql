-- Insert the special SystemIssuer trader (who holds all IPO shares initially)
INSERT INTO traders (trader_name, email, balance)
VALUES ('SystemIssuer', 'issuer@market.com', 0);

-- Procedure to simulate company issuing shares to SystemIssuer
-- Marks fake orders using a price of 0 and a status 'ISSUED'
DELIMITER //

CREATE PROCEDURE IssueInitialShares (
  IN p_ticker VARCHAR(10),
  IN p_quantity INT
)
BEGIN
  DECLARE v_order_id INT;

  -- Insert a fake "BUY" order to grant SystemIssuer ownership
  INSERT INTO orders (
    ticker, trader_id, order_type, quantity, price, status, order_date
  ) VALUES (
    p_ticker, 1, 'BUY', p_quantity, 0.00, 'ISSUED', CURRENT_TIMESTAMP
  );

  SET v_order_id = LAST_INSERT_ID();

  -- Insert a fake transaction to reflect the issued shares
  INSERT INTO transactions (
    order_id, quantity, price_per_share, transaction_type, transaction_date
  ) VALUES (
    v_order_id, p_quantity, 0.00, 'BUY', CURRENT_TIMESTAMP
  );
END;
//
DELIMITER ;


-- Issue shares to SystemIssuer and list IPOs

-- Neutrino Robotics (1,000,000 shares)
CALL IssueInitialShares('NTR', 1000000);
CALL SellStock(1, 'NTR', 1000000, 10.50);

-- MetroCore Bank (850,000 shares)
CALL IssueInitialShares('MCR', 850000);
CALL SellStock(1, 'MCR', 850000, 12.00);

-- Quantum Bloom Labs (900,000 shares)
CALL IssueInitialShares('QBL', 900000);
CALL SellStock(1, 'QBL', 900000, 13.25);

-- SolarNova Energy (1,200,000 shares)
CALL IssueInitialShares('SNE', 1200000);
CALL SellStock(1, 'SNE', 1200000, 9.75);

-- HyperLoopX (600,000 shares)
CALL IssueInitialShares('HLX', 600000);
CALL SellStock(1, 'HLX', 600000, 14.30);

-- EchoVerse Studios (500,000 shares)
CALL IssueInitialShares('EVS', 500000);
CALL SellStock(1, 'EVS', 500000, 8.50);

-- ByteForge (1,000,000 shares)
CALL IssueInitialShares('BYF', 1000000);
CALL SellStock(1, 'BYF', 1000000, 11.80);

-- AquaPure (400,000 shares)
CALL IssueInitialShares('AQP', 400000);
CALL SellStock(1, 'AQP', 400000, 7.25);

-- SynthGenomics (300,000 shares)
CALL IssueInitialShares('SGM', 300000);
CALL SellStock(1, 'SGM', 300000, 6.60);

-- StellarMesh (700,000 shares)
CALL IssueInitialShares('STM', 700000);
CALL SellStock(1, 'STM', 700000, 13.00);

-- DeepMining Co. (200,000 shares)
CALL IssueInitialShares('DMC', 200000);
CALL SellStock(1, 'DMC', 200000, 5.95);

-- CloudTide (950,000 shares)
CALL IssueInitialShares('CLT', 950000);
CALL SellStock(1, 'CLT', 950000, 12.50);

-- NeuroLinkAI (1,100,000 shares)
CALL IssueInitialShares('NLA', 1100000);
CALL SellStock(1, 'NLA', 1100000, 10.00);

-- FireGlass Security (650,000 shares)
CALL IssueInitialShares('FGS', 650000);
CALL SellStock(1, 'FGS', 650000, 15.75);

-- EcoCore Farming (800,000 shares)
CALL IssueInitialShares('ECF', 800000);
CALL SellStock(1, 'ECF', 800000, 9.20);

SELECT * FROM transactions;
select * FROM current_holdings;
SELECT * FROM orders;
