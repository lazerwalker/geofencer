import Foundation
import MapKit

class Geofence {
    let points:[CLLocationCoordinate2D]
    let title:String

    let circle: MKCircle

    init (points:[CLLocationCoordinate2D], title:String) {
        self.points = points
        self.title = title

        // TODO: This assumes only 2 points
        circle = Geofence.circleFromPoints(points.first!, points.last!)
        circle.title = title
    }

    class func circleFromPoints(first:CLLocationCoordinate2D, _ second:CLLocationCoordinate2D) -> MKCircle {
        let p1 = MKMapPointForCoordinate(first)
        let p2 = MKMapPointForCoordinate(second)

        let mapRect = MKMapRectMake(fmin(p1.x,p2.x),
                                    fmin(p1.y,p2.y),
                                    fabs(p1.x-p2.x),
                                    fabs(p1.y-p2.y))
        return MKCircle(mapRect:mapRect)
    }

    //-
    // TODO: All the lols.
    func toJSON() -> String {
        let pointString = points.map { (coordinate) -> String in
            return String("\"\(coordinate.latitude),\(coordinate.longitude)\"")
            }.joinWithSeparator(",")
        return "{\"title\":\"\(title)\", \"points\":[\(pointString)]}"
    }

    class func fromJSON(json:String) -> Geofence? {
        do {
            let data = json.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String: AnyObject]
            if let pointStrings = json["points"] as? [String],
                title = json["title"] as? String {
                let points = pointStrings.map({ (str) -> CLLocationCoordinate2D in
                    let latlng = str.componentsSeparatedByString(",")
                    let lat = (latlng[0] as NSString).doubleValue
                    let lng = (latlng[1] as NSString).doubleValue
                    return CLLocationCoordinate2D(latitude: lat, longitude: lng)
                })
                return Geofence(points: points, title: title)
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
            return nil
        }
        return nil
    }

    class func listAsJSON(geofences:[Geofence]) -> String {
        let list = geofences.map({$0.toJSON()})
        return "[\(list.joinWithSeparator(","))]"
    }
}
