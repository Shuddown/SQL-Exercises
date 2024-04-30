REM: Dropping the TABLES
DROP TABLE SHIP_DETAIL;

DROP TABLE ORDER_DETAIL;

DROP TABLE PART;

DROP TABLE EMPLOYEE;

DROP TABLE CUSTOMER;

DROP TABLE CITY;

DROP TABLE ORDER_LIST;

DROP TABLE ORDERS;

DROP TABLE CUSTOMER;

DROP TABLE PIZZA;

DROP VIEW Pizza_200_250;

DROP VIEW Pizza_Type_Order;

DROP VIEW Spanish_Customers;


REM: Creating the tables

CREATE TABLE CUSTOMER(
    CUST_ID CHAR(4),
    CONSTRAINT CUST_ID_PK PRIMARY KEY (CUST_ID),
    CONSTRAINT CUST_ID_CHECK CHECK (REGEXP_LIKE (CUST_ID, 'c[0-9]*')),
    CUST_NAME VARCHAR(100),
    ADDRESS VARCHAR(500),
    PHONE NUMBER(10)
);

DESC customer;

CREATE TABLE PIZZA(
    PIZZA_ID CHAR(4),
    CONSTRAINT P_ID_PK PRIMARY KEY (PIZZA_ID),
    CONSTRAINT P_ID_CHECK CHECK (REGEXP_LIKE (PIZZA_ID, 'p[0-9]*')),
    PIZZA_TYPE VARCHAR(50),
    UNIT_PRICE FLOAT,
    CONSTRAINT P_UP_CHECK CHECK (UNIT_PRICE > 0)
);

DESC pizza;

CREATE TABLE ORDERS(
    ORDER_NO CHAR(5),
    CONSTRAINT O_ID_PK PRIMARY KEY (ORDER_NO),
    CONSTRAINT O_ID_CHECK CHECK (REGEXP_LIKE (ORDER_NO, 'OP[0-9]*')),
    CUST_ID CHAR(4),
    CONSTRAINT O_CID_CHECK CHECK (REGEXP_LIKE (CUST_ID, 'c[0-9]*')),
    CONSTRAINT O_CID_FK FOREIGN KEY (CUST_ID) REFERENCES CUSTOMER(CUST_ID),
    ORDER_DATE DATE,
    DELV_DATE DATE,
    CONSTRAINT O_DATE_CHECK CHECK (DELV_DATE >= ORDER_DATE)
);

DESC orders;

CREATE TABLE ORDER_LIST(
    ORDER_NO CHAR(5),
    CONSTRAINT OL_ON_CHECK CHECK (REGEXP_LIKE (ORDER_NO, 'OP[0-9]*')),
    CONSTRAINT OL_ON_FK FOREIGN KEY (ORDER_NO) REFERENCES ORDERS(ORDER_NO),
    PIZZA_ID CHAR(4),
    CONSTRAINT OL_PID_CHECK CHECK (REGEXP_LIKE (PIZZA_ID, 'p[0-9]*')),
    CONSTRAINT OL_PID_FK FOREIGN KEY (PIZZA_ID) REFERENCES PIZZA(PIZZA_ID),
    QTY INT,
    CONSTRAINT OL_QTY_CHECK CHECK (QTY > 0),
    CONSTRAINT OL_QTY_NN CHECK(QTY IS NOT NULL),
    CONSTRAINT OL_ID_PK PRIMARY KEY (ORDER_NO, PIZZA_ID)
);

DESC order_list;

REM: Running PIZZA_DB.sql

@/home/shuddown/Programs/SQL/SQL-Exercises/Ex-3/Pizza_DB.sql

ALTER TABLE orders ADD Total_Amount FLOAT;

REM: 1.Write a stored procedure to display the total number of pizza's ordered by the given order number. (Use IN, OUT)

REM: Procedure
SET SERVEROUTPUT ON;


CREATE OR REPLACE PROCEDURE TotalPizzasFromOrderNo(request_order_no IN orders.order_no%TYPE, total OUT NUMBER)
AS
BEGIN
    SELECT SUM(ol.qty) INTO total
    FROM order_list ol
    GROUP BY ol.order_no
    HAVING ol.order_no = request_order_no;
END;
/

REM: Input and execution of PROCEDURE

ACCEPT user_input PROMPT 'Give the order no whose total qty you want to find: '

DECLARE
request_order_no orders.order_no%TYPE;
total NUMBER;

BEGIN
    request_order_no := '&user_input';
    TotalPizzasFromOrderNo(request_order_no, total);
    DBMS_OUTPUT.PUT_LINE('Total qty ordered for order ' || request_order_no || ' is ' || total);
END;
/

-- 2. For the given order number, calculate the Discount as follows:
-- For total amount > 2000 and total amount < 5000: Discount=5%
-- For total amount > 5000 and total amount < 10000: Discount=10%
-- For total amount > 10000: Discount=20%
-- Calculate the total amount (after the discount) and update the same in
-- orders table

CREATE OR REPLACE FUNCTION CalculateDiscountFromTotal
(
    total IN pizza.unit_price%TYPE
)
RETURN FLOAT
AS
BEGIN
    IF total > 10000 THEN
        RETURN 0.20;
    ELSIF total > 5000 THEN
        RETURN 0.10;
    ELSIF total > 2000 THEN
        RETURN 0.05;
    ELSE 
        RETURN 0.00;
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE displayOrderInformation
(
    p_order_no orders.order_no%TYPE
)
AS
v_total_amt FLOAT;
v_total_qty NUMBER;
v_discount FLOAT;
v_cust_info customer%ROWTYPE;
v_order_date orders.order_date%TYPE;
CURSOR cur_order_info
IS
SELECT 
ROW_NUMBER() OVER (ORDER BY p.pizza_id) as SNo,
    p.pizza_type as Pizza,
    ol.qty as Qty,
    p.unit_price as Price,
    ol.qty * p.unit_price as Amount
FROM order_list ol
JOIN pizza p
ON ol.pizza_id = p.pizza_id
WHERE ol.order_no = p_order_no;
roi cur_order_info%ROWTYPE;

BEGIN
    SELECT * INTO v_cust_info
    FROM customer c
    WHERE c.cust_id = (
        SELECT o.cust_id
        FROM orders o
        WHERE o.order_no = p_order_no
    );

    SELECT o.order_date INTO v_order_date
    FROM orders o
    WHERE o.order_no = p_order_no;

    DBMS_OUTPUT.PUT_LINE('Order Number: ' || p_order_no || 'Customer Name: ' || v_cust_info.cust_name);
    DBMS_OUTPUT.PUT_LINE('Order Date: ' || v_order_date || 'Phone: ' || v_cust_info.phone);
    DBMS_OUTPUT.PUT_LINE('*****************************************************');

    v_total_amt := 0.00;
    v_total_qty := 0;

    DBMS_OUTPUT.PUT_LINE('SNo Pizza Type Qty Price Amount');
    OPEN cur_order_info;
    LOOP
        FETCH cur_order_info INTO roi;
        EXIT WHEN cur_order_info%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(roi.SNo || ' ' || roi.Pizza || ' ' || roi.Qty || ' ' || roi.Price || ' ' || roi.Amount);
        v_total_amt := v_total_amt + roi.Amount;
        v_total_qty := v_total_qty + roi.Qty;
    END LOOP;
    CLOSE cur_order_info;

    SELECT CalculateDiscountFromTotal(v_total_amt) INTO v_discount
    FROM dual;

    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total: ' || v_total_qty || ' ' || v_total_amt);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total Amount: Rs.' || v_total_amt);
    DBMS_OUTPUT.PUT_LINE('Discount (' ||v_discount*100 || '%): Rs.' || v_total_amt*v_discount);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Amount to be paid: Rs.' || v_total_amt*(1-v_discount));
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Great Offers! Up to 25% on DIWALI Festival Day..');
    DBMS_OUTPUT.PUT_LINE('*****************************************************');

    UPDATE orders
    SET Total_Amount = v_total_amt*(1-v_discount)
    WHERE orders.order_no = p_order_no;

END;
/


ACCEPT user_no PROMPT 'Give the order no: ';

DECLARE
v_order_no orders.order_no%TYPE;
BEGIN
    v_order_no := '&user_no';
    displayOrderInformation(v_order_no);
END;
/

SELECT * FROM orders;

REM: 3. Write a stored function to display the customer name who ordered highest among the total number of pizzas for a given pizza type.

CREATE OR REPLACE FUNCTION MostProlificCust
(
    p_pizza_type pizza.pizza_type%TYPE
)
RETURN customer.cust_name%TYPE
AS

CURSOR cur_most_pizza
IS
SELECT c.cust_id as id, SUM(ol.qty) as total_qty
FROM customer c
JOIN orders o
ON c.cust_id = o.cust_id
JOIN order_list ol
ON ol.order_no = o.order_no
JOIN pizza p
ON p.pizza_id = ol.pizza_id
GROUP BY c.cust_id, p.pizza_type
HAVING p.pizza_type = p_pizza_type
ORDER BY SUM(ol.qty) DESC;

r_most_pizza cur_most_pizza%ROWTYPE;
most_name customer.cust_name%TYPE;

BEGIN 
    OPEN cur_most_pizza;
    FETCH cur_most_pizza INTO r_most_pizza;

    SELECT c.cust_name INTO most_name
    FROM customer c
    WHERE c.cust_id = r_most_pizza.id;

    DBMS_OUTPUT.PUT_LINE('Name: ' || most_name || ' Qty: ' || r_most_pizza.total_qty);
    RETURN most_name;
END;
/

ACCEPT user_pizza PROMPT "Give the pizza type: ";

DECLARE
v_pizza_type pizza.pizza_type%TYPE;
v_most_orderer customer.cust_name%TYPE;
BEGIN
    v_pizza_type := '&user_pizza';
    SELECT MostProlificCust(v_pizza_type) INTO v_most_orderer
    FROM dual;
END;
/

REM 4. Implement Question (2) using a stored function to return the amount to be paid and update the same, for the given order number.

CREATE OR REPLACE FUNCTION CalculateDiscountFromTotal
(
    total IN pizza.unit_price%TYPE
)
RETURN FLOAT
AS
BEGIN
    IF total > 10000 THEN
        RETURN 0.20;
    ELSIF total > 5000 THEN
        RETURN 0.10;
    ELSIF total > 2000 THEN
        RETURN 0.05;
    ELSE 
        RETURN 0.00;
    END IF;
END;
/

CREATE OR REPLACE FUNCTION getAmountPaid
(
    p_order_no orders.order_no%TYPE
)
RETURN FLOAT
AS
v_total_amt FLOAT;
v_total_qty NUMBER;
v_discount FLOAT;
v_cust_info customer%ROWTYPE;
v_order_date orders.order_date%TYPE;
CURSOR cur_order_info
IS
SELECT 
ROW_NUMBER() OVER (ORDER BY p.pizza_id) as SNo,
    p.pizza_type as Pizza,
    ol.qty as Qty,
    p.unit_price as Price,
    ol.qty * p.unit_price as Amount
FROM order_list ol
JOIN pizza p
ON ol.pizza_id = p.pizza_id
WHERE ol.order_no = p_order_no;
roi cur_order_info%ROWTYPE;

BEGIN
    SELECT * INTO v_cust_info
    FROM customer c
    WHERE c.cust_id = (
        SELECT o.cust_id
        FROM orders o
        WHERE o.order_no = p_order_no
    );

    SELECT o.order_date INTO v_order_date
    FROM orders o
    WHERE o.order_no = p_order_no;

    DBMS_OUTPUT.PUT_LINE('Order Number: ' || p_order_no || 'Customer Name: ' || v_cust_info.cust_name);
    DBMS_OUTPUT.PUT_LINE('Order Date: ' || v_order_date || 'Phone: ' || v_cust_info.phone);
    DBMS_OUTPUT.PUT_LINE('*****************************************************');

    v_total_amt := 0.00;
    v_total_qty := 0;

    DBMS_OUTPUT.PUT_LINE('SNo Pizza Type Qty Price Amount');
    OPEN cur_order_info;
    LOOP
        FETCH cur_order_info INTO roi;
        EXIT WHEN cur_order_info%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(roi.SNo || ' ' || roi.Pizza || ' ' || roi.Qty || ' ' || roi.Price || ' ' || roi.Amount);
        v_total_amt := v_total_amt + roi.Amount;
        v_total_qty := v_total_qty + roi.Qty;
    END LOOP;
    CLOSE cur_order_info;

    SELECT CalculateDiscountFromTotal(v_total_amt) INTO v_discount
    FROM dual;

    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total: ' || v_total_qty || ' ' || v_total_amt);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total Amount: Rs.' || v_total_amt);
    DBMS_OUTPUT.PUT_LINE('Discount (' ||v_discount*100 || '%): Rs.' || v_total_amt*v_discount);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Amount to be paid: Rs.' || v_total_amt*(1-v_discount));
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Great Offers! Up to 25% on DIWALI Festival Day..');
    DBMS_OUTPUT.PUT_LINE('*****************************************************');
    RETURN v_total_amt;

END;
/

SET SERVEROUTPUT ON;
ACCEPT user_no PROMPT 'Give the order no: ';

DECLARE
v_order_no orders.order_no%TYPE;
v_total_amt_after_discount FLOAT;
BEGIN
    v_order_no := '&user_no';
    SELECT getAmountPaid(v_order_no) INTO v_total_amt_after_discount
    FROM dual;
    UPDATE orders
    SET Total_Amount = v_total_amt_after_discount
    WHERE orders.order_no = v_order_no;
END;
/

SELECT * FROM orders;








