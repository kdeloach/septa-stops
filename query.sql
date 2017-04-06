with

-- Return the number of stops for each route trip.
-- Ex.
-- 45 | 0 | 1234 | 100
-- 45 | 0 | 1235 |  99
-- 45 | 1 | 1236 | 100
-- 45 | 1 | 1237 |  98
num_stops_per_trip as (
    select
        t.route_id,
        t.direction_id,
        t.trip_id,
        count(*) as num_stops
    from trips t
    inner join stop_times st on st.trip_id = t.trip_id
    group by t.trip_id, t.direction_id
),

-- Return "best" trip for each route, which is the trip with the most stops.
-- Ex.
-- 45 | 0 | 1234
-- 45 | 1 | 1235
best_trip_per_route as (
    select
        route_id,
        direction_id,
        trip_id
    from num_stops_per_trip
    group by route_id, direction_id
    having max(num_stops)
),

-- Return all stops from the "best" trip for each route ordered
-- by direction and stop sequence.
-- Ex.
-- 45 | 0 | 1 | <Point>
-- 45 | 0 | 2 | <Point>
-- 45 | 1 | 1 | <Point>
-- 45 | 1 | 2 | <Point>
stops_per_trip as (
    select
        t.route_id,
        t.direction_id,
        st.stop_sequence,
        MakePoint(s.stop_lon, s.stop_lat) point
    from stop_times st
    inner join stops s on s.stop_id = st.stop_id
    inner join best_trip_per_route t on t.trip_id = st.trip_id
    order by
        t.route_id,
        t.direction_id,
        st.stop_sequence
)

-- Return Polyline for each route.
-- Ex.
-- 45 | <Polyline>
select
    r.route_short_name,
    AsGeoJSON(MakeLine(tmp.point)) line
from stops_per_trip tmp
inner join routes r on r.route_id = tmp.route_id
group by r.route_short_name;
