# Quakes

This Swift project fetches real-time Earthquake data from the USGS site and performs several calculations on it

## Data source
Visit http://earthquake.usgs.gov/earthquakes/feed/. This site, run by the United States
Geological Survey, provides globally aggregated real-time data feeds for seismic events


## Implemented methods in QuakeFeed class
- **update**: replaces any existing stored Quake objects with new objects, derived from data that
is downloaded from the USGS site

- **meanDepth**: which returns the mean depth for all quakes in the feed
- **meanMagnitude**: which returns the mean magnitude for all quakes in the feed
- **sortedByDepth**: which returns a new QuakeFeed object where the quakes have been sorted into
ascending order of quake depth
- **sortedByMagnitude**: which returns a new QuakeFeed object where the quakes have been
sorted into descending order of quake magnitude
- **boundedBy**: which has tuple parameters representing a range of longitudes and a
range of latitudes, and which returns a new QuakeFeed object containing only those quakes that lie
within the specified bounds, as in this example: ```let feed2 = feed.boundedBy(lon:(0.0,20.0), lat:(-5.0,5.0))```
- **boundedBy**: which has a tuple parameter representing a range of depths, and
which returns a new QuakeFeed object containing only those quakes with depths in that range

## Usage
Run main.swift and provide an Earthquake level and period in the command prompt
