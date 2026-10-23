-- Q1. Write a query that selects product_name, list_price, and a calculated column price_in_thousands (list_price divided by 1000) from production.products.

SELECT
    product_name,
    list_price,
    list_price / 1000.0 AS price_in_thousands
FROM production.products;

-- Q2. Write a query that returns the distinct list of state values from sales.customers.

SELECT DISTINCT state
FROM sales.customers;

-- Q3. Write a query that returns the 5 cheapest products, showing product_name and list_price, sorted appropriately.

SELECT TOP 5
    product_name,
    list_price
FROM production.products
ORDER BY list_price ASC;

-- Q4. Write a query that returns products priced between 200 and 600, where the category is either 1 or 6. Use BETWEEN and IN together.

SELECT
    product_name,
    list_price,
    category_id
FROM production.products
WHERE list_price BETWEEN 200 AND 600
  AND category_id IN (1, 6);

-- Q5. The following query is meant to find affordable mountain or road bikes (categories 1 and 6) under $1000, but it has a bug. Identify it and rewrite it correctly:

-- SELECT product_name, category_id, list_price
-- FROM production.products
-- WHERE category_id = 1 OR category_id = 6 AND list_price < 1000;

-- Ans: The bug is missing parentheses around the OR conditions. In SQL Server, AND has higher precedence than OR, so the original query returns all category 1 products, including those priced at $1,000 or more.

SELECT
    product_name,
    category_id,
    list_price
FROM production.products
WHERE (category_id = 1 OR category_id = 6)
  AND list_price < 1000;

-- Another Alternative Approach by using IN:

SELECT
    product_name,
    category_id,
    list_price
FROM production.products
WHERE category_id IN (1, 6)
  AND list_price < 1000;

-- Both queries return the same results.

-- Q6. Write a query that finds all customers whose email ends in .com and whose last_name starts with the letter "M".

SELECT
    first_name,
    last_name,
    email
FROM sales.customers
WHERE email LIKE '%.com'
  AND last_name LIKE 'M%';

-- Q7. Write a query that returns the 11th through 20th most expensive products using OFFSET...FETCH.

SELECT
    product_name,
    list_price
FROM production.products
ORDER BY list_price DESC
OFFSET 10 ROWS
FETCH NEXT 10 ROWS ONLY;

-- Q8. Think About It: A junior engineer writes WHERE discount <> NULL to find order items with a defined discount, and the query returns zero rows even though the table clearly has non-null discount values. Explain why, using three-valued logic, and write the correct version.

-- Ans: The query returns zero rows because SQL uses three-valued logic when comparing values with NULL. In SQL Server, comparing any value with NULL using <> produces UNKNOWN, because NULL represents an unknown or missing value.

-- Correct query (Use IS NOT NULL to find order items with a defined discount)

SELECT *
FROM sales.order_items
WHERE discount IS NOT NULL;

-- To find order items whose discount is missing, use:

SELECT *
FROM sales.order_items
WHERE discount IS NULL;