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
        
        //Sorted by arrivalTime
        var venueVisitors = visitors?.sorted(by: {$0.arriveTime < $1.arriveTime})
        
        // NOTE: - On^2 solutionm
        for index in 0..<(venueVisitors?.count)! - 1 {
            guard let thisVisitor = venueVisitors?[index], let nextVisitor = venueVisitors?[index + 1] else {
                return nil
            }

            //Skip if theres overlap between current and next visitor's start and end times
            if (thisVisitor.leaveTime.isLess(than: nextVisitor.leaveTime)) && (thisVisitor.leaveTime.isLess(than: nextVisitor.arriveTime)) {
                let visitorLeave = thisVisitor.leaveTime
                let nextVisitorArrival = nextVisitor.arriveTime
                
                let fillerVisitor = FSVenueVisitorGap(arriveTime: visitorLeave, leaveTime: nextVisitorArrival)!
                venueVisitors?.append(fillerVisitor)
            }
        }
        return venueVisitors
    }
}
