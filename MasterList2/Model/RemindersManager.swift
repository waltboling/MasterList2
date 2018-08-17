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
import UserNotifications

class RemindersManager: NSObject {

        let locationManager = CLLocationManager()
        var currentLocation: CLLocation?
        let userDefaults = UserDefaults.standard
        static let shared = RemindersManager()
        let userDefaultsKey = "RemindersUserDefaultsKey"
        let notificationCenter = UNUserNotificationCenter.current()
    
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
                    //showAlert(reminder: reminder)
                    locNotification(reminder: reminder)
                }
            }
        }
        
        func locNotification(reminder: Reminder) {
            let content = UNMutableNotificationContent()
            content.title = "You have tasks due nearby"
            content.body = "further description to come"
            content.sound = UNNotificationSound.default()
            let region = CLCircularRegion(center: reminder.coordinate, radius: CLLocationDistance(reminder.selectedRadius), identifier: reminder.identifier)
            let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
            let identifier = "identifier"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            notificationCenter.add(request, withCompletionHandler: { (error) in
                if error != nil {
                    print("Something went wrong")
                } else {
                    print("location notification set up successfully")
                }
            })
        
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
