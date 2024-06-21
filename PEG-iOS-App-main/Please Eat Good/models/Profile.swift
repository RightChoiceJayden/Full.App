//
//  Profile.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/4/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

protocol ProfileInfo {
    var id:String? { get set }
    var firstName:String{ get set }
    var lastName:String { get set }
    var phone:String { get set }
    var profileURL:String { get set }
}

struct Meal:Codable {
    var name:String
}

struct Gallery: Codable, Equatable, Hashable, Identifiable {
    var id:String?
    var name:String = ""
    var photos:[GalleryPhoto] = [
        GalleryPhoto(),
        GalleryPhoto(),
        GalleryPhoto(),
        GalleryPhoto(),
        GalleryPhoto(),
        GalleryPhoto(),
        GalleryPhoto()
    ]
}

struct GalleryPhoto: Codable, Equatable, Hashable, Identifiable {
    var id:String?
    var url:String = ""
}

struct Profile: Codable, Equatable, Hashable {
    var id: String? = ""
    var firstName: String = ""
    var lastName: String = ""
    var phone: String = ""
    var birthday: Timestamp
    var profileURL: String = ""
    var defaultAddress:String? = ""
    var gender:String = ""
    var bio:String? = ""
    var hourlyPrice:Int = 0
    var isOnline:Bool = false
    var accountLink:String? = ""
    var isAccountEnabled:Bool? = false
    var status:String? = ""
    var hideVerificationSuccess:Bool? = false
    var didPurchase:Bool = false
    var updateLocation:Bool = false
    var didConnectBankAccount:Bool = false
    var isScanningBankAccount:Bool = false
    var photos:[GalleryPhoto] = []
    
    enum CodingKeys:String, CodingKey {
        case id = "uid"
        case firstName = "first_name"
        case lastName = "last_name"
        case phone = "phone"
        case birthday = "dob"
        case profileURL = "profileURL"
        case defaultAddress = "defaultAddress"
        case bio = "bio"
        case isOnline = "isOnline"
        case hourlyPrice = "hourlyPrice"
        case gender = "gender"
        case accountLink = "accountLink"
        case isAccountEnabled = "isAccountEnabled"
        case status = "status"
        case hideVerificationSuccess = "hideVerificationSuccess"
        case updateLocation = "update_location"
        case didConnectBankAccount = "didConnectBankAccount"
        case isScanningBankAccount = "isScanningBankAccount"
    }
}



enum ProfileValidation:Error {
    case isEmpty(name:String)
}
