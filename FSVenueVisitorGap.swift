//
//  FSVenueVisitorGap.swift
//  ios-interview
//
//  Created by Tieshow Daniels on 4/21/17.
//  Copyright © 2017 Foursquare. All rights reserved.
//

import Foundation

// NOTE: - This class is subclassed from the 'FSVenueVisitor' and is used to indicate 'gaps' between
//actual visitors - will be shown as greyed out as indicated in the screenshot
final class VenueVisitorGap: FSVenueVisitor {
    
    // MARK: - Initialization
    
    required init?(arriveTime: TimeInterval, leaveTime: TimeInterval) {
        let dictionary: [String: Any] = ["id": "gap",
                                         "name": "No visitors",
                                         "arriveTime": arriveTime,
                                         "leaveTime": leaveTime]
        super.init(dictionary: dictionary)
    }
    
    // MARK: - Unsupported Initializers
    
    @available(*, unavailable)
    required init?(dictionary: [String : Any]) { fatalError("init(dictionary:) has not been implemented") }
}
