//
//  File.swift
//  ios-interview
//
//  Created by Tieshow Daniels on 4/21/17.
//  Copyright © 2017 Foursquare. All rights reserved.
//

import UIKit

final class FSPeopleHereTableViewCell: UITableViewCell {
    
    // MARK: - Cell constants
    
    static let cellReuseId = String(describing: FSPeopleHereTableViewCell.self)
    
    // MARK: - Initialization 
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use default initialization!")
    }
    
    // MARK: - override
    
    override func prepareForReuse() {
        resetCell()
    }
    
    // MARK: - Properties
    
    var venueVisitor: FSVenueVisitor? {
        didSet {
            configureCell(visitor: venueVisitor)
        }
    }
}

// MARK: - Private API for cell configuration

fileprivate extension FSPeopleHereTableViewCell {
    
    // MARK: - Setup cell
    
    func configureCell(visitor: FSVenueVisitor?) {
        guard let venueVisitor = visitor else {
            resetCell()
            return
        }
        
        textLabel?.text = venueVisitor.name
        
        // MARK: - Format visitor visiting time string (9:00 - 12:00)
        let unknownVenue = FSVenueLocalizations.Unknown
        let arriveTimeString = FSTimeUtility.timeStringFor(secondsSinceMidnight: venueVisitor.arriveTime) ?? unknownVenue
        let leaveTimeString = FSTimeUtility.timeStringFor(secondsSinceMidnight: venueVisitor.leaveTime) ?? unknownVenue
        detailTextLabel?.text = String(format: "%@ - %@", arriveTimeString, leaveTimeString)
        
        //Bool to check whether cell data configuration is for 'gap' data or legitimate visitor data
        let isEnabled = (venueVisitor is FSVenueVisitorGap) == false
        textLabel?.isEnabled = isEnabled
        detailTextLabel?.isEnabled = isEnabled
        isUserInteractionEnabled = isEnabled
    }
    
    
    func resetCell() {
        isUserInteractionEnabled = true
        textLabel?.isEnabled = true
        detailTextLabel?.isEnabled = true
        textLabel?.text = ""
        detailTextLabel?.text = ""
    }
}
