with

-- Return distinct stop times. Most trips contain the same stops so this
-- filters out a lot of noise. The stop sequence order is not guaranteed
-- to be contiguous.
-- Ex.
-- 45 | 0 | 1234 | 1
-- 45 | 0 | 1235 | 2
-- 45 | 0 | 1236 | 2
-- 45 | 0 | 1237 | 3
distinct_stop_times as (
    select distinct * from (
        select
            t.route_id,
            t.direction_id,
            st.stop_id,
            st.stop_sequence
        from stop_times st
        inner join trips t on t.trip_id = st.trip_id
    )
),

-- Return distinct stops from all route trips ordered
-- by direction and stop sequence.
-- Ex.
-- 45 | 0 | 1 | <Point>
-- 45 | 0 | 2 | <Point>
-- 45 | 1 | 1 | <Point>
-- 45 | 1 | 2 | <Point>
stops_per_trip as (
    select
        dst.route_id,
        dst.direction_id,
        dst.stop_sequence,
        MakePoint(s.stop_lon, s.stop_lat) point
    from distinct_stop_times dst
    inner join stops s on s.stop_id = dst.stop_id
    order by
        dst.route_id,
        dst.direction_id,
        dst.stop_sequence
),

-- Return Polyline for each route.
-- Ex.
-- 45 | <Polyline>
lines_per_trip as (
    select
        route_id,
        MakeLine(point) line
    from stops_per_trip
    group by route_id
)

-- Return route trace as GeoJSON.
-- Ex.
-- 45 | <Polyline>
select
    r.route_short_name,
    AsGeoJSON(n.line) line
from lines_per_trip n
inner join routes r on r.route_id = n.route_id
order by r.route_short_name;
