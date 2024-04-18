-- Question 2a.1 

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