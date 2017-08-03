select hours.hour, event_ranges.* from (
  select hour from generate_series(
    (select min(event_start) from event_ranges),
    (select max(event_end) from event_ranges),
    '1 hour'::interval
  ) hour
) hours
join event_ranges
  on (event_start, event_end) overlaps (hours.hour, hours.hour+'1 hour'::interval)
;
