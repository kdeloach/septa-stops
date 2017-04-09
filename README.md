# septa-stops

Generate SEPTA route traces based on GTFS data. Route traces are
available as GeoJSON in the [`dist`](https://github.com/kdeloach/septa-stops/tree/master/dist) folder.
Each GeoJSON extract contains a FeatureCollection with two LineStrings,
one for each route direction.

## Description

The goal of this project is to produce a GeoJSON route trace for each SEPTA
bus route. By combining bus stops and route traces into a single file, we
are able to conserve bandwidth, which is important for mobile applications.
Due to the nature of bus schedules, which may change during different times
of the day, creating a static route trace can be a challenge.

### SEPTA API KML

Accurate route traces are available from the [SEPTA API](http://www3.septa.org/hackathon).
These route traces are KML files, which can be converted
to GeoJSON by using [GDAL](http://www.gdal.org/). These should be used when
accuracy is important and bandwidth is not a concern. However, considering
that route traces may be derived from bus stops, but not the other
way around, it makes sense to prefer to use bus stops only, instead of
downloading two overlapping data sets.

### SEPTA API JSON

Ideally, we would be able to download bus stops for each route from the
SEPTA API directly. Although a JSON endpoint for bus stops exists, the data is
unsorted. The route trace generated from this data looks completely random:

![](https://github.com/kdeloach/septa-stops/raw/readme/images/unsorted.png)

### GTFS

The GTFS data extracts from the SEPTA API contain the most complete
information available. Using this data, we can generate accurate route traces.
However, bus schedules may change during the day, so we need to figure
out a strategy to generate the most reasonable static representation.

Here are the three different strategies that I tried along with a baseline
reference image:

### Baseline

This snapshot is from SEPTA TransitView for Bus 104, which
I will use as a baseline reference.

![](https://github.com/kdeloach/septa-stops/raw/readme/images/kml-reference.png)

### Use the "longest trip"

First, I tried to use the longest trip. I assumed that the trip with the
most bus stops would contain *all* bus stops, but that's not true. The
longest trip for Bus 104 does not include stops that are
visited during peak hours.

![](https://github.com/kdeloach/septa-stops/raw/readme/images/longest-trip.png)

### Union all trips together

This strategy creates a route trace by generating a line for each possible
trip, then combining the result into a single line per bus route.
The paths generated are more "complete" compared to the
previous solution, but the results may be difficult to interpret.

![](https://github.com/kdeloach/septa-stops/raw/readme/images/union-trips.png)

### Use distinct stops

Finally, I created a route trace by selecting distinct bus stops
from all route trips. I was worried that combining stops from other trips
would be confusing, but the results are reasonable. The final route trace
is a single contiguous line which is easy to understand. In my opinion,
this is the best strategy out of all three in terms of simplicity and
filesize.

![](https://github.com/kdeloach/septa-stops/raw/readme/images/distinct-stops.png)

## Getting Started

Install `docker` then run `make`.

## License

MIT
