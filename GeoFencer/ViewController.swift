import CoreLocation
import MapKit
import UIKit

class ViewController: UIViewController {
    let locationManager = CLLocationManager()

    var first:MKPointAnnotation?
    var second:MKPointAnnotation?

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
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()

        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.FollowWithHeading, animated: true)
    }
}

