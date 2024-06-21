//
//  UpdateEmailView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/4/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

enum FormViewState {
    case loading, loaded, error, noRequest
}

class FormViewModel: ObservableObject {
    @Published var state:FormViewState = .noRequest
    @Published var onSave:(()->Void)? = nil
    @Published var isFormError:Bool = false
    @Published var isError:Bool = false
    @Published var alertViewModel:AlertViewModel = AlertViewModel()
    
    func getFormButton() -> some View {
        Button(action: {
            guard let onSave = self.onSave else{ return }
            self.state = .loading
            onSave()
        }, label: {
            self.formButtonText()
        })
        .background(Color("primaryColor"))
        .cornerRadius(50)
        .padding(.horizontal, 20)
    }
    
    private func formButtonText() -> some View {
        Text(self.state == .loading ? "Saving" : "Save")
        .fontWeight(.semibold)
        .foregroundColor(.black)
        .frame(minWidth:0, maxWidth: .infinity, minHeight: 60)
    }
    
}

class UpdateEmailViewModel: ObservableObject {
    // Input
    @Published var email:String = ""
    @Published var session:SessionStore = SessionStore()
    @Published var formViewModel:FormViewModel = FormViewModel()
    @State private var oldEmail:String = ""
    
    
    init() {
        self.formViewModel.onSave = self.onSave
    }
    
    func setView() {
        self.formViewModel.state = .loading
        self.session.listen(callback: {
            guard let user = self.session.session else{ return }
            self.email = user.email ?? ""
            self.oldEmail = self.email
            self.formViewModel.state = .loaded
        })
    }
    
    func onSave() {
        self.formViewModel.state = .loaded
        self.session.updateEmail(email: email, success: {
            self.updateEmailSuccess()
        }, error: { error in
            self.onEror(error:error)
        })
    }
    private func updateEmailSuccess() {
        self.formViewModel.alertViewModel.showAlertView(title: "Success", message: "Emil updated")
        self.formViewModel.state = .loaded
    }
    private func onEror(error:Error) {
        print(error.localizedDescription)
        self.formViewModel.alertViewModel.showAlertView(title: "Error", message: error.localizedDescription)
    }
    
}

struct UpdateEmailView: View {
    
    @State var email:String = ""
    @State var isUpdating:Bool = false
    @State var session:SessionStore = SessionStore()
    @State private var oldEmail:String = ""
    @State var state:FormViewState = .noRequest
    
    @State var showAlert:Bool = false
    @State var alertTitle:String = ""
    @State var alertMessage:String = ""
    
    func getUser(){
        self.state = .loading
        self.session.listen(callback: {
            guard let user = self.session.session else{ return }
            self.email = user.email ?? ""
            self.state = .loaded
        })
    }
    
    private func formButtonText() -> some View {
        Text(self.state == .loading ? "Saving" : "Save")
            .fontWeight(.semibold)
            .foregroundColor(.black)
            .frame(minWidth:0, maxWidth: .infinity, minHeight: 45)
    }

    var body: some View {
        ZStack(alignment:.topLeading) {
            Color("backgroundColor")
            VStack {
                Divider()
                TextInputView(label: .constant("EMAIL ADDRESS"), placeholder: .constant("youremail@here.com"), value: $email)
                Spacer().frame(height:30)
                

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
            
            // Add button
            
            
            
            
        }
        .navigationTitle("Update Email")
        .onAppear(perform: getUser)
    }
    
    func sendButton() -> some View {
        Button(action: {
            self.updateEmail()
        }, label: {
            self.formButtonText()
        })
        .background(Color("primaryColor"))
        .cornerRadius(4)
        .padding(.horizontal)
        .disabled(self.isUpdating)
        .opacity(self.isUpdating ? 0.3 : 1)
        .alert(isPresented: $showAlert) {
            Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .cancel(Text("Okay")))
        }
    }
    
    func updateEmail() {
        self.state = .loading
        self.session.updateEmail(email: email, success: {
            self.updateEmailSuccess()
        }, error: { error in
            self.onEror(error:error)
        })
    }
    private func updateEmailSuccess() {
        self.showAlertView(title: "Success", message: "Email updated successfully")
        self.state = .loaded
    }
    private func onEror(error:Error) {
        self.state = .error
        self.showAlertView(title: "Error", message: error.localizedDescription)
    }
    
    func showAlertView(title:String, message:String) {
        self.alertTitle = title
        self.alertMessage = message
        self.showAlert = true
    }
}

//struct UpdateEmailView_Previews: PreviewProvider {
//    static var previews: some View {
//        UpdateEmailView()
//    }
//}
