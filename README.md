# E-Commerce Sales Drop Analysis (Snowflake & Databricks)

An end-to-end analytical project investigating an e-commerce revenue decline between **June 2026 and August 2026**. This repository isolates commercial, technical, and operational drop-offs using data extracted via **Snowflake SQL** and validated in **Databricks (Python/Pandas)**.

## 🔍 Core Problem & Diagnosis Matrix

The investigation follows a strict diagnostic order of operations to isolate revenue leakages:
**Revenue ➔ Order Volume ➔ AOV ➔ Product Performance ➔ Customer Funnel ➔ Payments ➔ Operations**

| Dimension | Key Metrics & Trends Identified | Identified Driving Factor? |
| :--- | :--- | :--- |
| **Order Volume** | Found stable month-over-month; no major volume collapse. | ❌ No |
| **AOV (Average Order Value)** | Dropped across key products (June: -12.9%, August: -4%). Driven by lower realized average selling prices. |  Yes (Commercial) |
| **Funnel Conversion** | Extreme 88% drop-off identified at the **View-to-Cart** stage (12% conversion). |  Yes (Demand/Intent) |
| **Payment Failures** | Identified ₹16,103.75 in revenue exposure due to bank declines & auth timeouts. | ⚠️ Partial (Technical Risk) |
| **Operations & Fulfillment** | Clear fulfillment deterioration in August. Delivery failure, return, and cancellation rates spiked. |  Yes (Operational) |

---

## 📈 Deep-Dive Segment Breakdown

### 1. High-Risk Segments & Categories
* **Top Regional Declines:** South region in June (~18.4% drop) and West region in August (~18.1% drop).
* **Top Product Category Declines:** Cosmetics was hardest hit, dipping -25.3% in June and -20% in August.
* **Affected Products:** **SPF 30 Moisturizer** (June: -42.1%), **Matte Lipstick Ruby** (August: -31.3%), and **Vitamin C Face Serum** (August: -30.8%).

### 2. Operational Funnel Attrition
Fulfillment rates declined significantly by August (dropping to 90%). Co-dependent window analysis exposed leaky pipelines spanning:
`Dispatched ➔ Shipped` ➔ `Shipped ➔ Out for Delivery` ➔ `Out for Delivery ➔ Delivered`.

---

## 🛠️ Advanced SQL Techniques Applied
The underlying analytical engine utilizes structured Snowflake optimization components:
* **Multi-Stage CTEs:** To clean, slice, and calculate metric snapshots.
* **Window Functions (`LAG() OVER PARTITION`):** Implemented to dynamically pull Month-over-Month (MoM) deltas across complex regional and item matrices.
* **Conditional Aggregation:** Deployed to translate absolute operational status strings into quantifiable conversion percentages.
* **Zero-Safe Arithmetic:** Heavy usage of `NULLIF()` to actively neutralize mathematical division-by-zero database compilation errors.

---

## 🚀 Actionable Recommendations
1. **Optimize View-to-Cart Conversion:** Review item layout, price appeal, or missing customer reviews on the top 3 affected cosmetics assets.
2. **Audit August Fulfillment Chains:** Identify logistics or warehouse bottlenecks driving regional delivery failures and shipping drop-offs.
3. **Resolve Payment Success Rates:** Connect with payment gateways to curb authorization failure losses (Estimated ₹16K+ risk).
