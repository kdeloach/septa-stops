with

-- Return stops from all trips ordered by stop sequence.
-- Ex.
-- 45 | Trip 1 | 0 | 1 | <Point>
-- 45 | Trip 2 | 0 | 2 | <Point>
-- 45 | Trip 3 | 1 | 1 | <Point>
-- 45 | Trip 4 | 1 | 2 | <Point>
stops_per_trip as (
    select
        t.route_id,
        t.trip_id,
        t.direction_id,
        st.stop_sequence,
        MakePoint(s.stop_lon, s.stop_lat) point
    from stop_times st
    inner join trips t on t.trip_id = st.trip_id
    inner join stops s on s.stop_id = st.stop_id
    order by
        t.route_id,
        t.trip_id,
        st.stop_sequence
),

-- Return Polyline for each trip.
-- Ex.
-- 45 | Trip 1 | 0 | <Polyline>
-- 45 | Trip 2 | 1 | <Polyline>
lines_per_trip as (
    select
        route_id,
        trip_id,
        direction_id,
        MakeLine(point) line
    from stops_per_trip
    group by trip_id
),

-- Return all route trip lines unioned together as one shape.
-- Ex.
-- 45 | 0 | <Geometry>
-- 45 | 1 | <Geometry>
lines_per_route as (
    select
        route_id,
        direction_id,
        GUnion(line) line
    from lines_per_trip
    group by route_id, direction_id
)

-- Return route trace as GeoJSON for both directions.
-- Ex.
-- 45 | <Polyline> | <Polyline>
select
    r.route_short_name,
    AsGeoJSON(n.line) line0,
    AsGeoJSON(s.line) line1
from lines_per_route n
-- Join against the opposite direction line
inner join lines_per_route s
    on s.route_id = n.route_id
    and s.direction_id != n.direction_id
inner join routes r on r.route_id = n.route_id
where n.direction_id = 0
order by r.route_short_name;
