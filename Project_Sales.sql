set serveroutput on;

                        
                                                        /*PROJECT RETAIL SALES */
--------CREATION OF TABLE SALES------------

            create table Sales(
            transaction_id INT PRIMARY KEY,
            sale_date DATE,
            sale_time TIMESTAMP,
            customer_id INT,
            gender VARCHAR(10),
            age INT,
            categories VARCHAR(15),
            quantity INT,
            price_per_unit NUMBER(10,2),
            cogs  NUMBER(10,2),
            total_sale  NUMBER(10,2));  
            
--------CREATING AN ANOTHER TABLE BECAUSE OF NEW TABLE UPDATAED WITH 24 HPURS FORMAT---------
           
            alter table sales add Sales_time varchar2(30);
           update sales set Sales_time=TO_char(sale_time,'hh24:mi:ss');
            
            create table Sales_Market as 
            select  transaction_id ,
            sale_date ,
            Sales_time,
            customer_id ,
            gender ,
            age,
            categories ,
            quantity,
            price_per_unit,
            cogs  ,
            total_sale  from sys.sales;
            
             drop table Sales;
             /*IMPORTING ALL THE DATA'S FROM A FILE AND VIEW THE TABLE SALES*/
              select * from Sales_market;

---------DATA CLEANING---------
             select * from sales_market where transaction_id is null or
                    sale_date is null or
                    sales_time is null or 
                    customer_id is null or   
                    gender is null or
                    age is null or
                    categories is null or
                    quantity is null or
                    price_per_unit is null or
                    cogs is null or  
                    total_sale is null ;
            
              DELETE  from sales_market where transaction_id is null or 
                   sale_date is null or
                   sales_time is null or
                   customer_id is null or
                   gender is null or
                   age is null or
                   categories is null or
                   quantity is null or
                   price_per_unit is null or
                   cogs is null or  
                   total_sale is null ;
                                

---------DATA EXPLORATION-----------

                     /*How many sales does we have in sales_market*/
                                     SELECT Count(*) as Total_sales_count from sales_market;
                                     
                     /*How many customer does we have in sales_market*/
                                     SELECT Count(sales_market.customer_id) as Total_customer_count from sales_market;
                                     
                      /*how many unique customer without duplicates*/
                                     SELECT Count( distinct sales_market.customer_id) as Total_customer_count from sales_market;
                                     
                    /*how many unique category in sales_market*/
                                      SELECT Count( distinct sales_market.categories) as Total_categories_count from sales_market;
                    
                    /*Categories that in sales_market*/
                                      SELECT distinct sales_market.categories as types_categories from sales_market;

-----------DATA ANALYSIS AND BUSINESS KEY PROBLEMS QUESTIONS AND ANSWERS-------------

                    ---Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05---
                    select * from sales_market where sale_date=to_date('05-11-22','dd-mm-yy');
                    select count(*) as specific_date_count  from sales_market    where sale_date=to_date('05-11-22','dd-mm-yy');
                    

                    ----Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022----
                    select *  from sales_market where sales_market.categories='Clothing' and sales_market.quantity>=4 and to_char (sales_market.sale_date,'mm-yy')='11-22';
            
                    
                    ----Q.3 Write a SQL query to calculate the total sales (total sale) for each category.----
                    select sales_market.categories,sum(sales_market.total_sale) as Total_sale,count(*) as total_orders from sales_market group by sales_market.categories;
                    
                    ----Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category. ----
                    select cast(avg(age) as int )as Average from sales_market Where categories='Beauty';
                                                                                  /*OR*/
                    select round(avg(age),2) as Average from sales_market Where categories='Beauty';
                    
                    ----Q.5 Write a SQL query to find all transactions where the total sale is greater than 1000.----
                    select * from sales_market where total_sale>1000;
                    select count(*) as Total_transaction from sales_market where  total_sale>1000;
                    
                    ----Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.----
                    select categories,gender,count(*) from sales_market group by  categories,gender order by sales_market.categories;
                    
                    ----Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year----
                    select 
                    to_char(sales_market.sale_date,'yyyy') as year,
                    to_char(sales_market.sale_date,'mm')as month,
                    avg(total_sale) as Average_sale from sales_market 
                    group by to_char(sales_market.sale_date,'yyyy'),to_char(sales_market.sale_date,'mm')
                    order by year,month;
                    
                    /*for highest sales in year and month*/
                    select 
                    to_char(sales_market.sale_date,'yyyy') as year,
                    to_char(sales_market.sale_date,'mm')as month,
                    avg(total_sale) as highest_Sales from sales_market 
                    group by to_char(sales_market.sale_date,'yyyy'),to_char(sales_market.sale_date,'mm')
                    order by year,highest_sales DESC; 
                    
                    /*Ranking in highest sales in partition by using each year */
                    select * from(
                    select
                    to_char(sales_market.sale_date,'yyyy')as year,
                    to_char(sales_market.sale_date,'mm')as month,
                    avg(total_sale) as Average_sale ,
                    rank() over(partition by to_char(sales_market.sale_date,'yyyy') order by avg(total_sale) desc ) as rank from sales_market 
                    group by to_char(sales_market.sale_date,'yyyy'),to_char(sales_market.sale_date,'mm')) t1 where rank=1; 
                    --order by year,month;
                    
                     ----Q.8 Write a SQL query to find the top 5 customers based on the highest total sales----
                    select * from sales_market order by total_sale desc fetch first 100 rows only;
                    
                 /*Aliter*/  select * from( select * from sales_market order by total_sale desc) where rownum<=5;
                   
                  /*Aliter*/ select * from( select sales_market.* ,row_number() over(order by total_sale desc) as n1 from sales_market)  where n1<=5;
                  
                  
                    ----Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.----
                    select categories,count(distinct customer_id) as counts from sales_market group by categories order by counts desc ;
                    
                     ----Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)----
                                WITH cte AS (
                             SELECT
                                 CASE
                                     WHEN sales_time < '12' THEN 'Morning'
                                     WHEN sales_time BETWEEN '12' AND '17' THEN 'Afternoon'
                                     ELSE 'Evening'
                                 END AS shift
                             FROM sales_market
                         )
                         SELECT
                             shift,
                             COUNT(*) AS total_orders
                         FROM cte
                         GROUP BY shift;
                         
                         /*to check whether any time is null or not defined or '0'*/
                         select sales_time from sales_market where sales_time is null or length(trim(sales_time))=0;
