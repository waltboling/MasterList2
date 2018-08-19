//
//  SetDeadlineViewController.swift
//  MasterList2
//
//  Created by Jon Boling on 8/14/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import UserNotifications
import CloudKit
import Flurry_iOS_SDK


class SetDeadlineViewController: UIViewController {
    
    let notificationCenter = UNUserNotificationCenter.current()
    var dateFormatter = DateFormatter()
    var currentList: CKRecord?
    let privateDatabase = CKContainer.default().privateCloudDatabase
    
    //IB Outlets
    @IBOutlet weak var reminderOptions: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var deadlineLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //request notification authorization. need to see if there is a way to make sure the app only does this once
        let options: UNAuthorizationOptions = [.alert, .sound, .badge];
        
        notificationCenter.requestAuthorization(options: options) { (granted, error) in
            if granted {
                print("Accepted permission.")
            } else {
                print("Did not accept permission.")
            }
        }
    }
    
    //IB Actions
    @IBAction func DeadlineWasSet(_ sender: UIDatePicker) {
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        deadlineLabel.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func doneBtnWasTapped(_ sender: Any) {
        configureNotification()
        if let list = currentList {
            list["deadline"] = deadlineLabel.text as CKRecordValue?
            
            privateDatabase.save(list, completionHandler: { (record: CKRecord?, error: Error?) in
                if error == nil {
                    print("deadline saved!")
                } else {
                    print("Error: \(error.debugDescription)")
                }
            })
        }
        
        Flurry.logEvent("Deadline Added")
        
        dismiss(animated: true, completion: nil)
        //need to save date, alert
    }
    
    @IBAction func cancelBtnWasTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func configureNotification() {
        let content = UNMutableNotificationContent()
        content.title = "You have tasks due"
        content.body = "item due will go here eventually"
        content.sound = UNNotificationSound.default()
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: datePicker.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let identifier = "identifier"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request, withCompletionHandler: { (error) in
            if error != nil {
                print("Something went wrong")
            } else {
                print("notification set up successfully")
            }
        })
    }
}
