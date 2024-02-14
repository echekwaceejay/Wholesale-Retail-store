use store 
select * from orders
select * from supplier

ALTER TABLE orders
ADD COLUMN date_order_was_placed_new DATE,
ADD COLUMN delivery_date_new DATE;

UPDATE orders
SET date_order_was_placed_new = STR_TO_DATE(date_order_was_placed, '%m/%d/%Y'),
    delivery_date_new = STR_TO_DATE(delivery_date, '%m/%d/%Y');
    
ALTER TABLE orders
DROP COLUMN date_order_was_placed,
DROP COLUMN delivery_date;

-- PRODUCT CLASSIFICATION 
SELECT 
	COUNT(DISTINCT product_line) AS Product_l,
    COUNT(DISTINCT product_category) AS Product_c,
    COUNT(DISTINCT product_group) AS Product_g,
    COUNT(DISTINCT product_name) AS Product_n
FROM orders o
LEFT JOIN supplier s
	ON o.product_id = s.product_id;

SELECT 
	DISTINCT product_line AS Product_l
FROM supplier;
	
SELECT 
	DISTINCT product_category AS Product_cat
FROM supplier;

SELECT 
	DISTINCT product_group AS Product_g
FROM supplier;

    -- CUMULATIVE SALES EACH YEAR. HENCE 2019 AND 2021 HAS THE HIGHEST SALES REVENUE WITHIN THIS YEARS  
SELECT 
	YEAR(date_order_was_placed_new) AS Yr,
    ROUND(SUM(retail_price)) AS Sales
FROM orders
GROUP BY 1;

-- MONTHLY SALES FOR EACH YEAR 
SELECT 
	YEAR(date_order_was_placed_new) as Yr,
	MONTH(date_order_was_placed_new) AS Mon,
    ROUND(SUM(retail_price)) AS Sales
FROM orders
GROUP BY 1, 2;

-- 2019 AND 2021 HAS THE MOST SALES. WHICH MONTH HAS THE HIGEST SALES 
SELECT 
	YEAR(date_order_was_placed_new) as Yr,
	MONTH(date_order_was_placed_new) AS Mon,
    ROUND(SUM(retail_price)) AS Sales
FROM orders
WHERE YEAR(date_order_was_placed_new) IN ('2019', '2021')
GROUP BY 1, 2;

-- MONTH 12(DECEMBER) ARE THE DRIVER OF HIGER SALES IN THE BOTH YEARS. WHICH PRODUCT GROUP ARE DRIVING THIS SALES?

SELECT *
FROM 
(SELECT 
	YEAR(date_order_was_placed_new) AS Yr,
    MONTH(date_order_was_placed_new) AS Mon,
	product_group, -- THIS APPLY TO FINDING DRIVERS OF SALES IN (PRODUCT CATEGORY AND PRODUCT LINE)
    ROUND(SUM(retail_price)) AS Sales,
    RANK() OVER (PARTITION BY YEAR(date_order_was_placed_new) ORDER BY ROUND(SUM(retail_price))desc) AS Rank_sales
FROM orders o
LEFT JOIN supplier s
	ON o.product_id = s.product_id
WHERE YEAR(date_order_was_placed_new) IN ('2019', '2021')
	AND MONTH(date_order_was_placed_new) = 12
GROUP BY 1, 2, 3)e
WHERE e.Rank_sales = 1;

-- FINANCIAL STATUS. SALES REVENUE, PURCHASES AND PROFIT (2017 to 2021)
SELECT 
	YEAR(date_order_was_placed_new) AS Yr,
    ROUND(SUM(retail_price)) AS Sales,
    ROUND(SUM(cost_per_unit * quantity_ordered)) AS COGS,
    ROUND(SUM(retail_price)) - ROUND(SUM(cost_per_unit * quantity_ordered)) AS Gross_profit,
    ROUND((SUM(retail_price) - SUM(cost_per_unit * quantity_ordered)) / SUM(retail_price) * 100,2) AS Profit_margin
FROM orders 
GROUP BY 1
ORDER BY 1;

-- PRODUCT, DELIVERY AND SUPPLISERS PERFORMANCE
SELECT 
    supplier_country,
    supplier_name,
    COUNT(product_name) AS Num_product,
    SUM(quantity_ordered) AS Qty_ordered,
    ROUND(SUM(cost_per_unit * quantity_ordered)) AS Amount_supplied
FROM orders o
LEFT JOIN supplier s
	ON o.product_id = s.product_id
GROUP BY 1, 2
ORDER BY 1;

-- LEAD TIME
SELECT
	YEAR(date_order_was_placed_new) AS Yr,
    AVG(DATEDIFF(delivery_date_new, date_order_was_placed_new)) AS Lead_time
FROM orders
GROUP BY 1;

SELECT 
	product_line,
	COUNT(CASE WHEN product_line = 'Children' THEN product_name ELSE NULL END) AS Children_product,
    COUNT(CASE WHEN product_line = 'Clothes & Shoes' THEN product_name ELSE NULL END) AS Clothes_product,
    COUNT(CASE WHEN product_line = 'Outdoors' THEN product_name ELSE NULL END) AS Outdoors_product,
    COUNT(CASE WHEN product_line = 'Sports' THEN product_name ELSE NULL END) AS Sports_product
FROM supplier
GROUP BY 1;

-- CUSTOMER_STATUS PERFORMANCE 
SELECT
	YEAR(date_order_was_placed_new) AS Yr,
	customer_status,
    ROUND(SUM(retail_price)) AS Sales
FROM orders
GROUP BY 1, 2;

