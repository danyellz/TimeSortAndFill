//
//  FS + DateFormatter.swift
//  ios-interview
//
//  Created by Tieshow Daniels on 4/21/17.
//  Copyright © 2017 Foursquare. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    // Generates a formatter from the given date string
    
    // -Input should be a string; in the format for parsing a Date
    // -Output should be a DateFormatter utilizing the users current timezone information
    
    static func fs_formatterFrom(string: String) -> DateFormatter {
        let formatter  = DateFormatter()
        formatter.dateFormat = string
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
}
