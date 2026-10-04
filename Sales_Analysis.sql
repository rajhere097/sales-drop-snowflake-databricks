use database sales_analysis_2026;

use schema public;

select * from orders
limit 5;

select * from product
limit 5;

-- monthly_drop as
with monthly_sales_drop as
(select month(order_date) as months, sum(sales_amount) as monthly_sales, 
lag(sum(sales_amount)) over (order by month(order_date)) as previous_month_sales
from orders where order_date >= '2026-05-01' and order_date <= '2026-08-31'
group by month(order_date))
select *, (monthly_sales - previous_month_sales) * 100 / nullif(previous_month_sales, 0) as sales_drop
from monthly_sales_drop
order by sales_drop;

-- Notes
/* June has the highest MOM drop -14%, revenue recovered in July, and again dropped in August - -5%. */

-- AOV DROP
with t1 as
(select month(order_date) as months, sum(sales_amount)/ count(distinct order_id) as avg_order_value
from orders
where order_date >= '2026-05-01' and order_date <= '2026-08-31'
group by month(order_date)),
t2 as
(select *, lag(avg_order_value) over(order by months) as prev_month_avg_order_value
from t1)
select months, (avg_order_value - prev_month_avg_order_value) * 100/nullif(prev_month_avg_order_value, 0) as AOV_Drop
from t2;
-- June: - 12.9, July: 16, Aug: -4

-- volume drop
with t1 as 
(select month(order_date) as months, count(distinct order_id) as current_volumne,
lag(count(distinct order_id)) over(order by month(order_date)) as prev_month_volumne
from orders
where order_date >= '2026-05-01' and order_date <= '2026-08-31' 
group by month(order_date)
order by current_volumne)
select months, current_volumne, prev_month_volumne,
(current_volumne - prev_month_volumne) * 100/nullif(prev_month_volumne, 0) as volumne_drop_rate
from t1
order by volumne_drop_rate;
-- No such drop in volumne noticed

-- fullfillment rate
select * from operations
limit 5;
select month(od.order_date), count(distinct case when o.status ='Delivered' then od.order_id end) 
* 100/nullif(count(distinct od.order_id),0)
from operations o join orders od
on o.order_id = od.order_id
where od.order_date >= '2026-05-01' and od.order_date <= '2026-08-31'
group by month(od.order_date)
order by month(od.order_date);
-- June : 94, July : 97, Aug: 90


-- regional drop
with regions_sales_drop as
(select month(order_date) as months, region, sum(sales_amount) as monthly_sales, 
lag(sum(sales_amount)) over (partition by region order by month(order_date)) as previous_month_sales
from orders where order_date >= '2026-05-01' and order_date <= '2026-08-31'
group by month(order_date), region)
select *, (monthly_sales - previous_month_sales) * 100 / nullif(previous_month_sales, 0) as sales_drop
from regions_sales_drop
order by sales_drop;

/***Note:** Taking the top 5 rows, the major declines were seen across **June and August**, mainly in the **South, West, North and East** regions. The **South region in June** showed the largest decline (~18.4%), followed by **West in August (~18.1%)**, **West in June (~16.3%)**, **North in June (~16.1%)**, and **East in August (~12.4%)**.*/


-- category drop
with category_sales_drop as
(select month(order_date) as months, category, sum(sales_amount) as monthly_sales, 
lag(sum(sales_amount)) over (partition by category order by month(order_date)) as previous_month_sales
from orders where order_date >= '2026-05-01' and order_date <= '2026-08-31'
and region in ('South','North','West','East')
group by month(order_date), category)
select *, (monthly_sales - previous_month_sales) * 100 / nullif(previous_month_sales, 0) as sales_drop
from category_sales_drop
order by sales_drop;

/***Note:** Taking the top 4 rows, the major declines were seen in **June and August**, mainly across **Cosmetics, Home & Kitchen, and Apparel**. **Cosmetics in June** showed the largest decline (~25.3%), followed by **Cosmetics in August (~20.0%)**, **Home & Kitchen in June (~14.3%)**, and **Apparel in June (~12.9%)**.*/


-- sub category drop 
with category_sales_drop as
(select month(order_date) as months, subcategory, sum(sales_amount) as monthly_sales, 
lag(sum(sales_amount)) over (partition by subcategory order by month(order_date)) as previous_month_sales
from orders where order_date >= '2026-05-01' and order_date <= '2026-08-31' and region in ('South','North','West','East')
and category in ('Cosmetics', 'Home & Kitchen', 'Apparel')
group by month(order_date), subcategory)
select *, (monthly_sales - previous_month_sales) * 100 / nullif(previous_month_sales, 0) as sales_drop
from category_sales_drop
order by sales_drop;

/* **Note:** Taking the top 5 rows, the major declines were seen across **Skincare, Lips and Appliances**, mainly in **June and August**. **Skincare in June** showed the largest decline (~29.7%), followed by **Lips in August (~29.4%)**, **Lips in June (~28.4%)**, **Appliances in June (~26.4%)**, and **Skincare***/


select distinct p.product_id, o.product_id
from product p left join orders o
on p.product_id = o.product_id
where o.product_id is null;


-- product drop
with product_sales_drop as
(select month(order_date) as months, product_name, sum(sales_amount) as monthly_sales, 
lag(sum(sales_amount)) over (partition by product_name order by month(order_date)) as previous_month_sales
from orders where order_date >= '2026-05-01' and order_date <= '2026-08-31' and region in ('South','North','West','East')
and category in ('Cosmetics', 'Home & Kitchen', 'Apparel') and 
subcategory in ('Skincare', 'Lips', 'Appliances')
group by month(order_date), product_name)
select *, (monthly_sales - previous_month_sales) * 100 / nullif(previous_month_sales, 0) as sales_drop
from product_sales_drop
order by sales_drop;

/* **Note:** Taking the top 7 rows, the major declines were concentrated across **SPF 30 Moisturizer, Matte Lipstick Ruby, Vitamin C Face Serum, Matte Lipstick Nude, Matte Lipstick Ruby, and Mixer Grinder**, mainly in **June and August**. **SPF 30 Moisturizer in June** showed the largest decline (~42.1%), followed by **Matte Lipstick Ruby in August (~31.3%)**, **Vitamin C Face Serum in August (~30.8%)**, **Matte Lipstick Nude in June (~29.7%)**, **Matte Lipstick Nude in August (~27.8%)**, **Matte Lipstick Ruby in June (~27.0%)**, and **Mixer Grinder in June (~26.4%)**.*/


-- volume drop
with t1 as 
(select month(order_date) as months, product_name, count(distinct order_id) as current_volumne,
lag(count(distinct order_id)) over(partition by product_name order by month(order_date)) as prev_month_volumne
from orders
where order_date >= '2026-05-01' and order_date <= '2026-08-31' and region in ('South','North','West','East')
and category in ('Cosmetics', 'Home & Kitchen', 'Apparel') and
subcategory in ('Skincare', 'Lips', 'Appliances')
and product_name in ('SPF 30 Moisturizer','Matte Lipstick Ruby', 'Vitamin C Face Serum', 'Matte Lipstick Nude','Mixer Grinder')
group by month(order_date), product_name
order by current_volumne)
select months, product_name, current_volumne, prev_month_volumne,
(current_volumne - prev_month_volumne) * 100/nullif(prev_month_volumne, 0) as volumne_drop_rate
from t1
order by volumne_drop_rate;

/*No major drop in order volume was observed, indicating that customers were still placing orders despite the decline in sales.*/


-- AOV Drop
with t1 as
(select month(order_date) as months, product_name, sum(sales_amount)/ count(distinct order_id) as avg_order_value
from orders
where order_date >= '2026-05-01' and order_date <= '2026-08-31' and region in ('South','North','West','East')
and category in ('Cosmetics', 'Home & Kitchen', 'Apparel') and
subcategory in ('Skincare', 'Lips', 'Appliances')
and product_name in ('SPF 30 Moisturizer','Matte Lipstick Ruby', 'Vitamin C Face Serum', 'Matte Lipstick Nude','Mixer Grinder')
group by month(order_date), product_name
order by avg_order_value),
t2 as
(select months, product_name, avg_order_value, 
lag(avg_order_value, 1) over(partition by product_name order by months) as prev_order_val
from t1)
select *, (avg_order_value - prev_order_val) * 100 / nullif(prev_order_val, 0) as avg_change_rate
from t2;

-- estimate average price
with t1 as
(select month(order_date) as months, product_name, sum(sales_amount)/nullif(sum(quantity),0) as estimated_avg_price,
lag(sum(sales_amount)/nullif(sum(quantity),0)) over(partition by product_name order by month(order_date)) 
as prev_estimated_avg_price
from orders
where order_date >= '2026-05-01' and order_date <= '2026-08-31' and region in ('South','North','West','East')
and category in ('Cosmetics', 'Home & Kitchen', 'Apparel') and
subcategory in ('Skincare', 'Lips', 'Appliances')
and product_name in ('SPF 30 Moisturizer','Matte Lipstick Ruby', 'Vitamin C Face Serum', 'Matte Lipstick Nude','Mixer Grinder')
group by month(order_date), product_name
order by months)
select months, product_name, estimated_avg_price, prev_estimated_avg_price,
(estimated_avg_price - prev_estimated_avg_price) as diff
from t1;
/***Note:** Order volume remained relatively stable, but AOV declined for several affected products. I therefore checked the **estimated average selling price (Sales Amount ÷ Quantity)** and observed noticeable declines for some products, particularly in August. This indicated that **lower realized selling value may have contributed to the AOV decline**. I considered pricing, discounts, and promotional activity as possible drivers; however, the demo dataset did not contain direct **unit-price, discount, or promotion fields**, so these factors could not be directly validated.*/

-- funnel convertion analysis
with monthly_metrics as 
(select p.month as months, sum(p.visits) as total_visits, sum(p.product_views) as total_views, sum(p.add_to_cart) as total_cart,
sum(p.checkout_started) as total_checkout, sum(p.orders_placed) as total_orders
from product p where p.month in ('2026-06', '2026-07', '2026-08') and exists
(select 1
from orders o
where o.product_id = p.product_id and o.order_date >= '2026-06-01' and o.order_date < '2026-09-01'
and o.region in ('South', 'North', 'West', 'East')
and o.category in ('Cosmetics', 'Home & Kitchen', 'Apparel')
and o.subcategory in ('Skincare', 'Lips', 'Appliances')
and o.product_name in ('SPF 30 Moisturizer', 'Matte Lipstick Ruby', 'Vitamin C Face Serum', 'Matte Lipstick Nude', 'Mixer Grinder'))
group by p.month)
select months, total_views * 100.0 / nullif(total_visits, 0) as visit_to_view_conversion,
total_cart * 100.0 / nullif(total_views, 0) as view_to_cart_conversion,
total_checkout * 100.0 / nullif(total_cart, 0) as cart_to_checkout_conversion,
total_orders * 100.0 / nullif(total_checkout, 0) as checkout_to_order_conversion,

(total_visits - total_views) * 100.0 / nullif(total_visits, 0) as visit_to_view_dropoff,
(total_views - total_cart) * 100.0 / nullif(total_views, 0) as view_to_cart_dropoff,
(total_cart - total_checkout) * 100.0 / nullif(total_cart, 0) as cart_to_checkout_dropoff,
(total_checkout - total_orders) * 100.0 / nullif(total_checkout, 0) as checkout_to_order_dropoff
from monthly_metrics
order by months;

/*The biggest issue identified in the funnel was the View-to-Cart stage. Conversion remained around 12%, resulting in approximately 88% drop-off. This indicates that while customers are viewing the products, most are not proceeding to add them to the cart. This could point to a potential demand or product-interest issue, where the products may not be sufficiently appealing to customers to drive further engagement. Therefore, the next step was to investigate product-level performance and demand patterns to understand what may be driving the low View-to-Cart conversion.*/


select * from payments
limit 5;

select count(*)
from orders o left join payments p
on o.order_id = p.order_id
where p.order_id is null;

select distinct error_message
from payments;

-- error counts
select month(o.order_date) as months, p.error_message, count(distinct o.order_id) as error_count
from payments p join orders o
on p.order_id = o.order_id
where o.order_date >= '2026-05-01' and o.order_date < '2026-09-01'
and o.region in ('South', 'North', 'West', 'East')
and o.category in ('Cosmetics', 'Home & Kitchen', 'Apparel')
and o.subcategory in ('Skincare', 'Lips', 'Appliances')
and o.product_name in ('SPF 30 Moisturizer', 'Matte Lipstick Ruby', 'Vitamin C Face Serum', 'Matte Lipstick Nude', 'Mixer Grinder')
group by  month(o.order_date), p.error_message
order by months, error_count desc;

-- estimated amount at risk
with product_avg_price as
(select p.error_message, sum(o.sales_amount)/nullif(sum(o.quantity),0) as estimated_avg_price
from payments p join orders o
on p.order_id = o.order_id
where o.order_date >= '2026-05-01' and o.order_date <= '2026-08-31' and o.region in ('South','North','West','East')
and o.category in ('Cosmetics', 'Home & Kitchen', 'Apparel') and
o.subcategory in ('Skincare', 'Lips', 'Appliances')
and o.product_name in ('SPF 30 Moisturizer','Matte Lipstick Ruby', 'Vitamin C Face Serum', 'Matte Lipstick Nude','Mixer Grinder')
and p.error_message in ('Transaction declined by the issuing bank', 'Transaction declined due to insufficient funds',
'Card or bank authorization could not be completed for this transaction')
group by p.error_message),
overall_avg_price as
(select avg(estimated_avg_price) as total_avg_price from product_avg_price),
error_counts as
(select count(*) as total_error_counts
from payments p join orders o
on p.order_id = o.order_id
where o.order_date >= '2026-05-01' and o.order_date <= '2026-08-31' and o.region in ('South','North','West','East')
and o.category in ('Cosmetics', 'Home & Kitchen', 'Apparel') and
o.subcategory in ('Skincare', 'Lips', 'Appliances')
and o.product_name in ('SPF 30 Moisturizer','Matte Lipstick Ruby', 'Vitamin C Face Serum', 'Matte Lipstick Nude','Mixer Grinder')
and p.error_message in ('Transaction declined by the issuing bank', 'Transaction declined due to insufficient funds',
'Card or bank authorization could not be completed for this transaction'))
select e.total_error_counts * o.total_avg_price as estimated_loss
from overall_avg_price o cross join error_counts e;

/*The identified payment errors indicate an estimated potential revenue loss of ₹16,103.75. This estimate was calculated using the number of affected payment errors and the estimated average order value associated with those transactions. The figure represents potential revenue exposure from payment failures and was used to assess the impact of payment related issues*/


-- fullfillment rate
select * from operations;

select monthname(o.order_date) as months, 
count(distinct case when op.status= 'Delivered' then o.order_id end) * 100/nullif(count(distinct o.order_id),0)
from orders o join operations op
on o.order_id = op.order_id
where o.order_date >= '2026-06-01' and o.order_date <= '2026-08-31' and o.region in ('South','North','West','East')
and o.category in ('Cosmetics', 'Home & Kitchen', 'Apparel') and
o.subcategory in ('Skincare', 'Lips', 'Appliances')
and o.product_name in ('SPF 30 Moisturizer','Matte Lipstick Ruby', 'Vitamin C Face Serum', 'Matte Lipstick Nude','Mixer Grinder')
group by monthname(o.order_date);

/*Fulfillment rate dropped significantly in August to 79.17 percent, compared with 93.75 percent in June and 100 percent in July. This indicates a fulfillment related issue in August. My next step is to analyze the operational stages to identify where the orders were getting delayed or failing and determine the specific stage contributing to the drop.*/


-- operational funnel track
WITH cohort_counts AS (
    SELECT
        DATE_TRUNC('month', o.order_date) AS cohort_month,
        COUNT(DISTINCT CASE WHEN op.status = 'Order Placed' THEN op.order_id END) AS order_placed,
        COUNT(DISTINCT CASE WHEN op.status = 'Order Confirmed' THEN op.order_id END) AS order_confirmed,
        COUNT(DISTINCT CASE WHEN op.status = 'Processing' THEN op.order_id END) AS processing,
        COUNT(DISTINCT CASE WHEN op.status = 'Preparing' THEN op.order_id END) AS preparing,
        COUNT(DISTINCT CASE WHEN op.status = 'Dispatched' THEN op.order_id END) AS dispatched,
        COUNT(DISTINCT CASE WHEN op.status = 'Shipped' THEN op.order_id END) AS shipped,
        COUNT(DISTINCT CASE WHEN op.status = 'Out for Delivery' THEN op.order_id END) AS out_for_delivery,
        COUNT(DISTINCT CASE WHEN op.status = 'Delivered' THEN op.order_id END) AS delivered,
        COUNT(DISTINCT CASE WHEN op.status = 'Failed Delivery' THEN op.order_id END) AS failed_delivery,
        COUNT(DISTINCT CASE WHEN op.status = 'Returned' THEN op.order_id END) AS returned,
        COUNT(DISTINCT CASE WHEN op.status = 'Cancelled' THEN op.order_id END) AS cancelled
    FROM orders o
    JOIN operations op ON o.order_id = op.order_id
    WHERE o.order_date >= '2026-06-01' AND o.order_date <= '2026-08-31'
      AND o.region IN ('South','North','West','East')
      AND o.category IN ('Cosmetics', 'Home & Kitchen', 'Apparel')
      AND o.subcategory IN ('Skincare', 'Lips', 'Appliances')
      AND o.product_name IN ('SPF 30 Moisturizer', 'Matte Lipstick Ruby', 'Vitamin C Face Serum', 'Matte Lipstick Nude', 'Mixer Grinder')
    GROUP BY 1
)
SELECT
    cohort_month,
    -- Step-by-Step Conversion Rates
    order_confirmed * 100.0 / NULLIF(order_placed, 0) AS placed_to_confirmed_pct,
    processing * 100.0 / NULLIF(order_confirmed, 0) AS confirmed_to_processing_pct,
    preparing * 100.0 / NULLIF(processing, 0) AS processing_to_preparing_pct,
    dispatched * 100.0 / NULLIF(preparing, 0) AS preparing_to_dispatched_pct,
    shipped * 100.0 / NULLIF(dispatched, 0) AS dispatched_to_shipped_pct,
    out_for_delivery * 100.0 / NULLIF(shipped, 0) AS shipped_to_out_pct,
    delivered * 100.0 / NULLIF(out_for_delivery, 0) AS out_to_delivered_pct,
    
    -- Drop-off / Risk Metrics
    failed_delivery * 100.0 / NULLIF(out_for_delivery, 0) AS delivery_failure_rate,
    returned * 100.0 / NULLIF(delivered, 0) AS return_rate,
    cancelled * 100.0 / NULLIF(order_placed, 0) AS total_cancellation_rate
FROM cohort_counts
ORDER BY cohort_month;

-- operations fulfillment conversion and drop-off analysis
WITH cohort_counts AS (
    SELECT
        DATE_TRUNC('month', o.order_date) AS cohort_month,
        COUNT(DISTINCT CASE WHEN op.status = 'Order Placed' THEN op.order_id END) AS order_placed,
        COUNT(DISTINCT CASE WHEN op.status = 'Order Confirmed' THEN op.order_id END) AS order_confirmed,
        COUNT(DISTINCT CASE WHEN op.status = 'Processing' THEN op.order_id END) AS processing,
        COUNT(DISTINCT CASE WHEN op.status = 'Preparing' THEN op.order_id END) AS preparing,
        COUNT(DISTINCT CASE WHEN op.status = 'Dispatched' THEN op.order_id END) AS dispatched,
        COUNT(DISTINCT CASE WHEN op.status = 'Shipped' THEN op.order_id END) AS shipped,
        COUNT(DISTINCT CASE WHEN op.status = 'Out for Delivery' THEN op.order_id END) AS out_for_delivery,
        COUNT(DISTINCT CASE WHEN op.status = 'Delivered' THEN op.order_id END) AS delivered,
        COUNT(DISTINCT CASE WHEN op.status = 'Failed Delivery' THEN op.order_id END) AS failed_delivery,
        COUNT(DISTINCT CASE WHEN op.status = 'Returned' THEN op.order_id END) AS returned,
        COUNT(DISTINCT CASE WHEN op.status = 'Cancelled' THEN op.order_id END) AS cancelled
    FROM orders o
    JOIN operations op ON o.order_id = op.order_id
    WHERE o.order_date >= '2026-06-01' AND o.order_date <= '2026-08-31'
      AND o.region IN ('South','North','West','East')
      AND o.category IN ('Cosmetics', 'Home & Kitchen', 'Apparel')
      AND o.subcategory IN ('Skincare', 'Lips', 'Appliances')
      AND o.product_name IN ('SPF 30 Moisturizer', 'Matte Lipstick Ruby', 'Vitamin C Face Serum', 'Matte Lipstick Nude', 'Mixer Grinder')
    GROUP BY 1
)
SELECT
    cohort_month,
    -- Step-by-Step Conversion Rates
    order_confirmed * 100.0 / NULLIF(order_placed, 0) AS placed_to_confirmed_pct,
    processing * 100.0 / NULLIF(order_confirmed, 0) AS confirmed_to_processing_pct,
    preparing * 100.0 / NULLIF(processing, 0) AS processing_to_preparing_pct,
    dispatched * 100.0 / NULLIF(preparing, 0) AS preparing_to_dispatched_pct,
    shipped * 100.0 / NULLIF(dispatched, 0) AS dispatched_to_shipped_pct,
    out_for_delivery * 100.0 / NULLIF(shipped, 0) AS shipped_to_out_pct,
    delivered * 100.0 / NULLIF(out_for_delivery, 0) AS out_to_delivered_pct,
    
    -- Drop-off / Risk Metrics
    failed_delivery * 100.0 / NULLIF(out_for_delivery, 0) AS delivery_failure_rate,
    returned * 100.0 / NULLIF(delivered, 0) AS return_rate,
    cancelled * 100.0 / NULLIF(order_placed, 0) AS total_cancellation_rate
FROM cohort_counts
ORDER BY cohort_month;
/*No major issue was identified on the distribution side. The distribution metrics remained relatively stable, with no significant deterioration observed across the analyzed period.*/

/* Final NOTE
The analysis indicates that the primary issues were not operational or fulfillment-related. Order volume remained relatively stable, and there was no major breakdown across the downstream fulfillment stages. The key funnel weakness was the low Product View → Add to Cart conversion, with approximately 12% conversion and 88% drop-off, indicating that many customers viewed the products but did not proceed to purchase consideration. In addition, the decline in Average Order Value contributed to the overall revenue decline. Therefore, the main areas requiring further investigation are customer purchase intent/product-level conversion and the factors contributing to the decline in AOV, rather than operational fulfillment.*/