# Project summary

 MySQL project for analyzing warehouse and retail sales with the following questions.

## Data Cleaning

We are creating a duplicate table projects where we're copying the entire data from our raw file warehouse_and_retail_sales

Query : 
````sql
CREATE TABLE PROJECTS AS
SELECT *FROM warehouse_and_retail_sales;
select *from projects;



### checking for missing values

Query : 
````sql
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

Result : 
![supply](https://github.com/user-attachments/assets/f9470d92-dc6d-4b0e-961f-158294833e32)

There are no missing values

### checking for duplicates
   
Query : 
````sql
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

Result : 
![s2](https://github.com/user-attachments/assets/f9470d92-dc6d-4b0e-961f-158294833e32)

There are no duplicate Values present

## Aggregation

### What is the total retail sales for each supplier ?

Query :
````sql
select supplier, round(sum(`retail sales`),3) as total_retail_sales
from projects 
group by supplier;

Result :
![s3](https://github.com/user-attachments/assets/25d4fe92-726b-4153-8029-b280e9bb71bb)

### How many distinct item codes are in the dataset?

Query :
````sql
select count(distinct `item code`) as distinct_item_codes
from projects;

Result :
![s3](https://github.com/user-attachments/assets/19b5fa4c-9a2d-4ae9-9917-3843a53e5173)

### What is the total retail sales for each item type

Query : 
````sql
select `item type`, round(sum(`retail sales`),3) as total_retail_sales
from projects 
group by `item type`;

Result :
![s4](https://github.com/user-attachments/assets/4a6973ac-932d-449f-98cf-5153eed632cb)

### What is the total retail sales for each combination of supplier and month 

Query :
````sql
select supplier, year, month, round(sum(`retail sales`),3) as total_retail_sales
from projects 
group by supplier, year, month;

Result :
![s5](https://github.com/user-attachments/assets/37970cb4-7172-43a8-a86b-3f0663ff17dd)

### What is the maximum warehouse sales for each item description 

Query :
````sql
select `item description`, max(`retail sales`) as max_warehouse_sales
from projects 
group by `item description`;

Result :
![s6](https://github.com/user-attachments/assets/31b16565-fdb9-436e-b913-8c93368ef446)

### What is the average retail transfer for each year 

Query :
````sql
select year, round(avg(`retail transfers`),2) as avg_retail_transfers
from projects
group by year;

Result :
![s7](https://github.com/user-attachments/assets/4c42556c-beb2-49f7-9b46-0c32585ccfb5)

### For each item description, what is the difference between the maximum and minimum retail sales

Query :
````sql
select `item description`, round((max(`retail sales`) - min(`retail sales`)),3) as diff_max_min_retail_sales
from projects 
group by `item description`;

Result :
![s8](https://github.com/user-attachments/assets/fd1aa113-6560-4399-8855-c0f4c0f1fed2)

### What is the total retail sales for each item type where the retail sales exceed 1000

Query :
````sql
select `item type`, round(sum(`retail sales`),3) as total_retail_sales
from projects 
where `retail sales` > 1000
group by `item type`;

Result :
![s9](https://github.com/user-attachments/assets/8615d078-a6bf-49c1-be65-26eabfb69833)

### what is the average daily retail sales for each combination of supplier and item code

Query :
````sql
select `item code`, supplier, round(avg(`retail sales`),2) as avg_daily_retail_sales
from projects 
group by  `item code`, supplier
having 
AVG(`retail sales`) <> 0
order by avg(`retail sales`) ;

Result :
![s10](https://github.com/user-attachments/assets/377ad403-823a-4bac-bbfd-4c51368a7d37)

### List suppliers whose average retail sales per item are above the overall average retail sales for all items

Query :
````sql
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

Result :
![s11](https://github.com/user-attachments/assets/d84a1d6c-df2b-401d-b52c-c584c50b0b42)

### List the item codes and their average retail sales for suppliers with the highest average retail sales

Query :
````sql
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

Result :
![s12](https://github.com/user-attachments/assets/5f89f199-8180-4b6a-926a-d7e505bf3e65)

### Calculate the year-to-date sales for each Year

Query :
````sql
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

Result :
![s13](https://github.com/user-attachments/assets/630c4ea1-bbff-493c-95ec-683bd433534d)



