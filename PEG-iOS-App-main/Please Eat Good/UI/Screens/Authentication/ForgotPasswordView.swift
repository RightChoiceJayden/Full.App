//
//  ForgotPasswordView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 2/24/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    @State private var email:String = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var session = SessionStore()
    @State private var didSendResetEmail:Bool = false
    @ObservedObject var alertViewModel:AlertViewModel = AlertViewModel()
    @State var loading:Bool = false
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
            VStack {
                VStack {
                    Divider()
                    Spacer().frame(height:20)
                    Text("Enter your email and we'll send you a link to reset your password.")
                        .font(.headline)
                        .foregroundColor(Color("textColor"))
                         .frame(minWidth:0, maxWidth: .infinity)
                        .multilineTextAlignment(.leading)
                    Spacer().frame(height:10)
                    VStack {
                        TextInputView(label: .constant("EMAIL ADDRESS"), placeholder: .constant("Enter email address"), value: $email)
                    }

                    Spacer().frame(height:20)
                    Button(action : {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        return Text("Already have account? Log in.")
                        .foregroundColor(Color("primaryColor"))
                    
                    })
                }
                Spacer()
                
                ZStack {
                    VStack(spacing:0) {
                        Spacer()
                        Divider()
                        ZStack {
                            Rectangle()
                                .foregroundColor(Color("backgroundColor"))
                            self.sendBtn()
                        }.frame(height:80)
                    }
                }
                
                
            }.navigationTitle("Reset password")
        }
    }
    
    func sendBtn() -> some View {
        Button(action:{
            
            guard !self.email.isEmpty else {
                self.alertViewModel.showAlertView(title: "Sorry", message: "Email is required")
                return
            }
            self.loading = true
            self.session.resetPassword(email: self.email) { error in
                if let error = error {
                    self.alertViewModel.showAlertView(title: "Sorry", message: error.localizedDescription)
                    self.loading = false
                }else{
                    self.didSendResetEmail = true
                    self.loading = false
                }
            }
        }, label: {
            Text(self.loading ? "Sending..." : "Send password reset link" ).fontWeight(.semibold)
                .foregroundColor(.black).frame(minWidth:0, maxWidth: .infinity, minHeight: 45)
        })
        .background(Color("primaryColor"))
        .cornerRadius(4)
        .padding(.horizontal)
        .disabled(self.loading)
        .opacity(self.loading ? 0.3 : 1)
        .alert(isPresented:$alertViewModel.showAlert){
            self.alertViewModel.alertView()
        }
    }
    
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
