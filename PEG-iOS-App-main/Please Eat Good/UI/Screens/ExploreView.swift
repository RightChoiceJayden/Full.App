//
//  ExploreView.swift
//  Truth Dating
//
//  Created by Christopher on 1/24/21.
//

import SwiftUI
import GeoFire
import SwiftLocation

struct UserListItem: View {
    
    var profile:Profile
    @EnvironmentObject var profileStore:ProfileStore
    @State var cityState:String = ""
    @EnvironmentObject var sessionStore:SessionStore
    @State var distanceFrom:String? = nil
    var showDistanceFrom:Bool = true
    
    func setProfileDistance(profile:Profile) {
        guard let user = self.sessionStore.session else { return }
        self.profileStore.getLatLonForProfile(userId: profile.id ?? "", coords: { location in
            self.profileStore.getUserDistanceFromLocation(userId: user.uid, locationFrom: location, distance: { dis in
                self.distanceFrom = dis
            })
        })
    }
    
    func onAppear() {
        guard let profileId = profile.id else { return }
        self.profileStore.getCityStateForProfile(userId:profileId, address: { address in
            self.cityState = address
        })
        if self.showDistanceFrom {
            self.setProfileDistance(profile: profile)
        }
    }
    
    var body: some View {
        NavigationLink(destination:profileView(profile:profile), label: {
            Item(title: "\(profile.firstName) \(profile.lastName)", subtitle: "\(self.profileStore.getAgeForProfile(profile: profile)), \(self.cityState)", thumbnailURL: self.profile.profileURL, bodyText:profile.bio ?? "No bio", rightSubtitle: self.distanceFrom ?? "")
        })
        .onAppear(perform: onAppear)
    }
    
}





struct UserList: View{
    @Binding var profiles:[Profile]
    @EnvironmentObject var sessionStore:SessionStore
    var showDistanceFrom:Bool = true
    var body: some View {
        VStack {
            ForEach(self.profiles, id:\.id) { profile in
                UserListItem(profile: profile, showDistanceFrom: self.showDistanceFrom)
            }
        }
    }
}

struct ExploreView: View {
    
    let geofireRef = Database.database().reference()
    @State var userQuery: GFQuery?
    @State var profiles:[Profile] = []
    @EnvironmentObject var profileStore:ProfileStore
    @State var title:String = "Please Eat Good"
    @EnvironmentObject var sessionStore:SessionStore
    @State var userState:String = ""
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack(spacing:0) {
                        Text("Meal Recommendations")
                            .font(.title2)
                            .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
//                        Text("Daters living in \(self.userState)")
//                            .font(.title3)
//                            .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
//                            .foregroundColor(.gray)
//                        Spacer().frame(height:20)
//                        UserList(profiles: self.$profileStore.nearByProfiles)
                    }
                }
                .navigationBarTitle( "" )
                .navigationBarItems(leading: Text(self.title).font(.custom("", size: 30)))
                .navigationBarTitleDisplayMode(.inline)
                .padding()
            }
        }.onAppear(perform: {
            self.onInit()
        })
    }
    
    
    func getCityState() {
        guard let user = self.sessionStore.session else { return }
        self.profileStore.getCityStateForProfile(userId:user.uid, address: { address in
            self.userState = address
        })
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
    
    func queryByDeviceLocation(location:CLLocation?, radius:Double) {
        if let location = location {
            let geoFire = GeoFire(firebaseRef: geofireRef.child("user_locations"))
            let searchRadiusMiles = Measurement(value: radius, unit: UnitLength.miles)
            let searchRadiusKilometers = searchRadiusMiles.converted(to: UnitLength.kilometers)
            self.userQuery = geoFire.query(at: location, withRadius: searchRadiusKilometers.value)
            
            DispatchQueue.main.async {
                self.profiles.removeAll()
                userQuery?.observe(.keyEntered, with: { (key, location) in
                    self.profileStore.getProfileByUserIdOnce(userId: key, success:{ profile in
                        guard let profile = profile else { return }
                        self.profiles.append(profile)
                    }, error: { error in
                        
                    })
                })
            }
            

        }
    }
    
    func onSearchRadiusChange(value:Double) {
        self.queryUsersByDeviceLocation(radiusInMiles: value)
    }
    
    func onInit() {
        self.sessionStore.onSlideChange = onSearchRadiusChange
        self.getCityState()
        //self.queryUsersByDeviceLocation(radiusInMiles: Double(self.sessionStore.maxDistance))
    }
}



struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
