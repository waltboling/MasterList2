//
//  File.swift
//  MasterList2
//
//  Created by Jon Boling on 8/4/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import SystemConfiguration

enum LoginResults {
    case userNotExist
    case userExists
    case passwordFails
    case loginSucceeds
}

struct User {
    var username: String = ""
    var password: String = ""
}

class UserData {
    static let shared = UserData()
    
    var users: [User] = []
    var privateDatabase: CKDatabase = CKContainer.default().privateCloudDatabase
    
    private init() {
    }
    
    func loadUsers() {
        
        users = []
        
        print ("Load Cloudkit Users")
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "User", predicate: predicate)
        privateDatabase.perform(query, inZoneWith: nil) {(records: [CKRecord]?, error: Error?) in
            if error == nil {
                guard let records = records else
                {
                    print ("No Records")
                    return
                }
                for record in records {
                    let username = record.object(forKey: "username") as! String
                    let password = record.object(forKey: "password") as! String
                    print ("\(String(describing: username)), \(String(describing: password))")
                    self.addUser(username: username, password: password)
                }
            } else {
                print ("There Was an Error with CloudKit")
                print (error?.localizedDescription ?? "Error")
            }
        }
    }
    
    func saveUsers() {
        
        let record = CKRecord(recordType: "User")
        
        for user in users {
            
            record.setObject(user.username as CKRecordValue? , forKey: "username")
            record.setObject(user.password as CKRecordValue? , forKey: "password")
            privateDatabase.save(record) { (savedRecord: CKRecord?, error: Error?) -> Void in
                if error == nil {
                    print ("saved")
                }
            }
        }
    }
    
    func addUser(username: String, password: String) {
        let tempUser = User(username: username.lowercased(), password: password)
        users.append(tempUser)
    }
    
    func testCloudKit() -> Bool {
        if FileManager.default.ubiquityIdentityToken != nil {
            return true
        } else {
            return false
        }
    }
    
    func checkUser(username: String) -> LoginResults {
        if users.contains(where: {$0.username == username.lowercased()}) {
            return .userExists
        } else {
            return .userNotExist
        }
    }
    
    func login(username: String, password: String)->LoginResults {
        if let user = users.first(where: {$0.username == username.lowercased()}) {
            if user.password == password {
                return .loginSucceeds
            }
        }
        return .passwordFails
    }
    
    func testConnection() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0,0,0,0,0,0,0,0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                zeroSockAddress in SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
    
    //Working for Cellular and WiFi
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let isConnected = (isReachable && !needsConnection)
        
        return isConnected
    }
    
}

