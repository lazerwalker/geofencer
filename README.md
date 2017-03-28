# GeoFencer

This is a simple iOS app designed for people creating location-based content.

It lets you manually define geofences by tagging physical points in the real world that you're currently standing at, using your phone's GPS. It then lets you export that data, in JSON, in a format that can be easily turned into iOS CoreLocation geofence regions.

<img src="https://raw.github.com/lazerwalker/geofencer/master/screenshot.jpg" data-canonical-src="https://raw.github.com/lazerwalker/geofencer/master/screenshot.jpg" height="400" />

(This screenshot is slightly out-of-date. This is from the old `circle` branch, which generates regions that are circular, rather than polygonal.)

## Setup

This assumes a functioning iOS development environment. It has not yet been tested on iOS 10.

1. Clone this repo

2. Open `GeoFencer.xcworkspace`

3. Run on-device


## Usage

Currently, this lets you generate regions of arbitrary polygons by geotagging each vertex in the polygon. If you'd rather generate circular regions, the `circle` branch will let you create a circle by tagging two points along the edge of the circle. That code is slightly out-of-date and may not function as well.

Tapping the "add point" button in the app will tag your current location. If other points exist, the latest point will be connected by a straight line to the previous point. You can tap an existing vertex to delete it, and the corresponding edges will update. Once you're satisfied with a region, tapping the 'done' button will prompt you to set a name for the region. The first and last points you tagged will be connected as well.

You can tap any existing center pin to edit that region.

The share icon lets you export your data as JSON. It uses a standard iOS share sheet.

Data persists across app launches. The `Reset` button erases all data (it will confirm you want to do this, in case you mis-tap).

## Export

The exported JSON currently looks like the following:

```json
[
  {
    "points": [
      "37.8053159175211,-122.431976418021",
      "37.8053038168884,-122.431748222821",
      "37.8054518462878,-122.431365492526",
      "37.8058360113568,-122.431400638617",
      "37.8063346277532,-122.430483738629",
      "37.8064451004557,-122.430249010784",
      "37.8066738708886,-122.430057514652",
      "37.8070129522718,-122.429962294254",
      "37.8074057819674,-122.429847736026",
      "37.8076199874648,-122.42978801471",
      "37.8073967424848,-122.430262948936",
      "37.8073015327024,-122.431152691057",
      "37.8071338474233,-122.432052737086",
      "37.8070644938624,-122.43213397622",
      "37.8069573129585,-122.432158430515"
    ],
    "title": "fort"
  }
]
```

* `points`: The two lat/long coordinates that correspond to your "first corner" and "second corner" locations
* `title`: The string you entered when creating the region

## Future Plans

This code is basically provided as-is. Maybe it'll be useful to you. Contributions are gladly accepted, although not particularly expected.

## Caveat Emptor

This was a pretty quick project slapped together for the purposes of another art project (a [generative poetry walk](http://lzrwlkr.me/compflaneur) built for Fort Mason as part of the 2016 [Come out and Play](https://comeoutandplay.org) festival). As an app, this may suit your purposes. As a codebase, don't necessarily take anything I'm doing here as an endorsement of best practices.

## Contact Info

[@lazerwalker](https://twitter.com/lazerwalker)

For technical concerns and questions, please use GitHub Issues.

## License

This project is licensed under the MIT License. See the LICENSE file in this repo for more info.
