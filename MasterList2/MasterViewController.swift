//
//  ViewController.swift
//  MasterList2
//
//  Created by Jon Boling on 8/3/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//
import UIKit
import CloudKit
//import ChameleonFramework

class MasterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    fileprivate var collapseDetailViewController = true
    var masterLists = [CKRecord]()
    var refresh = UIRefreshControl()
    var detailController: SublistViewController?
    private let mainStoryboard = "Main"
    /*let backgroundColor: [UIColor] = [
        UIColor.flatTeal,
        UIColor.flatMintDark
    ]*/
    
    @IBOutlet weak var masterTableView: UITableView!
    
    @IBOutlet weak var inputNewList: UITextField!
    
    @IBOutlet weak var addListBtn: UIButton!
    
    
    @IBAction func addListWasTapped(_ sender: Any) {
        masterListWasEntered()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitViewController?.delegate = self
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to load Lists")
        refresh.addTarget(self, action: #selector(MasterViewController.loadLists), for: .valueChanged)
        masterTableView.addSubview(refresh)
        
        /*NotificationCenter.default.addObserver(self, selector: #selector(loadLists), name: NSNotification.Name(rawValue: "load"), object: nil)*/
        
        self.loadLists()
        
    }
   /* override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //tableView.backgroundColor = GradientColor(.topToBottom, frame: view.frame, colors: backgroundColor)
        
        /*DispatchQueue.main.async(execute: {
         self.loadLists()
         })*/
        
    }*/
    
    func masterListWasEntered() {
        if inputNewList.text != "" {
            let newMaster = CKRecord(recordType: "masterLists")
            newMaster["listName"] = inputNewList.text as CKRecordValue?
            let publicDatabase = CKContainer.default().publicCloudDatabase
            
            publicDatabase.save(newMaster, completionHandler: {(record: CKRecord?, error: Error?) in
                if error == nil {
                    print("list saved")
                    DispatchQueue.main.async(execute: {
                        self.masterTableView.beginUpdates()
                        self.masterLists.insert(newMaster, at: 0)
                        let indexPath = IndexPath(row: 0, section: 0)
                        self.masterTableView.insertRows(at: [indexPath], with: .top)
                        self.masterTableView.endUpdates()
                    })
                } else {
                    print("Error: \(error.debugDescription)")
                }
            })
        }
        
        inputNewList.text = ""
    }
    
  
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == DataStructs.toDetailList {
            if let indexPath = self.masterTableView.indexPathForSelectedRow {
                let currentMasterList = masterLists[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! SublistViewController
                controller.masterList = currentMasterList
            }
        }
    }
    
    
    
    @objc func loadLists() {
        print("in loadLists")
        let publicDatabase = CKContainer.default().publicCloudDatabase
        let query = CKQuery(recordType: "MasterLists", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        publicDatabase.perform(query, inZoneWith: nil) { (results: [CKRecord]?, error: Error?) in
            if let lists = results {
                self.masterLists = lists
                print("\(self.masterLists.count) masterLists in loadLists")
                DispatchQueue.main.async(execute: {
                    self.masterTableView.reloadData()
                    self.refresh.endRefreshing()
                })
            }
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("\(masterLists.count) records")
        return masterLists.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let masterCell = tableView.dequeueReusableCell(withIdentifier: DataStructs.masterCell, for: indexPath)
        let masterList = masterLists[indexPath.row]
        
        if let masterListName = masterList["listName"] as? String {
            masterCell.textLabel?.text = masterListName
        }
        
        masterCell.backgroundColor = .clear
       // masterCell.textLabel?.font = UIFont(name:"Dense-Regular", size: 26)
        
        return masterCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selectedRecordID = masterLists[indexPath.row].recordID
            
            let publicDatabase = CKContainer.default().publicCloudDatabase
            
            publicDatabase.delete(withRecordID: selectedRecordID) { (recordID, error) -> Void in
                if error != nil {
                    print(error!)
                } else {
                    OperationQueue.main.addOperation({ () -> Void in
                        self.masterLists.remove(at: indexPath.row)
                        self.masterTableView.reloadData()
                    })
                }
            }
        }
    }
    
    
}

extension MasterViewController: UISplitViewControllerDelegate {
    
    //so that masterview comes up instead of detail on app load
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return collapseDetailViewController
    }
}


