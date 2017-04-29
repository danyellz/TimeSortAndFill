//
//  FSAPI+Venues.swift
//  ios-interview
//
//  Created by Tieshow Daniels on 4/20/17.
//  Copyright © 2017 Foursquare. All rights reserved.
//

import Foundation

//API struct to share JSON deserializer/other conveniences throughout the application
struct FSAPI {}

extension FSAPI {
    
    /* Creates venue object from locally store JSON data file
     
     - If JSON is readable into a venue object, returns an optional FSVenue object.
    */
    struct Venues {
        
        static func getVenueFromJSON() -> FSVenue? {
            
            // Parallel assignment of attributes - check if json, data, and the dictionary are valid.
            //before returning a dictionary for FSVenue.
            guard let json = Bundle.main.url(forResource: "people-here", withExtension: "json"),
            let data = try? Data(contentsOf: json),
            let dictionary = FSJSON.deserializeJSON(data: data) else {
                    debugPrint("Error parsing JSON")
                    return nil
            }
            
            return FSVenue(dictionary: dictionary)
        }
    }
}

/* 
 MARK: - Objective-C support for Swift Venue methods.
 This allows for bridging Swift 3.0 usage
 without converting Obj-C.
 */
final class FSVenueToObjC: NSObject {
    
    static func loadVenue() -> FSVenue? {
        return FSAPI.Venues.getVenueFromJSON()
    }
}

