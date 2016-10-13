
import Foundation

struct Quake : CustomStringConvertible {
    var timestamp : Date?
    var latitude : Double?
    var longitude : Double?
    var depth : Double? //Could be a float ?
    var magnitude : Double?
    
    var description: String {
        return "\(formatDateToString(date: timestamp!)) - (\(longitude!)\u{00b0}, \(latitude!)\u{00b0}, \(depth!)km), M\(magnitude!)"
    }
    
    private func formatDateToString(date: Date)-> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return formatter.string(from: date)
    }
    
    /**
     This function does the required parsing of date and
     time when creating Quake objects from downloaded data
     of Quake records
     
     - returns: Date
     */
    static func formatStringToDate(timestamp: String) -> Date {
        var dateTimeComponents = timestamp.components(separatedBy: "T")
        let date = dateTimeComponents[0]
        let time = dateTimeComponents[1].components(separatedBy: ".")[0]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd H:mm:ss"
        
        let formattedDate = formatter.date(from: "\(date) \(time)")!
        return formattedDate
        
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

        if validProperties(inputLevel: level, inputPeriod: period){
            let path = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/\(self.level)_\(self.period).csv"
            
            self.fetchQuakeFeed(from: path)
        }
        
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
    
    func meanDepth() -> Double? {
        if dataset.isEmpty{
            return nil
        }
        
        var total = 0.0
        for record in dataset {
            if let depth = record.depth {
                total += depth
            }
        }
        let average = total/Double(dataSize)
        return formatResult(number: average, dp: 2)
    }
    
    func meanMagnitude() -> Double? {
        if dataset.isEmpty{
            return nil
        }
        
        var total = 0.0
        for record in dataset {
            if let magnitude = record.magnitude {
                total += magnitude
            }
        }
        let average = total/Double(dataSize)
        return formatResult(number: average, dp: 2)
    }
  
    
    func sortedByDepth() -> QuakeFeed? {
        if dataset.isEmpty{
            return nil
        }
        let sortedDataset = dataset.sorted(by: { $0.depth! < $1.depth! })
        return QuakeFeed(level: self.level, period: self.period, dataset: sortedDataset)
    }
    
    func sortedByMagnitude() -> QuakeFeed? {
        if dataset.isEmpty{
            return nil
        }
        let sortedDataset = dataset.sorted(by: { $0.magnitude! > $1.magnitude! })
        return QuakeFeed(level: self.level, period: self.period, dataset: sortedDataset)
    }
    
    func boundedBy(lon:(start: Double, end: Double), lat:(start: Double, end: Double)) -> QuakeFeed? {
        if dataset.isEmpty{
            return nil
        }
        //initialize a range for each coordinate type
        let longitudeRange = lon.start ... lon.end
        let latitudeRange = lat.start ... lat.end

        let filteredDataset = dataset.filter(){(quake) in
            let containsLongitude = longitudeRange.contains(quake.longitude!)
            let containsLatitude =  latitudeRange.contains(quake.latitude!)
            
//            print("\(containsLongitude && containsLatitude) \(quake.longitude!) : \(quake.latitude!)")
            return containsLongitude && containsLatitude
        }
        
        return QuakeFeed(level: self.level, period: self.period, dataset: filteredDataset)
    }
    
    func boundedBy(magnitude: (min: Double, max: Double)) -> QuakeFeed? {
        if dataset.isEmpty{
            return nil
        }
        
        //initialize a range for the given magnitude
        let magnitudeRange = magnitude.min ... magnitude.max
        
        let filteredDataset = dataset.filter(){(quake) in
          return magnitudeRange.contains(quake.magnitude!)
        }
        
        return QuakeFeed(level: self.level, period: self.period, dataset: filteredDataset)
    }
    
    /**
       This function will fetch Quake Feeds from the given endpoint and create a dataset
       of Quake records

     - parameter HTTP endpoint.
     
     - returns: Void
     */
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
                        let quakeRecord = Quake(timestamp: Quake.formatStringToDate(timestamp: dataRecord[0]), latitude: Double(dataRecord[1]), longitude: Double(dataRecord[2]), depth: Double(dataRecord[3]), magnitude: Double(dataRecord[4]))
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
    
    private func formatResult(number: Double, dp: Int) -> Double{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.roundingMode = .halfUp
        numberFormatter.maximumFractionDigits = dp
        
        return Double(numberFormatter.string(from: NSNumber(floatLiteral: number))!)!
    }
    
    private func validProperties(inputLevel: String, inputPeriod: String) -> Bool {
        
        let allowedLevels = ["all", "1.0", "2.5", "4.5", "significant"]
        let allowedPeriods = ["hour", "day", "week", "month"]
        var state = false
        
        if allowedLevels.contains(inputLevel) == false {
            print("Please provide a level in \(allowedLevels) ")
        }
        if allowedPeriods.contains(inputPeriod) == false {
            print("Please provide a period in \(allowedPeriods) ")
        }
        else{
            state = true
        }
        
        return state
    }
    
}


let feed = QuakeFeed(level: "4.5", period: "day")
print("original feed: \(feed)")

if let feedSortedByDepth = feed.sortedByDepth() {
    print("Quake feed sorted by depth(asc) \(feedSortedByDepth)")
}

if let feedSortedByMag = feed.sortedByMagnitude() {
    print("Quake feed sorted by magnitude(desc) \(feedSortedByMag)")
}

if let feedFilteredByCoordinates = feed.boundedBy(lon: (start: 5.938, end: 95.7386), lat: (start: -54.4368, end: 36.3916)){
    print("bounded coordinates: \(feedFilteredByCoordinates)")
}

if let boundedMag = feed.boundedBy(magnitude: (min: 4.5, max: 4.6)) {
    print("bounded magnitude: \(boundedMag)")
}

print("-------------------------------------------------------------")

if let meanDepth = feed.meanDepth() {
    print("mean depth: \(meanDepth)")
}

if let meanMag = feed.meanMagnitude() {
    print("mean magnitude: \(meanMag)")
}






