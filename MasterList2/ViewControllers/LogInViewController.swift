//
//  LogInViewController.swift
//  MasterList2
//
//  Created by Jon Boling on 8/4/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import ChameleonFramework

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    let colors: [UIColor] = [
        UIColor.flatTeal,
        UIColor.flatTeal,
        UIColor.flatMintDark
    ]
    
    //IB Outlets
    
    @IBOutlet weak var logInBtn: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    configureVisuals()
    usernameTextField.delegate = self
    passwordTextField.delegate = self
    }
    
    
    @IBAction func logInWasTapped(_ sender: Any) {
        //userDidLogIn()
    }

    func configureVisuals() {
        view.backgroundColor = GradientColor(.topToBottom, frame: view.frame, colors: colors)
        logInBtn.tintColor = UIColor.flatOrange
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    func userDidLogIn() {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        if UserData.shared.checkUser(username: username) == LoginResults.userNotExist {
            UserData.shared.addUser(username: username, password: password)
            UserData.shared.saveUsers()
            //loginSucceeded(username: username, password: password)
            performSegue(withIdentifier: "toMaster", sender: self)
        } else {
            if UserData.shared.login(username: username, password: password) == .loginSucceeds {
               // loginSucceeded(username: username, password: password)
                performSegue(withIdentifier: "toMaster", sender: self)
            } else { // Login Failed
                loginFailed()
            }
        }
    }
    
   /* func loginSucceeded(username: String, password: String) {
        print ("Login Succeeded")
        OurDefaults.shared.saveUserDefaults(username: username, password: password, autoLogin: autoLoginSwitch.isOn, useiCloud: useiCloudSwitch.isOn)
        moveToHomeScreen()
    }*/
    
    func loginFailed() {
        print ("Login Failed")
        let alert = UIAlertController(title: "Login Failed", message: "Your Password is incorrect", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }

}
