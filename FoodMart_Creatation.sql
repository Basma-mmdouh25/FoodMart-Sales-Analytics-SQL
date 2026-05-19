CREATE DATABASE FoodMart_Sales;
use FoodMart_Sales;
CREATE TABLE Region (
    region_id       INT PRIMARY KEY,
    sales_district  NVARCHAR(100),
    sales_region    NVARCHAR(100)
);
-- CUSTOMER
CREATE TABLE Customer (
    customer_id             INT PRIMARY KEY,
    customer_acct_num       NVARCHAR(50),
    first_name              NVARCHAR(50),
    last_name               NVARCHAR(50),
    customer_address        NVARCHAR(200),
    customer_city           NVARCHAR(100),
    customer_state_province NVARCHAR(50),
    customer_postal_code    NVARCHAR(20),
    customer_country        NVARCHAR(50),
    birthdate               DATE,
    marital_status          CHAR(1),
    yearly_income           NVARCHAR(20),
    gender                  CHAR(1),
    total_children          INT,
    num_children_at_home    INT,
    education               NVARCHAR(50),
    acct_open_date          DATE,
    member_card             NVARCHAR(20),
    occupation              NVARCHAR(50),
    homeowner               CHAR(1)
);

-- PRODUCT
CREATE TABLE Product (
    product_id           INT PRIMARY KEY,
    product_brand        NVARCHAR(100),
    product_name         NVARCHAR(200),
    product_sku          NVARCHAR(50),
    product_retail_price DECIMAL(10,2),
    product_cost         DECIMAL(10,2),
    product_weight       DECIMAL(10,2),
    recyclable           BIT,
    low_fat              BIT
);



-- TRANSACTIONS (combined 1997 + 1998)
CREATE TABLE Transactions (
    transaction_id   INT AUTO_INCREMENT PRIMARY KEY,
    transaction_date DATE,
    stock_date       DATE,
    product_id       INT REFERENCES Product(product_id),
    customer_id      INT REFERENCES Customer(customer_id),
    store_id         INT REFERENCES Store(store_id),
    quantity         INT
);