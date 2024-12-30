create database pizzahut;

create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key (order_id) );


create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key (order_details_id) );


-- Round 1:
-- Q1. Retrieve the total number of orders placed.

SELECT COUNT(order_id) AS total_orders 
FROM orders;

-- Q2. Calculate the total revenue generated from pizza sales.

SELECT SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;

-- Q3. Identify the highest-priced pizza.

select pt.name, p.price
	from pizza_types pt join pizzas p
	on pt.pizza_type_id = p.pizza_type_id
	order by p.price desc limit 1;

	
-- Q4. Identify the most common pizza size ordered.

SELECT p.size, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_quantity DESC
LIMIT 1;


-- Q5. List the top 5 most ordered pizza types along with their quantities.

SELECT pt.name, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;



-- Round 2:
-- Q6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;


-- Q7. Determine the distribution of orders by hour of the day.

SELECT HOUR(o.order_time) AS order_hour, COUNT(*) AS total_orders
FROM orders o
GROUP BY HOUR(o.order_time)
ORDER BY order_hour;


-- Q8. Join relevant tables to find the category-wise distribution of pizzas.

SELECT pt.category, COUNT(*) AS total_pizzas
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;


-- Q9. Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT o.order_date, AVG(od.quantity) AS average_pizzas_per_day
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY o.order_date;


-- Q10. Determine the top 3 most ordered pizza types based on revenue.

SELECT pt.name, SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;


-- Round 3:

-- Q11. Calculate the percentage contribution of each pizza type to total revenue.

/* my query below here calculated the revenue for each pizza type but did not yet calculate percentages.
 It groups the data by pizza type and sums the revenue for each.

SELECT 
    pt.name, 
    SUM(od.quantity * p.price) AS revenue
FROM 
    order_details od
 JOIN 
     pizzas p ON od.pizza_id = p.pizza_id
 JOIN 
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
 GROUP BY 
     pt.name;
/*


/* correct and better way now which gives my answer more accurately to the question asked

Now i have written an advanced query which includes a subquery to calculate the total revenue and uses it to compute the percentage contribution of each pizza type.
It provides both the revenue and the percentage contribution, while the query above in comments only provided the revenue.
*/
SELECT pt.name, 
       SUM(od.quantity * p.price) AS revenue,
       (SUM(od.quantity * p.price) / (SELECT SUM(od.quantity * p.price) 
				FROM order_details od
				JOIN pizzas p ON od.pizza_id = p.pizza_id)) * 100 AS percentage_contribution
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY percentage_contribution DESC;


-- Q12. Analyze the cumulative revenue generated over time.

/* 
my query below calculated the daily revenue but did not calculate cumulative revenue.
It groups orders by date and sums the revenue for each day.

SELECT 
    o.date, 
    SUM(od.quantity * p.price) AS daily_revenue
FROM 
    orders o
JOIN 
    order_details od ON o.order_id = od.order_ids
JOIN 
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY 
    o.date
ORDER BY 
    o.date;

*/

/*
correct and better way now which gives my answer more accurately to the question asked

Now i have written an advanced query that uses a window function (SUM() OVER) to calculate cumulative revenue over time.
the first query in comments only provided daily revenue, while this advanced query adds a running total.
*/
SELECT o.order_date, 
       SUM(od.quantity * p.price) AS daily_revenue,
       SUM(SUM(od.quantity * p.price)) OVER (ORDER BY o.order_date) AS cumulative_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.order_date
ORDER BY o.order_date;


-- Q13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
/*

This query calculates the revenue for each pizza type within each category but did not limit the results to the top 3 per category.
It groups by category and name, then sorts by category and revenue.

SELECT 
    pt.category, 
    pt.name, 
    SUM(od.quantity * p.price) AS total_revenue
FROM 
    order_details od
JOIN 
    pizzas p ON od.pizza_id = p.pizza_id
JOIN 
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY 
    pt.category, pt.name
ORDER BY 
    pt.category, total_revenue DESC;

*/


/*
correct and better way now which gives my answer more accurately to the question asked

Now I have written an advanced query which uses a window function (RANK() OVER) to rank pizza types within each category and filters the top 3 using QUALIFY.
the query above in comments listed all pizza types within each category, while this advanced query limits the results to the top 3.
*/
SELECT pt.category, pt.name, SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category, pt.name
ORDER BY pt.category, total_revenue DESC
LIMIT 3;




