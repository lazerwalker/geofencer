import CoreLocation
import MapKit
import UIKit

class ViewController: UIViewController, MKMapViewDelegate {
    let locationManager = CLLocationManager()

    var first:MKPointAnnotation?
    var second:MKPointAnnotation?
    var circle:MKCircle?

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    
    @IBAction func didTapFirstButton(sender: AnyObject) {
        if let first = first {
            mapView.removeAnnotation(first)
        }

        first = MKPointAnnotation()
        if let first = first, location = mapView.userLocation.location {
            first.coordinate = location.coordinate
            mapView.addAnnotation(first)

            recalculateCircle()
        }
    }

    @IBAction func didTapSecondButton(sender: AnyObject) {
        if let second = second {
            mapView.removeAnnotation(second)
        }

        second = MKPointAnnotation()
        if let second = second, location = mapView.userLocation.location {
            second.coordinate = location.coordinate
            mapView.addAnnotation(second)

            recalculateCircle()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()

        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.FollowWithHeading, animated: true)
    }

    // -
    func recalculateCircle() {
        if let first = first, second = second {
            if let circle = circle {
                mapView.removeOverlay(circle)
                mapView.removeAnnotation(circle)
            }

            let p1 = MKMapPointForCoordinate(first.coordinate)
            let p2 = MKMapPointForCoordinate(second.coordinate)

            let mapRect = MKMapRectMake(fmin(p1.x,p2.x),
                                        fmin(p1.y,p2.y),
                                        fabs(p1.x-p2.x),
                                        fabs(p1.y-p2.y))
            circle = MKCircle(mapRect: mapRect)

            if let circle = circle {
                mapView.addOverlay(circle)
                mapView.addAnnotation(circle)
            }
        }
    }

    //-
    // MKMapViewDelegate
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKindOfClass(MKCircle.self) {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor.cyanColor().colorWithAlphaComponent(0.2)
            renderer.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.7)
            renderer.lineWidth = 0.5;

            return renderer
        }

        // This case should never be reached, and fail silently.
        // But this function doesn't have a return type of Optional.
        // Obj-C interop is hard!
        return MKCircleRenderer()
    }
}

