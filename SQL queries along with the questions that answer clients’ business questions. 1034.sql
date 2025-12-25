create database project_1034;

use project_1034;

CREATE TABLE sales_analysis_1034 (
    Order_ID VARCHAR(20) PRIMARY KEY,
    Customer_ID VARCHAR(20),
    Date DATE,
    Age INT,
    Gender VARCHAR(10),
    City VARCHAR(50),
    Product_Category VARCHAR(50),
    Unit_Price DECIMAL(10,2),
    Quantity INT,
    Total_Amount_Before_Discount DECIMAL(12,2),
    Discount_Amount DECIMAL(10,2),
    Discount_Percent DECIMAL(5,2),
    Total_Amount_After_Discount DECIMAL(12,2),
    Payment_Method VARCHAR(50),
    Device_Type VARCHAR(20),
    Session_Duration_Minutes INT,
    Pages_Viewed INT,
    Is_Returning_Customer BOOLEAN,
    Delivery_Time_Days INT,
    Customer_Rating INT);
    
    -- 🔹 Phase 1:

-- 1.	What is the total revenue generated in the selected period?

SELECT
    '01/01/2025 - 31/12/2025' AS Period,
    CONCAT('₺', ROUND(SUM(CAST(Total_Amount_After_Discount AS DECIMAL(15,2)))/1000000, 2), ' M') AS Total_Revenue
FROM sales_analysis_1034;

-- 2.	Which product categories generated the highest sales revenue?

SELECT
    Product_Category,
    CONCAT('₺', ROUND(SUM(Total_Amount_After_Discount)/1000000, 2), ' M') AS Total_Revenue
FROM sales_analysis_1034
GROUP BY Product_Category
ORDER BY SUM(Total_Amount_After_Discount) DESC;

-- 3.	Which product categories sold the highest quantity of units?

SELECT
    Product_Category,
    SUM(Quantity) AS Total_Units_Sold
FROM sales_analysis_1034
GROUP BY Product_Category
ORDER BY Total_Units_Sold DESC;

-- 4.	Which customer age groups made the most purchases?

SELECT
    CASE
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END AS Age_Group,
    COUNT(DISTINCT Customer_ID) AS Total_Customers,
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM sales_analysis_1034
GROUP BY Age_Group
ORDER BY Total_Orders DESC;

-- 5.	Did male or female customers generate more sales?

SELECT
    Gender,
    COUNT(DISTINCT Customer_ID) AS Total_Customers,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    CONCAT('₺', ROUND(SUM(Total_Amount_After_Discount)/1000000, 2), ' M') AS Total_Revenue
FROM sales_analysis_1034
GROUP BY Gender
ORDER BY SUM(Total_Amount_After_Discount) DESC;

-- 6.	Which devices (mobile or desktop) generated more sales?

SELECT
    Device_Type,
    COUNT(DISTINCT Customer_ID) AS Total_Customers,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    CONCAT('₺', ROUND(SUM(Total_Amount_After_Discount)/1000000, 2), ' M') AS Total_Revenue
FROM sales_analysis_1034
GROUP BY Device_Type
ORDER BY SUM(Total_Amount_After_Discount) DESC;

-- 7.	Which payment methods were used most frequently by customers?

SELECT
    Payment_Method,
    COUNT(DISTINCT Customer_ID) AS Total_Customers,
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM sales_analysis_1034
GROUP BY Payment_Method
ORDER BY Total_Orders DESC;

-- Phase 2:

-- 1.	How much impact did discounts have on total revenue?

SELECT
    CONCAT(
        ROUND(SUM(Total_Amount_Before_Discount) / 1000000, 2),
        'M'
    ) AS Total_Revenue_Before_Discount,

    CONCAT(
        ROUND(SUM(Total_Amount_After_Discount) / 1000000, 2),
        'M'
    ) AS Total_Revenue_After_Discount,

    CONCAT(
        ROUND(
            (
                (SUM(Total_Amount_Before_Discount)
                 - SUM(Total_Amount_After_Discount))
                / SUM(Total_Amount_Before_Discount)
            ) * 100
        , 2),
        '%'
    ) AS Discount_Impact_Percentage

FROM sales_analysis_1034;

-- Question No 1 (Part 2)

SELECT
    /* 1. Total Sales WITHOUT Discount */
    CONCAT(
        ROUND(
            SUM(CASE 
                    WHEN Discount_Amount = 0 
                    THEN Total_Amount_After_Discount 
                    ELSE 0 
                END) / 1000000
        , 2),
        'M'
    ) AS Total_Sales_Without_Discount,

    /* 2. Total Sales AFTER Discount (Overall Sales) */
    CONCAT(
        ROUND(
            SUM(Total_Amount_After_Discount) / 1000000
        , 2),
        'M'
    ) AS Total_Sales_After_Discount,

    /* 3. Total Sales Increase (Amount) */
    CONCAT(
        ROUND(
            (
                SUM(Total_Amount_After_Discount)
                -
                SUM(CASE 
                        WHEN Discount_Amount = 0 
                        THEN Total_Amount_After_Discount 
                        ELSE 0 
                    END)
            ) / 1000000
        , 2),
        'M'
    ) AS Total_Sales_Increase,

    /* 4. Sales % Increase Due To Discount */
    CONCAT(
        ROUND(
            (
                (
                    SUM(Total_Amount_After_Discount)
                    -
                    SUM(CASE 
                            WHEN Discount_Amount = 0 
                            THEN Total_Amount_After_Discount 
                            ELSE 0 
                        END)
                )
                /
                SUM(CASE 
                        WHEN Discount_Amount = 0 
                        THEN Total_Amount_After_Discount 
                        ELSE 0 
                    END)
            ) * 100
        , 2),
        '%'
    ) AS Sales_Increase_Percentage_Due_To_Discount

FROM sales_analysis_1034;

-- 2.	Did customers who received discounts make repeat purchases?

-- 2 Part 1

SELECT
    CASE 
        WHEN Discount_Amount <> 0 THEN 'Discounted'
        ELSE 'Non Discounted'
    END AS customer_type,

    COUNT(*) AS total_customers,

    COUNT(CASE WHEN Is_Returning_Customer = 1 THEN 1 END) 
        AS total_returning_customers,

    ROUND(
        COUNT(CASE WHEN Is_Returning_Customer = 1 THEN 1 END) * 100.0 / COUNT(*), 
        2
    ) AS returning_percentage

FROM sales_analysis_1034
GROUP BY 
    CASE 
        WHEN Discount_Amount <> 0 THEN 'Discounted'
        ELSE 'Non Discounted'
    END;

-- 2  Part 2

SELECT
    City,
    COUNT(*) AS total_discounted_customers,
    COUNT(CASE WHEN Is_Returning_Customer = 1 THEN 1 END) AS total_discounted_returning_customers,
    ROUND(
        COUNT(CASE WHEN Is_Returning_Customer = 1 THEN 1 END) * 100.0 / COUNT(*), 2
    ) AS returning_percentage
FROM sales_analysis_1034
WHERE Discount_Amount <> 0
GROUP BY City
ORDER BY total_discounted_customers DESC;

-- 2 Part 3

SELECT
    CASE 
        WHEN Age BETWEEN 18 AND 20 THEN '18-20'
        WHEN Age BETWEEN 21 AND 25 THEN '21-25'
        WHEN Age BETWEEN 26 AND 30 THEN '26-30'
        WHEN Age BETWEEN 31 AND 35 THEN '31-35'
        ELSE '36+' 
    END AS Age_Group,
    COUNT(*) AS total_discounted_customers,
    COUNT(CASE WHEN Is_Returning_Customer = 1 THEN 1 END) AS total_discounted_returning_customers,
    ROUND(
        COUNT(CASE WHEN Is_Returning_Customer = 1 THEN 1 END) * 100.0 / COUNT(*), 2
    ) AS returning_percentage
FROM sales_analysis_1034
WHERE Discount_Amount <> 0
GROUP BY 
    CASE 
        WHEN Age BETWEEN 18 AND 20 THEN '18-20'
        WHEN Age BETWEEN 21 AND 25 THEN '21-25'
        WHEN Age BETWEEN 26 AND 30 THEN '26-30'
        WHEN Age BETWEEN 31 AND 35 THEN '31-35'
        ELSE '36+' 
    END
ORDER BY Age_Group;

-- 2 Part 4

SELECT
    Product_Category,
    COUNT(*) AS total_discounted_customers,
    COUNT(CASE WHEN Is_Returning_Customer = 1 THEN 1 END) AS total_discounted_returning_customers,
    ROUND(
        COUNT(CASE WHEN Is_Returning_Customer = 1 THEN 1 END) * 100.0 / COUNT(*), 2
    ) AS returning_percentage
FROM sales_analysis_1034
WHERE Discount_Amount <> 0
GROUP BY Product_Category
ORDER BY total_discounted_customers DESC;

-- 3.	Did discounted customers provide higher ratings or better reviews?

-- 3 Part 1

SELECT
    CASE 
        WHEN Discount_Amount <> 0 THEN 'Discounted'
        ELSE 'Non-Discounted'
    END AS Customer_Type,
    COUNT(*) AS total_customers,
    ROUND(AVG(Customer_Rating), 2) AS avg_rating
FROM sales_analysis_1034
GROUP BY 
    CASE 
        WHEN Discount_Amount <> 0 THEN 'Discounted'
        ELSE 'Non-Discounted'
    END;

-- 3 Part 2

SELECT
    Customer_Rating,
    COUNT(*) AS Total_Rating_Customers,
    COUNT(CASE WHEN Discount_Amount <> 0 THEN 1 END) AS Discounted_Count,
    COUNT(CASE WHEN Discount_Amount = 0 THEN 1 END) AS Non_Discounted_Count,
    COUNT(CASE WHEN Discount_Amount <> 0 THEN 1 END)
      - COUNT(CASE WHEN Discount_Amount = 0 THEN 1 END) AS Discount_Difference
FROM sales_analysis_1034
GROUP BY Customer_Rating
ORDER BY Customer_Rating;

-- 4.	On average, how many pages do buyers view before making a purchase?

SELECT 
    CASE 
        WHEN COALESCE(Discount_Percent, 0) > 0 
             OR COALESCE(Discount_Amount, 0) > 0
        THEN 'Discounted Customers'
        ELSE 'Non-Discounted Customers'
    END AS Customer_Type,
    AVG(Pages_Viewed) AS Avg_Pages_Viewed
FROM sales_analysis_1034
GROUP BY 
    CASE 
        WHEN COALESCE(Discount_Percent, 0) > 0 
             OR COALESCE(Discount_Amount, 0) > 0
        THEN 'Discounted Customers'
        ELSE 'Non-Discounted Customers'
    END;

-- 5.	Did customers who spent more time on the website give better ratings?

SELECT 
    CASE 
        WHEN Session_Duration_Minutes BETWEEN 1 AND 4 THEN '1-4 min'
        WHEN Session_Duration_Minutes BETWEEN 5 AND 8 THEN '5-8 min'
        WHEN Session_Duration_Minutes BETWEEN 9 AND 12 THEN '9-12 min'
        WHEN Session_Duration_Minutes BETWEEN 13 AND 16 THEN '13-16 min'
        WHEN Session_Duration_Minutes BETWEEN 17 AND 20 THEN '17-20 min'
        WHEN Session_Duration_Minutes BETWEEN 21 AND 24 THEN '21-26 min'
        ELSE 'Other' 
    END AS Session_Time_Group,
    AVG(Customer_Rating) AS Avg_Customer_Rating
FROM sales_analysis_1034
GROUP BY 
    CASE 
        WHEN Session_Duration_Minutes BETWEEN 1 AND 4 THEN '1-4 min'
        WHEN Session_Duration_Minutes BETWEEN 5 AND 8 THEN '5-8 min'
        WHEN Session_Duration_Minutes BETWEEN 9 AND 12 THEN '9-12 min'
        WHEN Session_Duration_Minutes BETWEEN 13 AND 16 THEN '13-16 min'
        WHEN Session_Duration_Minutes BETWEEN 17 AND 20 THEN '17-20 min'
        WHEN Session_Duration_Minutes BETWEEN 21 AND 24 THEN '21-26 min'
        ELSE 'Other' 
    END
ORDER BY Session_Time_Group;


-- 6.	How did customers with low session duration behave in terms of ratings and purchases?


-- 7. Which platform—mobile or desktop—users spend more time per session 
-- prior to completing a purchase? 

SELECT
    Device_Type,
    COUNT(*) AS Total_Orders,
    AVG(Session_Duration_Minutes) AS Avg_Session_Duration,
    ROUND( (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM sales_analysis_1034), 2) AS Orders_Percentage
FROM sales_analysis_1034
GROUP BY Device_Type;


-- 8. Is there a correlation between 
-- session duration and the number of pages viewed or the likelihood of making a purchase?

SELECT 
    CASE 
        WHEN Session_Duration_Minutes BETWEEN 1 AND 4 THEN '1-4 min'
        WHEN Session_Duration_Minutes BETWEEN 5 AND 8 THEN '5-8 min'
        WHEN Session_Duration_Minutes BETWEEN 9 AND 12 THEN '9-12 min'
        WHEN Session_Duration_Minutes BETWEEN 13 AND 16 THEN '13-16 min'
        WHEN Session_Duration_Minutes BETWEEN 17 AND 20 THEN '17-20 min'
        WHEN Session_Duration_Minutes BETWEEN 21 AND 24 THEN '21-24 min'
        WHEN Session_Duration_Minutes BETWEEN 25 AND 26 THEN '25-26 min'
        ELSE 'Other' 
    END AS Session_Time_Group,
    AVG(Pages_Viewed) AS Avg_Pages_Viewed,
    COUNT(Order_ID) AS Purchases,
    ROUND((COUNT(Order_ID)*100.0)/COUNT(*),2) AS Purchase_Percentage
FROM sales_analysis_1034
GROUP BY 
    CASE 
        WHEN Session_Duration_Minutes BETWEEN 1 AND 4 THEN '1-4 min'
        WHEN Session_Duration_Minutes BETWEEN 5 AND 8 THEN '5-8 min'
        WHEN Session_Duration_Minutes BETWEEN 9 AND 12 THEN '9-12 min'
        WHEN Session_Duration_Minutes BETWEEN 13 AND 16 THEN '13-16 min'
        WHEN Session_Duration_Minutes BETWEEN 17 AND 20 THEN '17-20 min'
        WHEN Session_Duration_Minutes BETWEEN 21 AND 24 THEN '21-24 min'
        WHEN Session_Duration_Minutes BETWEEN 25 AND 26 THEN '25-26 min'
        ELSE 'Other' 
    END
ORDER BY Session_Time_Group;


-- 9.	Does higher engagement (time + page views) lead to higher sales and repeat purchases?

SELECT
    CASE 
        WHEN Session_Duration_Minutes + Pages_Viewed <= 10 THEN 'Low Engagement'
        WHEN Session_Duration_Minutes + Pages_Viewed BETWEEN 11 AND 20 THEN 'Medium Engagement'
        ELSE 'High Engagement'
    END AS Engagement_Level,
    COUNT(Order_ID) AS Total_Orders,
    AVG(Total_Amount_After_Discount) AS Avg_Sales,
    ROUND( (SUM(CASE WHEN Is_Returning_Customer=1 THEN 1 ELSE 0 END)*100.0)/COUNT(*),2) AS Repeat_Purchase_Percentage
FROM sales_analysis_1034
GROUP BY
    CASE 
        WHEN Session_Duration_Minutes + Pages_Viewed <= 10 THEN 'Low Engagement'
        WHEN Session_Duration_Minutes + Pages_Viewed BETWEEN 11 AND 20 THEN 'Medium Engagement'
        ELSE 'High Engagement'
    END
ORDER BY Engagement_Level;


-- 🔹 Phase 3:

-- 10.	In which months did sales increase, and what were the main reasons for the increase?

-- 11.	In which months did sales decrease or remain low, and 
-- what were the main reasons for the decline?

-- 12.	Which customers returned for repeat purchases, and what factors influenced their return?
