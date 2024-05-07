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

ALTER TABLE orders ADD total_amount FLOAT;

REM: 1. Ensure that the pizza can be delivered on same day or on the next day only.



CREATE OR REPLACE TRIGGER orders_check_dates
BEFORE INSERT OR UPDATE ON orders
FOR EACH ROW
DECLARE
    v_days_diff NUMBER;
BEGIN
    v_days_diff := TO_DATE(:NEW.delv_date, 'DD/MM/YYYY') - TO_DATE(:NEW.order_date, 'DD/MM/YYYY');
    IF v_days_diff > 1 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Delivery date cannot be more than one day after the order date.');
    END IF;
END;
/



REM:2. Update the total_amt in ORDERS while entering an order in ORDER_LIST.


CREATE OR REPLACE TRIGGER orders_add_total_amount
AFTER INSERT OR UPDATE OR DELETE ON order_list
FOR EACH ROW
DECLARE 
    unit_price pizza.unit_price%TYPE;
    old_unit_price pizza.unit_price%TYPE;
BEGIN
    IF INSERTING THEN
        SELECT p.unit_price INTO unit_price
        FROM pizza p
        WHERE p.pizza_id = :NEW.pizza_id;
        UPDATE orders o
        SET o.total_amount = CASE WHEN o.total_amount IS NULL THEN :NEW.qty * unit_price
                                  ELSE o.total_amount + :NEW.qty * unit_price
                              END
        WHERE o.order_no = :NEW.order_no; 
    ELSIF UPDATING THEN
        SELECT p.unit_price INTO unit_price
        FROM pizza p
        WHERE p.pizza_id = :NEW.pizza_id;
        SELECT p.unit_price INTO old_unit_price
        FROM pizza p
        WHERE p.pizza_id = :OLD.pizza_id;
        UPDATE orders o
        SET o.total_amount = o.total_amount - :OLD.qty * old_unit_price + :NEW.qty * unit_price
        WHERE o.order_no = :NEW.order_no; 
    ELSIF DELETING THEN
        SELECT p.unit_price INTO old_unit_price
        FROM pizza p
        WHERE p.pizza_id = :OLD.pizza_id;
        UPDATE orders o
        SET o.total_amount = o.total_amount - :OLD.qty * old_unit_price
        WHERE o.order_no = :OLD.order_no; 
    END IF;
END;
/




REM: 3.To give preference to all customers in delivery of pizzas’, a threshold is set on the number of orders per day per customer. Ensure that a customer can not place more than 5 orders per day

CREATE OR REPLACE TRIGGER NO_MORE_FIVE_ORDERS
BEFORE INSERT OR UPDATE ON orders
FOR EACH ROW
DECLARE 
    v_orders_today NUMBER;
BEGIN
    SELECT COUNT(o.order_no) INTO v_orders_today
    FROM orders o
    GROUP BY o.cust_id, o.order_date
    HAVING o.cust_id = :NEW.cust_id
    AND o.order_date = :NEW.order_date;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        v_orders_today := 0;

    BEGIN
        IF v_orders_today >= 5 THEN
            RAISE_APPLICATION_ERROR(-20002, 'One customer cannot give more than 5 orders a day!');
        END IF;
    END;
END;
/

insert into customer values('c001','Hari','32 RING ROAD,ALWARPET',9001200031);
insert into orders values('OP100','c001','29-JUN-2015','30-JUN-2015', 20000);
SELECT * FROM orders;
DELETE FROM customer;

@Z:\Pizza_DB.sql
