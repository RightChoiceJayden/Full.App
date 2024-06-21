//
//  SignupFormView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 2/7/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
import Firebase

struct SignupFormView: View {
    
    @State private var fullname:String = ""
    @State private var email:String = ""
    @State private var password:String = ""
    @State private var passwordConfirm:String = ""
    
    @State private var showingSignupAlert:Bool = false
    @State private var signupAlertErrorMessage:String = ""
    @State private var signupAlertTitle:String = ""
    
    @State private var signupComplete:Bool = false
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var sessionStore:SessionStore
    @State private var loading:Bool = false
    @ObservedObject var alertViewModel:AlertViewModel = AlertViewModel()
    
    private func doesPasswordMatch() -> Bool {
        return self.password == self.passwordConfirm
    }
    
    var body: some View {
        ZStack(alignment:.topLeading) {
            Color("backgroundColor")
            VStack {
                
                TextInputView(label: .constant("EMAIL ADDRESS"), placeholder: .constant("Enter email address"), value: $email)
                
                TextInputView(label: .constant("PASSWORD"), placeholder: .constant("Enter password"), value: $password, isSecure:true)
                
                TextInputView(label: .constant("CONFIRM PASSWORD"), placeholder: .constant("Enter password again"), value: $passwordConfirm, isSecure:true)
                
                
                    Spacer().frame(height:20)
                
                    Button(action : {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Already have account? Log in.").foregroundColor(Color("primaryColor"))
                    
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
            
        }.navigationTitle("Create an account")
        }
    
    func sendBtn() -> some View {
        Button(action:{
            
                guard self.doesPasswordMatch() else {
                    self.alertViewModel.showAlertView(title: "Password mismatch", message: "Password and password confirm must match")
                    return
                }
                
                self.loading = true
                
                #if TrainerApp
                self.sessionStore.noTenantSignUp(email: self.email, password: self.password,err:{ error in
                    self.alertViewModel.showAlertView(title: "Sorry", message: error.localizedDescription)
                    self.loading = false
                })
                #else
                
                self.sessionStore.noTenantSignUp(email: self.email, password: self.password,err:{ error in
                    self.alertViewModel.showAlertView(title: "Sorry", message: error.localizedDescription)
                    self.loading = false
                })
                
//                    self.sessionStore.signupCustomer(email: self.email, password: self.password,err:{ error in
//
//                        self.alertViewModel.showAlertView(title: "Sorry", message: error.localizedDescription)
//
//                        self.loading = false
//                    })
                #endif

            }, label: {
                Text(self.loading ? "Creating Account..." : "Create Account").fontWeight(.semibold)
                    .foregroundColor(.black).frame(minWidth:0, maxWidth: .infinity, minHeight: 45)
            })
            .alert(isPresented: $alertViewModel.showAlert) {
                self.alertViewModel.alertView()
            }
        .background(Color("primaryColor"))
        .cornerRadius(4)
        .padding(.horizontal)
        .disabled(self.loading)
        .opacity(self.loading ? 0.3 : 1)
    }
    
    }


//struct SignupFormView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignupFormView().environmentObject(SessionStore())
//    }
//}
