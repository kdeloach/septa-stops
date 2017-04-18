with

all_stops as (
    select
        t.route_id,
        st.stop_id
    from trips t
    inner join stop_times st on st.trip_id = t.trip_id
),

distinct_stops as (
    select distinct * from all_stops
)

select
    r.route_short_name route_num,
    s.stop_lat lat,
    s.stop_lon lng
from distinct_stops ds
inner join routes r on r.route_id = ds.route_id
inner join stops s on s.stop_id = ds.stop_id
order by
    r.route_id,
    s.stop_id;
