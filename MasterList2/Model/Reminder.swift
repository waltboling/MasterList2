//
//  Reminder.swift
//  MasterList2
//
//  Created by Jon Boling on 8/13/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import MapKit

class Reminder: NSObject, NSCoding {
    
    
    //let text: String
    let coordinate: CLLocationCoordinate2D
    let identifier: String
    let notifyOnEntry: Bool, notifyOnExit: Bool
    let selectedRadius: Int
    
    convenience init(coordinate: CLLocationCoordinate2D,
                     notifyOnEntry: Bool, notifyOnExit: Bool, selectedRadius: Int) {
        self.init(coordinate: coordinate, identifier: NSUUID().uuidString, notifyOnEntry: notifyOnEntry, notifyOnExit: notifyOnExit, selectedRadius: selectedRadius)
    }
    
    init(coordinate: CLLocationCoordinate2D, identifier: String,
         notifyOnEntry: Bool, notifyOnExit: Bool, selectedRadius: Int) {
        //self.text = text
        self.coordinate = coordinate
        self.identifier = identifier
        self.notifyOnEntry = notifyOnEntry
        self.notifyOnExit = notifyOnExit
        self.selectedRadius = selectedRadius
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        // let text = aDecoder.decodeObject(forKey: "text") as! String
        let longitude = aDecoder.decodeDouble(forKey: "longitude")
        let latitude = aDecoder.decodeDouble(forKey: "latitude")
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let identifier = aDecoder.decodeObject(forKey: "identifier") as! String
        let notifyEntry = aDecoder.decodeBool(forKey: "notifyOnEntry")
        let notifyExit = aDecoder.decodeBool(forKey: "notifyOnExit")
        let selectedRadius = aDecoder.decodeInt64(forKey: "selectedRadius")
        
        self.init(coordinate: coordinate, identifier: identifier, notifyOnEntry: notifyEntry, notifyOnExit: notifyExit, selectedRadius: Int(selectedRadius))
        print("decoding: \(identifier) \(selectedRadius) \(notifyOnEntry)  \(notifyOnExit)" )
    }
    
    func encode(with aCoder: NSCoder) {
        //aCoder.encode(text, forKey: "text")
        aCoder.encode(coordinate.longitude, forKey: "longitude")
        aCoder.encode(coordinate.latitude, forKey: "latitude")
        aCoder.encode(identifier, forKey: "identifier")
        aCoder.encode(notifyOnEntry, forKey: "notifyOnEntry")
        aCoder.encode(notifyOnExit, forKey: "notifyOnExit")
        aCoder.encode(selectedRadius, forKey: "selectedRadius")
        
        print("encoding: \(identifier) \(selectedRadius) \(notifyOnEntry)  \(notifyOnExit)" )
    }
    
}


