USE BikeStores;
GO

-- Q1. List customers from the state of NY who have no phone number on file. 
-- Show their first name, last name, email and city with the aliases First Name, Last Name, Email and City. 
-- Sort by last name, then first name, and return only the first 10 rows.

-- Ans: Customers from NY without a phone number
-- Approach: (Select --> From --> Where (AND, IS NULL) --> ORDER BY --> OFFSET --> FETCH NEXT)

SELECT
    first_name AS [First Name],
    last_name AS [Last Name],
    email AS Email,
    city AS City
FROM sales.customers
WHERE state = 'NY'
    AND phone IS NULL
ORDER BY last_name, first_name
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY;

---------------------------------------------------------------------------------------------------------------------------------------------*

-- Q2. Find products with a model year of 2017 or 2018, a list price between 500 and 1500, whose name contains Trek but does not contain Kids. 
-- Show product_id, product_name, model_year and list_price, sorted by list_price from highest to lowest.

-- Ans: Trek products from model years 2017 and 2018
-- Approach: (Select --> From --> Where --> Logical Operators (IN, AND, BETWEEN, LIKE, NOT LIKE) --> ORDER BY (DESC))

SELECT
    product_id,
    product_name,
    model_year,
    list_price
FROM production.products
WHERE model_year IN (2017, 2018)
  AND list_price BETWEEN 500 AND 1500
  AND product_name LIKE '%Trek%'
  AND product_name NOT LIKE '%Kids%'
ORDER BY list_price DESC;

---------------------------------------------------------------------------------------------------------------------------------------------*

-- Q3. 
-- (a) List the distinct values of order_status in sales.orders. 
-- (b) List orders that have not been shipped yet, placed at store 1 or 3 during 2018. Show order_id, customer_id, store_id, order_date and 
-- required_date, sorted by order_date.

-- Ans: Order status and pending orders
-- (a): Find all distinct order statuses
-- Approach: (Select --> Distinct --> From)

SELECT DISTINCT
    order_status
FROM sales.orders;

-- (b): Find orders that have not been shipped
-- Approach: (Select --> From --> Where --> Logical Operators (IS NULL, AND, IN) --> Date Range Filtering (>=, <) --> ORDER BY)

SELECT
    order_id,
    customer_id,
    store_id,
    order_date,
    required_date
FROM sales.orders
WHERE shipped_date IS NULL
  AND store_id IN (1, 3)
  AND order_date >= '20180101'
  AND order_date < '20190101'
ORDER BY order_date;

---------------------------------------------------------------------------------------------------------------------------------------------*

-- Q4. For order_id = 1, show one row per order line with: order_id, order_date, customer full name, product_name, brand_name, category_name, 
-- quantity, list_price, discount and line_revenue, where line_revenue = quantity * list_price * (1 - discount) from sales.order_items.

-- Ans: Display complete details of order number 1
-- Line Revenue = Quantity * List Price * ( 1 - Discount )
-- Approach: (Select --> From --> INNER JOIN --> ON --> Multiple Table Joins --> CONCAT() --> Calculated Column (Arithmetic Operations) --> Where)

SELECT
    o.order_id,
    o.order_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_full_name,
    p.product_name,
    b.brand_name,
    cat.category_name,
    oi.quantity,
    oi.list_price,
    oi.discount,
    oi.quantity * oi.list_price * (1 - oi.discount) AS line_revenue
FROM sales.orders o
INNER JOIN sales.customers c
    ON o.customer_id = c.customer_id
INNER JOIN sales.order_items oi
    ON o.order_id = oi.order_id
INNER JOIN production.products p
    ON oi.product_id = p.product_id
INNER JOIN production.brands b
    ON p.brand_id = b.brand_id
INNER JOIN production.categories cat
    ON p.category_id = cat.category_id
WHERE o.order_id = 1;

---------------------------------------------------------------------------------------------------------------------------------------------*

-- Q5. Show every staff member with their store_name and their manager's full name. Staff who have no manager must still appear, with the 
-- manager shown as 'No Manager'.

-- Ans: Staff members with their stores and managers
-- Approach: (Select --> From --> INNER JOIN --> ON --> LEFT JOIN (Self Join) --> ON --> CONCAT() --> CASE (Conditional Expression))

SELECT
    s.staff_id,
    CONCAT(s.first_name, ' ', s.last_name) AS staff_full_name,
    st.store_name,
    CASE
        WHEN m.staff_id IS NULL THEN 'No Manager'
        ELSE CONCAT(m.first_name, ' ', m.last_name)
    END AS manager_full_name
FROM sales.staffs s
INNER JOIN sales.stores st
    ON s.store_id = st.store_id
LEFT JOIN sales.staffs m
    ON s.manager_id = m.staff_id;

---------------------------------------------------------------------------------------------------------------------------------------------*

-- Q6. List products that have never been ordered. Show product_id, product_name, brand_name and model_year.

-- Ans: Products that have never been ordered
-- Approach: (Select --> From --> INNER JOIN --> ON --> LEFT JOIN --> ON --> WHERE (IS NULL))

SELECT
    p.product_id,
    p.product_name,
    b.brand_name,
    p.model_year
FROM production.products p
INNER JOIN production.brands b
    ON p.brand_id = b.brand_id
LEFT JOIN sales.order_items oi
    ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;

---------------------------------------------------------------------------------------------------------------------------------------------*

-- Q7. 
-- (a) Create a view sales.vw_order_line_details that returns the Q4 details for all orders, also including store_name and order_status. 
-- (b) Query the view to return all order lines from January 2018, sorted by order_date, then order_id.


-- Ans: Create a view for order line details
-- (a): Create the view
-- Approach: (CREATE VIEW --> AS --> Select --> From --> Multiple INNER JOINs --> ON --> CONCAT() --> Calculated Column (Arithmetic Operations) --> GO)

CREATE VIEW sales.vw_order_line_details
AS
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    st.store_name,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_full_name,
    p.product_name,
    b.brand_name,
    cat.category_name,
    oi.quantity,
    oi.list_price,
    oi.discount,
    oi.quantity * oi.list_price * (1 - oi.discount) AS line_revenue
FROM sales.orders o
INNER JOIN sales.customers c
    ON o.customer_id = c.customer_id
INNER JOIN sales.stores st
    ON o.store_id = st.store_id
INNER JOIN sales.order_items oi
    ON o.order_id = oi.order_id
INNER JOIN production.products p
    ON oi.product_id = p.product_id
INNER JOIN production.brands b
    ON p.brand_id = b.brand_id
INNER JOIN production.categories cat
    ON p.category_id = cat.category_id;
GO

-- (b): Find all order lines from January 2018
-- Approach: (Select --> From (EXISTING VIEW) --> Where (Date Range: >= AND <) --> ORDER BY)

SELECT *
FROM sales.vw_order_line_details
WHERE order_date >= '20180101'
  AND order_date < '20180201'
ORDER BY order_date, order_id;

---------------------------------------------------------------------------------------------------------------------------------------------*

-- Q8. 
-- (a) Create a view production.vw_product_catalog with product_id, product_name, brand_name, category_name, model_year and list_price. 
-- (b) Using only this view, return all Electric Bikes priced above 3000, sorted by price from highest to lowest.

-- Ans: Create a product catalog view

-- (a): Create the view
-- Approach: (CREATE VIEW --> AS --> Select --> From --> INNER JOIN --> ON --> GO)

CREATE VIEW production.vw_product_catalog
AS
SELECT
    p.product_id,
    p.product_name,
    b.brand_name,
    c.category_name,
    p.model_year,
    p.list_price
FROM production.products p
INNER JOIN production.brands b
    ON p.brand_id = b.brand_id
INNER JOIN production.categories c
    ON p.category_id = c.category_id;
GO

-- (b): Find Electric Bikes priced above 3000
-- Approach: (Select --> From (Existing VIEW) --> Where --> AND --> ORDER BY DESC)

SELECT *
FROM production.vw_product_catalog
WHERE category_name = 'Electric Bikes'
  AND list_price > 3000
ORDER BY list_price DESC;

---------------------------------------------------------------------------------------------------------------------------------------------*

-- Q9. Using sales.vw_order_line_details, show the total number of distinct orders and total revenue for each store in each year. Sort by 
-- store_name, then year.

-- Ans: Total orders and revenue for each store in each year
-- Approach: (Select --> From --> YEAR() --> GROUP BY (Multiple Columns) --> Aggregate Functions --> ORDER BY)

SELECT
    store_name,
    YEAR(order_date) AS order_year,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(line_revenue) AS total_revenue
FROM sales.vw_order_line_details
GROUP BY
    store_name,
    YEAR(order_date)
ORDER BY
    store_name,
    order_year;

---------------------------------------------------------------------------------------------------------------------------------------------*

-- Q10. For each brand, show the number of products and the minimum, average and maximum list price. Keep only brands with more than 10 
-- products, sorted by average price from highest to lowest.

-- Ans: Brand-wise product count and price analysis
-- Approach: (Select --> From --> INNER JOIN --> GROUP BY --> Aggregate Functions --> HAVING --> ORDER BY)

SELECT
    b.brand_name,
    COUNT(p.product_id) AS total_products,
    MIN(p.list_price) AS minimum_price,
    AVG(p.list_price) AS average_price,
    MAX(p.list_price) AS maximum_price
FROM production.brands b
INNER JOIN production.products p
    ON b.brand_id = p.brand_id
GROUP BY b.brand_name
HAVING COUNT(p.product_id) > 10
ORDER BY average_price DESC;

---------------------------------------------------------------------------------------------------------------------------------------------*

-- Q11. Find products whose list price is higher than the average list price of their own category. Show product_name, category_name, 
-- list_price and the category's average price.

-- Ans: Products priced above their category average
-- Approach: (Select --> From --> INNER JOIN --> Correlated Scalar Subquery (AVG) --> Where --> Comparison Operator (>))

SELECT
    p.product_name,
    c.category_name,
    p.list_price,
    (
        SELECT AVG(p2.list_price)
        FROM production.products p2
        WHERE p2.category_id = p.category_id
    ) AS category_average_price
FROM production.products p
INNER JOIN production.categories c
    ON p.category_id = c.category_id
WHERE p.list_price >
    (
        SELECT AVG(p2.list_price)
        FROM production.products p2
        WHERE p2.category_id = p.category_id
    );

---------------------------------------------------------------------------------------------------------------------------------------------*

-- Q12. Find customers who placed at least one order in 2016 but no orders in 2018. Show customer_id, full name, email and state. Write the 
-- query twice: once with IN / NOT IN and once with EXISTS / NOT EXISTS.

-- Ans: Customers who ordered in 2016 but not in 2018

-- (a): Using IN and NOT IN
-- Approach: (Select --> From --> Where --> IN (Subquery) --> NOT IN (Subquery))

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    c.email,
    c.state
FROM sales.customers c
WHERE c.customer_id IN
(
    SELECT customer_id
    FROM sales.orders
    WHERE order_date >= '20160101'
      AND order_date < '20170101'
)
AND c.customer_id NOT IN
(
    SELECT customer_id
    FROM sales.orders
    WHERE order_date >= '20180101'
      AND order_date < '20190101'
);

-- (b): Using EXISTS and NOT EXISTS
-- Approach: (Select --> From --> Where --> EXISTS (Correlated Subquery) --> NOT EXISTS (Correlated Subquery))

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    c.email,
    c.state
FROM sales.customers c
WHERE EXISTS
(
    SELECT 1
    FROM sales.orders o
    WHERE o.customer_id = c.customer_id
      AND o.order_date >= '20160101'
      AND o.order_date < '20170101'
)
AND NOT EXISTS
(
    SELECT 1
    FROM sales.orders o
    WHERE o.customer_id = c.customer_id
      AND o.order_date >= '20180101'
      AND o.order_date < '20190101'
);

---------------------------------------------------------------------------------------------------------------------------------------------*

-- Q13. Using two CTEs in one WITH clause, first calculate the total revenue for each store, then the average of those store totals. Return 
-- only the stores whose revenue is above the average, with store_name, total_revenue, average and the difference.

-- Ans: Stores with revenue above the average store revenue
-- Approach: (WITH (Two CTEs) --> First CTE (Store Revenue) --> SUM() --> GROUP BY --> Second CTE (Average Revenue) --> AVG() --> Final SELECT --> From --> CROSS JOIN --> Where (Comparison Operator >) --> ORDER BY)

WITH StoreRevenue AS
(
    SELECT
        store_name,
        SUM(line_revenue) AS total_revenue
    FROM sales.vw_order_line_details
    GROUP BY store_name
),
AverageRevenue AS
(
    SELECT
        AVG(total_revenue) AS average_revenue
    FROM StoreRevenue
)
SELECT
    sr.store_name,
    sr.total_revenue,
    ar.average_revenue,
    sr.total_revenue - ar.average_revenue AS difference
FROM StoreRevenue sr
CROSS JOIN AverageRevenue ar
WHERE sr.total_revenue > ar.average_revenue
ORDER BY sr.total_revenue DESC;

---------------------------------------------------------------------------------------------------------------------------------------------*

-- Q14. Using a recursive CTE, build the staff hierarchy starting from the staff member with no manager. Show staff_id, staff full name, 
-- manager_id, level (top = 1) and a reporting path such as Fabiola Jackson > Mireya Copeland > Genna Serrano.

-- Ans: Create a staff hierarchy using a recursive CTE
-- Approach: (WITH (Recursive CTE) --> Anchor Member --> Where (IS NULL) --> UNION ALL --> Recursive Member --> INNER JOIN --> ON --> Level Calculation (Addition) --> CONCAT() --> CAST (VARCHAR(MAX)) --> Final SELECT --> ORDER BY --> OPTION (MAXRECURSION 100))

WITH StaffHierarchy AS
(
    -- Starting point: Staff members without a manager
    SELECT
        staff_id,
        first_name,
        last_name,
        manager_id,
        1 AS level,
        CAST(
            CONCAT(first_name, ' ', last_name)
            AS VARCHAR(MAX)
        ) AS reporting_path
    FROM sales.staffs
    WHERE manager_id IS NULL

    UNION ALL

    -- Find employees reporting to the previous level
    SELECT
        s.staff_id,
        s.first_name,
        s.last_name,
        s.manager_id,
        sh.level + 1,
        CAST(
            CONCAT(
                sh.reporting_path,
                ' > ',
                s.first_name,
                ' ',
                s.last_name
            ) AS VARCHAR(MAX)
        )
    FROM sales.staffs s
    INNER JOIN StaffHierarchy sh
        ON s.manager_id = sh.staff_id
)
SELECT
    staff_id,
    CONCAT(first_name, ' ', last_name) AS staff_full_name,
    manager_id,
    level,
    reporting_path
FROM StaffHierarchy
ORDER BY reporting_path
OPTION (MAXRECURSION 100);

---------------------------------------------------------------------------------------------------------------------------------------------*

-- Q15. 
-- (a) Using a CTE with a window function, find the top 3 products by 2017 revenue within each category. Show category_name, product_name, total quantity, total revenue and rank. 
-- (b) Using a recursive CTE that generates months 1 to 12, show the total orders and total revenue for every month of 2017, with month number and month name, showing 0 for months with no sales.

-- Ans: Advanced SQL queries

-- (a): Find the top 3 products by revenue in 2017 within each category
-- Approach: (WITH (CTE) --> Select --> From --> Where (Date Range) --> Aggregate Data (SUM) --> GROUP BY --> Second CTE --> Window Function (ROW_NUMBER) --> PARTITION BY --> ORDER BY (DESC) --> Final SELECT --> Where (Rank <= 3) --> ORDER BY)

WITH ProductRevenue AS
(
    SELECT
        v.category_name,
        v.product_name,
        SUM(v.quantity) AS total_quantity,
        SUM(v.line_revenue) AS total_revenue
    FROM sales.vw_order_line_details v
    WHERE v.order_date >= '20170101'
      AND v.order_date < '20180101'
    GROUP BY
        v.category_name,
        v.product_name
),
ProductRanking AS
(
    SELECT
        category_name,
        product_name,
        total_quantity,
        total_revenue,
        ROW_NUMBER() OVER
        (
            PARTITION BY category_name
            ORDER BY total_revenue DESC
        ) AS product_rank
    FROM ProductRevenue
)
SELECT
    category_name,
    product_name,
    total_quantity,
    total_revenue,
    product_rank
FROM ProductRanking
WHERE product_rank <= 3
ORDER BY category_name, product_rank;

-- (b): Display monthly orders and revenue for all months of 2017
-- Approach: (WITH (Recursive CTE) --> Anchor Member --> UNION ALL --> Recursive Member --> Generate Months (1 to 12) --> Second CTE (Monthly Sales) --> Aggregate Data (COUNT, SUM) --> GROUP BY --> LEFT JOIN --> Final SELECT --> Date Functions (DATENAME, DATEFROMPARTS) --> NULL Handling (ISNULL) --> ORDER BY --> OPTION (MAXRECURSION 12))

WITH Months AS
(
    -- Start with January
    SELECT 1 AS month_number

    UNION ALL

    -- Generate the remaining months
    SELECT month_number + 1
    FROM Months
    WHERE month_number < 12
),
MonthlySales AS
(
    SELECT
        MONTH(order_date) AS month_number,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(line_revenue) AS total_revenue
    FROM sales.vw_order_line_details
    WHERE order_date >= '20170101'
      AND order_date < '20180101'
    GROUP BY MONTH(order_date)
)
SELECT
    m.month_number,
    DATENAME(
        MONTH,
        DATEFROMPARTS(2017, m.month_number, 1)
    ) AS month_name,
    ISNULL(ms.total_orders, 0) AS total_orders,
    ISNULL(ms.total_revenue, 0) AS total_revenue
FROM Months m
LEFT JOIN MonthlySales ms
    ON m.month_number = ms.month_number
ORDER BY m.month_number
OPTION (MAXRECURSION 12);

---------------------------------------------------------------------------------------------------------------------------------------------*