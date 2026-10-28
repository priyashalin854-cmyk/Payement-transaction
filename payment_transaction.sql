USE ordermanagementdb;

CREATE TABLE Payment (
    Payment_ID INT PRIMARY KEY,
    Order_ID INT NOT NULL UNIQUE,
    Payment_Date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Payment_Mode VARCHAR(30) NOT NULL,
    Payment_Status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    Transaction_Amount DECIMAL(10,2) NOT NULL CHECK (Transaction_Amount > 0),
    CONSTRAINT fk_payment_order
        FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    CONSTRAINT chk_payment_mode
        CHECK (Payment_Mode IN ('UPI', 'Credit Card', 'Debit Card', 'Net Banking', 'Cash on Delivery')),
    CONSTRAINT chk_payment_status
        CHECK (Payment_Status IN ('Pending', 'Success', 'Failed'))
);

desc payment;

INSERT INTO Payment
(Payment_ID, Order_ID, Payment_Date, Payment_Mode, Payment_Status, Transaction_Amount) VALUES
(5001, 1001, '2026-10-01 10:15:00', 'UPI', 'Success', 799.00),
(5002, 1002, '2026-10-02 11:20:00', 'Credit Card', 'Success', 58999.00),
(5003, 1003, '2026-10-03 12:30:00', 'Debit Card', 'Failed', 8999.00),
(5004, 1004, '2026-10-04 09:45:00', 'Cash on Delivery', 'Pending', 599.00),
(5005, 1005, '2026-10-05 16:00:00', 'Net Banking', 'Success', 9798.00),
(5006, 1006, '2026-10-06 14:10:00', 'UPI', 'Pending', 1598.00);

SELECT * FROM Payment ORDER BY Payment_ID;

SELECT p.*, o.Customer_ID, o.Order_Date, o.Total_Amount, o.Order_Status
FROM Payment p
JOIN Orders o ON p.Order_ID = o.Order_ID
WHERE p.Order_ID = 1001;

SELECT * FROM Payment WHERE Payment_Status = 'Success';

SELECT * FROM Payment
WHERE Payment_Status IN ('Failed', 'Pending')
ORDER BY Payment_Status, Payment_ID;

SELECT Payment_Status, COUNT(*) AS Transaction_Count
FROM Payment
WHERE Payment_Status IN ('Success', 'Failed')
GROUP BY Payment_Status;

SELECT
    p.Payment_ID, p.Order_ID, c.Customer_ID, c.Customer_Name, c.Email,
    o.Order_Date, o.Order_Status, p.Payment_Date, p.Payment_Mode,
    p.Payment_Status, p.Transaction_Amount
FROM Payment p
JOIN Orders o ON p.Order_ID = o.Order_ID
JOIN Customer c ON o.Customer_ID = c.Customer_ID
ORDER BY p.Payment_ID;

SELECT Payment_Mode, COUNT(*) AS Transaction_Count
FROM Payment
GROUP BY Payment_Mode
ORDER BY Transaction_Count DESC, Payment_Mode;

SELECT COALESCE(SUM(Transaction_Amount), 0) AS Successful_Payment_Revenue
FROM Payment
WHERE Payment_Status = 'Success';

SELECT Payment_Mode,
       COUNT(*) AS Successful_Transactions,
       SUM(Transaction_Amount) AS Successful_Revenue
FROM Payment
WHERE Payment_Status = 'Success'
GROUP BY Payment_Mode
ORDER BY Successful_Revenue DESC;

SELECT ROUND(AVG(Transaction_Amount), 2) AS Average_Transaction_Amount
FROM Payment;

SELECT c.Customer_ID, c.Customer_Name, o.Order_ID,
       p.Payment_ID, p.Payment_Date, p.Payment_Mode,
       p.Payment_Status, p.Transaction_Amount
FROM Customer c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
JOIN Payment p ON o.Order_ID = p.Order_ID
ORDER BY c.Customer_ID, p.Payment_Date;

SELECT status_list.Payment_Status,
       COUNT(p.Payment_ID) AS Transaction_Count
FROM (
    SELECT 'Success' AS Payment_Status
    UNION ALL SELECT 'Failed'
    UNION ALL SELECT 'Pending'
) AS status_list
LEFT JOIN Payment p ON p.Payment_Status = status_list.Payment_Status
GROUP BY status_list.Payment_Status
ORDER BY FIELD(status_list.Payment_Status, 'Success', 'Failed', 'Pending');

SELECT o.Order_ID, c.Customer_Name, o.Order_Date, o.Total_Amount,
     p.Payment_Mode, p.Payment_Status, p.Transaction_Amount
FROM Orders o
JOIN Customer c ON o.Customer_ID = c.Customer_ID
JOIN Payment p ON o.Order_ID = p.Order_ID
WHERE p.Payment_Status IN ('Failed', 'Pending')
ORDER BY o.Order_ID;

SELECT p.Payment_ID, p.Order_ID, p.Transaction_Amount, o.Total_Amount
FROM Payment p
JOIN Orders o ON p.Order_ID = o.Order_ID
WHERE p.Transaction_Amount <> o.Total_Amount;















