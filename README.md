# Sales Drop Analysis — Snowflake & Databricks

An end-to-end e-commerce sales analysis project investigating a revenue decline through **SQL-based analysis, data validation, customer funnel analysis, product-level performance, AOV analysis, payment-error analysis, and operational fulfillment analysis**.

The project uses **Snowflake for analytical SQL** and **Databricks/Python for data validation and supporting analysis**.

---

## Project Overview

The objective of this project was to investigate a reported decline in e-commerce revenue and identify the underlying business drivers.

Rather than looking only at total revenue, the analysis breaks the problem down into multiple dimensions:

- Revenue and sales trends
- Order volume trends
- Average Order Value (AOV)
- Product-level performance
- Customer funnel conversion
- Funnel drop-off
- Payment failures and error distribution
- Operational fulfillment stages
- Delivery failures and returns
- Data validation

The analysis focuses primarily on the period from **June 2026 to August 2026**, with additional historical data used where required for comparison.

---

## Business Problem

The business reported a decline in sales/revenue and required an analysis to determine whether the decline was caused by:

1. Lower order volume
2. Lower Average Order Value
3. Product-level performance
4. Customer conversion issues
5. Payment failures
6. Operational/fulfillment problems

The analysis therefore follows a structured approach:

**Revenue → Volume → AOV → Product Performance → Customer Funnel → Payment → Operations**

This helps separate commercial problems from technical and operational problems.

---

## Technology Stack

### SQL & Data Warehousing

- **Snowflake**
- **SQL**
- CTEs
- Aggregations
- `CASE WHEN`
- `COUNT`
- `SUM`
- `COUNT(DISTINCT)`
- `NULLIF`
- `DATE_TRUNC`
- Date filtering
- `GROUP BY`
- `ORDER BY`
- Window functions
- `LAG()`
- `PARTITION BY`
- Conditional aggregation
- Joins
- `EXISTS` where appropriate

### Data Analysis & Validation

- **Databricks**
- **Python**
- **Pandas**
- Jupyter Notebook
- Data validation
- Data profiling
- Result verification

### Visualization

Analysis outputs were also exported/visualized to examine:

- Sales/revenue trends
- AOV changes
- Order-volume changes
- Funnel conversion
- Drop-off rates
- Product-level trends

---

## Data Sources / Tables

The analysis works across multiple business datasets/tables, including:

### `orders`

Used for:

- Order information
- Order dates
- Product information
- Region
- Category
- Subcategory
- Order volume
- Sales-related analysis

### `product`

Used for:

- Product-level monthly activity
- Visits
- Product views
- Add-to-cart activity
- Checkout starts
- Orders placed

### `payments`

Used for:

- Payment errors
- Transaction failures
- Authorization failures
- Gateway issues
- Invalid payment details
- Insufficient-fund errors

### `operations`

Used for:

- Order fulfillment stages
- Order status progression
- Delivery failures
- Returns
- Cancellations

---

# Analysis Methodology

## 1. Revenue and Sales Trend Analysis

The first step was to establish whether the reported sales decline was primarily driven by:

- Fewer orders
- Lower order value
- Product-level changes

Monthly sales performance was compared across the analysis period.

The analysis separated **order volume** from **revenue**, allowing the investigation to determine whether revenue was falling because customers were placing fewer orders or because the value generated per order was declining.

---

## 2. Order Volume Analysis

Monthly order volume was analyzed to determine whether there was a significant reduction in customer purchasing activity.

Product-level volume was also compared against the previous month.

The objective was to determine whether the sales decline was associated with a major reduction in the number of orders.

The analysis showed that order volume remained relatively stable for the analyzed products, with only limited month-to-month movement.

This shifted the investigation toward **order value and conversion behavior rather than a major volume collapse**.

---

## 3. Average Order Value (AOV) Analysis

AOV was analyzed as:

```
AOV = Total Sales / Total Orders
```

The analysis compared estimated average selling price/order value across months and products.

Product-level comparisons were performed using monthly values and previous-month values, including `LAG()` and `PARTITION BY` where required.

The analysis identified a decline in AOV for several affected products.

This indicated that the revenue decline could not be explained solely by order volume.

Potential commercial drivers considered included:

- Pricing changes
- Discounts
- Promotional activity
- Product mix

However, the available dataset did not contain sufficient direct pricing/discount/promotion fields to independently validate these causes.

Therefore, these were treated as potential drivers rather than confirmed causes.

---

## 4. Product-Level Analysis

Product-level performance was analyzed to determine whether specific products were responsible for the sales decline.

The analysis examined:

- Order volume
- Previous-month volume
- Volume change
- Volume drop rate
- Estimated average selling price
- Previous-month estimated average selling price
- AOV difference

The objective was to identify whether the overall sales decline was concentrated within specific products.

---

## 5. Customer Funnel Analysis

A customer funnel was created to understand where users were dropping out before placing an order.

The funnel stages were:

```
Visits
   ↓
Product Views
   ↓
Add to Cart
   ↓
Checkout Started
   ↓
Orders Placed
```

Conversion rates were calculated between consecutive stages.

For example:

```
Visit → View
View → Cart
Cart → Checkout
Checkout → Order
```

Drop-off was calculated as:

```
Drop-off % = 100 - Conversion %
```

### Key Funnel Observation

One of the most important observations was the relatively low **View-to-Cart conversion**.

This indicates that a substantial number of customers were viewing products but were not progressing to the cart.

From a business perspective, this can indicate weaker product-level purchase intent or a customer-value proposition issue.

However, funnel data alone cannot prove the exact reason.

Possible areas for further investigation include:

- Product pricing
- Product attractiveness
- Discounts/promotions
- Product descriptions
- Reviews/ratings
- Competitor pricing
- Product availability
- Customer expectations

### Cart-to-Checkout Analysis

The Cart-to-Checkout stage was also investigated, particularly for July and August.

Conversion remained around the analyzed range while a significant percentage of users dropped between these stages.

This created a second investigation path:

```
Cart Drop-off
       ↓
Payment Analysis
       ↓
Payment Error Distribution
```

---

## 6. Payment Error Analysis

Payment data was analyzed to determine whether technical payment failures could explain checkout-related drop-off.

The analysis examined error categories such as:

- Transaction declined by the issuing bank
- Card/bank authorization failure
- Payment gateway timeout
- Invalid or incomplete payment details
- Insufficient funds

The payment table was joined with the orders table using:

```
p.order_id = o.order_id
```

The errors were then grouped by month and analyzed using conditional aggregation.

The purpose was to determine whether payment failures represented a significant technical barrier in the customer journey.

---

## 7. Operational Fulfillment Analysis

The operational funnel was analyzed separately from the customer conversion funnel, and compared month by month across June, July and August.

The fulfillment stages included:

```
Order Placed
      ↓
Order Confirmed
      ↓
Processing
      ↓
Preparing
      ↓
Dispatched
      ↓
Shipped
      ↓
Out for Delivery
      ↓
Delivered
```

Additional risk states included:

- Failed Delivery
- Returned
- Cancelled

Conversion rates were calculated between consecutive fulfillment stages.

Examples:

```
Placed → Confirmed
Confirmed → Processing
Processing → Preparing
Preparing → Dispatched
Dispatched → Shipped
Shipped → Out for Delivery
Out for Delivery → Delivered
```

Additional metrics included:

```
Delivery Failure Rate
Return Rate
Cancellation Rate
```

### Operational Finding

The fulfillment analysis identified a **significant deterioration in August** compared with the earlier months.

Fulfillment performance weakened across the order journey, which points to an operational issue emerging alongside the AOV decline and the view-to-cart drop-off, rather than a purely commercial explanation.

Fulfillment is therefore treated as a confirmed contributing factor in the August revenue decline, and it is flagged for stage-level root-cause analysis (see Business Recommendation below).

---

## 8. Data Validation

Data validation was performed using **Databricks and Python/Pandas**.

The purpose was to validate the analytical results and identify potential inconsistencies before drawing business conclusions.

Validation included:

- Checking dataset structure
- Reviewing records
- Comparing analytical outputs
- Validating product/order relationships
- Checking monthly values
- Reviewing volume movements
- Verifying analytical calculations

A dedicated validation notebook is included in the repository.

---

# SQL Techniques Used

The project demonstrates practical SQL techniques including:

### CTEs

Used to break complex analysis into logical stages.

```
WITH monthly_metrics AS (
    ...
)
```

### Conditional Aggregation

Used for funnel and payment-error calculations.

```
COUNT(
    CASE
        WHEN error_message = '...'
        THEN 1
    END
)
```

### Distinct Counting

Used where order-level uniqueness was required.

```
COUNT(DISTINCT order_id)
```

### Date Filtering

Date ranges were filtered using explicit date boundaries.

```
WHERE order_date >= '2026-06-01'
  AND order_date < '2026-09-01'
```

Using an exclusive upper bound helps avoid problems when timestamp columns contain time components.

### Window Functions

`LAG()` was used to compare current-month values with previous-month values.

Conceptually:

```
LAG(metric) OVER (
    PARTITION BY product_name
    ORDER BY month
)
```

This enabled product-level month-over-month comparisons.

---

# Python / Pandas

Python and Pandas were used primarily for data validation and supporting analysis.

Typical workflow:

```
Data
 ↓
Load
 ↓
Inspect
 ↓
Validate
 ↓
Compare
 ↓
Analyze
 ↓
Export Results
```

The validation notebook is included as:

```
Sales_Data_Validation.ipynb
```

---

# Repository Structure

```
sales-drop-snowflake-databricks/
│
├── Sales_Analysis.sql
│
├── Sales_Data_Validation.ipynb
│
├── funnel_analysis.png
├── AOV_drop.png
├── volume_drop.png
├── drop_rate.png
│
├── Fulfilment_Stages.csv
├── FunnelAnalysis_June_Aug.csv
│
└── README.md
```

---

# Key Business Findings

The analysis indicates that the sales decline should not be attributed to a single cause.

The main areas identified were:

### 1. AOV Decline

Order volume remained relatively stable, while average order value declined for several affected products.

This suggests that changes in the value generated per order contributed to the overall revenue decline.

### 2. View-to-Cart Conversion

A significant funnel drop-off occurred between product views and add-to-cart activity.

This suggests that customers were reaching product pages but a relatively smaller proportion were progressing toward purchase.

This may indicate a demand, product-value, pricing, or merchandising issue, although the dataset does not contain enough information to identify the exact cause.

### 3. Payment Funnel

Payment errors were investigated to determine whether technical/payment failures contributed to checkout drop-off.

### 4. Operations

Fulfillment stages were analyzed to determine whether distribution or delivery problems contributed to the sales decline.

The analysis identified a **significant fulfillment deterioration in August**, making operations a confirmed contributing factor alongside the AOV decline and the view-to-cart drop-off.

---

# Investigation Framework

The overall investigation followed this structure:

```
Revenue Decline
      │
      ├── Order Volume
      │       └── Relatively Stable
      │
      ├── AOV
      │       └── Decline Identified
      │
      ├── Product Performance
      │       └── Product-level differences
      │
      ├── Customer Funnel
      │       └── View → Cart Drop-off
      │
      ├── Payment
      │       └── Error Analysis
      │
      └── Operations
              └── Significant August Fulfillment Deterioration Identified
```

---

# Business Recommendation / Next Investigation

Based on the analysis, the next investigation should focus on three areas:

- Understanding **why customers who view products are not adding them to their carts**
- Understanding **why AOV has declined**
- Identifying **which fulfillment stages drove the August deterioration**, and fixing them to recover delivery performance

Further analysis could include:

- Product pricing comparison
- Discount/promotion analysis
- Competitor pricing
- Product rating/review analysis
- Product availability
- Customer segmentation
- Regional funnel conversion
- Device/channel-level conversion
- Product-level conversion
- Basket-size analysis
- Stage-level and regional breakdown of August fulfillment delays, failed deliveries and cancellations

These additional dimensions would help distinguish between a **demand/value proposition issue**, a **pricing, merchandising, or customer-experience issue**, and an **operational execution issue**.

---

# Tools Used

| Tool / Technology | Purpose                                                     |
| ----------------- | ----------------------------------------------------------- |
| Snowflake         | Data warehouse and SQL analysis                             |
| SQL               | Data extraction, transformation and analytical calculations |
| Databricks        | Data validation and notebook-based analysis                 |
| Python            | Data validation and analytical support                      |
| Pandas            | Data manipulation and validation                            |
| Jupyter Notebook  | Validation workflow                                         |
| GitHub            | Version control and project portfolio                       |
| CSV               | Exported analytical results                                 |
| PNG               | Visualization of analytical findings                        |

---

# Skills Demonstrated

- SQL Analytics
- Data Warehousing
- Snowflake
- Databricks
- Python
- Pandas
- Data Validation
- CTEs
- Window Functions
- Conditional Aggregation
- Joins
- Funnel Analysis
- Conversion Analysis
- Drop-off Analysis
- AOV Analysis
- Product-Level Analysis
- Payment Error Analysis
- Operational Analysis
- Business Problem Solving
- Data Storytelling
- GitHub

---

## Project Outcome

This project demonstrates an end-to-end approach to investigating a real-world style e-commerce sales decline.

Instead of stopping at the observation that revenue decreased, the analysis decomposes the problem into **volume, AOV, product performance, customer conversion, payment behavior, and operational fulfillment**.

The final analysis narrows the investigation toward **AOV decline and customer funnel conversion**, while also identifying a **significant deterioration in fulfillment performance in August** as an additional operational driver.

**Author:** Ratnajit — [LinkedIn](https://www.linkedin.com/in/ratnajit-chakraborty-076ab520a)
