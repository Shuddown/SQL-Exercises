REM: DELETING TABLES
DROP TABLE ship_detail;
DROP TABLE order_detail;
DROP TABLE part;
DROP TABLE employee;
DROP TABLE customer;
DROP TABLE city;

REM: Creating table city

CREATE TABLE city(
  pin INT CONSTRAINT c_pin_pk PRIMARY KEY,
  city VARCHAR(100)
);

REM: Describing city

DESC city;

REM: INSERTING VALUES INTO city

INSERT INTO city VALUES(603103, 'Chennai');
INSERT INTO city VALUES(100000, 'Coimbatore');

REM: CHECKING PRIMARY KEY CONSTRAINT FOR PIN 

INSERT INTO city VALUES(NULL, 'Hyderabad');
INSERT INTO city VALUES(603103, 'Hyderabad');

REM: DISPLAYING city

SELECT * FROM city;

REM: Creating table employee
create table employee(
  emp_num CHAR(4) constraint e_num_pk PRIMARY KEY constraint e_num_check CHECK (REGEXP_LIKE(emp_num, 'E[0-9]*')),
  emp_name VARCHAR(100),
  dob DATE,
  pin INT constraint e_pin_fk references city(pin)
);

REM: Describing employee

DESC employee;
REM: INSERTING VALUES INTO employee

INSERT INTO employee VALUES('E001', 'John', DATE '2004-06-07', 603103);
INSERT INTO employee VALUES('E002', 'Jack', DATE '2004-06-08', 603103);

REM: CHECKING PRIMARY KEY CONSTRAINT FOR emp_num 

INSERT INTO employee VALUES(NULL, 'John', DATE '2004-06-07', 603103);
INSERT INTO employee VALUES('E001', 'John', DATE '2004-06-07', 603103);

REM: Checking the formatting check constraint for emp_num

INSERT INTO employee VALUES('B003', 'John', DATE '2004-06-07', 603103);

REM: Checking foreign key CONSTRAINT

INSERT INTO employee VALUES('E003', 'John', DATE '2004-06-07', 200000);

REM: DISPLAYING employee

SELECT * FROM employee;

REM: Creating table customer
CREATE TABLE customer(
  cust_num CHAR(4) CONSTRAINT c_num_pk PRIMARY KEY CONSTRAINT c_num_check CHECK (REGEXP_LIKE(cust_num, 'C[0-9]*')),
  cust_name VARCHAR(100),
  street VARCHAR(100),
  pin INT constraint c_pin_fk REFERENCES city(pin),
  dob DATE,
  phone_no NUMBER(10) constraint c_phone_uq UNIQUE
);

REM: Describing customer
DESC customer;

REM: INSERTING VALUES INTO customer

INSERT INTO customer VALUES('C001', 'John', 'Jane Street', 603103, DATE '2004-06-07', 1234445556);
INSERT INTO customer VALUES('C002', 'Jane', 'Jane Street', 603103, DATE '2004-06-08', 3456778899);

REM: CHECKING PRIMARY KEY CONSTRAINT FOR cust_num


INSERT INTO customer VALUES('C002', 'Jane', 'Jane Street', 603103, DATE '2004-06-08', 3400000000);
INSERT INTO customer VALUES(NULL, 'Jane', 'Jane Street', 603103, DATE '2004-06-08', 3459988899);


REM: Checking formatting constraint for cust_num


INSERT INTO customer VALUES('D002', 'Jane', 'Jane Street', 603103, DATE '2004-06-08', 5456778899);


REM: Checking foreign key constraing of pin

INSERT INTO customer VALUES('C003', 'Jane', 'Jane Street', 200000, DATE '2004-06-08', 3406778899);

REM: Checking the unique constraint of phone_no

INSERT INTO customer VALUES('C004', 'Jane', 'Jane Street', 100000, DATE '2004-06-08', 3456778899);
REM: DISPLAYING customer

SELECT * FROM customer;

REM: Creating table part

CREATE TABLE part(
  part_num CHAR(4) CONSTRAINT p_num_pk PRIMARY KEY CONSTRAINT p_num_check CHECK (REGEXP_LIKE(part_num, 'P[0-9]*')),
  part_name VARCHAR(100), 
  price FLOAT CONSTRAINT p_price_nn NOT NULL,
  quantity INT CONSTRAINT p_qty_check CHECK (quantity > 0)
);

REM: Describing table PART

DESC part;

REM: Inserting values into part 

INSERT INTO part VALUES('P001', 'Screws', 300, 10);
INSERT INTO part VALUES('P002', 'Oil', 488, 37);

REM: Checking part_num primary key CONSTRAINT

INSERT INTO part VALUES(NULL, 'Scrap', 488, 37);
INSERT INTO part VALUES('P002', 'bil', 488, 37);

REM: Checking part_num check CONSTRAINT

INSERT INTO part VALUES('R002', 'bil', 488, 37);

REM: Checking price not null CONSTRAINT

INSERT INTO part VALUES('P003', 'bil', NULL, 37);

REM: Checking quantity check CONSTRAINT

INSERT INTO part VALUES('P003', 'bil', 455, 0);

REM: Displaying part TABLE

SELECT * FROM part;

REM: Creating table order_details

CREATE TABLE order_detail(
  order_num CHAR(4),
  CONSTRAINT od_num_pk PRIMARY KEY(order_num),
  CONSTRAINT od_num_check CHECK (REGEXP_LIKE(order_num, 'O[0-9]*')),
  cust_num CHAR(4),
  CONSTRAINT od_cust_check CHECK (REGEXP_LIKE(cust_num, 'C[0-9]*')),
  CONSTRAINT od_cust_fk FOREIGN KEY (cust_num) REFERENCES customer(cust_num),
  emp_num CHAR(4),
  CONSTRAINT od_emp_check CHECK (REGEXP_LIKE(emp_num, 'E[0-9]*')), 
  CONSTRAINT od_emp_fk FOREIGN KEY (emp_num) REFERENCES employee(emp_num),
  ship_date DATE,
  rec_date DATE,
  CONSTRAINT od_date_check CHECK (rec_date > ship_date)
);

REM: Describing order_detail

DESC order_detail;

REM: Inserting values into order_detail 

INSERT INTO order_detail VALUES('O001', 'C001', 'E001', DATE '2010-11-23', DATE '2010-12-04');
INSERT INTO order_detail VALUES('O002', 'C002', 'E002', DATE '2011-11-23', DATE '2011-12-04');

REM: Checking order_num primary key CONSTRAINT

INSERT INTO order_detail VALUES(NULL, 'C002', 'E002', DATE '2011-11-23', DATE '2011-12-04');
INSERT INTO order_detail VALUES('O002', 'C002', 'E002', DATE '2011-11-23', DATE '2011-12-04');

REM: Checking order_num check CONSTRAINT

INSERT INTO order_detail VALUES('B003', 'C002', 'E002', DATE '2011-11-23', DATE '2011-12-04');

REM: Checking cust_num check CONSTRAINT and FOREIGN KEY constraint

INSERT INTO order_detail VALUES('O003', 'D002', 'E002', DATE '2011-11-23', DATE '2011-12-04');
INSERT INTO order_detail VALUES('O003', 'C003', 'E002', DATE '2011-11-23', DATE '2011-12-04');


REM: Checking emp_num check CONSTRAINT and FOREIGN KEY CONSTANT

INSERT INTO order_detail VALUES('O003', 'C002', 'L002', DATE '2011-11-23', DATE '2011-12-04');
INSERT INTO order_detail VALUES('O003', 'C002', 'E003', DATE '2011-11-23', DATE '2011-12-04');

REM: Checking ship date order date check CONSTRAINT

INSERT INTO order_detail VALUES('O003', 'C002', 'E002', DATE '2011-12-23', DATE '2011-12-04');

REM: Displaying  order_detail `TABLE

SELECT * FROM order_detail;

REM: Creating table ship_detail

CREATE TABLE ship_detail(
  order_num CHAR(4),
  CONSTRAINT sd_order_check CHECK (REGEXP_LIKE(order_num, 'O[0-9]*')), 
  CONSTRAINT sd_order_fk FOREIGN KEY (order_num) REFERENCES order_detail(order_num),
  part_num CHAR(4),
  CONSTRAINT sd_part_check CHECK (REGEXP_LIKE(part_num, 'P[0-9]*')),
  CONSTRAINT sd_part_fk FOREIGN KEY (part_num) REFERENCES part(part_num),
  quantity INT CONSTRAINT sd_qty_check CHECK (quantity > 0),
  PRIMARY KEY (order_num, part_num)
);

REM: Describing ship_detail

DESC ship_detail;

REM:inserting values into ship_detail

INSERT INTO ship_detail VALUES('O001', 'P001', 2);
INSERT INTO ship_detail VALUES('O002', 'P002', 3);

REM: Checking order_num check constraint and foreign key CONSTRAINT

INSERT INTO ship_detail VALUES('B001', 'P001', 2);
INSERT INTO ship_detail VALUES('O003', 'P001', 2);

REM: Checking part_num check constraint and foreign key CONSTRAINT


INSERT INTO ship_detail VALUES('O001', 'B001', 2);
INSERT INTO ship_detail VALUES('O001', 'P003', 2);

REM: Checking quantity check CONSTRAINT


INSERT INTO ship_detail VALUES('O002', 'P001', -1);

REM: Checking Composite key (order_num, part_num)


INSERT INTO ship_detail VALUES(NULL, 'P001', 2);
INSERT INTO ship_detail VALUES('O001', NULL, 2);


INSERT INTO ship_detail VALUES('O001', 'P002', 5);
INSERT INTO ship_detail VALUES('O002', 'P001', 5);
INSERT INTO ship_detail VALUES('O001', 'P001', 5);

REM: Displaying ship_detail

SELECT * FROM ship_detail;


REM: ALTERING TABLES

REM: Adding reorder_level to part
ALTER TABLE part ADD reorder_level INT;
INSERT INTO part VALUES('P003', 'Hammers', 300, 10, 3);
SELECT * FROM part;

REM: Adding hiredate to employee 
ALTER TABLE employee ADD hiredate DATE;
INSERT INTO employee VALUES('E003', 'John', DATE '2004-06-07', 603103, DATE '2020-12-13');
SELECT * FROM employee;

REM: Modifying cust_name to make it longer 
ALTER TABLE customer MODIFY cust_name VARCHAR(150);
INSERT INTO customer VALUES('C003', 'Jane is very cool and is the greatest person ever, yeah totally amazing ', 'Jane Street', 603103, DATE '2004-06-08', 3456978899);
SELECT * FROM customer;

REM: Dropping dob column from customer
ALTER TABLE customer DROP COLUMN dob;
SELECT * FROM customer;

REM: Making sure receive date is not null
ALTER TABLE order_detail ADD CONSTRAINT od_rec_nn CHECK (rec_date IS NOT NULL);
INSERT INTO order_detail VALUES('O003', 'C001', 'E001', DATE '2010-11-23', NULL);
SELECT * FROM order_detail;

REM: Making sure on removing details of an order, all corresponding details are also deleted
ALTER TABLE ship_detail DROP CONSTRAINT sd_order_fk;
ALTER TABLE ship_detail 
  ADD CONSTRAINT sd_order_fk 
  FOREIGN KEY (order_num) 
  REFERENCES order_detail(order_num) 
  ON DELETE CASCADE;

DELETE FROM order_detail WHERE order_num = 'O001';
SELECT * FROM order_detail;
SELECT * FROM ship_detail;

