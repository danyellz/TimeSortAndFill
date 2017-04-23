//
//  FSVenueVisitor.swift
//  ios-interview
//
//  Created by Tieshow Daniels on 4/20/17.
//  Copyright © 2017 Foursquare. All rights reserved.
//

import Foundation

// NOTE: - If written purely in Swift, Struct use would be ideal here.
//
// - FSVenue inherits from NSObject for Obj-C support.
class FSVenueVisitor : NSObject {
    
    required init?(dictionary: [String : Any]) {
        id = dictionary["id"] as! String
        name = dictionary["name"] as! String
        arriveTime = dictionary["arriveTime"] as! TimeInterval
        leaveTime = dictionary["leaveTime"] as! TimeInterval
    }
    
    // MARK: - Initialization convenience methods
    
    static func arrayFrom(dictionary: [[String : Any]]?) -> [FSVenueVisitor]? {
        guard let dictionary = dictionary else {
            return nil
        }
        return dictionary.flatMap({ FSVenueVisitor(dictionary: $0) }) //Convert dictionary into [FSVenueVisitor]
    }
    
    let id: String
    let name: String
    let arriveTime: TimeInterval
    let leaveTime: TimeInterval
}
