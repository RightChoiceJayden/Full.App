//
//  ProfileViewModel.swift
//  iTrayne Client
//
//  Created by Christopher on 9/19/20.
//  Copyright © 2020 iTrayne LLC. All rights reserved.
//

import Foundation
import Combine

class ProfileViewModel:ObservableObject {
    // Read
    @Published var profile:Profile? = nil
    @Published var profileID:String = ""
    private var cancellableSet: Set<AnyCancellable> = []
    //private var profileService:AppService<Profile> = AppService<Profile>(collectionName: "Profiles")
    
    init() {
       
    }
    
    func onAppear() {
        //self.profileService.listenToDocument(documentID: self.profileID)
        //self.profileService.$documentData
//             .receive(on: RunLoop.main)
//             .assign(to: \.profile, on: self)
//             .store(in: &cancellableSet)
    }
}


