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

class DetailItemsViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
   
    var sublist: CKRecord?
    var detailItems = [CKRecord]()
    
    @IBOutlet weak var detailItemsTableView: UITableView!
    
    @IBOutlet weak var addItemBtn: UIButton!
    
    @IBAction func addItemWasTapped(_ sender: Any) {
        detailItemWasAdded()
    }
    
    @IBOutlet weak var inputDetailItems: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputDetailItems.delegate = self
        
        if let sublist = sublist {
            self.navigationItem.title = sublist["sublistName"] as? String
            
            let publicDatabase = CKContainer.default().publicCloudDatabase
            let reference = CKReference(recordID: sublist.recordID, action: .deleteSelf)
            let query = CKQuery(recordType: "detailItems", predicate: NSPredicate(format:"sublist == %@", reference))
            publicDatabase.perform(query, inZoneWith: nil) { (results: [CKRecord]?, error: Error?) in
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
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputDetailItems.resignFirstResponder()
        detailItemWasAdded()
        return true
    }
    func detailItemWasAdded() {
        if inputDetailItems.text != "" {
            let newDetailItem = CKRecord(recordType: "detailItems")
            newDetailItem["itemName"] = inputDetailItems.text as CKRecordValue?
            
            if let list = self.sublist {
                let reference = CKReference(recordID: list.recordID, action: .deleteSelf)
                newDetailItem.setObject(reference, forKey: "sublist")
                
                let publicDatabase = CKContainer.default().publicCloudDatabase
                
                publicDatabase.save(newDetailItem, completionHandler: { (record: CKRecord?, error: Error?) in
                    if error == nil {
                        print("list saved")
                        DispatchQueue.main.async(execute: {
                            self.detailItemsTableView.beginUpdates()
                            self.detailItems.insert(newDetailItem, at: 0)
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

    //MARK: Table View Data Source / Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let detailCell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        let detailItem = detailItems[indexPath.row]
        
        if let itemName = detailItem["itemName"] as? String {
            detailCell.textLabel?.text = itemName
            detailCell.backgroundColor = .clear
            detailCell.textLabel?.textColor = UIColor.flatTeal
            detailCell.textLabel?.font = UIFont(name: "Quicksand-Regular", size: 17)
        }
        
        return detailCell
    }
    
}
