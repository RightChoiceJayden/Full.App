//
//  RootView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 2/24/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
import Firebase
import SwiftLocation
import CoreLocation
import GeoFire

class DeviceLocation: ObservableObject {
    @Published var cords:CLLocation? = nil
    init(){
        
    }
}

struct RootView: View {
    
    //@EnvironmentObject var app:App
    @EnvironmentObject var session:SessionStore
    @EnvironmentObject var profileStore:ProfileStore
    @State var loading:Bool = true
    @State var profile:Profile? = nil
    @State var showIdentity:Bool = false
    @State var alertViewModel:AlertViewModel = AlertViewModel()
    @ObservedObject var deviceLocation:DeviceLocation = DeviceLocation()
    let geofireRef = Database.database().reference()
    @State var userQuery: GFQuery?
    
    func onAppear() {
        self.session.listen(callback: {
            self.loading = false
            //self.queryUsersByDeviceLocation(radiusInMiles: 3000)
            self.profileStore.listenForUserProfile(session: self.session)
            guard let userProfile = self.profileStore.userProfile else { return }
            self.profile = userProfile
            
        })
    }
    
    func queryByDeviceLocation(location:CLLocation?, radius:Double) {
        if let location = location {
            let geoFire = GeoFire(firebaseRef: geofireRef.child("user_locations"))
            let searchRadiusMiles = Measurement(value: radius, unit: UnitLength.miles)
            let searchRadiusKilometers = searchRadiusMiles.converted(to: UnitLength.kilometers)
            self.userQuery = geoFire.query(at: location, withRadius: searchRadiusKilometers.value)
            userQuery?.observe(.keyEntered, with: { (key, location) in
                self.profileStore.getProfileByUserIdOnce(userId: key, success:{ profile in
                    guard let profile = profile else { return }
                    self.profileStore.nearByProfiles.append(profile)
                }, error: { error in
                    
                })
            })
        }
    }
    
    func queryUsersByDeviceLocation(radiusInMiles:Double) {
        let location = SwiftLocation.lastKnownGPSLocation
        
        if let location = location {
            self.queryByDeviceLocation(location: location, radius: radiusInMiles)
        }else{
            SwiftLocation.gpsLocation().then {
                let location = $0.location
                self.queryByDeviceLocation(location: location, radius: radiusInMiles)
            }
        }
    }
    
    func updateProfile() {
        if var profile = self.profile {
            profile.hideVerificationSuccess = true
            self.profileStore.updateOrCreateProfile(profile: profile)
        }
    }
    
    func isPending() -> Bool {
        return (self.profile?.status ?? "") == "pending" ? true : false
    }
    
    func isVerified() -> Bool {
        return (self.profile?.status ?? "") == "verified" ? true : false
    }
    
    func isUnverified() -> Bool {
        return (self.profile?.status ?? "") == "unverified" ? true : false
    }
    
    var body: some View {
        Group {
            ZStack(alignment:.topLeading) {
                if !self.loading {
                    if self.session.session != nil {
                        AppTabView()
                        self.alertView()
                    }else {
                        LoginForm()
                    }
                }else{
                    LoadingView()
                }
            }
        }
        .onAppear(perform: onAppear)
    }
    
    func getDeviceLocation() {
        SwiftLocation.gpsLocationWith {
            $0.precise = .fullAccuracy
            $0.subscription = .continous
            $0.accuracy = .house
            $0.activityType = .fitness
        }.then { result in
            switch result {
            case .success(let newData):
                guard let profile = profile else { return }
                if profile.updateLocation {
                    self.updateLocationForUser(coords:newData.coordinate)
                }
            case .failure(let error):
                print("An error has occurred: \(error.localizedDescription)")
            }
        }
    }
    
    func updateLocationForUser(coords:CLLocationCoordinate2D) {
        guard let user = self.session.session else { return }
        let geoFire = GeoFire(firebaseRef: geofireRef.child("user_locations"))
        let location = CLLocation(latitude: coords.latitude, longitude: coords.longitude)
        geoFire.setLocation(location, forKey: user.uid)
    }
    
    func alertView() -> some View {
        ZStack {
            VStack {
                Spacer()
                if !(self.profile?.isAccountEnabled ?? false && self.profile != nil) {
                    if self.isUnverified() {
                        
                        Button(action: {
                            self.showIdentity.toggle()
                        }, label: {
                            VStack(spacing:8) {
                                Text("Verify your identity")
                                    .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: 18, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                    
                                Text("MORE INFORMATION REQUIRED")
                                    .font(.system(size: 12))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                                Spacer()
                            }.padding(20)
                        })
                        .frame(height:120)
                        .background(Color.red)
                        .offset(x: 0, y: 35)
                    }
                    if self.isPending() {
                        Button(action: {
                            self.showIdentity.toggle()
                        }, label: {
                            VStack(spacing:8) {
                                Text("Identity verification is pending")
                                    .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: 18, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                    
                                Text("MORE INFORMATION MIGHT BE NEEDED")
                                    .font(.system(size: 12))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                                Spacer()
                            }.padding(20)
                        })
                        .frame(height:120)
                        .background(Color.gray)
                        .offset(x: 0, y: 35)
                    }
                }
                if self.isVerified() {
                    if !(self.profile?.hideVerificationSuccess ?? false) {
                        
                        Button(action: {
                            self.updateProfile()
                        }, label: {
                            HStack {
                                VStack(spacing:8) {
                                    Text("Your identity has been verified")
                                        .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                                        .font(.system(size: 18, weight: .bold, design: .default))
                                        .foregroundColor(.white)
                                        
                                    Text("YOU CAN NOW GET PAID INSTANTLY")
                                        .font(.system(size: 12))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                                    Spacer()
                                }
                                Spacer()
                                VStack {
                                    
                                    Image("exit").renderingMode(.original).resizable().aspectRatio(contentMode: .fit).frame(width:20).padding()
                                    Spacer()
                                }
                            }.padding(20)

                        })
                        .frame(height:120)
                        .background(Color.green)
                        .offset(x: 0, y: 35)
                    }
                }
            }
        }
        
    }
    
}

//struct RootView_Previews: PreviewProvider {
//    static var previews: some View {
//        RootView().environmentObject(SessionStore())
//    }
//}
