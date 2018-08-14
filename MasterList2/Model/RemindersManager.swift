//
//  RemindersManager.swift
//  MasterList2
//
//  Created by Jon Boling on 8/13/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
class RemindersManager: NSObject {

        let locationManager = CLLocationManager()
        var currentLocation: CLLocation?
        let userDefaults = UserDefaults.standard
        static let shared = RemindersManager()
        let userDefaultsKey = "RemindersUserDefaultsKey"
        
        func updateLocation() {
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
        }
        
        func reminders() -> [Reminder] {
            if let remindersData  = userDefaults.object(forKey: userDefaultsKey) as? Data {
                let reminders = NSKeyedUnarchiver.unarchiveObject(with: remindersData) as! [Reminder]
                
                return reminders
            }
            
            return [Reminder]()
        }
        
        func add(reminder: Reminder) {
            var reminders = self.reminders()
            reminders.append(reminder)
            
            let remindersData = NSKeyedArchiver.archivedData(withRootObject: reminders)
            UserDefaults.standard.set(remindersData, forKey: userDefaultsKey)
            UserDefaults.standard.synchronize()
            
            let region = CLCircularRegion(center: reminder.coordinate, radius: CLLocationDistance(reminder.selectedRadius), identifier: reminder.identifier)
            region.notifyOnEntry = reminder.notifyOnEntry
            region.notifyOnExit = reminder.notifyOnExit
            
            locationManager.startMonitoring(for: region)
        }
        
        func delete(reminderAtIndex index: Int) {
            var reminders = self.reminders()
            let reminderIdentifier = reminders[index].identifier
            
            for region in locationManager.monitoredRegions {
                if let circularRegion = region as? CLCircularRegion, circularRegion.identifier == reminderIdentifier {
                    locationManager.stopMonitoring(for: circularRegion)
                }
            }
            
            reminders.remove(at: index)
            
            let remindersData = NSKeyedArchiver.archivedData(withRootObject: reminders)
            UserDefaults.standard.set(remindersData, forKey: userDefaultsKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    extension RemindersManager: CLLocationManagerDelegate {
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Error: " + error.localizedDescription)
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            currentLocation = locations.last
        }
        
        //probably want to attach some sort of notification that opens the to-do list to the following code
        func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
            for reminder in reminders() {
                if reminder.identifier == region.identifier {
                    showAlert(reminder: reminder)
                }
            }
        }
        
        func showAlert(reminder: Reminder) {
           // print(reminder.text)
            let alertController = UIAlertController(title: "Reminder",
                                                    message: "Place New Reminder Alert Here",
                                                    preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "Okay",
                                            style: .default,
                                            handler: nil)
            
            alertController.addAction(alertAction)
            
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
}
