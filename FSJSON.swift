//
//  FSJSON.swift
//  ios-interview
//
//  Created by Tieshow Daniels on 4/20/17.
//  Copyright © 2017 Foursquare. All rights reserved.
//

import Foundation

class FSJSON {
    
    /*
     MARK: - JSON deserialization
     
     Method to check whether JSON is capable of being serialized into a dictionary.
     - Input will be a set of data in the form of JSON
     - Output will be a JSON deserialized into a dictionary.
     */
    static func deserializeJSON(data: Data?) -> [String : Any]? {
        guard let data = data, data.count != 0 else {
            return nil
        }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
            return nil
        }
        return json
    }
}
