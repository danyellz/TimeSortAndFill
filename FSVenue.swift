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
        
        //Create array of visitor objects from the nested JSON dictionary
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

// MARK: - Private API for venue helpers

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
        guard var sortedArrivals = visitors?.sorted(by: {$0.arriveTime < $1.arriveTime}), //Sorted by arrival
            var sortedLeaves = visitors?.sorted(by: {$0.leaveTime < $1.leaveTime}), // Sorted by leave
            var scheduleWithGaps = visitors?.sorted(by: {($0.arriveTime < $1.arriveTime)} ) else { return nil } //visitor
        
        // - Array of 'FSVenueVisitor' sorted start/end times
        var sortedByStartAndEnd = [FSVenueVisitor]()
        
        // - Gap before first guest
        let firstGap = FSVenueVisitorGap(arriveTime: open, leaveTime: (scheduleWithGaps.first?.arriveTime)!)
        scheduleWithGaps.append(firstGap!)
        
        // - Build the collection with sorted start/end times for simpler comparisons
        for index in 0..<(scheduleWithGaps.count) - 1 {
            
            // Creates a VenueVisitor object with arriveTime/leaveTime previously sorted in ascending order
            let gapVisitor = FSVenueVisitorGap(arriveTime: (sortedArrivals[index].arriveTime), leaveTime: (sortedLeaves[index].leaveTime))
            sortedByStartAndEnd.append(gapVisitor!)
        }
        
        // - Gap between the last customers leaveTime and business close
        let lastGap = FSVenueVisitorGap(arriveTime: (sortedByStartAndEnd.last?.leaveTime)!, leaveTime: close)
        scheduleWithGaps.append(lastGap!)
    
        /* 
         MARK: - Algorithm to iterate and find/fill 'gaps' in O(Log n) time:
         
         - Checks if [i - 1].leaveTime (visitor at current index) checkout is less than the following visitor's arrivalTime comparing TimeIntervals
         - A leaveTime < the subsequent visitor's arrivalTime indicates a gap (e.g. Neil left "16:30" --gap-- Nathan arrived "17:00")
         - Since visitors are sorted by both arriveTime/leaveTime, we are able to find differences or 'gaps' in a single iteration
         */
        
        for i in 1..<(sortedByStartAndEnd.count) {
            
            // - Append the 'gap' object if the current leaveTime < the subsequent indexes arriveTime
            if (sortedByStartAndEnd[i - 1].leaveTime < sortedByStartAndEnd[i].arriveTime) {
                if let gapSpace = FSVenueVisitorGap(arriveTime: sortedByStartAndEnd[i - 1].leaveTime,
                                                    leaveTime: sortedByStartAndEnd[i].arriveTime) { scheduleWithGaps.append(gapSpace) }
            }
        }
        // Sort the array of newly added 'gap' times in order of leaveTimes <= next index arriveTimes
        
        // - Makes filled gaps' arriveTime follow the prior visitor leaveTime
        return scheduleWithGaps.sorted(by: {$0.leaveTime <= $1.arriveTime})
    }
}
