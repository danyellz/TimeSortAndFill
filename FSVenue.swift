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
    let visitors: [FSVenueVisitor]?
    
    lazy var visitorsDuringOpenHours: [FSVenueVisitor] = { [unowned self] in
        print(self.sortVenueVisitorsByTimeAndFillGaps())
        return self.sortVenueVisitorsByTimeAndFillGaps()
    }()
}

// MARK: - Private API for sorting

fileprivate extension FSVenue {

    // MARK: - Algorithms for sort visitors for tableview usage, and represent gaps or 'downtime'.
    
    func sortVenueVisitorsByTimeAndFillGaps() -> [FSVenueVisitor] {
        var venueVisitors = visitors!
        let fillerVisitor = FSVenueVisitorGap(arriveTime: 60, leaveTime: 60)!
        venueVisitors.append(fillerVisitor)
        return venueVisitors
    }
}
