import Foundation

struct DiskStore {
    let filename:String
    
    init() {
        self.init(filename:"data")
    }

    init(filename:String) {
        self.filename = filename
    }

    func save(geofences:[Geofence]) {
        let json = geofences.map({ return $0.toJSON() })
        let result = NSKeyedArchiver.archivedDataWithRootObject(json)
        NSUserDefaults.standardUserDefaults().setObject(result, forKey: filename)

    }

    func load() -> [Geofence] {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey(filename) as? NSData,
            json = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String] {
            let results:[Geofence?] = json.map({ return Geofence.fromJSON($0) })
            return results
                .filter({ $0 != nil })
                .map({ $0 as Geofence! })
        }
        return []
    }
}