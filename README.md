Sales Drop Analysis: Snowflake & Databricks
An end-to-end data analysis project investigating the root causes of a recent revenue decline using Snowflake and Databricks.

📌 Executive Summary & Key Findings
The analysis follows a structured approach (Revenue → Volume → AOV → Product Performance → Customer Funnel → Payment → Operations) to separate commercial problems from technical and operational issues.

Based on the investigation:

Primary Drivers: The revenue decline was primarily driven by a lower Average Order Value (AOV) and a significant view-to-cart drop-off in the customer conversion funnel.

Operational Issues: Fulfillment metrics deteriorated in August—particularly in downstream delivery stages—highlighting potential operational bottlenecks alongside conversion and order-value concerns.

🛠️ Technology Stack
SQL & Data Warehousing (Snowflake)
Core functions: CTEs, Aggregations, Window Functions (LAG(), PARTITION BY), Joins, Conditional Aggregation, and Date Filtering (DATE_TRUNC, NULLIF).

Data Analysis & Validation (Databricks)
Python / Pandas / Jupyter Notebooks: Used for data validation, profiling, and result verification.

Visualization
Analyzed trends across sales/revenue, AOV changes, order volumes, conversion funnels, and product-level drop-off rates.

📊 Data Sources & Tables
orders: Order details, dates, regions, categories, subcategories, and order volumes.

product: Product-level monthly activity, including visits, product views, add-to-cart actions, checkout starts, and completed orders.

payments: Transaction errors, authorization failures, gateway issues, and invalid payment details.

**Author** Ratnajit
https://www.linkedin.com/in/ratnajit-chakraborty-076ab520a
