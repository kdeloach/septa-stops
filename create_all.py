#!/usr/bin/env python
import sys
import csv
import json
from collections import defaultdict


def write_file(route_num, line0, line1):
    path = 'dist/' + route_num + '.geojson'
    with open(path, 'w') as fp:
        f1 = Feature(geometry=geojson.loads(line0), properties={
            'stroke': 'blue',
            'stroke-width': 3,
            'stroke-opacity': 1,
        })
        f2 = Feature(geometry=geojson.loads(line1), properties={
            'stroke': 'red',
            'stroke-width': 3,
            'stroke-opacity': 1,
        })
        fcoll = FeatureCollection([f1, f2])
        fp.write(geojson.dumps(fcoll))


def main():
    stops = defaultdict(list)

    with open('all.csv', 'r') as fp:
        reader = csv.reader(fp)

        # Skip header
        next(fp)

        for line in reader:
            route_num, lat, lng = line
            stops[route_num].append((
                float(lat),
                float(lng),
            ))

    with open('dist/all.json', 'w') as fp:
        json.dump(stops, fp, separators=(',', ':'))


if __name__ == '__main__':
    main()
