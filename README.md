# septa-stops

Generate SEPTA route traces based on GTFS data. Route traces are
available as GeoJSON in the [`dist`](https://github.com/kdeloach/septa-stops/tree/master/dist) folder.
Each GeoJSON extract contains a FeatureCollection with two LineStrings,
one for each route direction.

## Overview

The goal of this project is to produce a GeoJSON route trace for each SEPTA
bus route. By combining bus stops and route traces into a single file, we
are able to conserve bandwidth, which is important for mobile applications.
Because bus schedules may change during different times of the day,
creating a static route trace can challenging.

### KML

KML route traces are available from the [SEPTA API](http://www3.septa.org/hackathon).
These can be converted to GeoJSON by using [GDAL](http://www.gdal.org/).
Although accurate, the filesizes are somewhat large. There is also a
considerable amount of overlap between route traces and bus stops
(list of points). Most applications will probably want to show
both. If we can generate route traces from a much smaller dataset (bus
stops), then we can reduce bandwidth usage by half.

### JSON

Bus stops are available from the SEPTA API as JSON. Unfortunately, these
are unsorted (by design), so there's no way to generate route traces from
this data.

### GTFS

GTFS data from the SEPTA API contains the most complete
information available, and can be used to generate accurate route traces.
However, bus schedules may change during the day, so we need to figure
out a strategy to generate the most reasonable static representation.

Here are the three different strategies that I tried along with a baseline
reference image:

### Baseline

This snapshot is from [SEPTA TransitView](http://www.septa.org/realtime/status/system-status.shtml)
for Bus 104, which I will use as a baseline reference to compare each strategy.

![](https://github.com/kdeloach/septa-stops/raw/readme/images/kml-reference.png)

### Use the "longest trip"

First, I tried to use the longest trip. I assumed that the trip with the
most bus stops would contain *all* bus stops, but that turned out not to be
the case. The longest trip for Bus 104 doesn't include some peak hour only
stops(?).

![](https://github.com/kdeloach/septa-stops/raw/readme/images/longest-trip.png)

### Union all trips together

Next, I tried to create a route trace by generating a line for each possible
trip, then combining the result into a single line per bus route.
The result is more "complete" compared to the previous solution, but I
find the results difficult to interpret.

![](https://github.com/kdeloach/septa-stops/raw/readme/images/union-trips.png)

### Use distinct stops

Finally, I created a route trace by selecting distinct bus stops
from all route trips. I was worried that combining stops from other trips
would be confusing, but the results are reasonable. The final route trace
is a single contiguous line which is easy to understand. In my opinion,
this is the best strategy out of all three in terms of simplicity and
filesize, and this is the strategy I used to generate route traces on
the `master` branch.

![](https://github.com/kdeloach/septa-stops/raw/readme/images/distinct-stops.png)

## Getting Started

Run `make`.

## License

MIT
