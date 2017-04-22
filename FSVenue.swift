//
//  FSVenue.swift
//  ios-interview
//
//  Created by Tieshow Daniels on 4/20/17.
//  Copyright © 2017 Foursquare. All rights reserved.
//

import Foundation

// NOTE: - If written purely in Swift, Struct use would be ideal here.
//
// - FSVenue inherits from NSObject for Obj-C support.

final class FSVenue: NSObject {
    
    // MARK: - Initialization
    
    required init?(dictionary: [String:Any]) {
        
        //Check if a dictionary exists from 'venue' object
        guard let dictionaryForVenue = dictionary["venue"] as? [String: Any] else {
            return nil
        }
        
        id = dictionaryForVenue["id"] as! String
        name = dictionaryForVenue["name"] as! String
        open = dictionaryForVenue["openTime"] as! TimeInterval
        close = dictionaryForVenue["closeTime"] as! TimeInterval
        
        //Create array of visitor objects
        let dictionaryOfVisitors = dictionaryForVenue["visitors"] as! [[String:Any]]
        visitors = FSVenueVisitor.arrayFrom(dictionary: dictionaryOfVisitors)
    }
    
    let id: String
    let name: String
    let open: TimeInterval
    let close: TimeInterval
    var visitors: [FSVenueVisitor]?
    
    lazy var visitorsDuringOpenHours: [FSVenueVisitor] = { [unowned self] in
        return self.sortVenueVisitorsByTimeAndFillGaps()
    }()!
}

// MARK: - Private API for sorting

fileprivate extension FSVenue {

    // MARK: - Algorithms for sort visitors for tableview usage, and represent gaps or 'downtime'.
    
    func sortVenueVisitorsByTimeAndFillGaps() -> [FSVenueVisitor]? {
        
        /*
         An algorithm to sort visitors and fill in gaps to show
         venue owners where they could improve foot traffic
         
         What we know:
         -------------
         - Time (opening hours / visits) is given as seconds from midnight and converted into 24hr time
         - People are sorted by their entry time and can overlap (so we sort by entry and then by the latter of exit times)
         - Gaps are inserted based on lack of entry time or immediately after someone exits until the next person or closing
         */
        
        // MARK - Instatiate sorted arrays used within the algorithm
        guard var sortedFirst = visitors?.sorted(by: {$0.arriveTime < $1.arriveTime}),
            var sortedLast = visitors?.sorted(by: {$0.leaveTime < $1.leaveTime}),
            var scheduleWithGaps = visitors?.sorted(by: {$0.arriveTime < $1.arriveTime}) else { return nil
        
        }
        
        // - Array of 'FSVenueVisitor' sorted start/end times
        var sortedByStartAndEnd = [FSVenueVisitor]()
        
        // - Gap before first guest
        let firstGap = FSVenueVisitorGap(arriveTime: open, leaveTime: (scheduleWithGaps.first?.arriveTime)!)
        scheduleWithGaps.append(firstGap!)
        
        // - Create array with sorted start/end times
        for index in 0..<(sortedLast.count) {
            
            let gapVisitor = FSVenueVisitorGap(arriveTime: (sortedFirst[index].arriveTime), leaveTime: (sortedLast[index].leaveTime))
            sortedByStartAndEnd.append(gapVisitor!)
        }
        
        let lastGap = FSVenueVisitorGap(arriveTime: (sortedByStartAndEnd.last?.leaveTime)!, leaveTime: close)
        scheduleWithGaps.append(lastGap!)
        
        for i in 1..<(sortedByStartAndEnd.count) {
            
            let beginningOfGap = sortedByStartAndEnd[i - 1].leaveTime
            let endOfGap = sortedByStartAndEnd[i].arriveTime
            
            if (beginningOfGap < endOfGap) {
                let overlapping = FSVenueVisitorGap(arriveTime: beginningOfGap, leaveTime: endOfGap)
                scheduleWithGaps.append(overlapping!)
            }
        }
        
        return scheduleWithGaps.sorted(by: {$0.arriveTime < $1.arriveTime})
    }
}
