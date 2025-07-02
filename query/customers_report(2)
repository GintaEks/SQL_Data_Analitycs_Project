--/* ==================
--		Customer Report
-- ================== 
-- Purpose :
--	-This report consolidates key customer metrics and behaviors
-- Highlights:
--	1. Gathers essential fileds such as names, ages, and transaction details.
-- 	2. Segmentes customers into categories (VIP, Regural, New) and age groups.
--	3. Aggregates customer-level metrics:
--		- Total orders
--		- Total sales
--		- Tolal quantity purchased
--		- Total products
--		- Lifespan (in months)
--	4. Calculates valuabke KPIs:
--		- Recency (months since last order)
-- 		- Average order valuue 
-- 		- average monthly spend
--	
--==============================================*/

-- create view gold_report_customers as 



with base_query as (

-- 1. base query Retrieves core columns from tables
select 
	f.order_number,
	f.product_key,
	f.order_date,
	f.sales_amount,
	f.quantity,
	c.customer_key,
	c.customer_number ,
	concat(c.first_name, ' ', c.last_name ) as customer_name,
	date_part('year',age(current_date, c.birthdate))as age
from gold_fact_sales f 
left join gold_dim_customers c 
	on f.customer_key = c.customer_key
where order_date is not null)
, customer_aggregation as (
-- 
-- 2. customer aggregations : summarizes key metrics at the customer level
--
select 
	customer_key,
	customer_number,
	customer_name,
	age,
	count(distinct order_number) as total_orders,
	sum(sales_amount) as total_sales,
	sum(quantity) as total_quantity,
	count(distinct product_key) as total_product,
	max(order_date) as last_order,
	(date_part('year', age(max(order_date), min(order_date))) * 12) + 
   date_part('month', age(max(order_date), min(order_date)))as lifespan
from base_query
group by 
	customer_key,
	customer_number,
	customer_name,
	age
)

select 
	customer_key,
	customer_number,
	customer_name,
	age,
	case 
		when age < 20 then 'Under 20'
		when age between 20 and 29 then '20-29'
		when age between 30 and 39 then '30-39'
		when age between 40 and 49 then '40-49'
		else '50 and above'
	end as age_group,
	case
		when lifespan >= 12 and total_sales >5000 then 'VIP'
	 	when lifespan >= 12 and total_sales <= 5000 then 'Regular'
	 	else 'NEW'
	end customer_segment,
	date_part('year', age(current_date, last_order))*12 +
	date_part('month',age(current_date, last_order))	as recency,
	total_orders,
	total_sales,
	total_quantity,
	total_product,
	last_order,
	lifespan,
-- Compuate average order value (AVO)
	case 
		when total_sales = 0 then 0
		else total_sales / total_orders
	end as avg_order_value,
	
-- Compuate average monthly spend
	case 
		when lifespan = 0 then total_sales
		else total_sales / lifespan
	end as avg_monthly_spend
from customer_aggregation



--top 15 customer
select *
from gold_report_customers
order by total_sales desc
limit 15
;
