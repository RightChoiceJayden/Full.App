//
//  SessionStore.swift
//  iTrayne_Trainer
//
//  Created by Chris on 2/24/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
import Firebase
import Combine
import FirebaseFunctions

class SessionStore : HTTPErrorHandler, ObservableObject {
    
    @Published var session:User? = nil
    @Published var isSigningUp:Bool = false
    @Published var didSignUp:Bool = false
    var handle:AuthStateDidChangeListenerHandle?
    var onSlideChange:((Double)->Void)? = nil
    @Published var maxValueRead:Double = 0
    @Published var maxDistance:Float = 10 {
        didSet {
            if(oldValue != maxDistance) {
                self.maxValueRead = Double(maxDistance)
                if let slideChange = self.onSlideChange {
                    slideChange(Double(maxDistance))
                }
            }
        }
    }
    
    func listen(callback:(()->Void)? = nil) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.session = user
            }else{
                self.session = nil
            }
            if let cb = callback {
                cb()
            }
        }
    }
    
    func signupCustomer(email:String, password:String, err:((Error)->Void)? = nil) {
        var functions = Functions.functions()
        functions.httpsCallable("signupCustomer").call(["email":email, "password":password]) { (result, error) in
            if let _ = result {
                self.signInUser(email: email, password: password, error: { _err in
                    if let err = err {
                        err(_err)
                    }
                })
            }
            if let error = error {
                if let err = err {
                    err(error)
                }
            }
        }
    }
    
    func signupBusiness(email:String, password:String, err:((Error)->Void)? = nil) {
            var functions = Functions.functions()
            functions.httpsCallable("signupBusiness").call(["email":email, "password":password]) { (result, error) in
                if let _ = result {
                    self.signInUser(email: email, password: password, error: { _err in
                        if let err = err {
                            err(_err)
                        }
                    })
                }
                if let error = error {
                    if let err = err {
                        err(error)
                    }
                }
            }
    }
    
    func noTenantSignUp(email:String, password:String, err:((Error)->Void)? = nil) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { auth, error in
            if let error = error {
                if let err = err {
                    err(error)
                }
            }
            if let _ = auth {
                self.signInUser(email: email, password: password, error: { signInError in
                    if let err = err {
                        err(signInError)
                    }
                })
            }
        })
    }
    
    class SignUp :HTTPErrorHandler, ObservableObject {
        func emailAndPassword(email:String, password:String, success: ((AuthDataResult)->Void)? = nil, error:((Error)->Void)? = nil) {
            Auth.auth().createUser(withEmail: email, password: password, completion: { auth, err in
                guard let err = err else {
                    if let auth = auth {
                        if let success = success {
                            success(auth)
                        }
                    }
                    if let currentUser = Auth.auth().currentUser {
                        currentUser.sendEmailVerification { (err) in
                            guard let err = err else {
                                return
                            }
                            self.displayErrorAlert(err)
                        }
                    }
                    return
                }
                if let error = error {
                    error(err)
                }
                self.displayErrorAlert(err)
            })
        }
    }
    
    func sendEmailVerification(success:(()->Void)? = nil, error:((Error)->Void)? = nil) {
        if let currentUser = Auth.auth().currentUser {
            currentUser.sendEmailVerification { (err) in
                if let err = err {
                    if let error = error {
                        error(err)
                    }
                }else{
                   if let success = success {
                        success()
                    }
                }
            }
        }
    }
    
    func sendPasswordResetEmail(success:(()->Void)? = nil, error:((Error)->Void)? = nil) {
        if let user = self.session, let email = user.email {
            Auth.auth().sendPasswordReset(withEmail: email) { err in
                if let err = err {
                    if let error = error {
                        error(err)
                    }
                }else{
                   if let success = success {
                        success()
                    }
                }
            }
        }
    }
    
    func updateEmail(email:String, success: (()->Void)? = nil, error:((Error)->Void)? = nil) {
        Auth.auth().currentUser?.updateEmail(to: email) { (err) in
         guard let err = err else {
              if let success = success {
                  success()
              }
              return
          }
          if let error = error {
              error(err)
          }
          self.displayErrorAlert(err)
        }
    }
    
    func signInUser(email:String, password:String, success: ((AuthDataResult)->Void)? = nil, error:((Error)->Void)? = nil) {
        
        #if TrainerApp
            //Auth.auth().tenantID = "businesses-y3o26"
        #else
            //Auth.auth().tenantID = "customers-0oz1i"
        #endif
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { auth, err in
            guard let err = err else {
                if let auth = auth {
                    if let success = success {
                        success(auth)
                    }
                }
                return
            }
            if let error = error {
                error(err)
            }
            self.displayErrorAlert(err)
        })
    }
    
    class SignIn : HTTPErrorHandler, ObservableObject {
        func emailAndPassword(email:String, password:String, success: ((AuthDataResult)->Void)? = nil, error:((Error)->Void)? = nil) {
            
            Auth.auth().signIn(withEmail: email, password: password, completion: { auth, err in
                guard let err = err else {
                    if let auth = auth {
                        if let success = success {
                            success(auth)
                        }
                    }
                    return
                }
                if let error = error {
                    error(err)
                }
                self.displayErrorAlert(err)
            })
        }
    }
    
    class UpdatePassword:HTTPErrorHandler, ObservableObject {
        func update(password:String, success:(()->Void)? = nil, error:((Error)->Void)? = nil) {
            Auth.auth().currentUser?.updatePassword(to: password) { (err) in
                if let err = err {
                    if let error = error {
                        self.displayErrorAlert(err)
                        error(err)
                    }
                }else{
                    if let success = success {
                        success()
                    }
                }
            }
        }
    }

    class ReAuth : HTTPErrorHandler, ObservableObject  {
        func withEmailAndPassword(email:String, password:String, success:((AuthDataResult)->Void)? = nil, error:((Error)->Void)? = nil) {
            let user = Auth.auth().currentUser
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            // Prompt the user to re-provide their sign-in credentials
            user?.reauthenticate(with: credential) { auth, err in
              if let err = err {
                if let error = error{ error(err) }
                self.displayErrorAlert(err)
              } else {
                if let result = auth {
                    if let success = success{ success(result) }
                }
              }
            }
        }
    }

    func logout() -> Bool {
        do {
            try Auth.auth().signOut()
            self.session = nil
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func unbind() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func resetPassword(email:String, result: @escaping SendPasswordResetCallback) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: result)
    }
    
    
}

class HTTPErrorHandler {
    @Published var showHTTPAlert:Bool = false
    @Published var HTTPAllertTitle:String = ""
    @Published var HTTPAlertMessage:String = ""
    
    init(showHTTPAlert:Bool = false, HTTPAllertTitle:String = "", HTTPAlertMessage:String = "") {
        self.showHTTPAlert = showHTTPAlert
        self.HTTPAllertTitle = HTTPAllertTitle
        self.HTTPAlertMessage = HTTPAlertMessage
    }
    
    func displayErrorAlert(_ error:Error) {
        self.showHTTPAlert = true
        self.HTTPAllertTitle = "Error"
        self.HTTPAlertMessage = error.localizedDescription
    }
    
    func displaySuccessAlert(title:String = "Successfull", message:String = "") {
        self.showHTTPAlert = true
        self.HTTPAllertTitle = title
        self.HTTPAlertMessage = message
    }
}
