//
//  SettingsView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/29/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
import GeoFire

enum ScreenType {
    case tos,privacy,license,card,website,none
}

struct ToggleView{
    var label: String
    var enabled: Bool = true {
        didSet {
            print(enabled)
            // Here's where any code goes that needs to run when a switch is toggled
            //print("\(label) is \(enabled ? "enabled" : "disabled")")
        }
    }
}

class SettingsModel: ObservableObject {
    @Published var toggleView:ToggleView = ToggleView(label: "s")
}

struct SettingsView: View {
    
    @State private var title:String = "Settings"
    @State private var hasBackBtn:Bool = true
    @EnvironmentObject var sessionStore:SessionStore
    @State var updateEmailViewModel:UpdateEmailViewModel = UpdateEmailViewModel()
    @State private var showScreen:Bool = false
    @State var screenType:ScreenType = .none
    @State var screenTitle:String = ""
    @State var profileStore:ProfileStore = ProfileStore()
    let geofireRef = Database.database().reference()
    @State var geoFire:GeoFire?
    @State var userAddess:String = ""
    @State var profile:Profile? = nil
    @State var maxSearchDistance:Float = 3000
    
    
    
    @State var updateLocation:Bool = false {
        didSet {
            if(oldValue != updateLocation) {
                print(updateLocation)
                guard let user = self.sessionStore.session else { return }
                self.profileStore.updateProfile(userId:user.uid, data:["update_location":updateLocation])
            }
        }
    }
    @ObservedObject var settingsModel = SettingsModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack() {
                    self.accountSettingsSection()
                    //self.discoverSettingsSection(userId: self.sessionStore.session?.uid ?? "")
                    //self.paymentSettingsSection()
                    self.legalSettingsSection()
                    Spacer().frame(height:20)
                    self.linksSettingsSection()
                }
            }.navigationBarTitle("Settings")

        }
        .onAppear(perform: self.onAppear)
        .sheet(isPresented: $showScreen) {
            WebViewDis(screenType: $screenType, title:$screenTitle, exit:$showScreen)
        }
    }
    
    struct header2 : ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(.horizontal)
                .font(.system(size: 14, weight: .bold, design: .default))
            .frame(minWidth:0, maxWidth: .infinity, minHeight: 38, alignment:.leading)
            .foregroundColor(Color("textColor"))
            .background(Color("panelBackgroundColor"))
        }
    }
    
    func getProfile(userId:String) {
        self.profileStore.getProfileByUserId(userId:userId, success: { profile in
            self.profile = profile
            if self.profile != nil {
                self.updateLocation = self.profile!.updateLocation
            }
            
        })
    }
    
    func onAppear() {
        self.geoFire = GeoFire(firebaseRef: geofireRef.child("user_locations"))
        self.sessionStore.listen()
        guard let user = self.sessionStore.session else { return }
        self.getProfile(userId: user.uid)
    }
    
    
    func accountSettingsSection() -> some View {
        Group {
             VStack {
                 
                 Text("Account")
                     .modifier(header2())
                 NavigationLink(destination:ProfileFormView(isUpdatingProfile:true), label: {
                     HStack {
                         Image(systemName: "person.circle")
                             .resizable()
                             .aspectRatio(contentMode: .fit)
                             .frame(width:24)
                            .foregroundColor(Color("primaryColor"))
                         Spacer().frame(width:15)
                         Text("Edit Profile")
                             .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                             .foregroundColor(Color("textColor"))
                         Image(systemName:"chevron.right").foregroundColor(.gray)
                     }
                 }).padding(.horizontal)
             }
             Divider()
             NavigationLink(destination:UpdateEmailView().environmentObject(self.updateEmailViewModel) , label: {
                 HStack() {
                     Image(systemName: "envelope")
                         .resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(width:24)
                        .foregroundColor(Color("primaryColor"))
                     Spacer().frame(width:15)
                     Text("Update Email")
                         .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                         .foregroundColor(Color("textColor"))
                     Image(systemName:"chevron.right")
                         .foregroundColor(.gray)
                 }.padding(.horizontal)
             })
             Divider()
             NavigationLink(destination:PasswordUpdateView(), label: {
                 HStack {
                     Image(systemName: "lock.circle")
                         .resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(width:24)
                        .foregroundColor(Color("primaryColor"))
                     Spacer().frame(width:15)
                     Text("Change Password")
                         .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                         .foregroundColor(Color("textColor"))
                     Image(systemName:"chevron.right").foregroundColor(.gray)
                 }

             }).padding(.horizontal)
        }
    }
    
    
    
    
    
    
    
    func legalSettingsSection() -> some View {
        Group {
            Text("Legal")
                .modifier(header2())
            Spacer()
            Button(action:{
                self.screenTitle = "PRIVACY POLICY"
                self.screenType = .privacy
                //self.showScreen.toggle()
            }, label: {
                HStack {
                    Image(systemName: "shield")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:24)
                        .foregroundColor(Color("primaryColor"))
                    Spacer().frame(width:15)
                    Text("Privacy Policy")
                        .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("textColor"))
                    Spacer()
                }
            }).padding(.horizontal)
            Divider()
            Button(action:{
                self.screenTitle = "USER LICENSE AGREEMENT"
                self.screenType = .license
                //self.showScreen.toggle()
            }, label: {
                HStack {
                    Image(systemName: "shield")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:24)
                        .foregroundColor(Color("primaryColor"))
                    Spacer().frame(width:15)
                    Text("License")
                        .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("textColor"))
                    Spacer()
                }
            }).padding(.horizontal)
            Divider()
            Button(action:{
                self.screenTitle = "TERMS AND CONDITIONS"
                self.screenType = .tos
                //self.showScreen.toggle()
            }, label: {
                HStack {
                    Image(systemName: "shield")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:24)
                        .foregroundColor(Color("primaryColor"))
                    Spacer().frame(width:15)
                    Text("Terms & Conditions")
                        .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("textColor"))
                    Spacer()
                }
            }).padding(.horizontal)
            Divider()
            Spacer()
        }
    }
    
    func linksSettingsSection() -> some View {
        Group {
            Text("PLEASE EAT GOOD")
                .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 16, weight: .bold, design: .default))
                .padding(.horizontal)
                .foregroundColor(Color("primaryColor"))
            Button(action: {
                self.screenTitle = "1 on 1 Virtual Courses"
                self.screenType = .website
                //self.showScreen.toggle()
            }, label: {
                Text("pleaseeatgood.org")
                    .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .foregroundColor(Color("primaryColor"))
            })
            Spacer().frame(height:5)
            Divider()
            Button(action: {
                _ = self.sessionStore.logout()
            }, label: {
                Text("Log Out")
                    .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .foregroundColor(Color("primaryColor"))
            })
        }
    }
    

    
}

struct WebViewDis : View {
    
    @Binding var screenType:ScreenType
    @Binding var title:String
    @Binding var exit:Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                WebView(url: self.getUrl())
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(self.title)
            .navigationBarItems(leading: Button(action: {
                self.exit.toggle()
            }, label: {
                Image(systemName: "xmark").foregroundColor(Color("textColor"))
            }))
        }
    }
    
    func getUrl() -> String {
        if(self.screenType == .privacy) {
            return "https://www.afroacademy.org/privacy.html"
        }
        if(self.screenType == .license) {
            return "https://www.afroacademy.org/license.html"
        }
        if(self.screenType == .tos) {
            return "https://www.afroacademy.org/terms.html"
        }
        if(self.screenType == .website) {
            return "https://www.afroacademy.org"
        }
        return ""
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

//NavigationLink(destination:UpdateEmailView().environmentObject(self.updateEmailViewModel) , label: {
//    HStack() {
//        Image(systemName: "envelope")
//        Spacer().frame(width:15)
//        Text("Update email")
//            .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
//            .foregroundColor(Color("textColor"))
//        Image(systemName:"chevron.right")
//            .foregroundColor(.gray)
//    }
//}).padding(20)
