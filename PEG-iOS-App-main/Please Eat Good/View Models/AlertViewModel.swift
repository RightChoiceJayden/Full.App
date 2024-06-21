//
//  AlertViewModel.swift
//  iTrayne_Trainer
//
//  Created by Christopher on 8/10/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation
import SwiftUI

class AlertViewModel: ObservableObject {
    @Published var title:String = ""
    @Published var message:String = ""
    @Published var showAlert:Bool = false
    @Published var buttonText:String = "Okay"
    
    func showAlertView(title:String, message:String) {
        self.title = title
        self.message = message
        self.showAlert = true
    }
    
    func alertView() -> Alert {
        Alert(title: Text(self.title), message: Text(self.message), dismissButton: .cancel(Text(self.buttonText)))
    }
    
}
