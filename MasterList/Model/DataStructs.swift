//
//  DataStructs.swift
//  MasterList2
//
//  Created by Jon Boling on 8/3/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import Foundation

public struct DataStructs {
    
    static let createMasterPopover = "CreateMasterListController"
    //static let toDetailList = "ShowDetail"
    static let masterEntity = "MasterList"
    static let masterTitle = "masterTitle"
    static let masterCell = "masterCell"
    static let masterCache = "Master Cache"
    
    //for detail list
    static let detailEntity = "DetailList"
    static let detailTitle = "detailTitle"
    static let parentTitle = "parentTitle"
    static let sublistCell = "detailCell"
    //static let detailCache = "Detail Cache"
    
    //MARK: Segues
    static let toSublist = "ShowSublist"
    static let toDetailList = "ShowDetailList"
    static let toSubMenu = "ShowFromSublist"
    static let toDetailMenu = "ShowFromDetailList"
    static let toPhotoPicker = "PresentPhotoPicker"
    static let toDeadline = "PresentDeadline"
    static let toLocation = "PresentLocation"
    static let toNotes = "PresentNotes"
    
}
