import Foundation
import MapKit

struct PolygonRegion : Region {
    let points:[CLLocationCoordinate2D]
    let title:String

    init(points:[MKPointAnnotation], title:String) {
        let coordinates = points.map({ return $0.coordinate })

        self.points = coordinates
        self.title = title

        let polygon = PolygonRegion.polygonFromPoints(points)

        self.overlays = [polygon]

        // TODO: Add all points
        self.annotations = [polygon]
    }

    // Map presentation
    let annotations:[MKAnnotation]
    let overlays:[MKOverlay]

    //-

    static func polygonFromPoints(points:[MKPointAnnotation]) -> MKPolygon {
        // TODO: How to convert?
        let coords = points.map({ return $0.coordinate })
        let pointer:UnsafeMutablePointer<CLLocationCoordinate2D> = UnsafeMutablePointer(coords)
        return MKPolygon(coordinates: pointer, count: points.count)
    }


    // Serialization
    func toJSON() -> String {
        let pointString = points.map { (coordinate) -> String in
            return String("\"\(coordinate.latitude),\(coordinate.longitude)\"")
            }.joinWithSeparator(",")
        return "{\"title\":\"\(title)\", \"points\":[\(pointString)]}"
    }

    static func fromJSON(json:String) -> Region? {
        do {
            let data = json.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String: AnyObject]
            if let pointStrings = json["points"] as? [String],
                title = json["title"] as? String {
                let points = pointStrings.map({ (str) -> MKPointAnnotation in
                    let latlng = str.componentsSeparatedByString(",")
                    let lat = (latlng[0] as NSString).doubleValue
                    let lng = (latlng[1] as NSString).doubleValue
                    let coord = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    let point = MKPointAnnotation()
                    point.coordinate = coord
                    return point
                })
                return PolygonRegion(points: points, title: title)
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
            return nil
        }
        return nil
    }
}