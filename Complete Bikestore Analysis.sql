SELECT *
FROM production.brands;
SELECT *
FROM production.categories;
SELECT *
FROM production.products;
SELECT *
FROM production.stocks;


---- What are the top 10 best-selling products based on the quantity of stock sold across all stores? ---- 
--list down all the products with least number of units available in stock from top to bottom across all stores--

SELECT B.product_id, B.product_name, B.Quantity_Remaing, B.Ranking
FROM (
SELECT production.products.product_id, production.products.product_name, SUM(production.stocks.quantity) as Quantity_Remaing, 
DENSE_RANK () OVER (ORDER BY SUM(production.stocks.quantity)) as Ranking
FROM production.products
JOIN production.stocks ON production.products.product_id = production.stocks.product_id
GROUP BY production.products.product_id, production.products.product_name) B
WHERE B.Ranking <= 10;


----What is the average price of products in each category, and how does it compare to the overall average price of all products?----
--Average of each category--
--Average of the sum of the average of all three categories--
--Comparison of Average of each category to the Average of the sum of the average of all three categories--

SELECT production.categories.category_id, production.categories.category_name, ROUND(AVG(production.products.list_price),2) as Average_price
, (SELECT AVG(list_price) FROM production.products) as Overall_average
FROM production.categories 
JOIN production.products ON production.categories.category_id = production.products.category_id
GROUP BY production.categories.category_name, production.categories.category_id;

----Which brands have the highest number of products in the top 10 best-selling products list?----
--Get the list of the product ID of all the top 10 products--
--Get the brand ID's & Names for those product ID's--
--ORDER by brand Names's & Brand ID's--
--Group by brand Names's & Brand ID's--

SELECT b.brand_name, count(b.product_id) as Number_of_products
FROM (
SELECT production.brands.brand_name, production.products.product_id, production.brands.brand_id, production.products.product_name, 
SUM(production.stocks.quantity) as Quantity_Remaing, 
DENSE_RANK () OVER (ORDER BY SUM(production.stocks.quantity)) as Ranking
FROM production.products
JOIN production.stocks ON production.products.product_id = production.stocks.product_id
JOIN production.brands ON production.products.brand_id = production.brands.brand_id
GROUP BY production.brands.brand_name, production.products.product_id, production.products.product_name, production.brands.brand_id) b
WHERE b.Ranking <= '10'
GROUP BY b.brand_name
ORDER BY Number_of_products DESC;

----What is the total sales revenue for each category, and how does that compare to the overall sales revenue of all products?----
--Calculate the Revenue for each category--
--Compare it with Overall Revenue-- 

SELECT categories.category_name, SUM(production.stocks.quantity * production.products.list_price) as Sales_Revenue, 
		(
		SELECT SUM(production.stocks.quantity * production.products.list_price) as Average_Revenue 
				FROM production.products JOIN production.stocks ON production.products.product_id = production.stocks.product_id		
				)
FROM production.products
JOIN production.stocks ON production.products.product_id = production.stocks.product_id
JOIN production.brands ON production.products.brand_id = production.brands.brand_id
JOIN production.categories ON production.products.category_id = production.categories.category_id
GROUP BY categories.category_name
ORDER BY Sales_Revenue DESC;


SELECT *
FROM production.brands;
SELECT *
FROM production.categories;
SELECT *
FROM production.products;
SELECT *
FROM production.stocks;

SELECT *
FROM sales.customers;
SELECT *
FROM sales.order_items;
SELECT *
FROM sales.orders;
SELECT *
FROM sales.staffs;
SELECT *
FROM sales.stores;

----How many customers do we have?----

SELECT COUNT(customers.customer_id) AS Number_of_customers
FROM sales.customers

SELECT *
FROM sales.orders 
JOIN sales.order_items ON orders.order_id = order_items.order_id
JOIN sales.customers ON orders.customer_id = customers.customer_id;

SELECT COUNT(customers.customer_id) AS Number_of_customers
FROM sales.customers


----How many customers have placed an order in the last 30 days?----

SELECT orders.order_date
FROM sales.orders

SELECT MAX(orders.order_date)
FROM sales.orders
---Results : '2018-12-28'---

SELECT  COUNT(orders.order_date) AS NUMBER_OF_ORDERS_IN_LAST_30_DAYS
FROM sales.orders
WHERE orders.order_date BETWEEN DATEADD(DAY, -30, '2018-12-28') AND '2018-12-28';


----What is the total revenue generated by each store location?----

SELECT orders.store_id , SUM(list_price*quantity) as REVENUE 
FROM sales.order_items
JOIN sales.orders ON order_items.order_id = orders.order_id
GROUP BY orders.store_id
ORDER BY REVENUE;

----How many orders were shipped late and what was the total revenue loss due to late shipments? Assuming that discount is directly proportional to late delivery----

SELECT COUNT(orders.order_id) as Late_Orders_Delivered, SUM(order_items.list_price*order_items.quantity) as Loss
FROM sales.order_items
JOIN sales.orders ON order_items.order_id = orders.order_id
WHERE orders.shipped_date > orders.required_date;


----How many staff members are managed by each manager, and what is their average order value?----

SELECT staffs.manager_id , COUNT(staffs.staff_id) AS Number_of_staff_under_each_manager
FROM sales.staffs
GROUP BY staffs.manager_id
ORDER BY Number_of_staff_under_each_manager DESC;


SELECT staffs.manager_id as Manager_Id, AVG(list_price*quantity) as AVERAGE_ORDER_VALUE
FROM sales.staffs
JOIN sales.orders ON staffs.staff_id = orders.staff_id 
JOIN sales.order_items ON orders.order_id = order_items.order_id
GROUP BY staffs.manager_id
ORDER BY AVERAGE_ORDER_VALUE;


SELECT *
FROM production.brands;
SELECT *
FROM production.categories;
SELECT *
FROM production.products;
SELECT *
FROM production.stocks;

SELECT *
FROM sales.customers;
SELECT *
FROM sales.order_items;
SELECT *
FROM sales.orders;
SELECT *
FROM sales.staffs;
SELECT *
FROM sales.stores;

----Which product categories have generated the most revenue in the last quarter?----

SELECT *
FROM production.categories;
SELECT *
FROM production.products;
SELECT *
FROM sales.order_items;

SELECT categories.category_id, categories.category_name, SUM(order_items.quantity * order_items.list_price) AS REVENUE
FROM production.categories 
JOIN production.products ON categories.category_id = products.category_id
JOIN sales.order_items ON order_items.product_id = products.product_id
GROUP BY categories.category_id, categories.category_name
ORDER BY REVENUE DESC;



----Get the required columns together----

SELECT ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name) AS customer_name, cus.city, cus.state, ord.order_date, pro.product_name,
	cat.category_name, 
	SUM(ite.quantity) AS TOTAL_UNITS,
	SUM(ite.quantity * ite.list_price) AS REVENUE , 
	stf.staff_id as 'Sales_Rep', sto.store_id, sto.store_name
FROM sales.orders ord
JOIN sales.customers cus ON ord.customer_id = cus.customer_id
JOIN sales.order_items ite ON ite.order_id = ord.order_id
JOIN production.products pro ON pro.product_id = ite.product_id
JOIN production.categories cat ON cat.category_id = pro.category_id
JOIN sales.staffs stf ON stf.staff_id = ord.staff_id
JOIN sales.stores sto ON sto.store_id = ord.store_id
GROUP BY ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name), 
		cus.city, cus.state, ord.order_date,
		pro.product_name, cat.category_name,
		stf.staff_id, sto.store_id, sto.store_name;

----Yearly Revenue of the Company----

SELECT YEAR(B.order_date) AS Year_of_Sales , SUM(B.REVENUE) AS REVENUE
FROM 
	(SELECT ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name) AS customer_name, cus.city, 
	cus.state, ord.order_date, pro.product_name,
	cat.category_name, 
	SUM(ite.quantity) AS TOTAL_UNITS,
	SUM(ite.quantity * ite.list_price) AS REVENUE , 
	stf.staff_id as 'Sales_Rep', sto.store_id, sto.store_name
FROM sales.orders ord
JOIN sales.customers cus ON ord.customer_id = cus.customer_id 
JOIN sales.order_items ite ON ite.order_id = ord.order_id 
JOIN production.products pro ON pro.product_id = ite.product_id 
JOIN production.categories cat ON cat.category_id = pro.category_id
JOIN sales.staffs stf ON stf.staff_id = ord.staff_id 
JOIN sales.stores sto ON sto.store_id = ord.store_id
		GROUP BY ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name), 
		cus.city, cus.state, ord.order_date, 
		pro.product_name, cat.category_name, 
		stf.staff_id, sto.store_id, sto.store_name) B
GROUP BY YEAR(B.order_date);


----Revenue of the Company for first 2 Quarters every year since 2016----

SELECT YEAR(B.order_date) AS Year_of_Sales , MONTH(B.order_date) AS Month_of_Sales , SUM(B.REVENUE) AS REVENUE
FROM 
	(SELECT ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name) AS customer_name, cus.city, 
	cus.state, ord.order_date, pro.product_name,
	cat.category_name, 
	SUM(ite.quantity) AS TOTAL_UNITS,
	SUM(ite.quantity * ite.list_price) AS REVENUE , 
	stf.staff_id as 'Sales_Rep', sto.store_id, sto.store_name
FROM sales.orders ord
JOIN sales.customers cus ON ord.customer_id = cus.customer_id 
JOIN sales.order_items ite ON ite.order_id = ord.order_id 
JOIN production.products pro ON pro.product_id = ite.product_id 
JOIN production.categories cat ON cat.category_id = pro.category_id
JOIN sales.staffs stf ON stf.staff_id = ord.staff_id 
JOIN sales.stores sto ON sto.store_id = ord.store_id
		GROUP BY ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name), 
		cus.city, cus.state, ord.order_date, 
		pro.product_name, cat.category_name, 
		stf.staff_id, sto.store_id, sto.store_name) B
WHERE YEAR(B.order_date) >= '2016' AND MONTH(B.order_date) <= 6 
GROUP BY YEAR(B.order_date), MONTH(B.order_date)
ORDER BY YEAR(B.order_date), MONTH(B.order_date);



----When more than one customer ordered on the same day----

SELECT B.order_date, COUNT(Distinct(B.customer_name)) AS Number_of_orders
FROM (
	SELECT ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name) AS customer_name, cus.city, cus.state, ord.order_date, pro.product_name,
	cat.category_name, 
	SUM(ite.quantity) AS TOTAL_UNITS,
	SUM(ite.quantity * ite.list_price) AS REVENUE , 
	stf.staff_id as 'Sales_Rep', sto.store_id, sto.store_name
FROM sales.orders ord
JOIN sales.customers cus ON ord.customer_id = cus.customer_id
JOIN sales.order_items ite ON ite.order_id = ord.order_id
JOIN production.products pro ON pro.product_id = ite.product_id
JOIN production.categories cat ON cat.category_id = pro.category_id
JOIN sales.staffs stf ON stf.staff_id = ord.staff_id
JOIN sales.stores sto ON sto.store_id = ord.store_id
GROUP BY ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name), 
		cus.city, cus.state, ord.order_date,
		pro.product_name, cat.category_name,
		stf.staff_id, sto.store_id, sto.store_name ) B
WHERE B.order_date = B.order_date
GROUP BY B.order_date
HAVING COUNT(Distinct(B.customer_name)) > 1 ;


----Top 3 hot selling products in each store----

SELECT C.store_name, C.product_name, C.Sales, C.Ranking
FROM (
	SELECT B.store_name , B.product_name, B.REVENUE AS Sales, 
		DENSE_RANK() OVER (PARTITION BY B.store_name ORDER BY B.REVENUE DESC) AS Ranking
FROM (
		SELECT ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name) AS customer_name, cus.city, cus.state, ord.order_date, pro.product_name,
	cat.category_name, 
	SUM(ite.quantity) AS TOTAL_UNITS,
	SUM(ite.quantity * ite.list_price) AS REVENUE , 
	stf.staff_id as 'Sales_Rep', sto.store_id, sto.store_name
FROM sales.orders ord
JOIN sales.customers cus ON ord.customer_id = cus.customer_id
JOIN sales.order_items ite ON ite.order_id = ord.order_id
JOIN production.products pro ON pro.product_id = ite.product_id
JOIN production.categories cat ON cat.category_id = pro.category_id
JOIN sales.staffs stf ON stf.staff_id = ord.staff_id
JOIN sales.stores sto ON sto.store_id = ord.store_id
GROUP BY ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name), 
		cus.city, cus.state, ord.order_date,
		pro.product_name, cat.category_name,
		stf.staff_id, sto.store_id, sto.store_name
		) B
	) C
WHERE C.Ranking <= 3
ORDER BY C.store_name, C.Sales DESC;


----Revenue Generated by each store and each store's contribution to the total Revenue----

WITH CONTRIBUTION AS (
SELECT ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name) AS customer_name, cus.city, cus.state, ord.order_date, pro.product_name,
	cat.category_name, 
	SUM(ite.quantity) AS TOTAL_UNITS,
	SUM(ite.quantity * ite.list_price) AS REVENUE , 
	stf.staff_id as 'Sales_Rep', sto.store_id, sto.store_name
FROM sales.orders ord
JOIN sales.customers cus ON ord.customer_id = cus.customer_id
JOIN sales.order_items ite ON ite.order_id = ord.order_id
JOIN production.products pro ON pro.product_id = ite.product_id
JOIN production.categories cat ON cat.category_id = pro.category_id
JOIN sales.staffs stf ON stf.staff_id = ord.staff_id
JOIN sales.stores sto ON sto.store_id = ord.store_id
GROUP BY ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name), 
		cus.city, cus.state, ord.order_date,
		pro.product_name, cat.category_name,
		stf.staff_id, sto.store_id, sto.store_name) 
,
Total_Revenue AS (
SELECT SUM(CONTRIBUTION.REVENUE) AS Sum_of_Revenue
FROM CONTRIBUTION)

SELECT B.store_name, SUM(B.REVENUE) AS Revenues, 
       ROUND(SUM(B.REVENUE)/T.Sum_of_Revenue*100,2) AS Percentage_Contribution
FROM CONTRIBUTION B
JOIN TOTAL_REVENUE T ON 1=1 
GROUP BY B.store_name,T.Sum_of_Revenue
ORDER BY Revenues DESC;
