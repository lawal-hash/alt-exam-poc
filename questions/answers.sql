-- Question 2a.1
/* 
what is the most ordered item based on the number of times it appears in an order cart that checked out successfully?

To get the most ordered item, created 2 CTEs, most_ordered_items and most_ordered_items_rank.
1. most_ordered_items: in this CTE, only product that are successfully checked out are selected. It is also worth nothing that the sum of 'quantity' of each product is used to determine 
 					the number of times it appears in an order cart that checked out successfully.
2. most_ordered_items_rank: in this CTE, the rank() function is used to rank the products based on the number of times they appear in an order cart that checked out successfully.
   					The rank is done in descending order, finally, filter from this CTE where the row_rank is equal to 1.	

Note: Do not use order by and limit in the final query, as it will not work in the case of ties.
				
 */

with most_ordered_items as(
    select id as product_id,
        name as product_name,
        sum(quantity) as num_times_in_successful_orders
    from alt_school.orders o
        join alt_school.line_items li using(order_id)
        join alt_school.products p on li.item_id = p.id
    where status = 'success'
    group by id,
        name,
        status
),
most_ordered_items_rank as (
    select *,
        rank() over(
            order by num_times_in_successful_orders desc
        ) row_rank
    from most_ordered_items
)
select product_id,
    product_name,
    num_times_in_successful_orders
from most_ordered_items_rank
where row_rank = 1


-- Question 2a.2

with order_quantity as (
    select customer_id,
        e.event_data->>'event_type' as event_type,
        e.event_data->>'item_id' as item_id,
        e.event_data->>'quantity' as quantity
    from alt_school.events e
    where customer_id in (
            select distinct customer_id
            from alt_school.events e
            where e.event_data->>'status' = 'success'
        )
        and e.event_data->>'event_type' not in ('checkout', 'visit')
),
spender as (
    select customer_id,
        sum(quantity::int * price) as total_spend
    from order_quantity o
        join alt_school.products p on o.item_id::int = p.id
    where quantity is not null
    group by customer_id
),
spender_rank as (
    select customer_id,
        location,
        total_spend,
        rank() over(
            order by total_spend desc
        ) ROW_RANK
    from spender
        join alt_school.customers using (customer_id)
)
select customer_id,
    location,
    total_spend
from spender_rank
where row_rank <= 5


-- Question 2b.1 
/* 
Determine the most common location (country) where successful checkouts occurred
To get the most common location where successful checkouts occurred, created 2 CTEs, location_count and location_count_rank.
1. location_count: in this CTE, only successful checkouts are selected. The count of successful checkouts is grouped by location.
2. location_count_rank: in this CTE, the rank() function is used to rank the locations based on the number of successful checkouts.
   					The rank is done in descending order, finally, filter from this CTE where the row_rank is equal to 1.
*/ 

with location_count as (
    select location,
        count(1) as checkout_count
    from alt_school.events e
        join alt_school.customers using(customer_id)
    where e.event_data->>'event_type' = 'checkout'
        and e.event_data->>'status' = 'success'
    group by location
),
location_count_rank as (
    select location,
        checkout_count,
        rank() over(
            order by checkout_count desc
        ) row_rank
    from location_count
)
select location,
    checkout_count
from location_count_rank
where row_rank = 1



-- Question 2b.2
with event_group as (
    select customer_id,
        e.event_data->>'event_type' as event_type,
        e.event_data->>'status' as status,
        count(1) as event_count
    from alt_school.events e
    group by customer_id,
        e.event_data->>'event_type',
        e.event_data->>'status'
)
select customer_id,
    sum(event_count) as num_events
from event_group
    join alt_school.customers c using(customer_id)
where customer_id not in (
        select distinct customer_id
        from event_group
        where event_type = 'checkout'
            and status = 'success'
    )
    and event_type != 'visit'
group by customer_id



-- question 2b.3
with event_group as (
    select customer_id,
        count(distinct e.event_data->>'timestamp') as event_count
    from alt_school.events e
    where customer_id in (
            select distinct customer_id
            from alt_school.events e
            where e.event_data->>'status' = 'success'
        )
        and e.event_data->>'event_type' = 'visit'
    group by customer_id
)
select avg(event_count)::numeric(5, 2) as average_visits
from event_group;