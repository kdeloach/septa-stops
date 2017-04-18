#!/usr/bin/env python
import csv
import geojson
from geojson import Feature, FeatureCollection


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
        geojson.dump(fcoll, fp, separators=(',', ':'))


def main():
    with open('output.csv', 'r') as fp:
        reader = csv.reader(fp)

        # Skip header
        next(fp)

        for line in reader:
            route_num, line0, line1 = line
            write_file(route_num, line0, line1)


if __name__ == '__main__':
    main()
