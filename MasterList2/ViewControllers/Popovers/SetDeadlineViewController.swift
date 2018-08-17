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

class SetDeadlineViewController: UIViewController {
    
    let notificationCenter = UNUserNotificationCenter.current()
    var dateFormatter = DateFormatter()
    var currentList: CKRecord?
    @IBOutlet weak var reminderOptions: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var deadlineLabel: UILabel!
    
    
    
    @IBAction func DeadlineWasSet(_ sender: UIDatePicker) {
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        deadlineLabel.text = dateFormatter.string(from: sender.date)
    }
    @IBAction func doneBtnWasTapped(_ sender: Any) {
        configureNotification()
        dismiss(animated: true, completion: nil)
        //need to save date, alert
    }
    
    @IBAction func cancelBtnWasTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
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
