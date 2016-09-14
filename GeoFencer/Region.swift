import Foundation
import MapKit

protocol Region {
    // Internal representation
    var points:[CLLocationCoordinate2D] { get }
    var title:String { get }

    // Map presentation
    var annotations:[MKAnnotation] { get }
    var overlays:[MKOverlay] { get }

    // Serialization
    func toJSON() -> String
    static func fromJSON(json:String) -> Region?
}

func regionsAsJSON(regions:[Region]) -> String {
    let list = regions.map({$0.toJSON()})
    return "[\(list.joinWithSeparator(","))]"
}

