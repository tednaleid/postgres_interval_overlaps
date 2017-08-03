with measurements_per_hour as (
  select count(*) as measurements, hours.hour as hour from (
    select hour from generate_series(
      (select min(event_start) from event_ranges),
      (select max(event_end) from event_ranges),
      '1 hour'::interval
    ) hour
  ) hours
  join event_ranges
    on (event_start, event_end) overlaps (hours.hour, hours.hour+'1 hour'::interval)
  group by hours.hour
  order by hours.hour
)
select 
measurements, 
hour, repeat('X', (measurements::float / max(measurements) over() * 50)::int) as histogram
from measurements_per_hour
;

