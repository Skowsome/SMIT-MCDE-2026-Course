-- 1. Write a query that lists every product with its brand name, using production.products and production.brands.

SELECT
    p.product_name,
    b.brand_name
FROM production.products AS p
INNER JOIN production.brands AS b
    ON p.brand_id = b.brand_id;

-- Explanation:
-- production.products AS p assigns the alias p to the products table.
-- production.brands AS b assigns the alias b to the brands table.
-- INNER JOIN matches products with their corresponding brands using brand_id.
-- Note: If we want to include every product even when its brand is missing or unmatched, use LEFT JOIN instead of INNER JOIN.

-- *****************************************************************************************************

-- 2. Using a LEFT JOIN, write a query that finds every store with zero staff currently assigned to it.

SELECT
    s.store_id,
    s.store_name
FROM sales.stores AS s
LEFT JOIN sales.staffs AS st
    ON s.store_id = st.store_id
WHERE st.staff_id IS NULL;

-- Explanation:
-- LEFT JOIN returns every store, including stores without matching staff.
-- ON s.store_id = st.store_id matches staff to their assigned stores.
-- WHERE st.staff_id IS NULL keeps only stores with no matching staff records.
-- Remember: A LEFT JOIN combined with WHERE right_table.primary_key IS NULL is a common SQL pattern for finding records with no matching rows in another table.

-- *****************************************************************************************************

-- 3. Explain, in your own words, why the following query returns every product regardless of stock level, and rewrite it so that it only returns products with fewer than 5 units in stock at store 1:
-- SELECT p.product_name, s.quantity
--FROM production.products AS p
-- LEFT JOIN production.stocks AS s
   -- ON p.product_id = s.product_id AND s.quantity < 5 AND s.store_id = 1;

-- Ans: Why does the original query return every product?
-- The original query uses a LEFT JOIN:

SELECT p.product_name, s.quantity
FROM production.products AS p
LEFT JOIN production.stocks AS s
   ON p.product_id = s.product_id
  AND s.quantity < 5
  AND s.store_id = 1;

-- A LEFT JOIN returns every row from the left table (production.products), even when no matching row exists in production.stocks.

-- The conditions s.quantity < 5 and s.store_id = 1 are inside the ON clause. They determine which stock records can match a product, but they do not filter out products from the left table.

-- For products without matching stock records, SQL returns the product with NULL in the quantity column.

-- Correct Query:
-- To return only products with fewer than 5 units in stock at store 1, use an INNER JOIN:

SELECT
    p.product_name,
    s.quantity
FROM production.products AS p
INNER JOIN production.stocks AS s
    ON p.product_id = s.product_id
WHERE s.quantity < 5
  AND s.store_id = 1;

-- *****************************************************************************************************

-- 4. Write a self join on sales.staffs that lists every manager along with a count placeholder column showing 1 for each employee they manage (you will replace this with a real COUNT in Chapter 3); for now, just produce one row per employee-manager pair.

SELECT
    m.staff_id AS manager_id,
    m.first_name + ' ' + m.last_name AS manager_name,
    e.staff_id AS employee_id,
    e.first_name + ' ' + e.last_name AS employee_name,
    1 AS employee_count
FROM sales.staffs AS e
INNER JOIN sales.staffs AS m
    ON e.manager_id = m.staff_id;

-- Explanation:
-- sales.staffs AS e represents employees.
-- sales.staffs AS m represents managers. Both aliases refer to the same table, which makes this a self join.
-- e.manager_id = m.staff_id matches each employee to their manager.
-- 1 AS employee_count creates a placeholder column with the value 1 for each employee-manager pair.
-- Result: Each row represents one employee and their manager. A manager who supervises five employees will appear in five rows, each with employee_count = 1. We can later use COUNT() and GROUP BY to calculate the actual number of employees per manager.

-- *****************************************************************************************************

-- 5. Write a three-table join across sales.orders, sales.order_items, and production.products that lists every item in order #1, including product name and quantity.

SELECT
    o.order_id,
    p.product_name,
    oi.quantity
FROM sales.orders AS o
INNER JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN production.products AS p
    ON oi.product_id = p.product_id
WHERE o.order_id = 1;

-- Explanation:
-- sales.orders AS o identifies order #1.
-- sales.order_items AS oi retrieves the individual items and their quantities.
-- production.products AS p provides the product names.
-- The JOIN conditions connect the three tables through order_id and product_id.
-- WHERE o.order_id = 1 restricts the results to order #1.
-- Result: One row per item in order #1, showing its order ID, product name, and quantity.

-- *****************************************************************************************************

-- 6. A colleague joins orders to order_items and reports "we received 4,658 orders last year." Explain what actually went wrong with that number and how you would find the true order count instead.

-- Ans: The problem is that the colleague counted rows after joining orders to order_items, rather than counting distinct orders.
-- Noted that one order can contain multiple items. When sales.orders is joined to sales.order_items, the same order appears once for each item.

-- How to find the true order count
-- If we want to count orders placed during the previous calendar year, we use COUNT(DISTINCT) on the order ID:

SELECT COUNT(DISTINCT o.order_id) AS total_orders
FROM sales.orders AS o
INNER JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_date >= '2025-01-01'
  AND o.order_date <  '2026-01-01';

-- This counts each order only once, even when it contains multiple items.

-- An even simpler query
-- If we only need the number of orders and do not need any information from order_items, count directly from sales.orders:

SELECT COUNT(*) AS total_orders
FROM sales.orders
WHERE order_date >= '2025-01-01'
  AND order_date <  '2026-01-01';

-- This is generally the better approach because it avoids an unnecessary join.

-- *****************************************************************************************************

-- 7.  Think About It: CROSS JOIN is often considered dangerous because it can accidentally produce millions of rows from two innocent-looking tables. Under what real circumstances would you deliberately want a CROSS JOIN, and how would you guard against using one by accident, for example, by forgetting an ON clause that was meant to be there?

-- Ans: A CROSS JOIN is useful when we deliberately want every possible combination of rows from two tables. It becomes dangerous when we use it accidentally because the result contains the product of both tables' row counts.

-- 7.1. When would we deliberately use a CROSS JOIN?
-- Example: Generate all possible product and store combinations.

-- Suppose we want to check inventory for every product at every store, including combinations that do not yet have stock records.

SELECT
    p.product_name,
    s.store_name
FROM production.products AS p
CROSS JOIN sales.stores AS s;

-- If there are 100 products and 5 stores, the result contains:
--	100 x 5 = 500 rows

-- Other real-world uses include:
-- Sales planning: Combine products with future sales scenarios.
-- Scheduling: Generate every combination of employees and available shifts.
-- Test data generation: Create combinations of test cases, user roles, and environments.
-- Reporting: Generate every month and product-category combination, including combinations with zero sales.

-- 7.2. Why can a CROSS JOIN be dangerous?
-- Suppose we intended to join orders to customers but accidentally omitted the ON condition.

-- Incorrect query:

SELECT
    o.order_id,
    c.first_name,
    c.last_name
FROM sales.orders AS o
CROSS JOIN sales.customers AS c;

-- If there are 10,000 orders and 1,000 customers, SQL Server returns:
--	10,000 x 1,000 = 10,000,000 rows

-- The result may consume substantial memory, processing time, and network bandwidth, and its data will not represent the intended customer-order relationships.

-- 7.3. How do we guard against an accidental CROSS JOIN?
-- Use these practical safeguards:
-- 7.3.1. Choose the correct join explicitly. If tables are related, use INNER JOIN or LEFT JOIN with the appropriate ON condition.

SELECT
    o.order_id,
    c.first_name,
    c.last_name
FROM sales.orders AS o
INNER JOIN sales.customers AS c
    ON o.customer_id = c.customer_id;

-- 7.3.2. Estimate row counts before executing. If the result should contain roughly one row per order but the query produces millions, investigate the join conditions.
-- 7.3.3. Test with a small sample. Use TOP (100) during development to inspect the result before running a large query. Note that TOP limits returned rows but does not necessarily prevent expensive underlying work.
-- 7.3.4. Check the execution plan and table relationships. Confirm that the join uses the intended keys and that the resulting row count makes sense.
-- 7.3.5. Use code reviews and query formatting. Put each JOIN and its ON clause on separate lines, making missing conditions easier to spot.