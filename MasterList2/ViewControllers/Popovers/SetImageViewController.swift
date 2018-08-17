//
//  SetImageViewController.swift
//  MasterList2
//
//  Created by Jon Boling on 8/14/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import CloudKit

class SetImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
   
    
    var currentList: CKRecord?
    let imagePicker = UIImagePickerController()
    
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self

        // Do any additional setup after loading the view.
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

}
