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

class SublistViewController: UIViewController, UITextFieldDelegate {
    
    var sublists = [CKRecord]()
    var masterList: CKRecord?
    var refresh = UIRefreshControl()
    let backgroundColor = UIColor.flatTeal
        /*[UIColor] = [
        UIColor.flatTeal,
        UIColor.flatTeal,
        UIColor.flatMintDark
    ]*/
    
    //var fetchedResultsController: NSFetchedResultsController<DetailList>?
    
    @IBOutlet weak var inputNewItem: UITextField!
    @IBOutlet weak var addItemBtn: UIButton!
    @IBAction func addItemWasTapped(_ sender: Any) {
        sublistWasAdded()
    }
    
    @IBOutlet weak var sublistTableView: UITableView!
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputNewItem.resignFirstResponder()
        sublistWasAdded()
        return true
    }
    
    func sublistWasAdded() {
       
        if inputNewItem.text != "" {
            let newSublist = CKRecord(recordType: "sublists")
            newSublist["sublistName"] = inputNewItem.text as CKRecordValue?
            
            if let list = self.masterList {
                let reference = CKReference(recordID: list.recordID, action: .deleteSelf)
                newSublist.setObject(reference, forKey: "masterList")
                
                let privateDatabase = CKContainer.default().privateCloudDatabase
                
                privateDatabase.save(newSublist, completionHandler: { (record: CKRecord?, error: Error?) in
                    if error == nil {
                        print("list saved")
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        sublistTableView.backgroundColor = .clear
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
        
        self.inputNewItem.delegate = self
        addItemBtn.tintColor = UIColor.flatOrangeDark
        let navBar = self.navigationController?.navigationBar
        
        navBar?.tintColor = backgroundColor
        navBar?.barTintColor = .white
        
        //navBar?.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navBar?.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name:"Quicksand-Bold", size: 18)!, .foregroundColor: backgroundColor]
    }
    
    @IBAction func addRemindersWasTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "PresentFromSublist", sender: self)
    }
    //if edit button re-added
    /*override func setEditing(_ editing: Bool, animated: Bool) {
     super.setEditing(editing, animated: animated)
     
     if editing {
     detailTableView.setEditing(true, animated: true)
     } else {
     detailTableView.setEditing(false, animated: true)
     }
     }*/
}

extension SublistViewController: UITableViewDelegate {
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
        
        if let sublistName = sublist["sublistName"] as? String {
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetailItems", sender: self)
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
    
    //configure this later
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailItems" {
            if let indexPath = self.sublistTableView.indexPathForSelectedRow {
                let currentSublist = sublists[indexPath.row]
                let controller = (segue.destination as! DetailItemsViewController)
                controller.sublist = currentSublist
            }
        }
    }
    
    /*func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "PresentFromSublist", sender: self)
    }*/
 
 
}
