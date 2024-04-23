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