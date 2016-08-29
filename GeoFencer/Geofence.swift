import Foundation
import MapKit

class Geofence {
    let points:[CLLocationCoordinate2D]
    let circle: MKCircle

    init (points:[CLLocationCoordinate2D]) {
        self.points = points

        // TODO: This assumes only 2 points
        circle = Geofence.circleFromPoints(points.first!, points.last!)
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
}
