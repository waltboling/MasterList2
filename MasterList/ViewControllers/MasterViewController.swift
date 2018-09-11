//
//  ViewController.swift
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

class MasterViewController: UIViewController, UITextFieldDelegate, GADBannerViewDelegate {
    
    
    
    fileprivate var collapseDetailViewController = true
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
    var bannerView: GADBannerView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureVisual()
        configureAds()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitViewController?.delegate = self
        self.inputNewList.delegate = self
        
        //check for internet connection
        if ConnectionManager.shared.testConnection() {
            if ConnectionManager.shared.testCloudKit() {
                refresh = UIRefreshControl()
                refresh.attributedTitle = NSAttributedString(string: "Pull to load Lists")
                refresh.addTarget(self, action: #selector(MasterViewController.loadLists), for: .valueChanged)
                
                masterTableView.addSubview(refresh)
                
                self.loadLists()
                
            } else {
                showAlert(title: "iCloud Not Working", message: "Enable iCloud to Continue")
            }
            
        } else {
            showAlert(title: "No Internet Connection Detected", message: "Connect to Internet or try again later")
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) {(action) in self.openSettings()}
        
        alertController.addAction(okAction)
        alertController.addAction(settingsAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func openSettings() {
        guard let settingsURL = URL(string: UIApplicationOpenSettingsURLString) else {
            print("failed")
            return
        }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, completionHandler:{(success) in
                print ("SettingsOpened: \(success)")
            })
        }
    }
    
    //for AdMob banner
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
        } else {
            inputNewList.shake()
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

