import CoreLocation
import MapKit
import UIKit

class ViewController: UIViewController {
    let locationManager = CLLocationManager()

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    
    @IBAction func didTapFirstButton(sender: AnyObject) {
        print(mapView.userLocation.location)
    }
    @IBAction func didTapSecondButton(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()

        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.FollowWithHeading, animated: true)
    }
}

