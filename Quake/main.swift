
import Foundation

struct Quake : CustomStringConvertible {
    var timestamp : String?
    var latitude : Double?
    var longitude : Double?
    var depth : Double? //Could be a float ?
    var magnitude : Double?
    
    var description: String {
        //parse date and time from timestamp format
        var dateTimeComponents = self.timestamp?.components(separatedBy: "T")
        let date = dateTimeComponents?[0]
        let time = dateTimeComponents?[1].components(separatedBy: ".")[0]
        
        return "\(date!) \(time!) - (\(latitude!)\u{00b0}, \(longitude!)\u{00b0}, \(depth!)km), M\(magnitude!)"
    }
}

class QuakeFeed : CustomStringConvertible {
    
    var level: String
    var period: String
    var dataset : [Quake] = [Quake]()
    var dataSize : Int {
        return dataset.count
    }
    
    var description: String {
        print("-------------------------------------------------------------")
        for data in dataset {
            print(data)
        }
        return "\(dataSize) quakes (level: \(level) period: \(period))"
    }
    
    //convenience init will automatically fetch feed if not given
    convenience init(level: String, period: String){
        self.init(level: level, period: period, dataset: nil)
       
        let path = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/\(self.level)_\(self.period).csv"
        
        self.fetchQuakeFeed(from: path)
    }
    
    init(level: String, period: String, dataset: [Quake]?){
        self.level = level
        self.period = period
        
        if let quakeRecords = dataset {
            self.dataset = quakeRecords
        }
    }
    
    func update(){
        //TODO
    }
    
    func meanDepth() -> Double {
        var total = 0.0
        for record in dataset {
            if let depth = record.depth {
                total += depth
            }
        }
        return total/Double(dataSize)
    }
    
    func meanMagnitude() -> Double {
        var total = 0.0
        for record in dataset {
            if let magnitude = record.magnitude {
                total += magnitude
            }
        }
        return total/Double(dataSize)
    }
  
    
    func sortedByDepth() -> QuakeFeed {
        let filteredDataset = dataset.sorted(by: { $0.depth! < $1.depth! })
        return QuakeFeed(level: self.level, period: self.period, dataset: filteredDataset)
    }
    
    func sortedByMagnitude() -> QuakeFeed {
        let filteredDataset = dataset.sorted(by: { $0.magnitude! > $1.magnitude! })
        return QuakeFeed(level: self.level, period: self.period, dataset: filteredDataset)
    }
    
    func boundedBy(lon:(start: Double, end: Double), lat:(start: Double, end: Double)) {
        
    }
    
    private func fetchQuakeFeed(from path: String){
        if let url = URL(string: path) {
            do {
                let contents = try String(contentsOf: url)
                var contentArray = contents.components(separatedBy: "\n")
                //remove column titles
                contentArray.removeFirst()
                for content in contentArray {
                    if content.isEmpty {
                        //handle case where record line is empty
                        continue
                    }
                    let dataRecord = content.components(separatedBy: ",")
                    if dataRecord.count > 5 {
                        let quakeRecord = Quake(timestamp: dataRecord[0], latitude: Double(dataRecord[1]), longitude: Double(dataRecord[2]), depth: Double(dataRecord[3]), magnitude: Double(dataRecord[4]))
                        //print(quakeRecord)
                        self.dataset.append(quakeRecord)
                    }
                }
            } catch {
                // contents could not be loaded
            }
        } else {
            // the URL was malformed!
        }
    }
}

var path = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/4.5_day.csv"

let feed = QuakeFeed(level: "4.5", period: "day")
print("original feed: \(feed)")

print("Quake feed sorted by depth(asc) \(feed.sortedByDepth())")
print("Quake feed sorted by magnitude(desc) \(feed.sortedByMagnitude())")

let range = feed.dataset.sorted(by: {$0.0.latitude! >= -2.0 && $0.0.latitude! <= 4.0})

print("range is \(range.count)")
