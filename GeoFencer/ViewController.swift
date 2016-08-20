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
    
    @IBAction func didTapDoneButton(sender: AnyObject) {
        print("Tapped done!")
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

            circle = Geofence.circleFromPoints(first.coordinate, second.coordinate)

            if let circle = circle {
                circle.title = "My Geofence"
                mapView.addOverlay(circle)
                mapView.addAnnotation(circle)
            }
        }
    }

    //-
    // MKMapViewDelegate

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKPointAnnotation.self) || annotation.isKindOfClass(MKCircle.self) {
            let identifier = NSStringFromClass(MKPinAnnotationView.self)
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
            if (pinView == nil) {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }

            if annotation.isKindOfClass(MKCircle.self) {
                pinView?.pinTintColor = MKPinAnnotationView.greenPinColor()
            } else {
                pinView?.pinTintColor = MKPinAnnotationView.redPinColor()
            }
            
            return pinView
        }
        return nil
    }

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

