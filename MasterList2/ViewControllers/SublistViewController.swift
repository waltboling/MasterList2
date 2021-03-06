//
//  DetailViewController.swift
//  MasterList2
//
//  Created by Jon Boling on 8/3/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import CloudKit
import ChameleonFramework
import Flurry_iOS_SDK

class SublistViewController: UIViewController, UITextFieldDelegate {
    
    var sublists = [CKRecord]()
    var masterList: CKRecord?
    var refresh = UIRefreshControl()
    let backgroundColor = UIColor.flatTeal
    var longPressGesture = UIGestureRecognizer()
    
    //IB Outlets
    @IBOutlet weak var inputNewItem: UITextField!
    @IBOutlet weak var addItemBtn: UIButton!
    @IBOutlet weak var sublistTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVisual()
        self.inputNewItem.delegate = self
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        
        if let masterList = masterList {
            self.navigationItem.title = masterList["listName"] as? String
            let privateDatabase = CKContainer.default().privateCloudDatabase
            let reference = CKReference(recordID: masterList.recordID, action: .deleteSelf)
            let query = CKQuery(recordType: "sublists", predicate: NSPredicate(format:"masterList == %@", reference))
            
            privateDatabase.perform(query, inZoneWith: nil) { (results: [CKRecord]?, error: Error?) in
                if let items = results {
                    self.sublists = items
                    DispatchQueue.main.async(execute: {
                        self.sublistTableView.reloadData()
                        self.refresh.endRefreshing()
                    })
                }
            }
        }
        
        sublistTableView.addGestureRecognizer(longPressGesture)
        
    }
    
    @IBAction func addItemWasTapped(_ sender: Any) {
        sublistWasAdded()
    }
    
    func sublistWasAdded() {
        if inputNewItem.text != "" {
            let newSublist = CKRecord(recordType: "sublists")
            newSublist["listName"] = inputNewItem.text as CKRecordValue?
            
            if let list = self.masterList {
                let reference = CKReference(recordID: list.recordID, action: .deleteSelf)
                newSublist.setObject(reference, forKey: "masterList")
                let privateDatabase = CKContainer.default().privateCloudDatabase
                
                privateDatabase.save(newSublist, completionHandler: { (record: CKRecord?, error: Error?) in
                    if error == nil {
                        print("sublistlist saved")
                        DispatchQueue.main.async(execute: {
                            self.sublistTableView.beginUpdates()
                            self.sublists.insert(newSublist, at: 0)
                            let indexPath = IndexPath(row: 0, section: 0)
                            self.sublistTableView.insertRows(at: [indexPath], with: .top)
                            self.sublistTableView.endUpdates()
                        })
                    } else {
                        print("Error: \(error.debugDescription)")
                    }
                })
            }
        }
    
        inputNewItem.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputNewItem.resignFirstResponder()
        sublistWasAdded()
        return true
    }
    
    func configureVisual() {
        //background
        view.backgroundColor = .white
        sublistTableView.backgroundColor = .clear
        
        //navigation bar
        let navBar = self.navigationController?.navigationBar
        navBar?.tintColor = backgroundColor
        navBar?.barTintColor = .white
        navBar?.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name:"Quicksand-Bold", size: 18)!, .foregroundColor: backgroundColor]
        
         addItemBtn.tintColor = UIColor.flatOrangeDark
    }
    
    //handle segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == DataStructs.toDetailList {
            if let indexPath = self.sublistTableView.indexPathForSelectedRow {
                let currentSublist = sublists[indexPath.row]
                let controller = (segue.destination as! DetailItemsViewController)
                controller.sublist = currentSublist
            }
        } else if segue.identifier == DataStructs.toSubMenu {
            let touchPoint = longPressGesture.location(in: self.sublistTableView)
            if let indexPath = self.sublistTableView.indexPathForRow(at: touchPoint) {
                let currentSublist = sublists[indexPath.row]
                let controller = (segue.destination as! PopoverMenuTableViewController)
                controller.currentList = currentSublist
            }
        }
    }
    
    @objc func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        if longPressGesture.state == UIGestureRecognizerState.began {
            performSegue(withIdentifier: DataStructs.toSubMenu, sender: self)
            Flurry.logEvent("Segued to Sublist Reminders")
        }
    }
}

extension SublistViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: DataStructs.toDetailList, sender: self)
        Flurry.logEvent("Segued to DetailList")
    }
}

extension SublistViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sublists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sublistCell = tableView.dequeueReusableCell(withIdentifier: DataStructs.sublistCell, for: indexPath)
        let sublist = sublists[indexPath.row]
        
        if let sublistName = sublist["listName"] as? String {
            
            sublistCell.textLabel?.text = sublistName
            sublistCell.backgroundColor = .clear
            sublistCell.textLabel?.textColor = UIColor.flatTeal
            sublistCell.textLabel?.font = UIFont(name: "Quicksand-Regular", size: 17)
        }
        return sublistCell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    
    
    //deleting a cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selectedRecordID = sublists[indexPath.row].recordID
            
            let privateDatabase = CKContainer.default().privateCloudDatabase
            
            privateDatabase.delete(withRecordID: selectedRecordID) { (recordID, error) -> Void in
                if error != nil {
                    print(error!)
                } else {
                    OperationQueue.main.addOperation({ () -> Void in
                        self.sublists.remove(at: indexPath.row)
                        self.sublistTableView.reloadData()
                    })
                }
            }
        }
    }
}
