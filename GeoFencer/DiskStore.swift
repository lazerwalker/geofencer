import Foundation

struct DiskStore {
    let filename:String
    
    init() {
        self.init(filename:"data")
    }

    init(filename:String) {
        self.filename = filename
    }

    func save(geofences:[Region]) {
        let json = geofences.map({ return $0.toJSON() })
        let result = NSKeyedArchiver.archivedDataWithRootObject(json)
        NSUserDefaults.standardUserDefaults().setObject(result, forKey: filename)

    }

    func load() -> [Region] {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey(filename) as? NSData,
            json = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String] {

            return json.flatMap { PolygonRegion.fromJSON($0) }
                .map({ $0 as Region! })
        }
        return []
    }
}
