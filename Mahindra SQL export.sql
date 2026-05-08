SELECT * FROM mahindra.sales_data;

-- Monthly Revenue Trend
SELECT 
    YEAR,
    month,
    MONTHNAME(sale_date) AS month_name,
    SUM(total_revenue) AS monthly_revenue
FROM sales_data
GROUP BY YEAR, month, MONTHNAME(sale_date)
ORDER BY year, month;

-- Month-over-Month(MOM) Growth
SELECT 
    year,
    month,
    SUM(total_revenue) AS revenue,
    
    LAG(SUM(total_revenue)) OVER (ORDER BY year, month) AS previous_month_revenue,

    ROUND(
        (SUM(total_revenue) - LAG(SUM(total_revenue)) OVER (ORDER BY year, month))
        / LAG(SUM(total_revenue)) OVER (ORDER BY year, month) * 100,
    2) AS mom_growth_percentage

FROM sales_data
GROUP BY year, month
ORDER BY year, month;

-- Which region and city should we focus more on?
-- Revenue by region
SELECT
    region, SUM(total_revenue) AS region_revenue
FROM
    sales_data
GROUP BY region
ORDER BY region DESC;

-- Top cities based on unit sold
SELECT 
    city, SUM(units_sold) AS total_units
FROM
    sales_data
GROUP BY city
ORDER BY total_units DESC limit 3;

-- which variant generate high profit %
SELECT 
    variant,
    SUM(profit) AS total_profit,
    ROUND(
        (SUM(profit) * 100.0) / SUM(SUM(profit)) OVER (),
        2
    ) AS profit_percentage
FROM sales_data
GROUP BY variant
ORDER BY total_profit DESC;

-- total unit sold
SELECT 
    SUM(units_sold)
FROM
    sales_data;
    
-- Who are our main customers?
-- Q: Revenue by customer type
SELECT 
    customer_type, SUM(total_revenue) AS Total_Revenue
FROM
    sales_data
GROUP BY customer_type;

-- Intermediate Standard:-
-- Find the percentage contribution of each city to total revenue.
SELECT 
    city,
    ROUND(
        (SUM(profit) * 100.0) / SUM(SUM(profit)) OVER (),
        2
    ) AS profit_percentage
FROM sales_data
GROUP BY city
ORDER BY profit_percentage DESC;

-- Identify the top-selling variant in each city.
SELECT city, variant, total_units
FROM (
    SELECT 
        city,
        variant,
        SUM(units_sold) AS total_units,
        RANK() OVER (PARTITION BY city ORDER BY SUM(units_sold) DESC) AS rnk
    FROM sales_data
    GROUP BY city, variant
) t
WHERE rnk = 1;

-- Find the average revenue per order for each city.
SELECT 
    city,
    round(AVG(total_revenue),2) AS avg_revenue_per_order
FROM sales_data
GROUP BY city
ORDER BY avg_revenue_per_order DESC; 

-- Show daily total revenue and running (cumulative) revenue.
SELECT 
    sale_date,
    SUM(total_revenue) AS daily_revenue,
    SUM(SUM(total_revenue)) OVER (ORDER BY sale_date) AS cumulative_revenue
FROM sales_data
GROUP BY sale_date
ORDER BY sale_date;

-- Identify cities where sales are declining month over month.
SELECT 
    city,
    month,
    total_revenue,
    prev_revenue
FROM (
    SELECT 
        city,
        MONTH(sale_date) AS month,
        SUM(total_revenue) AS total_revenue,
        LAG(SUM(total_revenue)) OVER (
            PARTITION BY city 
            ORDER BY MONTH(sale_date)
        ) AS prev_revenue
    FROM sales_data
    GROUP BY city, MONTH(sale_date)
) t
WHERE total_revenue < prev_revenue;

-- Rank cities based on total revenue (use DENSE_RANK).
SELECT 
    city,
    SUM(total_revenue) AS total_revenue,
    DENSE_RANK() OVER (
        ORDER BY SUM(total_revenue) DESC
    ) AS city_rank
FROM sales_data
GROUP BY city;    

-- Identify high-revenue but low-profit cities.
SELECT 
    city,
    SUM(total_revenue) AS total_revenue,
    SUM(profit) AS total_profit
FROM sales_data
GROUP BY city
HAVING 
    SUM(total_revenue) > (
        SELECT AVG(city_revenue)
        FROM (
            SELECT SUM(total_revenue) AS city_revenue
            FROM sales_data
            GROUP BY city
        ) t
    )
    AND 
    SUM(profit) < (
        SELECT AVG(city_profit)
        FROM (
            SELECT SUM(profit) AS city_profit
            FROM sales_data
            GROUP BY city
        ) t
    )
ORDER BY total_revenue DESC;


SELECT 
    city,
    SUM(total_revenue) AS total_revenue,
    SUM(profit) AS total_profit,
    SUM(profit) * 100.0 / SUM(total_revenue) AS profit_margin
FROM sales_data
GROUP BY city
HAVING 
    SUM(total_revenue) > (
        SELECT AVG(city_revenue)
        FROM (
            SELECT SUM(total_revenue) AS city_revenue
            FROM sales_data
            GROUP BY city
        ) t1
    )
    AND 
    (SUM(profit) * 100.0 / SUM(total_revenue)) < (
        SELECT AVG(profit_margin)
        FROM (
            SELECT 
                SUM(profit) * 100.0 / SUM(total_revenue) AS profit_margin
            FROM sales_data
            GROUP BY city
        ) t2
    );
    
   -- case :- Profit & Cost Analysis
   
-- Which customer_type contributes the most to revenue and profit?
select customer_type,
sum(total_revenue) as total_revenue,
sum(profit) as total_profit
from sales_data
group by customer_type 
order by total_revenue, total_profit desc;


SELECT 
    loan_approved,
    SUM(total_revenue) AS total_revenue,
    AVG(total_revenue) AS avg_order_value,
    SUM(profit) AS total_profit
FROM sales_data
GROUP BY loan_approved
ORDER BY total_revenue DESC;

-- avg rating
SELECT AVG(rating) AS avg_rating
FROM sales_data;

-- Which payment mode gives highest customer satisfaction?
SELECT 
    payment_mode,
    AVG(rating) AS avg_rating
FROM sales_data
GROUP BY payment_mode
ORDER BY avg_rating DESC;

-- Which payment mode generates the highest revenue? 
SELECT payment_mode, SUM(total_revenue) AS revenue
FROM sales_data
GROUP BY payment_mode
ORDER BY revenue DESC;





