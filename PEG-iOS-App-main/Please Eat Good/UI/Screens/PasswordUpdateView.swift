//
//  PasswordUpdateView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/31/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct PasswordUpdateView: View {

    @State private var newPassword:String = ""
    @State private var confirmNewPassword:String = ""
    @ObservedObject var password = SessionStore.UpdatePassword()
    @State var success:Bool = false
    @State var error:Bool = false
    @State var passwordDontMatch:Bool = false
    @State var showAlert:Bool = false
    @State var emptyField:Bool = false
    @State var isLoading:Bool = false
    
    var body: some View {
    ZStack {
              Color("backgroundColor")
              VStack {
                  VStack {
                      
                    Divider()
                    
                    TextInputView(label: .constant("NEW PASSWORD"), placeholder: .constant("Enter new password"), value: $newPassword, isSecure: true)
                    
                    TextInputView(label: .constant("CONFIRM NEW PASSWORD"), placeholder: .constant("Enter new password again"), value: $confirmNewPassword, isSecure: true)

                      
                      Spacer().frame(height:30)
                      
                      
                    
                      Spacer().frame(height:50)

                      
                  }
                  Spacer()
              }
              
        ZStack {
            VStack(spacing:0) {
                Spacer()
                Divider()
                ZStack {
                    Rectangle()
                        .foregroundColor(Color("backgroundColor"))
                    self.sendButton()
                }.frame(height:80)
            }
        }
        
          }
        .navigationBarTitle("Update password")
    }
    
    func sendButton() -> some View {
        Button(action:{
          
          self.success = false
          self.showAlert = false
          self.passwordDontMatch = false
          
          if self.newPassword.isEmpty || self.confirmNewPassword.isEmpty {
              self.emptyField = true
              self.showAlert = true
          }else{
              if self.newPassword != self.confirmNewPassword {
                  self.passwordDontMatch = true
                  self.showAlert = true
                  self.emptyField = false
              }else{
                  self.isLoading = true
                  self.emptyField = false
                  self.password.update(password:self.newPassword, success: {
                      self.isLoading = false
                      self.success = true
                      self.showAlert = true
                      
                      self.newPassword = ""
                      self.confirmNewPassword = ""
                      
                  }, error: { error in
                      self.isLoading = false
                      self.success = false
                      self.showAlert = true
                  })
              }

          }

        }, label: {
          Text(self.isLoading ? "Updating..." : "Update").fontWeight(.semibold)
            .foregroundColor(.black).frame(minWidth:0, maxWidth: .infinity, minHeight: 45)
        })
        .background(Color("primaryColor"))
        .cornerRadius(4)
        .padding(.horizontal)
        .disabled(self.isLoading)
        .opacity(self.isLoading ? 0.3 : 1)
          .alert(isPresented:$showAlert) {

              if self.success {
                 return Alert(title: Text("Success"), message: Text("Password Updated"), dismissButton: .cancel(Text("Got it!")))
              }else if self.emptyField {
                   return Alert(title: Text("Error"), message: Text("Complete password and password confirm field"), dismissButton: .cancel(Text("Got it!")))
              }else if self.passwordDontMatch {
                  return Alert(title: Text("Error"), message: Text("Passwords dont match"), dismissButton: .cancel(Text("Got it!")))
              }else{
                  return Alert(title: Text("Error"), message: Text(self.password.HTTPAlertMessage), dismissButton: .cancel(Text("Got it!")))
              }
      
          }
    }
}

struct PasswordUpdateView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordUpdateView()
    }
}
