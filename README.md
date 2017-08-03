# demo postgres overlaps function with interval

usage with [docker-compose](https://docs.docker.com/docker-for-mac/install/):

```
docker-compose up -d
```

initialize the database:

```
docker exec -u postgres -it POSTGRES_1 /bin/bash -c "psql -d postgres -f /sql/init.sql"
```

runs [`init.sql`](/sql/init.sql) and creates a table like this:

```
CREATE TABLE event_ranges (
    id SERIAL PRIMARY KEY,
    event_start   timestamp NOT NULL,
    event_end     timestamp NOT NULL
);
```

and inserts 2000 rows into the table.  If more rows are desired, they could be generated with the [bin/random_date_ranges.sh](/bin/random_date_ranges.sh) script.

run the [interval overlaps query](/sql/grouped.sql):

```
select count(*), hours.hour from (
  select hour from generate_series(
    (select min(event_start) from event_ranges),
    (select max(event_end) from event_ranges),
    '1 hour'::interval
  ) hour
) hours
join event_ranges
  on (event_start, event_end) overlaps (hours.hour, hours.hour+'1 hour'::interval)
group by hours.hour
;
```

```
docker exec -u postgres -it POSTGRES_1 /bin/bash -c "psql -d testdb -f /sql/grouped.sql"
 count |        hour
-------+---------------------
  1226 | 2017-08-03 05:06:10
   865 | 2017-08-03 01:06:10
  1049 | 2017-08-03 06:06:10
   977 | 2017-08-03 02:06:10
   656 | 2017-08-03 08:06:10
   140 | 2017-08-03 12:06:10
  1161 | 2017-08-03 04:06:10
   351 | 2017-08-03 10:06:10
   232 | 2017-08-03 11:06:10
  1084 | 2017-08-03 03:06:10
   190 | 2017-08-02 21:06:10
   499 | 2017-08-03 09:06:10
    12 | 2017-08-03 14:06:10
   414 | 2017-08-02 22:06:10
   742 | 2017-08-03 00:06:10
   601 | 2017-08-02 23:06:10
   839 | 2017-08-03 07:06:10
    62 | 2017-08-03 13:06:10
(18 rows)
```

to see how many things happened in each hour in the database table.


Show discrete items that fall into each range:

```
docker exec -u postgres -it POSTGRES_1 /bin/bash -c "psql -d testdb -f /sql/select.sql"
        hour         |  id  |     event_start     |      event_end
---------------------+------+---------------------+---------------------
 2017-08-02 21:06:10 |    7 | 2017-08-02 21:44:52 | 2017-08-03 01:18:32
 2017-08-02 21:06:10 |   33 | 2017-08-02 21:17:29 | 2017-08-02 22:49:44
 2017-08-02 21:06:10 |   39 | 2017-08-02 21:21:38 | 2017-08-02 21:55:47
 2017-08-02 21:06:10 |   41 | 2017-08-02 21:36:33 | 2017-08-03 05:10:45
 2017-08-02 21:06:10 |   42 | 2017-08-02 21:07:51 | 2017-08-02 23:02:07
 2017-08-02 21:06:10 |   45 | 2017-08-02 21:32:21 | 2017-08-02 22:07:31
 2017-08-02 21:06:10 |   47 | 2017-08-02 22:01:52 | 2017-08-03 04:18:48
 2017-08-02 21:06:10 |   51 | 2017-08-02 22:03:53 | 2017-08-03 07:00:59
 2017-08-02 21:06:10 |   85 | 2017-08-02 21:55:17 | 2017-08-03 00:41:37
 2017-08-02 21:06:10 |   94 | 2017-08-02 21:48:54 | 2017-08-03 05:23:14
 2017-08-02 21:06:10 |   98 | 2017-08-02 21:38:29 | 2017-08-03 03:08:07
 2017-08-02 21:06:10 |  102 | 2017-08-02 21:59:58 | 2017-08-03 07:03:55
 2017-08-02 21:06:10 |  104 | 2017-08-02 21:16:26 | 2017-08-03 05:34:55
 ...
```
