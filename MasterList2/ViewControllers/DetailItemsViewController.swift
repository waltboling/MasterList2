//
//  DetailItemsViewController.swift
//  MasterList2
//
//  Created by Jon Boling on 8/4/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import CloudKit
import ChameleonFramework
import Flurry_iOS_SDK


class DetailItemsViewController: UIViewController, UITextFieldDelegate {
   
    var sublist: CKRecord?
    var detailItems = [CKRecord]()
    var longPressGesture = UIGestureRecognizer()
    
    //IB Outlets
    @IBOutlet weak var detailItemsTableView: UITableView!
    @IBOutlet weak var addItemBtn: UIButton!
    @IBOutlet weak var inputDetailItems: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputDetailItems.delegate = self
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        
        if let sublist = sublist {
            self.navigationItem.title = sublist["listName"] as? String
            
            let privateDatabase = CKContainer.default().privateCloudDatabase
            let reference = CKReference(recordID: sublist.recordID, action: .deleteSelf)
            let query = CKQuery(recordType: "detailItems", predicate: NSPredicate(format:"sublist == %@", reference))
            privateDatabase.perform(query, inZoneWith: nil) { (results: [CKRecord]?, error: Error?) in
                if let items = results {
                    self.detailItems = items
                    DispatchQueue.main.async(execute: {
                        self.detailItemsTableView.reloadData()
                        //self.refresh.endRefreshing()
                    })
                }
            }
        }
        
        addItemBtn.tintColor = UIColor.flatOrangeDark
        detailItemsTableView.addGestureRecognizer(longPressGesture)
    }
    
    @IBAction func addItemWasTapped(_ sender: Any) {
        detailItemWasAdded()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputDetailItems.resignFirstResponder()
        detailItemWasAdded()
        return true
    }
    
    func detailItemWasAdded() {
        if inputDetailItems.text != "" {
            let newDetailList = CKRecord(recordType: "detailItems")
            newDetailList["listName"] = inputDetailItems.text as CKRecordValue?
            
            if let list = self.sublist {
                let reference = CKReference(recordID: list.recordID, action: .deleteSelf)
                newDetailList.setObject(reference, forKey: "sublist")
                let privateDatabase = CKContainer.default().privateCloudDatabase
                
                privateDatabase.save(newDetailList, completionHandler: { (record: CKRecord?, error: Error?) in
                    if error == nil {
                        print("list saved")
                        DispatchQueue.main.async(execute: {
                            self.detailItemsTableView.beginUpdates()
                            self.detailItems.insert(newDetailList, at: 0)
                            let indexPath = IndexPath(row: 0, section: 0)
                            self.detailItemsTableView.insertRows(at: [indexPath], with: .top)
                            self.detailItemsTableView.endUpdates()
                        })
                    } else {
                        print("Error: \(error.debugDescription)")
                    }
                })
            }
        }
        
        inputDetailItems.text = ""
    }
    
    @objc func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        if longPressGesture.state == UIGestureRecognizerState.began {
            performSegue(withIdentifier: DataStructs.toDetailMenu, sender: self)
            Flurry.logEvent("Segued to Detail List Reminders")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == DataStructs.toDetailMenu {
            let touchPoint = longPressGesture.location(in: self.detailItemsTableView)
            if let indexPath = self.detailItemsTableView.indexPathForRow(at: touchPoint) {
                let currentDetailItem = detailItems[indexPath.row]
                let controller = (segue.destination as! PopoverMenuTableViewController)
                controller.currentList = currentDetailItem
            }
        }
    }
}

extension DetailItemsViewController: UITableViewDelegate {
    //add gesture for popover menu
}

extension DetailItemsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let detailCell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        let detailItem = detailItems[indexPath.row]
        
        if let itemName = detailItem["listName"] as? String {
            detailCell.textLabel?.text = itemName
            detailCell.backgroundColor = .clear
            detailCell.textLabel?.textColor = UIColor.flatTeal
            detailCell.textLabel?.font = UIFont(name: "Quicksand-Regular", size: 17)
        }
        
        return detailCell
    }
    
    //add delete func
}
