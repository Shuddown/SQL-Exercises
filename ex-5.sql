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

@Z:\Pizza_DB.sql
SET SERVEROUTPUT ON;
ACCEPT p_type PROMPT 'Give the pizza type: ';
DECLARE 
    v_type VARCHAR2(50);
    v_price FLOAT;

BEGIN
    v_type := '&p_type';

    BEGIN
        SELECT unit_price INTO v_price FROM pizza WHERE pizza_type = v_type;
        DBMS_OUTPUT.PUT_LINE('Pizza ' || v_type || ' exists, price: ' || v_price);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Pizza type ' || v_type || ' does not exist.');
    END;
END;
/

REM: For the given customer name and a range of order date, find whether a customer had placed any order, if so display the number of orders placed by the customer along with the order number(s).

ACCEPT c_name PROMPT 'What is the customer name: ';
ACCEPT s_date PROMPT 'What is the start date: ';
ACCEPT e_date PROMPT 'What is the end date: ';


DECLARE
    custo_name customer.cust_name%type;
    start_date orders.delv_date%type;
    end_date orders.delv_date%type;
    total NUMBER;
    ordernum orders.order_no%type;
    CURSOR orderss (cname custo_name%type) IS
        SELECT
            O.ORDER_NO
        FROM
            ORDERS   O,
            CUSTOMER C
        WHERE
            O.CUST_ID = C.CUST_ID
            AND C.CUST_NAME = cname;


BEGIN
    custo_name := '&c_name';
    start_date := TO_DATE('&s_date', 'DD-MON-YYYY');
    end_date := TO_DATE('&e_date', 'DD-MON-YYYY');

    BEGIN
        SELECT COUNT(o.order_no) into total
        FROM customer c
        JOIN orders o
        ON o.cust_id = c.cust_id
        WHERE o.order_date BETWEEN start_date AND end_date
        AND c.cust_name = custo_name;


        IF total > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Name: ' || custo_name || ' Total orders: ' || total);
            OPEN orderss(custo_name);
            LOOP
                FETCH orderss INTO ordernum;
                EXIT WHEN orderss%NOTFOUND;

                DBMS_OUTPUT.PUT_LINE('ORDER_NO: ' || ordernum);
            END LOOP;
            CLOSE orderss;


        ELSE
            DBMS_OUTPUT.PUT_LINE('NO RECORDS FOUND!');
        END IF;



    END;
END;
/


REM: 3. Display the customer name along with the details of pizza type and its quantity ordered for the given order number. Also find the total quantity ordered for the given order number as shown below:


ACCEPT oid PROMPT 'What is the order number: '

DECLARE
id orders.order_no%TYPE;
cname customer.cust_name%type;
CURSOR pizza_info(o_id id%type) IS
SELECT ol.pizza_type, ol.qty
FROM ol
WHERE ol.order_no = o_id;

v_type pizza.pizza_type%type
v_qty order_list.qty%TYPE





BEGIN
    id := '&oid'

    SELECT c.cust_name INTO cname
    FROM customer c 
    JOIN orders o 


