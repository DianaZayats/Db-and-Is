-- 1. Вивести всі страви у меню
SELECT * FROM menu;

-- 2. Вивести всі замовлення, зроблені після 1 січня 2024 року
SELECT * FROM orders WHERE order_time >= '2024-01-01';

-- 3. Вивести 10 найдорожчих страв у меню
SELECT * FROM menu ORDER BY price DESC LIMIT 10;

-- 4. Вивести 5 найдешевших страв у меню
SELECT * FROM menu ORDER BY price ASC LIMIT 5;

-- 5. Вивести замовлення з конкретним статусом ("Pending")
SELECT * FROM orders WHERE status = 'Pending';

-- 6. Підрахувати кількість замовлень у кожного клієнта
SELECT client_id, COUNT(*) AS order_count FROM orders GROUP BY client_id;

-- 7. Загальна кількість замовлень у кафе
SELECT COUNT(*) AS total_orders FROM orders;

-- 8. Середня ціна замовлення
SELECT AVG(price) FROM menu;

-- 9. Найдорожче та найдешевше замовлення
SELECT MAX(amount) AS max_payment, MIN(amount) AS min_payment FROM payments;

-- 10. Загальна сума всіх оплат у кафе
SELECT SUM(amount) FROM payments;

-- 11. Отримати список замовлень разом із іменами клієнтів та офіціантів
SELECT orders.id AS order_id, clients.name AS client_name, employees.name AS waiter_name, orders.status
FROM orders
JOIN clients ON orders.client_id = clients.id
LEFT JOIN employees ON orders.employee_id = employees.id;

-- 12. Вивести список замовлених страв із їх категоріями
SELECT menu.name, menu.category, COUNT(order_items.menu_id) AS total_orders
FROM order_items
JOIN menu ON order_items.menu_id = menu.id
GROUP BY menu.name, menu.category;

-- 13. Вивести список офіціантів та кількість замовлень, які вони прийняли
SELECT employees.name, COUNT(orders.id) AS total_orders
FROM orders
JOIN employees ON orders.employee_id = employees.id
GROUP BY employees.name;

-- 14. Вивести замовлення, які містять "Margherita Pizza"
SELECT orders.id, menu.name FROM order_items
JOIN orders ON order_items.order_id = orders.id
JOIN menu ON order_items.menu_id = menu.id
WHERE menu.name = 'Margherita Pizza';

-- 15. Вивести всі комбінації страв у меню (CROSS JOIN)
SELECT a.name AS dish1, b.name AS dish2 FROM menu AS a CROSS JOIN menu AS b WHERE a.id <> b.id;

-- 16. Знайти клієнтів, які зробили хоча б одне замовлення
SELECT name FROM clients WHERE id IN (SELECT client_id FROM orders);

-- 17. Вивести клієнтів, які не зробили жодного замовлення
SELECT name FROM clients WHERE NOT EXISTS (SELECT 1 FROM orders WHERE orders.client_id = clients.id);

-- 18. Знайти всі замовлення, де загальна сума перевищує середнє значення
SELECT orders.id, SUM(menu.price * order_items.quantity) AS total_price
FROM orders
JOIN order_items ON orders.id = order_items.order_id
JOIN menu ON order_items.menu_id = menu.id
GROUP BY orders.id
HAVING SUM(menu.price * order_items.quantity) > (SELECT AVG(price) FROM menu);

-- 19. Вивести список усіх унікальних імен клієнтів та працівників
SELECT name FROM clients
UNION
SELECT name FROM employees;

-- 20. Вивести страви, які були замовлені, і ті, що ще не замовляли
SELECT name FROM menu
EXCEPT
SELECT DISTINCT menu.name FROM order_items JOIN menu ON order_items.menu_id = menu.id;

-- 21. Порахувати середню кількість замовлень на день
WITH DailyOrders AS (
    SELECT DATE(order_time) AS order_date, COUNT(*) AS order_count
    FROM orders
    GROUP BY order_date
)
SELECT AVG(order_count) AS avg_orders_per_day FROM DailyOrders;

-- 22. Додати нумерацію до кожного замовлення клієнта
SELECT id, client_id, order_time, ROW_NUMBER() OVER (PARTITION BY client_id ORDER BY order_time) AS order_rank
FROM orders;

-- 23. Обчислити загальну суму замовлення клієнта з наростаючим підсумком
SELECT orders.client_id, payments.order_id, payments.amount, 
       SUM(payments.amount) OVER (PARTITION BY orders.client_id ORDER BY payments.order_id) AS running_total
FROM payments
JOIN orders ON payments.order_id = orders.id;

-- 24. Вивести кількість замовлень по кожному дню тижня
SELECT EXTRACT(DOW FROM order_time) AS day_of_week, COUNT(*) AS total_orders
FROM orders
GROUP BY day_of_week
ORDER BY total_orders DESC;

-- 25. Вивести кількість унікальних клієнтів
SELECT COUNT(DISTINCT client_id) FROM orders;

-- 26. Вивести середню кількість товарів у замовленні
SELECT AVG(item_count) FROM (
    SELECT order_id, COUNT(menu_id) AS item_count
    FROM order_items
    GROUP BY order_id
) AS subquery;

-- 27. Вивести кількість замовлень за останній місяць
SELECT COUNT(*) FROM orders WHERE order_time >= NOW() - INTERVAL '1 month';

-- 28. Знайти замовлення, які містять більше 3-х страв
SELECT order_id FROM order_items GROUP BY order_id HAVING COUNT(menu_id) > 3;

-- 29. Вивести клієнта з найбільшою кількістю замовлень
SELECT client_id, COUNT(*) AS total_orders
FROM orders
GROUP BY client_id
ORDER BY total_orders DESC
LIMIT 1;

-- 30. Вивести категорії меню та середню ціну в кожній категорії
SELECT category, AVG(price) FROM menu GROUP BY category;

-- 31. Вивести замовлення, що мають найбільшу кількість товарів
SELECT order_id, COUNT(*) AS item_count FROM order_items GROUP BY order_id ORDER BY item_count DESC LIMIT 1;

-- 32. Вивести працівника, який обслугував найбільше замовлень
SELECT employee_id, COUNT(*) AS order_count FROM orders GROUP BY employee_id ORDER BY order_count DESC LIMIT 1;

-- 33. Вивести кількість замовлень за кожен місяць
SELECT DATE_TRUNC('month', order_time) AS month, COUNT(*) AS total_orders FROM orders GROUP BY month;

-- 34. Вивести середню кількість замовлень кожного клієнта
SELECT client_id, COUNT(*) / (SELECT COUNT(DISTINCT client_id) FROM orders) AS avg_orders FROM orders GROUP BY client_id;

-- 35. Вивести клієнтів, які зробили найбільші покупки за сумою
SELECT orders.client_id, SUM(payments.amount) AS total_spent
FROM payments
JOIN orders ON payments.order_id = orders.id
GROUP BY orders.client_id
ORDER BY total_spent DESC
LIMIT 5;

-- 36. Вивести всі замовлення, які не містять напої
SELECT orders.id FROM orders WHERE orders.id NOT IN (
    SELECT order_items.order_id FROM order_items
    JOIN menu ON order_items.menu_id = menu.id
    WHERE menu.category = 'Drinks'
);

-- 37. Вивести всі замовлення, оформлені вранці (з 6 до 11 години)
SELECT * FROM orders WHERE EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 11;

-- 38. Вивести всі замовлення, оформлені після 23:00
SELECT * FROM orders WHERE EXTRACT(HOUR FROM order_time) >= 23;

-- 39. Вивести всі оплати, здійснені картою
SELECT * FROM payments WHERE payment_type = 'Card';

-- 40. Вивести клієнтів, які зробили повторне замовлення
SELECT client_id FROM orders GROUP BY client_id HAVING COUNT(id) > 1;
