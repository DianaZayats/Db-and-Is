-- Створення бази даних
CREATE DATABASE cafe_orders;

-- Підключення до бази
\c cafe_orders

-- Створення таблиць
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255) UNIQUE
);

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('Waiter', 'Cook', 'Administrator'))
);

CREATE TABLE menu (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(100) NOT NULL
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    client_id INT REFERENCES clients(id) ON DELETE CASCADE,
    employee_id INT REFERENCES employees(id) ON DELETE SET NULL,
    status VARCHAR(50) NOT NULL CHECK (status IN ('Pending', 'Ready', 'Paid')),
    order_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(id) ON DELETE CASCADE,
    menu_id INT REFERENCES menu(id) ON DELETE CASCADE,
    quantity INT NOT NULL CHECK (quantity > 0)
);

CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(id) ON DELETE CASCADE,
    payment_type VARCHAR(50) NOT NULL CHECK (payment_type IN ('Cash', 'Card')),
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0)
);

-- Заповнення таблиць тестовими даними
INSERT INTO clients (name, phone, email) VALUES
('Alice Johnson', '123-456-7890', 'alice@example.com'),
('Bob Smith', '987-654-3210', 'bob@example.com'),
('Charlie Brown', '555-666-7777', 'charlie@example.com');

INSERT INTO employees (name, role) VALUES
('Emma Wilson', 'Waiter'),
('John Carter', 'Waiter'),
('Olivia Martinez', 'Cook'),
('Daniel Robinson', 'Administrator');

INSERT INTO menu (name, price, category) VALUES
('Margherita Pizza', 12.99, 'Pizza'),
('Cheeseburger', 9.99, 'Burgers'),
('Caesar Salad', 7.99, 'Salads'),
('Latte', 4.50, 'Drinks'),
('Chocolate Cake', 6.99, 'Desserts');

INSERT INTO orders (client_id, employee_id, status) VALUES
(1, 1, 'Pending'),
(2, 2, 'Ready'),
(3, 1, 'Paid');

INSERT INTO order_items (order_id, menu_id, quantity) VALUES
(1, 1, 2),  
(1, 4, 1),  
(2, 2, 1),  
(3, 3, 1),  
(3, 5, 2);

INSERT INTO payments (order_id, payment_type, amount) VALUES
(3, 'Card', 21.97);

-- Аналітичні запити
SELECT orders.id AS order_id, clients.name AS client_name, employees.name AS waiter_name, orders.status, orders.order_time
FROM orders
JOIN clients ON orders.client_id = clients.id
LEFT JOIN employees ON orders.employee_id = employees.id;

SELECT orders.id, orders.status, orders.order_time
FROM orders
JOIN clients ON orders.client_id = clients.id
WHERE clients.name = 'Alice Johnson';

SELECT menu.name, COUNT(order_items.menu_id) AS order_count
FROM order_items
JOIN menu ON order_items.menu_id = menu.id
GROUP BY menu.name
ORDER BY order_count DESC;

SELECT DATE(order_time) AS order_date, SUM(menu.price * order_items.quantity) AS total_sales
FROM orders
JOIN order_items ON orders.id = order_items.order_id
JOIN menu ON order_items.menu_id = menu.id
WHERE DATE(order_time) = CURRENT_DATE
GROUP BY order_date;

SELECT 
    status, 
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders) AS percentage
FROM orders
GROUP BY status;

SELECT DISTINCT category FROM menu;

SELECT MAX(price) AS max_price, MIN(price) AS min_price FROM menu;

SELECT client_id, COUNT(*) AS orders_count
FROM orders
GROUP BY client_id;

SELECT COUNT(*) FROM orders WHERE status = 'Pending';

SELECT SUM(amount) AS total_revenue FROM payments;