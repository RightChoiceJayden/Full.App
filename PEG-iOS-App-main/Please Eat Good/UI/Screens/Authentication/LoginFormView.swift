//
//  ContentView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 2/5/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
import Firebase

struct LoginForm: View {
    @State private var email:String = ""
    @State private var password:String = ""
    @EnvironmentObject var signIn:SessionStore
    @State private var loading:Bool = false
    @State var alertViewModel:AlertViewModel = AlertViewModel()
    
    var body: some View {
        NavigationView {
            
            ZStack(alignment:.topLeading) {
                ScrollView {
                    VStack(spacing:0) {
                        self.headerImage()
                        self.formFields()
                        Spacer().frame(height:20)
                        self.loginBtn()
                        Spacer().frame(height:30)
                        self.forgetPasswordLinks()
                        Spacer().frame(height:30)
                        NavigationLink(destination:SignupFormView(), label: {
                           Text("Create a new account")
                            .foregroundColor(Color("textColor"))
                        })
                        Spacer()
                    }
                }.edgesIgnoringSafeArea(.all)
                
            }
            .navigationBarHidden(true)
            .navigationBarTitle("", displayMode: .inline)
            }
            
        }
    
    func headerImage() -> some View {
        VStack(spacing:0) {
            Rectangle()
                .foregroundColor(Color("primaryColor"))
                .frame(minWidth:0, maxWidth: .infinity, minHeight:25)
            Image("header")
                .resizable()
                .aspectRatio(contentMode: ContentMode.fill)
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    func forgetPasswordLinks() -> some View {
        NavigationLink(destination:ForgotPasswordView(), label: {
           return Text("Forgot your password?")
           .foregroundColor(Color("primaryColor"))
        })
    }
    
    func formFields() -> some View {
        Group {
            TextInputView(label: .constant("EMAIL ADDRESS"), placeholder: .constant("youremail@here.com"), value: $email)
            TextInputView(label: .constant("PASSWORD"), placeholder: .constant("Enter password"), value: $password, isSecure:true)
            Divider()
        }
    }
    
    func loginBtn() -> some View {
        Button(action:{
            
            self.loading = true
            self.signIn.signInUser(email: self.email, password: self.password,
            success: { auth in
                self.loading = false
            }, error:{ error in
                print(error.localizedDescription)
                self.alertViewModel.showAlertView(title: "Sorry", message: error.localizedDescription)
                self.loading = false
            })
            
        }, label: {
            Text(self.loading ? "Logging in..." : "Log In")
                .font(.system(size: 20))
                .fontWeight(.semibold)
                .foregroundColor(.black).frame(minWidth:0, maxWidth: .infinity, minHeight: 60)
        })
        .alert(isPresented: self.$alertViewModel.showAlert) {
            self.alertViewModel.alertView()
        }
        .opacity(self.loading ? 0.4 : 1)
        .background(Color("primaryColor"))
        .cornerRadius(50)
        .padding(.horizontal, 20)
        
    }


}



//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//         LoginForm()
//    }
//}

