-- Sample customers
INSERT INTO customers (name, phone, address) VALUES
('Ravi Kumar', '9876543210', '123 MG Road, Bengaluru, Karnataka'),
('Anita Sharma', '8765432109', '45 Residency Road, Bengaluru, Karnataka'),
('Suresh Reddy', '7654321098', '67 Brigade Road, Bengaluru, Karnataka'),
('Priya Menon', '6543210987', '12 Koramangala, Bengaluru, Karnataka'),
('Vikram Joshi', '5432109876', '89 Indiranagar, Bengaluru, Karnataka');

-- Sample products
INSERT INTO products (name, price, stock) VALUES
('Rice 1kg', 60.00, 100),
('Wheat Flour 1kg', 45.00, 80),
('Sugar 1kg', 50.00, 60),
('Milk 1L', 55.00, 40),
('Eggs 12pcs', 70.00, 30);

-- Sample bills
INSERT INTO bills (customer_id, date, total) VALUES
(1, '2025-05-10', 250.00),
(2, '2025-05-11', 180.00);

-- Sample bill items
INSERT INTO bill_items (bill_id, product_id, quantity, price) VALUES
(1, 1, 2, 60.00),
(1, 3, 1, 50.00),
(2, 2, 2, 45.00),
(2, 4, 1, 55.00);