#!/usr/bin/env python
import csv
import json
from collections import defaultdict


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
