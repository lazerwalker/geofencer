import Foundation
import MapKit

// This class isn't actually used, and probably only sort of functions. 
// When transitioning from using circular regions to polygonal regions,
// the hope was a refactor would allow both circles and arbitrary polygons.
// tl;dr: YAGNI
class CircularRegion : Region {
    let points:[CLLocationCoordinate2D]
    let title:String

    let circle:MKCircle
    let annotations:[MKAnnotation]
    let overlays:[MKOverlay]

    init (points:[CLLocationCoordinate2D], title:String) {
        self.points = points
        self.title = title

        // This should probably actually take in either a tuple of 
        // (CLLocationCoordinate2D, CLLocationCoordinate2D), or two separate args,
        // instead of the nasty force unwrap assuming points has at least two objects.
        // Again, though, this class isn't actually used.
        circle = CircularRegion.circleFromPoints(points.first!, points.last!)
        circle.title = title
        
        self.annotations = [circle]
        self.overlays = [circle]
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
    // Serializable

    // TODO: All the lols.
    func toJSON() -> String {
        func coordToString(coordinate:CLLocationCoordinate2D) -> String {
            return String("\"\(coordinate.latitude),\(coordinate.longitude)\"")
        }

        let pointString = points.map({ coordToString($0) }).joinWithSeparator(",")
        let centerCoordinate = coordToString(circle.coordinate)

        return "{\"title\":\"\(title)\", \"points\":[\(pointString)], \"center\":\(centerCoordinate), \"radius\":\(circle.radius)}"
    }

    class func fromJSON(json:String) -> Region? {
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
                return CircularRegion(points: points, title: title)
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
            return nil
        }
        return nil
    }
}
