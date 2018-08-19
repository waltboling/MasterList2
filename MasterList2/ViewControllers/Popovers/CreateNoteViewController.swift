//
//  CreateNoteViewController.swift
//  MasterList2
//
//  Created by Jon Boling on 8/14/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import CloudKit
import Flurry_iOS_SDK


class CreateNoteViewController: UIViewController {
    
    let privateDatabase = CKContainer.default().privateCloudDatabase
    var currentList: CKRecord?
    
    @IBOutlet weak var notesTextView: UITextView! {
        didSet {
            notesTextView.addDoneCancelToolbar()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let list = currentList {
            self.navigationItem.title = list.recordID.recordName
        }
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBtnTapped(_ sender: Any) {
        if notesTextView.text != nil {
            if let list = currentList {
                list["note"] = notesTextView.text as CKRecordValue?
                
                privateDatabase.save(list, completionHandler: { (record: CKRecord?, error: Error?) in
                    if error == nil {
                        print("note saved!")
                    } else {
                        print("Error: \(error.debugDescription)")
                    }
                })
            }
        }
        
        Flurry.logEvent("Note Added")
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        if notesTextView.text != nil {
            let newNote = CKRecord(recordType: "notes")
            newNote["content"] = notesTextView.text as CKRecordValue?
            
            if let list = self.currentList {
                let reference = CKReference(recordID: (list.recordID), action: .deleteSelf)
                newNote.setObject(reference, forKey: String(describing: list))
                
                privateDatabase.save(newNote, completionHandler: { (record: CKRecord?, error: Error?) in
                    if error == nil {
                        print("note saved!")
                    } else {
                        print("Error: \(error.debugDescription)")
                    }
                })
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}
