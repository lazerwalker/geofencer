import CoreLocation
import MapKit
import UIKit

class ViewController: UIViewController, MKMapViewDelegate {
    let locationManager = CLLocationManager()

    var first:MKPointAnnotation?
    var second:MKPointAnnotation?
    var circle:MKCircle?

    let diskStore = DiskStore()

    var previousGeofences:[Geofence] = [] {
        didSet {
            for geofence in oldValue {
                mapView.removeOverlay(geofence.circle)
                mapView.removeAnnotation(geofence.circle)
            }

            for geofence in previousGeofences {
                mapView.addOverlay(geofence.circle)
                mapView.addAnnotation(geofence.circle)
            }

            diskStore.save(previousGeofences)
        }

    }

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBAction func didTapFirstButton(sender: AnyObject) {
        if let first = first {
            mapView.removeAnnotation(first)
        }

        first = MKPointAnnotation()
        if let first = first, location = mapView.userLocation.location {
            first.coordinate = location.coordinate
            mapView.addAnnotation(first)

            recalculateCircle()
            recalculateDoneButton()
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
            recalculateDoneButton()
        }
    }
    
    @IBAction func didTapDoneButton(sender: AnyObject) {
        if let first = first, second = second {
            // TODO: Do anything with this
            let geofence = Geofence(points:[first.coordinate, second.coordinate])
            previousGeofences.append(geofence)

            mapView.removeAnnotation(first)
            mapView.removeAnnotation(second)
            mapView.removeAnnotation(circle!)
            mapView.removeOverlay(circle!)

            self.first = nil
            self.second = nil
            self.circle = nil

            self.doneButton.enabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()

        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.FollowWithHeading, animated: true)

        previousGeofences = diskStore.load()
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

    func recalculateDoneButton() {
        doneButton.enabled = (first != nil && second != nil)
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

