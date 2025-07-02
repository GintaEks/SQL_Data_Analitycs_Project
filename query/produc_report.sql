/* ===========
 * product report
 * ===========
 * Purpose:
 * 		- This report consolidates key product metrics and behaviors.
 * 
 * Highlights:
 * 	1. Gather essential fields such as product name, category, subccategory, and cost.
 * 	2. Segments products by revenue to identify high-performers, mid-range, or low-Performers.
 * 	3. Aggregates product - level metrics:
 * 		- Total orders
 * 		- Total sales
 * 		- total quantity sold
 * 		- total custoners(unique)
 * 		- lifespan(in months)
 * 	4. Calculates valuavle KPIs:
 * 		- recency (months since last sale)
 * 		- average order revenue(AOR)
 * 		- average monthly revenue
 * 
 * 
 */

-- create view gold_report_product as

with base_query as (

select 
	f.order_number,
	f.order_date,
	f.customer_key,
	f.sales_amount,
	f.quantity,
	p.product_key ,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost
	
from gold_fact_sales f
left join gold_dim_products p 
on f.product_key = p.product_key
where f.order_date is not null
), 
product_aggregation as(
select
	product_key ,
	product_name,
	category,
	subcategory,
	cost,
	count(distinct order_number) as total_order,
	sum(sales_amount ) as total_sales,
	sum(quantity ) as total_quantity,
	count(distinct customer_key) as total_unique_customers,
	max(order_date) as last_sale_date,
	(date_part('year', age(max(order_date), min(order_date))) * 12 )+
		date_part('month', age(max(order_date), min(order_date))) as lifespan
from base_query
group by 
	product_key,
	product_name,
	category,
	subcategory,
	cost
)

select 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	total_quantity,
	total_sales,
	case 
		
		when total_sales >= 500000 then ' High-Performer'
		when total_sales between 100000 and 500000 then 'mid-range'
		else 'low-performer'
	end as product_segment,
	total_order,
	(total_sales - (total_quantity * cost)) as total_profit,
	total_unique_customers,
	lifespan,
	-- recency (months since last sale)
	(date_part('year', age(current_date, last_sale_date)) * 12)+
		date_part('month', age(current_date,last_sale_date )) as recency,
		
	--average order revenue(AOR)
	case 
		when total_order = 0 then 0
		else total_sales / total_order
	end as average_order_revenue,
	--average monthly revenue
	case
		when lifespan = 0 then total_sales
		else total_sales / lifespan
	end as average_monthly_revenue
from product_aggregation;