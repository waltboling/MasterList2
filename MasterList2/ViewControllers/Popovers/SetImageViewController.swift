//
//  SetImageViewController.swift
//  MasterList2
//
//  Created by Jon Boling on 8/14/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import CloudKit
import Flurry_iOS_SDK

class SetImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let privateDatabase = CKContainer.default().privateCloudDatabase
    var currentList: CKRecord?
    let imagePicker = UIImagePickerController()
    let tempURL: URL? = nil
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        if let list = currentList {
            let photo = list["photo"] as! CKAsset
            imageView.image = UIImage(contentsOfFile: photo.fileURL.path)
        }
    }
    
    @IBAction func selectImageBtnTapped(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func takePhotoBtnTapped(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.cameraCaptureMode = .photo
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBtnTapped(_ sender: Any) {
        
        if let list = currentList {
            let photo = imageView.image
            if let asset = createAsset(from: UIImageJPEGRepresentation(photo!, 1.0)!) {
                list["photo"] = asset as CKRecordValue
            }
           /* let imageURL = SetImageViewController.getImageURL()
            let imageAsset = CKAsset(fileURL: imageURL)
            list["photo"] = imageAsset*/
            
            /*do {
                let data = UIImagePNGRepresentation(imageView.image!)!
                try data.write(to: tempURL!)
                let asset = CKAsset(fileURL: tempURL!)
                list["photo"] = asset
            }
            catch {
                print("Error saving photo", error)
            }*/
    
            privateDatabase.save(list, completionHandler: { (record: CKRecord?, error: Error?) in
                if error == nil {
                    print("photo saved!")
                } else {
                    print("Error: \(error.debugDescription)")
                }
            })
        }
        
        Flurry.logEvent("Photo Added")
        dismiss(animated: true, completion: nil)
        
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    class func getImageURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent("image.png")
    }
    
    /*func writeImage() {
        let image = imageView.image
        if let asset = createAsset(from: UIImageJPEGRepresentation(image, 1.0)){
        list["photo"] = asset as CKRecordValue
        }
    }*/
    
    func createAsset(from data: Data) -> CKAsset? {
        var asset: CKAsset? = nil
        let tempStr = ProcessInfo.processInfo.globallyUniqueString
        let fileName = "\(tempStr)_file.bin"
        let baseURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let fileURL = baseURL.appendingPathComponent(fileName, isDirectory: false)
        
        do {
            try data.write(to: fileURL, options: .atomicWrite)
            asset = CKAsset(fileURL: fileURL)
            
        } catch {
            print("error creating asset: \(error)")
        }
        return asset
    }
    

}
