#!/usr/bin/env python
import csv
import geojson
from geojson import Feature


def write_file(route_num, linestring):
    path = 'dist/' + route_num + '.geojson'
    with open(path, 'w') as fp:
        line = geojson.loads(linestring)
        feature = Feature(geometry=line, properties={
            'stroke': 'blue',
            'stroke-width': 3,
            'stroke-opacity': 1,
        })
        fp.write(geojson.dumps(feature))


def main():
    with open('output.csv', 'r') as fp:
        reader = csv.reader(fp)
        # Skip header
        next(fp)
        for line in reader:
            route_num, linestring = line
            write_file(route_num, linestring)


if __name__ == '__main__':
    main()
