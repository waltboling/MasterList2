//
//  DetailViewController.swift
//  MasterList
//
//  Created by Jon Boling on 8/3/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import CloudKit
import ChameleonFramework
import Flurry_iOS_SDK
import GoogleMobileAds

class SublistViewController: UIViewController, UITextFieldDelegate, GADBannerViewDelegate {
    
    var sublists = [CKRecord]()
    var masterList: CKRecord?
    var refresh = UIRefreshControl()
    let backgroundColor = UIColor.flatTeal
    var longPressGesture = UIGestureRecognizer()
    var bannerView: GADBannerView!
    
    //IB Outlets
    @IBOutlet weak var inputNewItem: UITextField!
    @IBOutlet weak var addItemBtn: UIButton!
    @IBOutlet weak var sublistTableView: UITableView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        configureVisual()
        configureAds()
        loadLists()
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to load Lists")
        refresh.addTarget(self, action: #selector(self.loadLists), for: .valueChanged)
        sublistTableView.addSubview(refresh)
        
        if let indexPath = sublistTableView.indexPathForSelectedRow {
            sublistTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.inputNewItem.delegate = self
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        
        //loadLists()
       
        sublistTableView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func loadLists() {
        if let masterList = masterList {
            self.navigationItem.title = masterList["listName"] as? String
            let privateDatabase = CKContainer.default().privateCloudDatabase
            let reference = CKReference(recordID: masterList.recordID, action: .deleteSelf)
            let query = CKQuery(recordType: "sublists", predicate: NSPredicate(format:"masterList == %@", reference))
            if ConnectionManager.shared.testConnection() {
                if ConnectionManager.shared.testCloudKit() {
                    privateDatabase.perform(query, inZoneWith: nil) { (results: [CKRecord]?, error: Error?) in
                        if let items = results {
                            self.sublists = items
                            DispatchQueue.main.async(execute: {
                                self.sublistTableView.reloadData()
                                self.refresh.endRefreshing()
                            })
                        }
                    }
                } else {
                    showAlert(title: "iCloud Not Working", message: "Enable iCloud to Continue")
                }
            } else {
                showAlert(title: "No Internet Connection Detected", message: "Connect to Internet or try again later")
            }
        }
    }
    
    @IBAction func addItemWasTapped(_ sender: Any) {
        inputNewItem.resignFirstResponder()
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
                        self.showAlert(title: "Unable to save list", message: "Check connection and try again")
                    }
                })
            }
        } else {
            inputNewItem.shake()
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
    
    func configureAds() {
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-3684839275222485/8331042439"
        bannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView.load(request)
        bannerView.delegate = self
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(bannerView)
        self.view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: self.view.safeAreaLayoutGuide,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: self.view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
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
            let touchPoint = longPressGesture.location(in: self.sublistTableView)
            if let indexPath = self.sublistTableView.indexPathForRow(at: touchPoint) {
                if indexPath.row <= sublists.count {
                    performSegue(withIdentifier: DataStructs.toSubMenu, sender: self)
                    Flurry.logEvent("Segued to Sublist Reminders")
                } else {
                    print("there is no row here")
                }
            } else {
                print("cannot find index path")
            }
        }
    }
}

extension SublistViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: DataStructs.toDetailList, sender: self)
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
            let chevronBlue = UIImage(named: "chevronIconColor")
            sublistCell.textLabel?.text = sublistName
            sublistCell.backgroundColor = .clear
            sublistCell.textLabel?.textColor = UIColor.flatTeal
            sublistCell.textLabel?.font = UIFont(name: "Quicksand-Regular", size: 18)
            
            sublistCell.detailTextLabel?.text = ""
            if sublist["photo"] != nil {
                sublistCell.detailTextLabel?.text = "Image | "
            }
            if sublist["deadline"] != nil {
                sublistCell.detailTextLabel?.text! += "Deadline | "
            }
            if sublist["location"] != nil {
                sublistCell.detailTextLabel?.text! += "Location | "
            }
            if sublist["note"] != nil {
                sublistCell.detailTextLabel?.text! += "Note"
            }
            sublistCell.accessoryView = UIImageView(image: chevronBlue)
            sublistCell.accessoryView?.contentMode = .scaleAspectFit
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
