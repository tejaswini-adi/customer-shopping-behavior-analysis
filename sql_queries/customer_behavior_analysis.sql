select * from customer limit 20;
select "Gender", SUM("Purchase Amount (USD)") as revenue
from customer
group by "Gender";
--Q2. Which customers used a discount but still spent more than the average purchase amount? 
select "Customer ID",
"Purchase Amount (USD)"
from customer
where "Discount Applied" = 'Yes'
and "Purchase Amount (USD)" >=
(
    select AVG("Purchase Amount (USD)")
    from customer
);
--Q3. Which are the top 5 products with the highest average review rating?
select "Item Purchased",

ROUND(
AVG("Review Rating")::numeric,
2
) as "Average Product Rating"

from customer

group by "Item Purchased"

order by AVG("Review Rating") desc

limit 5;
--Q4. Compare the average Purchase Amounts between Standard and Express Shipping.

select "Shipping Type",
ROUND(AVG("Purchase Amount (USD)"),2) as avg_purchase
from customer
where "Shipping Type" in ('Standard','Express')
group by "Shipping Type";
--Q5. Do subscribed customers spend more?
-- Compare average spend and total revenue between subscribers and non-subscribers.

SELECT "Subscription Status",
COUNT("Customer ID") AS total_customers,
ROUND(AVG("Purchase Amount (USD)"),2) AS avg_spend,
ROUND(SUM("Purchase Amount (USD)"),2) AS total_revenue
FROM customer
GROUP BY "Subscription Status"
ORDER BY total_revenue DESC;
--Q6. Which 5 products have the highest percentage of purchases with discounts applied?

SELECT "Item Purchased",
ROUND(
100.0 *
SUM(
CASE
WHEN "Discount Applied" = 'Yes'
THEN 1
ELSE 0
END
)
/ COUNT(*),2
) AS discount_rate
FROM customer
GROUP BY "Item Purchased"
ORDER BY discount_rate DESC
LIMIT 5;
--Q7. Segment customers into New, Returning, and Loyal customers.

WITH customer_type AS
(
SELECT
"Customer ID",
"Previous Purchases",

CASE
WHEN "Previous Purchases" = 1 THEN 'New'
WHEN "Previous Purchases" BETWEEN 2 AND 10 THEN 'Returning'
ELSE 'Loyal'
END AS customer_segment

FROM customer
)

SELECT customer_segment,
COUNT(*) AS "Number of Customers"
FROM customer_type
GROUP BY customer_segment;
--Q8. What are the top 3 most purchased products within each category?

WITH item_counts AS
(
SELECT
"Category",
"Item Purchased",
COUNT("Customer ID") AS total_orders,

ROW_NUMBER() OVER
(
PARTITION BY "Category"
ORDER BY COUNT("Customer ID") DESC
) AS item_rank

FROM customer
GROUP BY "Category", "Item Purchased"
)

SELECT
item_rank,
"Category",
"Item Purchased",
total_orders
FROM item_counts
WHERE item_rank <= 3;
--Q9. Are repeat buyers also likely to subscribe?

SELECT
"Subscription Status",
COUNT("Customer ID") AS repeat_buyers

FROM customer

WHERE "Previous Purchases" > 5

GROUP BY "Subscription Status";
--Q10. What is the revenue contribution of each age group?

SELECT
CASE
WHEN "Age" BETWEEN 18 AND 25 THEN '18-25'
WHEN "Age" BETWEEN 26 AND 35 THEN '26-35'
WHEN "Age" BETWEEN 36 AND 50 THEN '36-50'
ELSE '50+'
END AS age_group,

SUM("Purchase Amount (USD)") AS total_revenue

FROM customer

GROUP BY age_group

ORDER BY total_revenue DESC;