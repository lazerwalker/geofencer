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
            let alert = UIAlertController(title: "Name This Region", message: nil, preferredStyle: .Alert)
            alert.addTextFieldWithConfigurationHandler({ (field) in

            })
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
                self.dismissViewControllerAnimated(true, completion: nil)

                if let title = alert.textFields?.first?.text {
                    let geofence = Geofence(points:[first.coordinate, second.coordinate], title: title)
                    self.previousGeofences.append(geofence)

                    self.mapView.removeAnnotation(first)
                    self.mapView.removeAnnotation(second)
                    self.mapView.removeAnnotation(self.circle!)
                    self.mapView.removeOverlay(self.circle!)

                    self.first = nil
                    self.second = nil
                    self.circle = nil
                    
                    self.doneButton.enabled = false
                }

            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))

            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    @IBAction func didTapResetButton(sender: AnyObject) {
        let alert = UIAlertController(title: "Rest All Data", message: "Are you sure you'd like to erase all local regions?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)

            self.previousGeofences = []
            self.first = nil
            self.second = nil
            self.circle = nil
        }))

        alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))

        self.presentViewController(alert, animated: true, completion: nil)
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
                pinView?.canShowCallout = true
            } else {
                pinView?.pinTintColor = MKPinAnnotationView.redPinColor()
                pinView?.canShowCallout = false
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

