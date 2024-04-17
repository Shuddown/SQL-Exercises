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

REM: Using Joins

REM:1. For each pizza, display the total quantity ordered by the customers
SELECT
    PIZZA.PIZZA_ID      AS PIZZA_ID,
    PIZZA.PIZZA_TYPE    AS TYPE,
    SUM(ORDER_LIST.QTY) AS QTY
FROM
    PIZZA
    INNER JOIN ORDER_LIST
    ON PIZZA.PIZZA_ID = ORDER_LIST.PIZZA_ID
GROUP BY
    PIZZA.PIZZA_ID,
    PIZZA.PIZZA_TYPE
ORDER BY
    QTY DESC;

REM: 2. Find the pizza types not delivered on that DAY
SELECT
    PIZZA.PIZZA_TYPE  AS PIZZA_TYPE,
    ORDERS.ORDER_DATE,
    ORDERS.DELV_DATE
FROM
    ORDER_LIST
    INNER JOIN PIZZA
    ON ORDER_LIST.PIZZA_ID = PIZZA.PIZZA_ID
    INNER JOIN ORDERS
    ON ORDER_LIST.ORDER_NO = ORDERS.ORDER_NO
WHERE
    (ORDERS.ORDER_DATE <> ORDERS.DELV_DATE);

REM: 3.Display the number of order(s) placed by each customer whether or not he/she placed the order.
SELECT
    CUSTOMER.CUST_ID,
    CUSTOMER.CUST_NAME,
    COUNT(ORDERS.ORDER_NO) AS NUM_ORDERS
FROM
    ORDERS
    INNER JOIN CUSTOMER
    ON ORDERS.CUST_ID = CUSTOMER.CUST_ID
GROUP BY
    CUSTOMER.CUST_ID,
    CUSTOMER.CUST_NAME;

REM: 4.Display the pairs of pizza types for where first pair has more qty than second pair
SELECT
    P.PIZZA_TYPE  AS GREATER,
    O.QTY         AS QTY,
    P2.PIZZA_TYPE AS LESSER,
    O2.QTY        AS QTY
FROM
    ORDER_LIST O
    JOIN PIZZA P
    ON P.PIZZA_ID = O.PIZZA_ID
    JOIN ORDER_LIST O2
    ON O2.ORDER_NO = O.ORDER_NO
    JOIN PIZZA P2
    ON P2.PIZZA_ID = O2.PIZZA_ID
    AND P2.PIZZA_ID <> P.PIZZA_ID
WHERE
    O.ORDER_NO = 'OP100'
    AND O2.ORDER_NO = 'OP100'
    AND O.QTY > O2.QTY;

REM: Sub Queries

REM: 5. Display the details (order number, pizza type, customer name, qty) of the pizza with ordered quantity more than the average ordered quantity of pizzas.

SELECT
    ORDERS.ORDER_NO,
    PIZZA.PIZZA_TYPE,
    CUSTOMER.CUST_NAME,
    ORDER_LIST.QTY
FROM
    ORDERS,
    PIZZA,
    CUSTOMER,
    ORDER_LIST
WHERE
    ORDER_LIST.QTY > (
        SELECT
            AVG(QTY)
        FROM
            ORDER_LIST
    )
    AND ORDERS.ORDER_NO = ORDER_LIST.ORDER_NO
    AND ORDERS.CUST_ID = CUSTOMER.CUST_ID
    AND PIZZA.PIZZA_ID = ORDER_LIST.PIZZA_ID;

REM: 6. Find the customers who ordered more than one pizza type in each order.

SELECT
    C.CUST_ID,
    C.CUST_NAME
FROM
    CUSTOMER C
WHERE
    (
        SELECT
            COUNT(DISTINCT(OL.PIZZA_ID))
        FROM
            ORDER_LIST OL,
            ORDERS     O
        WHERE
            O.CUST_ID = C.CUST_ID
            AND O.ORDER_NO = OL.ORDER_NO
    ) > 1;
REM: TEST


SELECT
    AVG(ORDER_LIST.QTY)
FROM
    ORDER_LIST
GROUP BY
    ORDER_LIST.PIZZA_ID;

REM: 7. Display the details (order number, pizza type, customer name, qty) of the pizza with ordered quantity more than the average ordered quantity of each pizza type.

SELECT
    ORDERS.ORDER_NO,
    PIZZA.PIZZA_TYPE,
    CUSTOMER.CUST_NAME,
    ORDER_LIST.QTY
FROM
    ORDERS,
    PIZZA,
    CUSTOMER,
    ORDER_LIST
WHERE
    ORDER_LIST.QTY > (
        SELECT
            AVG(ORDER_LIST.QTY)
        FROM
            ORDER_LIST
        GROUP BY PIZZA.PIZZA_ID
    )
    AND ORDERS.ORDER_NO = ORDER_LIST.ORDER_NO
    AND ORDERS.CUST_ID = CUSTOMER.CUST_ID
    AND PIZZA.PIZZA_ID = ORDER_LIST.PIZZA_ID;


REM: 8. Display the details (order number, pizza type, customer name, qty) of the pizza with ordered quantity more than the average ordered quantity of its pizza type.

SELECT
    O.ORDER_NO,
    P.PIZZA_TYPE,
    C.CUST_NAME,
    OL.QTY
FROM
    ORDERS O,
    PIZZA P,
    CUSTOMER C,
    ORDER_LIST OL
WHERE
    OL.QTY > (
        SELECT
            AVG(OL2.QTY)
        FROM
            ORDER_LIST OL2
        WHERE OL2.PIZZA_ID = OL.PIZZA_ID
        GROUP BY P.PIZZA_ID
    )
    AND O.ORDER_NO = OL.ORDER_NO
    AND O.CUST_ID = C.CUST_ID
    AND P.PIZZA_ID = OL.PIZZA_ID;


REM: 9.Display the customer details who placed all pizza types in a single order

SELECT
    *
FROM
    CUSTOMER
WHERE
    (SELECT COUNT(DISTINCT(PIZZA.PIZZA_ID))
    FROM PIZZA) = (
        SELECT
            COUNT(DISTINCT(ORDER_LIST.PIZZA_ID))
        FROM
            ORDERS,
            ORDER_LIST
        WHERE
            ORDERS.ORDER_NO = ORDER_LIST.ORDER_NO
            AND CUSTOMER.CUST_ID = ORDERS.CUST_ID
        GROUP BY
            CUSTOMER.CUST_ID
    );

REM: 10. Display the order details that contains the pizza quantity more than the average pizza quantity or Pan or Italian Type Pizza.
SELECT
    *
FROM
    ORDERS     O
WHERE
    O.ORDER_NO IN(
        SELECT
            OL.ORDER_NO
        FROM
            ORDER_LIST OL
        GROUP BY
            OL.ORDER_NO
        HAVING
            SUM(OL.QTY) > (
                SELECT
                    AVG(OL.QTY)
                FROM
                    ORDER_LIST OL
                WHERE
                    OL.PIZZA_ID = (
                        SELECT
                            PIZZA_ID
                        FROM
                            PIZZA
                        WHERE
                            PIZZA.PIZZA_TYPE = 'italian'
                    )
                GROUP BY
                    OL.PIZZA_ID
            )
    )
UNION
SELECT
    *
FROM
    ORDERS     O
WHERE
    O.ORDER_NO IN(
        SELECT
            DISTINCT(OL.ORDER_NO)
        FROM
            ORDER_LIST OL
        GROUP BY
            OL.ORDER_NO
        HAVING
            SUM(OL.QTY) > (
                SELECT
                    AVG(OL.QTY)
                FROM
                    ORDER_LIST OL
                WHERE
                    OL.PIZZA_ID = (
                        SELECT
                            PIZZA_ID
                        FROM
                            PIZZA
                        WHERE
                            PIZZA.PIZZA_TYPE = 'pan'
                    )
                GROUP BY
                    OL.PIZZA_ID
            )
    );

REM: 11.Find the order(s) that contains Pan pizza but not the Italian pizza type.

SELECT
    O.ORDER_NO,
    O.CUST_ID,
    O.DELV_DATE
FROM
    ORDERS     O
WHERE
    O.ORDER_NO IN (
        SELECT
            DISTINCT(OL.ORDER_NO)
        FROM
            ORDER_LIST OL
        WHERE
            OL.PIZZA_ID = (
                SELECT
                    PIZZA_ID
                FROM
                    PIZZA
                WHERE
                    PIZZA_TYPE = 'pan'
            )
    ) MINUS
    SELECT
        O.ORDER_NO,
        O.CUST_ID,
        O.DELV_DATE
    FROM
        ORDERS     O
    WHERE
        O.ORDER_NO IN (
            SELECT
                DISTINCT(OL.ORDER_NO)
            FROM
                ORDER_LIST OL
            WHERE
                OL.PIZZA_ID = (
                    SELECT
                        PIZZA_ID
                    FROM
                        PIZZA
                    WHERE
                        PIZZA_TYPE = 'italian'
                )
        );

REM: 12.Display the customer(s) who ordered both Italian and Grilled pizza type.
SELECT
    *
FROM
    CUSTOMER
WHERE
    CUST_ID IN (
        SELECT
            DISTINCT(O.CUST_ID)
        FROM
            ORDERS     O,
            ORDER_LIST OL
        WHERE
            O.ORDER_NO = OL.ORDER_NO
            AND OL.PIZZA_ID = (
                SELECT
                    PIZZA_ID
                FROM
                    PIZZA
                WHERE
                    PIZZA_TYPE = 'italian'
            )
    ) INTERSECT
    SELECT
        *
    FROM
        CUSTOMER
    WHERE
        CUST_ID IN (
            SELECT
                DISTINCT(O.CUST_ID)
            FROM
                ORDERS     O,
                ORDER_LIST OL
            WHERE
                O.ORDER_NO = OL.ORDER_NO
                AND OL.PIZZA_ID = (
                    SELECT
                        PIZZA_ID
                    FROM
                        PIZZA
                    WHERE
                        PIZZA_TYPE = 'grilled'
                )
        );

SELECT
    PIZZA_ID
FROM
    PIZZA
WHERE
    PIZZA.PIZZA_TYPE = 'pan';

SELECT
    AVG(OL.QTY)
FROM
    ORDER_LIST OL
WHERE
    OL.PIZZA_ID = (
        SELECT
            PIZZA_ID
        FROM
            PIZZA
        WHERE
            PIZZA.PIZZA_TYPE = 'pan'
    )
GROUP BY
    OL.PIZZA_ID;
