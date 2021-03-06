//
//  FSTimeUtility.swift
//  ios-interview
//
//  Created by Tieshow Daniels on 4/21/17.
//  Copyright © 2017 Foursquare. All rights reserved.
//

import Foundation

// MARK: - Time utility API for converting TimeIntervals to Date objects, then readable fomatted strings.

struct FSTimeUtility {
    //Generate a time string (e.g. 18:31) for the seconds from midnight
    
    // - Input should be the seconds since midnight
    // - Output should be a time string in 24 hour time
    
    static func timeStringFor(secondsSinceMidnight: TimeInterval) -> String? {
        guard let date = dateFrom(secondsSinceMidnight: secondsSinceMidnight) else {
            return nil
        }
        
        return DateCache.timeFormatter.string(from: date)
    }
}

// MARK: - Private API for manipulating TimeIntervals into Date and getting Strings from Date

fileprivate extension FSTimeUtility {
    
    //Generate a Date with an offset from midnight in order to form a time string
    
    // - Input should be the seconds since midnight
    // - Output should be a Date
    static func dateFrom(secondsSinceMidnight: TimeInterval) -> Date? {
        return DateCache.midnightDate?.addingTimeInterval(secondsSinceMidnight)
    }
    
    //MARK: - Date formatter cache
    
    fileprivate struct DateCache {
        
        //Returns a Date for the current day at midnight (0h, 0m, 0s)
        static let midnightDate: Date? = {
            let today = Calendar.current
            var dateComponents = today.dateComponents([.hour, .minute, .second], from: Date())
            dateComponents.hour = 0
            dateComponents.minute = 0
            dateComponents.second = 0
            return today.date(from: dateComponents)
        }()
        
        static let timeFormatter: DateFormatter = {
           return DateFormatter.fs_formatterFrom(string: "H:mm") //Formats Date string without a leading zero (07:30)->(7:30)
        }()
    }
}
