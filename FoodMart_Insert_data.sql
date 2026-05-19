use foodmart_sales;

LOAD DATA LOCAL INFILE 'E:/FoodMart_Sales Data/FoodMart_Sales Data/Region-Lookup.csv'
INTO TABLE Region
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- =========================
-- STORE
-- =========================

LOAD DATA LOCAL INFILE "E:\\FoodMart_Sales Data\\FoodMart_Sales Data\\Store-Lookup.csv"
INTO TABLE Store
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;



-- =========================
-- CUSTOMER STAGING
-- =========================

DROP TABLE IF EXISTS Customer_Staging;

CREATE TABLE Customer_Staging (
    customer_id             VARCHAR(50),
    customer_acct_num       VARCHAR(50),
    first_name              VARCHAR(50),
    last_name               VARCHAR(100),
    customer_address        VARCHAR(200),
    customer_city           VARCHAR(100),
    customer_state_province VARCHAR(50),
    customer_postal_code    VARCHAR(20),
    customer_country        VARCHAR(50),
    birthdate               VARCHAR(20),
    marital_status          VARCHAR(10),
    yearly_income           VARCHAR(30),
    gender                  VARCHAR(10),
    total_children          VARCHAR(10),
    num_children_at_home    VARCHAR(10),
    education               VARCHAR(50),
    acct_open_date          VARCHAR(20),
    member_card             VARCHAR(20),
    occupation              VARCHAR(50),
    homeowner               VARCHAR(10)
);



LOAD DATA LOCAL INFILE "E:\\FoodMart_Sales Data\\FoodMart_Sales Data\\Customer-Lookup-Clean.csv"
INTO TABLE Customer_Staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


INSERT INTO Customer
SELECT
    CAST(customer_id AS UNSIGNED),
    customer_acct_num,
    first_name,
    last_name,
    customer_address,
    customer_city,
    customer_state_province,
    customer_postal_code,
    customer_country,
    STR_TO_DATE(birthdate, '%m/%d/%Y'),
    LEFT(marital_status, 1),
    yearly_income,
    LEFT(gender, 1),
    CAST(total_children AS UNSIGNED),
    CAST(num_children_at_home AS UNSIGNED),
    education,
    STR_TO_DATE(acct_open_date, '%m/%d/%Y'),
    member_card,
    occupation,
    LEFT(homeowner, 1)
FROM Customer_Staging;


DROP TABLE Customer_Staging;


-- =========================
-- PRODUCT
-- =========================

LOAD DATA LOCAL INFILE "E:\\FoodMart_Sales Data\\FoodMart_Sales Data\\Product-Lookup.csv"
INTO TABLE Product
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;



-- =========================
-- TRANSACTIONS STAGING
-- =========================

CREATE TABLE Transactions_Staging (
    transaction_date  VARCHAR(20),
    stock_date        VARCHAR(20),
    product_id        INT,
    customer_id       INT,
    store_id          INT,
    quantity          INT
);



-- =========================
-- LOAD 1997
-- =========================

LOAD DATA LOCAL INFILE "E:\\FoodMart_Sales Data\\FoodMart_Sales Data\\Orders\\FoodMart-Transactions-1997.csv"
INTO TABLE Transactions_Staging
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


INSERT INTO Transactions
(transaction_date, stock_date, product_id, customer_id, store_id, quantity)
SELECT
    STR_TO_DATE(transaction_date, '%m/%d/%Y'),
    STR_TO_DATE(stock_date, '%m/%d/%Y'),
    product_id,
    customer_id,
    store_id,
    quantity
FROM Transactions_Staging;





TRUNCATE TABLE Transactions_Staging;


-- =========================
-- LOAD 1998
-- =========================

LOAD DATA LOCAL INFILE "E:\\FoodMart_Sales Data\\FoodMart_Sales Data\\Orders\\FoodMart-Transactions-1998.csv"
INTO TABLE Transactions_Staging
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


INSERT INTO Transactions
(transaction_date, stock_date, product_id, customer_id, store_id, quantity)
SELECT
    STR_TO_DATE(transaction_date, '%m/%d/%Y'),
    STR_TO_DATE(stock_date, '%m/%d/%Y'),
    product_id,
    customer_id,
    store_id,
    quantity
FROM Transactions_Staging;

DROP TABLE Transactions_Staging;

