-- Створення бази даних
CREATE DATABASE online_clothing_store;
-- Підключення до бази даних
\c online_clothing_store
-- Створення таблиць
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category_id INT REFERENCES categories(id) ON DELETE CASCADE
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id) ON DELETE CASCADE,
    quantity INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Вставка даних
INSERT INTO categories (name) VALUES 
('Футболки'), 
('Джинси'), 
('Взуття');

INSERT INTO products (name, price, category_id) VALUES 
('Чорна футболка', 500, 1), 
('Сині джинси', 1200, 2), 
('Кросівки Nike', 3500, 3);

INSERT INTO orders (product_id, quantity) VALUES 
(1, 2), 
(2, 1), 
(3, 1);

-- Виконання SQL-запитів
SELECT * FROM products;

SELECT products.id, products.name, products.price, categories.name AS category_name
FROM products
JOIN categories ON products.category_id = categories.id;

UPDATE products SET price = 550 WHERE name = 'Чорна футболка';

DELETE FROM orders WHERE id = 2;

SELECT SUM(products.price * orders.quantity) AS total_sales
FROM orders
JOIN products ON orders.product_id = products.id;