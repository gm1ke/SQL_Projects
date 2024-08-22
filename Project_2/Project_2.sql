select *from warehouse_and_retail_sales;
select count(*) from warehouse_and_retail_sales;

CREATE TABLE PROJECTS AS
SELECT *FROM warehouse_and_retail_sales;
select *from projects;

-- check for missing values

SELECT *
FROM projects
WHERE `YEAR` IS NULL 
   OR `MONTH` IS NULL 
   OR `SUPPLIER` IS NULL 
   OR `ITEM CODE` IS NULL 
   OR `ITEM DESCRIPTION` IS NULL 
   OR `ITEM TYPE` IS NULL 
   OR `RETAIL SALES` IS NULL 
   OR `RETAIL TRANSFERS` IS NULL 
   OR `WAREHOUSE SALES` IS NULL;
   
-- check for duplicates
   
   SELECT 
    `YEAR`, `MONTH`, `SUPPLIER`, `ITEM CODE`, `ITEM DESCRIPTION`, `ITEM TYPE`, 
    `RETAIL SALES`, `RETAIL TRANSFERS`, `WAREHOUSE SALES`, COUNT(*) AS duplicate_count
FROM 
    projects
GROUP BY 
    `YEAR`, `MONTH`, `SUPPLIER`, `ITEM CODE`, `ITEM DESCRIPTION`, `ITEM TYPE`, 
    `RETAIL SALES`, `RETAIL TRANSFERS`, `WAREHOUSE SALES`
HAVING 
    COUNT(*) > 1;
    
/* removing rows with missing values
since it is less than 1% of the whole dataset */

SET SQL_SAFE_UPDATES=0;

DELETE FROM projects 
WHERE `YEAR` IS NULL 
   OR `MONTH` IS NULL 
   OR `SUPPLIER` IS NULL 
   OR `ITEM CODE` IS NULL 
   OR `ITEM DESCRIPTION` IS NULL 
   OR `ITEM TYPE` IS NULL 
   OR `RETAIL SALES` IS NULL 
   OR `RETAIL TRANSFERS` IS NULL 
   OR `WAREHOUSE SALES` IS NULL;
   
   /* USING THE AGGREGATE FUNCTIONS */

-- what is the total retail sales for each supplier ?

select supplier, round(sum(`retail sales`),3) as total_retail_sales
from projects 
group by supplier;

-- how many distinct item codes are in the dataset?

select count(distinct `item code`) as distinct_item_codes
from projects;

-- what is the total retail sales for each item type 

select `item type`, round(sum(`retail sales`),3) as total_retail_sales
from projects 
group by `item type`;

-- what is the total retail sales for each combination of supplier and month 

select supplier, year, month, round(sum(`retail sales`),3) as total_retail_sales
from projects 
group by supplier, year, month;

-- what is the maximum warehouse sales for each item description?

select `item description`, max(`retail sales`) as max_warehouse_sales
from projects 
group by `item description`;

-- what is the average retail transfer for each year 

select year, round(avg(`retail transfers`),2) as avg_retail_transfers
from projects
group by year;

/* for each item description, what is the difference between the maximum and minimum retail sales? */

select `item description`, round((max(`retail sales`) - min(`retail sales`)),3) as diff_max_min_retail_sales
from projects 
group by `item description`;

/* what is the total retail sales for each item type where the retail sales exceed 1000?
*/

select `item type`, round(sum(`retail sales`),3) as total_retail_sales
from projects 
where `retail sales` > 1000
group by `item type`;

/* what is the average daily retail sales for each combination of supplier and item code? */

select `item code`, supplier, round(avg(`retail sales`),2) as avg_daily_retail_sales
from projects 
group by  `item code`, supplier
having 
AVG(`retail sales`) <> 0
order by avg(`retail sales`) ;

-- Find Suppliers with Above Average Retail Sales
/*List suppliers whose average retail sales per item are above the overall average retail sales for all items.*/


SELECT 
    supplier, 
    `item code`, 
    ROUND(AVG(`retail sales`), 2) AS avg_daily_retail_sales
FROM 
    projects 
GROUP BY 
    `item code`, supplier
HAVING 
    AVG(`retail sales`) > (
        SELECT 
            ROUND(AVG(`retail sales`), 2)
        FROM 
            projects
    )
ORDER BY 
    avg_daily_retail_sales;
    

-- Find Items with the Highest Average Retail Sales Per Supplier
/*List the item codes and their average retail sales for suppliers with the highest average retail sales.*/

SELECT 
    supplier, 
    ROUND(AVG(`retail sales`), 2) AS avg_daily_retail_sales
FROM 
    projects
GROUP BY 
    supplier
HAVING 
    ROUND(AVG(`retail sales`), 2) = (
        SELECT 
            MIN(avg_sales)
        FROM (
            SELECT 
                `supplier`, 
                ROUND(AVG(`retail sales`), 2) AS avg_sales
            FROM 
                projects
            GROUP BY 
                `supplier`
            HAVING 
                ROUND(AVG(`retail sales`), 2) > 0
        ) AS subquery
    )
ORDER BY 
    avg_daily_retail_sales;
 
 
 -- List Suppliers with Sales Data in Every Month
/* find suppliers who have retail sales data for every month of the year. */

(
    SELECT 
        supplier
    FROM 
        projects
    GROUP BY 
        supplier
    HAVING 
        COUNT(DISTINCT (`MONTH`)) = 12
)
UNION ALL
(
    SELECT 'None' AS supplier
    WHERE NOT EXISTS (
        SELECT 
            1
        FROM 
            projects
        GROUP BY 
            supplier
        HAVING 
            COUNT(DISTINCT (`MONTH`)) = 12
    )
);


-- Compare Average Sales for Each Item Code Against the Overall Average
/* Find item codes where the average retail sales are above the overall average, including the item codes and their average sales. */

SELECT 
    `item code`, 
    ROUND(AVG(`retail sales`), 2) AS avg_daily_retail_sales
FROM 
    projects
GROUP BY 
    `item code`
HAVING 
    AVG(`retail sales`) > (
        SELECT 
            ROUND(AVG(`retail sales`), 2)
        FROM 
            projects
    )
ORDER BY 
    avg_daily_retail_sales DESC;
    
-- Calculate the running total of retail sales for each item code ordered by month.

SELECT 
    `item code`, 
    `MONTH`, 
    `YEAR`, 
    `retail sales`,
    SUM(`retail sales`) OVER (PARTITION BY `item code` ORDER BY `YEAR`, `MONTH`) AS running_total
FROM 
    projects
ORDER BY 
    `item code`, `YEAR`, `MONTH`;
    
-- Calculate the monthly average retail sales and compare each month’s average with the previous month’s average.

WITH MonthlyAverage AS (
    SELECT 
        `YEAR`,
        `MONTH`,
        round(AVG(`retail sales`),2) AS avg_sales
    FROM 
        projects
    GROUP BY 
        `YEAR`, `MONTH`
)
SELECT 
    `YEAR`,
    `MONTH`,
    avg_sales,
    LAG(avg_sales) OVER (ORDER BY `YEAR`, `MONTH`) AS prev_month_avg_sales
FROM 
    MonthlyAverage
ORDER BY 
    `YEAR`, `MONTH`;

-- Calculate the year-to-date sales for each item code.

SELECT 
    `YEAR`, 
    `MONTH`, 
    sales,
    ROUND(
        SUM(sales) OVER (
            PARTITION BY `YEAR` 
            ORDER BY `MONTH` ASC 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 2
    ) AS year_to_date_sales
FROM 
    (SELECT 
        `YEAR`, 
        `MONTH`, 
        ROUND(SUM(`retail sales`), 2) AS sales
    FROM 
        projects
    GROUP BY 
        `YEAR`, `MONTH`
    ) AS subquery
ORDER BY 
    `YEAR`, `MONTH` ASC;








