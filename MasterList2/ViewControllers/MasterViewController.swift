//
//  ViewController.swift
//  MasterList2
//
//  Created by Jon Boling on 8/3/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//
import UIKit
import CloudKit
import ChameleonFramework
import Flurry_iOS_SDK

class MasterViewController: UIViewController, UITextFieldDelegate {
    
    fileprivate var collapseDetailViewController = true
    //private let mainStoryboard = "Main"
    var masterLists = [CKRecord]()
    var refresh = UIRefreshControl()
    var detailController: SublistViewController?
   
    let colors: [UIColor] = [
        UIColor.flatTeal,
        UIColor.flatTeal,
        UIColor.flatMintDark
    ]
    
    //IB Outlets
    @IBOutlet weak var masterTableView: UITableView!
    @IBOutlet weak var logOutBtn: UIBarButtonItem!
    @IBOutlet weak var inputNewList: UITextField!
    @IBOutlet weak var addListBtn: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureVisual()
       
        /*DispatchQueue.main.async(execute: {
         self.loadLists()
         })*/
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitViewController?.delegate = self
        self.inputNewList.delegate = self
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to load Lists")
        refresh.addTarget(self, action: #selector(MasterViewController.loadLists), for: .valueChanged)
        
        masterTableView.addSubview(refresh)
        
        self.loadLists()
    }
    
    //IB funcs
    @IBAction func addListWasTapped(_ sender: Any) {
        masterListWasEntered()
    }
    
    @IBAction func logOutWasTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func configureVisual() {
        //background
        masterTableView.backgroundColor = .clear
        view.backgroundColor = .white
        
        //navigation bar
        let navBar = self.navigationController?.navigationBar
        navBar?.tintColor = .white
        navBar?.barTintColor = GradientColor(.topToBottom, frame: (view.frame), colors: colors)
        navBar?.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name:"Quicksand-Bold", size: 18)!, .foregroundColor: UIColor.white]
        self.navigationItem.title = "Master Lists"
        
         addListBtn.tintColor = UIColor.flatOrangeDark
    }
    
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputNewList.resignFirstResponder()
        masterListWasEntered()
        return true
    }
    
    func masterListWasEntered() {
        if inputNewList.text != "" {
            let newMaster = CKRecord(recordType: "masterLists")
            newMaster["listName"] = inputNewList.text as CKRecordValue?
            let privateDatabase = CKContainer.default().privateCloudDatabase
            
            privateDatabase.save(newMaster, completionHandler: {(record: CKRecord?, error: Error?) in
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
        if segue.identifier == DataStructs.toSublist {
            if let indexPath = self.masterTableView.indexPathForSelectedRow {
                let currentMasterList = masterLists[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! SublistViewController
                controller.masterList = currentMasterList
            }
        }
    }

    @objc func loadLists() {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        let query = CKQuery(recordType: "MasterLists", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        privateDatabase.perform(query, inZoneWith: nil) { (results: [CKRecord]?, error: Error?) in
            if let lists = results {
                self.masterLists = lists
                DispatchQueue.main.async(execute: {
                    self.masterTableView.reloadData()
                    self.refresh.endRefreshing()
                })
            }
        }
    }
}

extension MasterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: DataStructs.toSublist, sender: self)
    }
}

extension MasterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return masterLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let masterCell = tableView.dequeueReusableCell(withIdentifier: DataStructs.masterCell, for: indexPath)
        let masterList = masterLists[indexPath.row]
        
        if let masterListName = masterList["listName"] as? String {
            masterCell.textLabel?.text = masterListName
        }
        
        masterCell.backgroundColor = .clear
        masterCell.textLabel?.font = UIFont(name:"Quicksand-Regular", size: 20)
        masterCell.textLabel?.textColor = GradientColor(.topToBottom, frame: view.frame, colors: colors)
        
        return masterCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selectedRecordID = masterLists[indexPath.row].recordID
            let privateDatabase = CKContainer.default().privateCloudDatabase
            
            privateDatabase.delete(withRecordID: selectedRecordID) { (recordID, error) -> Void in
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


