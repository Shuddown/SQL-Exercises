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

@D:\Programming\SQL\Ex-3\Pizza_DB.sql

REM: 1. An user is interested to have list of pizza’s in the range of Rs.200-250. Create a view Pizza_200_250 which keeps the pizza details that has the price in the range of 200 to 250.

CREATE VIEW Pizza_200_250 AS
SELECT * FROM pizza
WHERE UNIT_PRICE BETWEEN 200 and 250;

SELECT * FROM Pizza_200_250

REM: This view is updateable as the query is simple, it contains no aggregate functions, group by functions and doesn't have any subqueries or joins, all the info also comes from the same table.

REM: 2. Pizza company owner is interested to know the number of pizza types ordered in each order.  Create a view Pizza_Type_Order that lists the number of pizza types ordered in each order.

CREATE VIEW Pizza_type_order AS
SELECT o.order_no, COUNT(ol.pizza_id)
FROM orders o
JOIN order_list ol
ON ol.ORDER_NO = o.ORDER_NO
GROUP_BY o.order_no;

SELECT * FROM Pizza_type_order;


REM: This view is not updateable as it contains an aggregate function, and relies on data from more than one table.

REM: 3. To know about the customers of Spanish pizza, create a view Spanish_Customers that list out the customer id, name, order_no of customers who ordered Spanish type

CREATE VIEW Spanish_Customers AS
SELECT c.cust_id, c.cust_name, o.order_no
FROM customer c
JOIN orders o
ON o.CUST_ID = c.CUST_ID
JOIN ORDER_LIST ol
ON ol.ORDER_NO = o.ORDER_NO
WHERE ol.PIZZA_ID = (
    SELECT PIZZA_ID
    FROM PIZZA
    WHERE PIZZA_TYPE = "spanish"
);

SELECT * FROM Spanish_Customers

REM: This view is not updateable as it relies on data from more than one table, and contains joins as well as subqueries.



