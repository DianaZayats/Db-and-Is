-- ENUM тип
CREATE TYPE order_state AS ENUM ('pending', 'ready', 'paid');

ALTER TABLE orders ADD COLUMN status_enum order_state DEFAULT 'pending';

-- Функція для середнього чеку клієнта
CREATE FUNCTION average_client_payment(input_client_id INT)
RETURNS NUMERIC AS $$
DECLARE
    avg_payment NUMERIC;
BEGIN
    SELECT AVG(p.amount)
    INTO avg_payment
    FROM payments p
    JOIN orders o ON p.order_id = o.id
    WHERE o.client_id = input_client_id;

    RETURN avg_payment;
END;
$$ LANGUAGE plpgsql;

-- Таблиця логів
CREATE TABLE order_logs (
    log_id SERIAL PRIMARY KEY,
    order_id INT,
    operation_type VARCHAR(10),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Функція для логування
CREATE FUNCTION log_order_change() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO order_logs (order_id, operation_type)
    VALUES (COALESCE(NEW.id, OLD.id), TG_OP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Тригер на orders
CREATE TRIGGER trigger_order_log
AFTER INSERT OR UPDATE OR DELETE ON orders
FOR EACH ROW EXECUTE FUNCTION log_order_change();

-- Додаткове поле для підсумку
ALTER TABLE orders ADD COLUMN total_amount NUMERIC DEFAULT 0;

-- Функція для оновлення total
CREATE FUNCTION update_order_total() RETURNS TRIGGER AS $$
BEGIN
    UPDATE orders
    SET total_amount = (
        SELECT SUM(oi.quantity * m.price)
        FROM order_items oi
        JOIN menu m ON oi.menu_id = m.id
        WHERE oi.order_id = NEW.order_id
    )
    WHERE id = NEW.order_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Тригер на order_items
CREATE TRIGGER trigger_update_order_total
AFTER INSERT OR UPDATE ON order_items
FOR EACH ROW EXECUTE FUNCTION update_order_total();

-- Тестові дії:
INSERT INTO orders (client_id, employee_id, status, status_enum)
VALUES (1, 1, 'Pending', 'pending');

SELECT * FROM order_logs ORDER BY changed_at DESC;

SELECT id, status, status_enum FROM orders ORDER BY id DESC LIMIT 5;

SELECT average_client_payment(1);

INSERT INTO payments (order_id, payment_type, amount)
VALUES (5, 'Card', 85.50);

SELECT average_client_payment(1);

INSERT INTO order_items (order_id, menu_id, quantity)
VALUES (5, 1, 2), (5, 4, 1);

SELECT id, total_amount FROM orders WHERE id = 5;

SELECT * FROM order_logs WHERE order_id = 5 ORDER BY changed_at DESC;
