-- Question 2a.1

with most_ordered_items as(
select
	id as product_id,
	name as product_name,
	sum(quantity)as num_times_in_successful_orders
from
	alt_school.orders o
join alt_school.line_items li
		using(order_id)
join alt_school.products p
on
	li.item_id = p.id
where
	status = 'success'
group by
	id,
	name,
	status),
most_ordered_items_rank as (
select
	*,
	rank() over(
order by
	num_times_in_successful_orders desc) row_rank
from
	most_ordered_items)

select
	product_id,
	product_name,
	num_times_in_successful_orders
from
	most_ordered_items_rank
where
	row_rank = 1
























-- Question 2b.1 

with location_count as (
select
	location,
	count(1) as checkout_count
from
	alt_school.events e
join alt_school.customers 
		using(customer_id)
where
	e.event_data ->> 'event_type' = 'checkout'
	and e.event_data ->> 'status' = 'success'
group by
	location),
location_count_rank as (
select
	location,
	checkout_count,
	rank() over(
	order by checkout_count desc) row_rank
from
	location_count)

select
	location,
	checkout_count
from
	location_count_rank
where
	row_rank = 1



-- Question 2b.2
with event_group as (
select
	customer_id,
	e.event_data ->> 'event_type' as event_type,
	e.event_data ->> 'status' as status,
	count(1)as event_count
from
	alt_school.events e
group by
	customer_id,
	e.event_data ->> 'event_type',
	e.event_data ->> 'status'
)
select
	customer_id,
	sum(event_count)as num_events
from
	event_group
join alt_school.customers c
		using(customer_id)
where
	customer_id not in (
	select
		distinct customer_id
	from
		event_group
	where
		event_type = 'checkout'
		and status = 'success')
	and event_type != 'visit'
group by
	customer_id



-- question 2b.3
with event_group as (
select
	customer_id,
	count( distinct e.event_data ->> 'timestamp')as event_count
from
	alt_school.events e
where
	customer_id in (
	select
		distinct customer_id
	from
		alt_school.events e
	where
		e.event_data ->> 'status' = 'success')
	and e.event_data ->> 'event_type' = 'visit'
group by
	customer_id
)

select
	avg(event_count):: numeric(5,
	2) as average_visits
from
	event_group;