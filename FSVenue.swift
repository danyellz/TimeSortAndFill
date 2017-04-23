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
        
        // MARK - Sorted arrays by: arrivalTime/leaveTime to later be combined into a collection
        guard var sortedFirst = visitors?.sorted(by: {$0.arriveTime < $1.arriveTime}),
            var sortedLast = visitors?.sorted(by: {$0.leaveTime < $1.leaveTime}),
            var scheduleWithGaps = visitors?.sorted(by: {($0.arriveTime, $0.leaveTime) < ($1.arriveTime, $1.leaveTime)}) else { return nil }
        
        // - Array of 'FSVenueVisitor' sorted start/end times
        var sortedByStartAndEnd = [FSVenueVisitor]()
        
        // - Gap before first guest
        let firstGap = FSVenueVisitorGap(arriveTime: open, leaveTime: (scheduleWithGaps.first?.arriveTime)!)
        scheduleWithGaps.append(firstGap!)
        
        // - Build the collection with sorted start/end times for simplified iteration
        for index in 0..<(sortedLast.count) {
            
            let gapVisitor = FSVenueVisitorGap(arriveTime: (sortedFirst[index].arriveTime), leaveTime: (sortedLast[index].leaveTime))
            sortedByStartAndEnd.append(gapVisitor!)
        }
        
        // - Gap between the last customers leaveTime and business close
        let lastGap = FSVenueVisitorGap(arriveTime: (sortedByStartAndEnd.last?.leaveTime)!, leaveTime: close)
        scheduleWithGaps.append(lastGap!)
    
        /* 
         MARK: - Algorithm to iterate and find/fill 'gaps' in O(n)n time:
         
         - Checks if [i - 1].leaveTime (the current visitors checkout) is less than the following visitor's arrivalTime comparing TimeIntervals
         - A leaveTime < the subsequent visitor's arrivalTime indicates a gap (e.g. Neil left "16:30" --gap-- Nathan arrived "17:00")
         - Since visitors are sorted by both arriveTime and leaveTime, we are able to find differences in a single iteration
         */
        for i in 1..<(sortedByStartAndEnd.count) {
            if (sortedByStartAndEnd[i - 1].leaveTime < sortedByStartAndEnd[i].arriveTime) {
                if let gapSpace = FSVenueVisitorGap(arriveTime: sortedByStartAndEnd[i - 1].leaveTime, leaveTime: sortedByStartAndEnd[i].arriveTime) {
                    scheduleWithGaps.append(gapSpace)
                }
            }
        }
        
        return scheduleWithGaps.sorted(by: {$0.leaveTime <= $1.arriveTime})
    }
}
