
import Foundation

print("Enter level: ")
let levelString = readLine(strippingNewline: true)

print("Enter period: ")
let periodString = readLine(strippingNewline: true)

if let period = periodString, let level = levelString {
    
    let feed = QuakeFeed(level: level, period: period)
    print("original feed: \(feed)")
    
    if let feedSortedByDepth = feed.sortedByDepth() {
        print("Quake feed sorted by depth(asc) \(feedSortedByDepth)")
    }
    
    if let feedSortedByMag = feed.sortedByMagnitude() {
        print("Quake feed sorted by magnitude(desc) \(feedSortedByMag)")
    }
    
    if let boundedByCoordinates = feed.boundedBy(lon: (start: 5.938, end: 95.7386), lat: (start: -54.4368, end: 36.3916)){
        print("bounded coordinates: \(boundedByCoordinates)")
    }
    
    
    if let boundedDepth = feed.boundedByDepth(limit: 30)?.sortedByMagnitude() {
        print("bounded depth: \(boundedDepth)")
    }
    
    print("-------------------------------------------------------------")
    
    if let meanDepth = feed.meanDepth() {
        print("mean depth: \(meanDepth)")
    }
    
    if let meanMag = feed.meanMagnitude() {
        print("mean magnitude: \(meanMag)")
    }
}


