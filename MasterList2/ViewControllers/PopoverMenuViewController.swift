//
//  PopoverMenuTableViewController.swift
//  MasterList2
//
//  Created by Jon Boling on 8/13/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import CloudKit
import Flurry_iOS_SDK

class PopoverMenuTableViewController: UITableViewController {
    
    var currentList: CKRecord?
    let privateDatabase = CKContainer.default().privateCloudDatabase
    
    //IB Outlets
    @IBOutlet weak var photoLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var displayNotesTextView: UITextView!
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var photoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Reminders"

        if let list = currentList {
            self.displayNotesTextView.text = list["note"] as? String
            self.deadlineLabel.text = list["deadline"] as? String
            self.locationLabel.text = list["location"] as? String
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let list = currentList {
            let listName = list["listName"] as? String
            self.displayNotesTextView.text = list["note"] as? String
            self.deadlineLabel.text = list["deadline"] as? String
            self.locationLabel.text = list["location"] as? String
            if let photo = list["photo"] as? CKAsset {
                self.photoButton.imageView?.image = UIImage(contentsOfFile: (photo.fileURL.path))
            self.photoLabel.text = listName! + "_img"
            }
            
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //var controller = segue.destination
        if segue.identifier == DataStructs.toPhotoPicker {
            let controller = segue.destination as! SetImageViewController
            controller.currentList = currentList
        } else if segue.identifier == DataStructs.toLocation {
            let controller = segue.destination as! LocationReminderViewController
            controller.currentList = currentList
        } else if segue.identifier == DataStructs.toDeadline {
            let controller = segue.destination as! SetDeadlineViewController
            controller.currentList = currentList
        } else {
            let controller = segue.destination as! CreateNoteViewController
            
            controller.currentList = currentList
            
        }
    }

    // MARK: - Table view data source (static cells currently set in storyboard)
}
