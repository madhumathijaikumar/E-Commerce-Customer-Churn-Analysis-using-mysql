USE ecomm;
select * from customer_churn;

-- calculating mean 

select round(avg(WarehouseToHome)) as averagewarehousetohome from customer_churn;
select round( avg(HourSpendOnApp)) as averageHourSpendOnApp from customer_churn;
select round(avg(OrderAmountHikeFromlastYear)) as averageOrderAmountHikeFromlastYear from customer_churn;
select round(avg(DaySinceLastOrder)) as averageDaySinceLastOrder from customer_churn;

-- calculating mode
select tenure from customer_churn
group by tenure
order by count(*) desc limit 1;

select couponused from customer_churn
group by couponused
order by count(*) desc limit 1; 

select ordercount from customer_churn
group by ordercount
order by count(*) desc limit 1;

-- Handle outliers in the 'WarehouseToHome' column by deleting rows where the values are greater than 100. 

delete from customer_churn where WarehouseToHome >100;


update customer_churn
set
    PreferredLoginDevice = case 
        when PreferredLoginDevice like '%Phone%' then 'Mobile Phone'
        else PreferredLoginDevice 
  end,
    PreferredOrderCat = case 
        when PreferredOrderCat like '%Mobile%' then 'Mobile Phone'
        else PreferredOrderCat 
    end
where
    PreferredLoginDevice like '%Phone%' or 
    PreferredOrderCat like '%Mobile%';
    
    select * from customer_churn;
    
-- Standardize payment mode values: Replace "COD" with "Cash on Delivery" and "CC" with "Credit Card" in the PreferredPaymentMode column.

update customer_churn
set PreferredPaymentMode=replace(PreferredPaymentMode,'CC','Credit card');

update customer_churn
set PreferredPaymentMode=replace(PreferredPaymentMode,'COD','Cash on Delivery');
select * from customer_churn;

-- Rename the column "PreferedOrderCat" to "PreferredOrderCat"
alter table customer_churn
rename column PreferedOrderCat to PreferredOrderCat;

-- Rename the column "HourSpendOnApp" to "HoursSpentOnApp"
alter table customer_churn
rename column HourSpendOnApp to HoursSpendOnApp;
select * from customer_churn;


-- create complaintreceived column
alter table customer_churn
add column ComplaintReceived enum('yes','no');
update customer_churn
set ComplaintReceived = if(complain=1,'yes','no');
select * from customer_churn;

-- create churnstatus column
alter table customer_churn
add column churnstatus enum('churned','active');
update customer_churn
set churnstatus = if(churn=1,'churned','active');
select * from customer_churn;

-- dropping columns from table
alter table customer_churn
drop column churn;
alter table customer_churn
drop column complain;
select * from customer_churn;

-- 1 Retrieve the count of churned and active customers from the dataset
select count(churnstatus) from customer_churn
where churnstatus='churned';

select count(churnstatus) from customer_churn
where churnstatus='active';


-- 2 Display the average tenure of customers who churned
select avg(tenure) as averagetenure from customer_churn
where churnstatus='churned';

-- 3 total cashback amount earned by customers who churned
select sum(cashbackamount) as cashback from customer_churn
where churnstatus='churned';

-- 4 percentage of churned customers who complained
select round( (count(ComplaintReceived)/count(churnstatus)*100)) as perceentage from customer_churn
where churnstatus='churned' and complaintreceived = 'yes';

-- 5 gender distribution of customers who complained
select count(gender)  as genderdistribution from customer_churn
where complaintreceived='yes'
group by gender;

-- 6 Identify the city tier with the highest number of churned customers whose preferred order category is Laptop & Accessory.

select count(CustomerID),citytier,PreferredOrderCat,churnstatus from customer_churn
where PreferredOrderCat='Laptop & Accessory' and churnstatus='churned'
group by CityTier limit 1;


-- 7 the most preferred payment mode among active customers
select churnstatus,max(PreferredPaymentMode) from customer_churn
where churnstatus='Active';

-- 8 preferred login device(s) among customers who took more than 10 days since their last order
select DaySinceLastOrder,PreferredLoginDevice from customer_churn
where  DaySinceLastOrder>10
order by PreferredLoginDevice desc;

-- 9 number of active customers who spent more than 3 hours on the app
select count(CustomerId) as activecustomerscount from customer_churn
where churnstatus='active' and HoursSpendOnApp>3;

-- 10 average cashback amount received by customers who spent at least 2 hours on the app
select round(avg(CashbackAmount)) as avgcashback from customer_churn
where HoursSpendOnApp>=2;

-- 11 the maximum hours spent on the app by customers in each preferred order category
select max(HoursSpendOnApp) as maxhrs, PreferredOrderCat from customer_churn
group by PreferredOrderCat;

-- 12 the average order amount hike from last year for customers in each marital status category.
select avg(OrderAmountHikeFromlastYear) as avgorder, MaritalStatus from customer_churn
group by MaritalStatus;

-- 13 the total order amount hike from last year for customers who are single and prefer mobile phones for ordering.
select sum(OrderAmountHikeFromlastYear) ,maritalstatus,PreferredLoginDevice from customer_churn
where maritalstatus='single' and PreferredLoginDevice='mobile phone';

-- 14 average number of devices registered among customers who used UPI as their preferred payment mode.
select round(avg(NumberOfDeviceRegistered)) as avg_no_of_devices from customer_churn
where PreferredPaymentMode='UPI';


-- 15  the city tier with the highest number of customers.
select count(customerId) as customercount,Citytier from customer_churn
group by CityTier
order by customercount desc limit 1;

-- 16 the marital status of customers with the highest number of addresses
select max(NumberOfAddress),maritalstatus from customer_churn
group by maritalstatus;

-- 17 the gender that utilized the highest number of coupons.
select gender,max(CouponUsed) from customer_churn
group by gender
order by gender desc limit 1;


-- the average satisfaction score in each of the preferred order categories
select avg(SatisfactionScore),PreferredOrderCat from customer_churn
group by PreferredOrderCat;

-- 19 the total order count for customers who prefer using credit cards and have the maximum satisfaction score.
select sum(OrderCount) from customer_churn
where PreferredPaymentMode='credit card'
order by SatisfactionScore desc limit 1;

-- 20 customers who spent only one hour on the app and days since their last order was more than 5?
select count(customerid) as custcount from customer_churn
where HoursSpendOnApp=1 and DaySinceLastOrder>5;

-- 21 the average satisfaction score of customers who have complained

select round(avg(Satisfactionscore)) as complainedcustomedavg from customer_churn
where ComplaintReceived='yes';


-- 22 no of customers in each preferred order category?
select count(CustomerId) as custno , PreferredOrderCat from customer_churn
group by PreferredOrderCat;

-- 23 average cashback amount received by married customers
select round(avg(CashbackAmount)) as avgcashback from customer_churn
where MaritalStatus='married';

-- 24 the average number of devices registered by customers who are not using Mobile Phone as their preferred login device

select avg(NumberOfDeviceRegistered) as avgdevices from customer_churn
where PreferredLoginDevice <> 'Mobile phone';

-- 25 preferred order category among customers who used more than 5 coupons.
select CustomerID,PreferredOrderCat,CouponUsed from customer_churn
where CouponUsed >5;

-- 26 top 3 preferred order categories with the highest average cashback amount
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
select CustomerID,PreferredOrderCat,avg(CashbackAmount) as avg_cashback from customer_churn
group by PreferredOrderCat
order by avg_cashback desc limit 3;


-- 27 the preferred payment modes of customers whose average tenure is 10 months and have placed more than 500 orders.
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
select PreferredPaymentMode,avg(Tenure) as avgtenure ,sum(OrderCount) as total_no_of_orders from customer_churn
group by tenure
having total_no_of_orders>500 and avgtenure=10;

-- 28 Categorize customers based on their distance
select customerId,WarehouseToHome,
case
when WarehouseToHome<=5 then 'Very close distance'
when WarehouseToHome<=10 then 'Close distance'
when WarehouseToHome<=15 then 'Moderate distance'
else 'Far distance'
end as distance_category from customer_churn;

create table customer_returns
(
returnid int,
customerid int,
returndate date,
refundamount int
);

-- customer’s order details who are married, live in City Tier-1, and their order counts are more than the average number of orders placed by all customers.
-- select avg(ordercount) from customer_churn;
select customerid,maritalstatus,citytier,ordercount from customer_churn 
where maritalstatus='Married' and citytier=1 and ordercount > (select avg(ordercount) from customer_churn);


-- Create a ‘customer_returns’ table in the ‘ecomm’ database
insert into customer_returns values 
(1001,50022,'2023-01-01',2130),
(1002,50316,'2023-01-23',2000),
(1003,51099,'2023-02-14',2290),
(1004,52321,'2023-03-08',2510),
(1005,52928,'2023-03-20',3000),
(1006,53749,'2023-04-17',1740),
(1007,54206,'2023-04-21',3250),
(1008,54838,'2023-04-30',1990);

select * from customer_returns;


--  Display the return details along with the customer details of those who have churned and have made complaints.
select c.customerid,c.Tenure,c.PreferredLoginDevice,c.CityTier,c.WarehouseToHome,c.PreferredPaymentMode,c.Gender,c.HoursSpendOnApp, c.NumberOfDeviceRegistered, c.PreferredOrderCat, c.SatisfactionScore, c.MaritalStatus, c.NumberOfAddress, c.OrderAmountHikeFromlastYear, c.CouponUsed, c.OrderCount, c.DaySinceLastOrder, c.CashbackAmount, c.ComplaintReceived, c.churnstatus
from customer_churn as c
inner join customer_returns as r on c.customerid=r.customerid
where churnstatus='churned' and ComplaintReceived='yes';




















































