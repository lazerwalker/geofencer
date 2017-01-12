# GeoFencer

This is a simple iOS app designed for people creating location-based content.

It lets you manually define geofences by tagging physical points in the real world that you're currently standing at, using your phone's GPS. It then lets you export that data, in JSON, in a format that can be easily turned into iOS CoreLocation geofence regions.

<img src="https://raw.github.com/lazerwalker/geofencer/master/screenshot.jpg" data-canonical-src="https://raw.github.com/lazerwalker/geofencer/master/screenshot.jpg" height="400" />

## Setup

This assumes a functioning iOS development environment. It has not yet been tested on iOS 10.

1. Clone this repo

2. Open `GeoFencer.xcworkspace`

3. Run on-device


## Usage

Currently, this lets you generate circular regions (center point + radius) by geotagging two points along the edge of the circle. If you care about being able to generate arbitrary polygons, rather than circles, check out the `region` branch. It currently functions.

Tapping either the "first corner" or "second corner" button in the app will tag your current location. If either the first or second corner is already set, your current position will overwrite the existing one. If you've set both positions, you will be able to see the region circle; once you're happy with that, tapping the 'done' button will prompt you to set a name for the region.

You can tap any existing center pin to edit that region.

The share icon lets you export your data as JSON. It uses a standard iOS share sheet.

Data persists across app launches. The `Reset` button erases all data (it will confirm you want to do this, in case you mis-tap).

## Export

The exported JSON currently looks like the following:

```json
[
  {
    "title": "fort",
    "points": [
      "37.8053518804142,-122.431926364193",
      "37.807515422961,-122.429801148074"
    ],
    "center": "37.8064336596108,-122.430863756134",
    "radius": 120.1796090214
  }
]
```

* `points`: The two lat/long coordinates that correspond to your "first corner" and "second corner" locations
* `center`: The calculated center of the circle
* `radius`: The calculated radius of the circle, in meters
* `title`: The string you entered when creating the region

## Future Plans

This code is basically provided as-is. Maybe it'll be useful to you. Contributions are gladly accepted, although not particularly expected.


## Contact Info

[@lazerwalker](https://twitter.com/lazerwalker)

For technical concerns and questions, please use GitHub Issues.

## License

This project is licensed under the MIT License. See the LICENSE file in this repo for more info.
