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

            shareButton.enabled = (previousGeofences.count > 0)
            resetButton.enabled = (previousGeofences.count > 0)
            diskStore.save(previousGeofences)
        }

    }

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var resetButton: UIBarButtonItem!

    @IBAction func didTapFirstButton(sender: AnyObject) {
        if let coordinate = mapView.userLocation.location?.coordinate {
            replaceFirstWithCoordinate(coordinate)
        }
    }

    @IBAction func didTapSecondButton(sender: AnyObject) {
        if let coordinate = mapView.userLocation.location?.coordinate {
            replaceSecondWithCoordinate(coordinate)
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

    @IBAction func didTapShareButton(sender: AnyObject) {
        let json = Geofence.listAsJSON(self.previousGeofences)
        let activityViewController = UIActivityViewController(activityItems: [json as NSString], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()

        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.FollowWithHeading, animated: true)

        previousGeofences = diskStore.load()
    }

    // -
    func replaceFirstWithCoordinate(coordinate:CLLocationCoordinate2D) {
        if let first = first {
            mapView.removeAnnotation(first)
        }

        first = MKPointAnnotation()
        if let first = first {
            first.coordinate = coordinate
            mapView.addAnnotation(first)

            recalculateCircle()
            recalculateDoneButton()
        }
    }

    func replaceSecondWithCoordinate(coordinate:CLLocationCoordinate2D) {
        if let second = second {
            mapView.removeAnnotation(second)
        }

        second = MKPointAnnotation()
        if let second = second {
            second.coordinate = coordinate
            mapView.addAnnotation(second)

            recalculateCircle()
            recalculateDoneButton()
        }
    }

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
                pinView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            } else {
                pinView?.pinTintColor = MKPinAnnotationView.redPinColor()
                pinView?.canShowCallout = false
                pinView?.rightCalloutAccessoryView = nil
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

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (!view.annotation!.isKindOfClass(MKCircle.self)) { return }
            if let circle = view.annotation as? MKCircle {
                if let index = self.previousGeofences.indexOf({ $0.circle == circle }) {
                    let geofence = self.previousGeofences[index]
                    self.previousGeofences.removeAtIndex(index)

                    self.circle = nil
                    replaceFirstWithCoordinate(geofence.points[0])
                    replaceSecondWithCoordinate(geofence.points[1])
                    self.title = geofence.title
                }
            }
        }
}

