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
    
    fileprivate func sortVenueVisitorsByTimeAndFillGaps() -> [FSVenueVisitor]? {
        /*
         An algorithm to sort visitors and fill in gaps to show
         venue owners where they could improve foot traffic
         
         What we know:
         -------------
         - Time (opening hours / visits) is given as seconds from midnight and converted into 24hr time
         - People are sorted by their entry time and can overlap (so we sort by entry and then by the latter of exit times)
         - Gaps are inserted based on lack of entry time or immediately after someone exits until the next person or closing
         */

        /*
         NOTE: 
         
         - Initially attempted to iterate through venueVisitor in ascending order, but this method doesn't account for
         overlapping throughout the collection, and requires an O(n^2) solution. However, this does prove to work when all
         arriveTimes/leaveTimes in the collection are in ascending order.
         - Building a collection of visitors sorted by arriveTime then leaveTime may cause lag if done with a large array
         */
        guard var scheduleWithGaps = visitors?.sorted(by: {($0.arriveTime < $1.arriveTime)} ) else { return nil }
        guard var sortedByArriveAndLeave = visitorsSortedAscending() else { return nil }
        
        if let firstGap = FSVenueVisitorGap(arriveTime: open, leaveTime: (scheduleWithGaps.first?.arriveTime)!),
           let lastGap = FSVenueVisitorGap(arriveTime: (sortedByArriveAndLeave.last?.leaveTime)!, leaveTime: close) {
            
            scheduleWithGaps.append(firstGap) // -Add a gap from opening to first arrival
            scheduleWithGaps.append(lastGap) // -Add a gap from the last leave to close
        }
        
        /* 
         MARK: - ALGORITHM to iterate and find/fill 'gaps' in O(Logn) time:
         
         - Checks if [i - 1].leaveTime (visitor at current index) checkout is less than the following visitor's arrivalTime comparing TimeInterval values
         - A leaveTime < the subsequent visitor's arrivalTime indicates a gap (e.g. Neil left "16:30" --gap-- Nathan arrived "17:00")
         - Since visitors are sorted by both arriveTime/leaveTime, we are able to find differences or 'gaps' in a single iteration
         */
        
        for i in 1..<(sortedByArriveAndLeave.count) {
            if (sortedByArriveAndLeave[i - 1].leaveTime < sortedByArriveAndLeave[i].arriveTime) {
                
                let leaveTime = sortedByArriveAndLeave[i - 1].leaveTime
                let arriveTime = sortedByArriveAndLeave[i].arriveTime
                
                let gapSpace = FSVenueVisitorGap(arriveTime: leaveTime, leaveTime: arriveTime)
                scheduleWithGaps.append(gapSpace!)
            }
        }
        return scheduleWithGaps.sorted(by: {$0.leaveTime <= $1.arriveTime})
    }
    
    /**
     MARK: - Build a collection sorted by
     both arriveTimes/leaveTimes ascending
     */
    fileprivate func visitorsSortedAscending() -> [FSVenueVisitor]? {
        
        guard var sortedArrivals = visitors?.sorted(by: {$0.arriveTime < $1.arriveTime}),
              var sortedLeaves = visitors?.sorted(by: {$0.leaveTime < $1.leaveTime}) else { return nil }
        var sortedByArriveAndLeave = [FSVenueVisitor]()
        
        for index in 0..<(sortedArrivals.count) {
            
            let arrival = sortedArrivals[index].arriveTime
            let leaveTime = sortedLeaves[index].leaveTime
            
            if let visitor = FSVenueVisitorGap(arriveTime: arrival, leaveTime: leaveTime) {
                sortedByArriveAndLeave.append(visitor)
            }
        }
        
        return sortedByArriveAndLeave
    }
}
