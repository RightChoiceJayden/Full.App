//
//  ProfileStore.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/30/20.
//  Copyright © 2020 Chris. All rights reserved.
//



import Foundation
import Firebase
import SwiftUI
import FirebaseFirestoreSwift
import GeoFire
import SwiftLocation

class ProfileStore: HTTPErrorHandler, ObservableObject {
   
    @Published var profileRef:CollectionReference = db.collection("Profiles")
    @Published var userProfile:Profile? = nil
    @Published var nearByProfiles:[Profile] = []
    
    lazy var functions = Functions.functions()
    
    func getStripeAccountLink(success:@escaping ((String)->Void)) {
        functions.httpsCallable("getAccountLink").call() { (result, err) in
            if let res = result {
                let dic = res.data as! NSDictionary
                let link = dic["url"] as! String
                success(link)
            }
        }
    }
    
    func listenForUserProfile(session:SessionStore) {
        guard let user = session.session else { return }
        self.getProfileByUserId(userId:user.uid, success: { profile in
            self.userProfile = profile
        })
    }
    
    func createGallery(userId:String, gallery:Gallery) {

        _ = try? db.collection("Profiles")
            .document(userId)
            .collection("gallery")
            .document(gallery.name)
            .setData(from: gallery, merge: true)
        
    }
    
    
    
    func createMeal(userId:String, meal:Meal) {

        _ = try? db.collection("Profiles")
            .document(userId)
            .collection("meals")
            .document(meal.name)
            .setData(from: meal, merge: true)
    }
    
    func getGallery(userId:String, galleryName:String, success:@escaping ((Gallery?)->Void) ) {
        db.collection("Profiles")
            .document(userId)
            .collection("gallery")
            .document(galleryName)
            .addSnapshotListener { (documentSnapshot, error) in
                if let document = documentSnapshot {
                    do {
                        let model = try document.data(as: Gallery.self)
                        if let model = model {
                            success(model)
                        }else{
                            success(nil)
                        }
                    }catch {
                        print(error)
                    }
                }
                
            }
    }
    
    private func geocode(latitude: Double, longitude: Double, completion: @escaping (_ placemark: [CLPlacemark]?, _ error: Error?) -> Void)  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { placemark, error in
            guard let placemark = placemark, error == nil else {
                completion(nil, error)
                return
            }
            completion(placemark, nil)
        }
    }
    
    func getLatLonForProfile(userId:String, coords:@escaping ((CLLocation)->Void)) {
        let geofireRef = Database.database().reference()
        let geoFire = GeoFire(firebaseRef: geofireRef.child("user_locations"))
        geoFire.getLocationForKey(userId) { (location, error) in
          if (error != nil) {
            print(error)
          } else if (location != nil) {
            coords(location!)
          } else {
            print("Couldnt find a location.")
          }
        }
    }
    
    func getUserDistanceFromLocation(userId:String, locationFrom:CLLocation, distance:@escaping ((String)->Void)) {
        
        let geofireRef = Database.database().reference()
        let geoFire = GeoFire(firebaseRef: geofireRef.child("user_locations"))
        geoFire.getLocationForKey(userId) { (location, error) in
          if (error != nil) {
            print(error)
          } else if (location != nil) {
            let distanceFrom = location!.distance(from: locationFrom)
            let distanceFromMeters = Measurement(value: distanceFrom, unit: UnitLength.meters)
            let distanceFromMiles = distanceFromMeters.converted(to: UnitLength.miles)
            let distanceFromFeet = distanceFromMeters.converted(to: UnitLength.feet)
            
            if(distanceFromMiles.value > 0.5) {
                distance("\(Int(distanceFromMiles.value)) mi")
            }else{
                distance("\(Int(distanceFromFeet.value)) ft")
            }
          } else {
            print("Couldnt find a location.")
          }
        }

        
    }
    
    func getDeviceDistanceFromLocation(location:CLLocation, distance:@escaping ((String)->Void)) {
        
        SwiftLocation.gpsLocationWith {
            $0.precise = .reducedAccuracy
            $0.subscription = .single
            $0.accuracy = .house
            $0.activityType = .fitness
        }.then { result in
            switch result {
            case .success(let newData):
                let loc = CLLocation(latitude: newData.coordinate.latitude, longitude: newData.coordinate.longitude)
                
                let distanceFrom = loc.distance(from: location)
                let distanceFromMeters = Measurement(value: distanceFrom, unit: UnitLength.meters)
                let distanceFromMiles = distanceFromMeters.converted(to: UnitLength.miles)
                let distanceFromFeet = distanceFromMeters.converted(to: UnitLength.feet)
                
                if(distanceFromMiles.value > 0.5) {
                    distance("\(Int(distanceFromMiles.value)) mi")
                }else{
                    distance("\(Int(distanceFromFeet.value)) ft")
                }
            case .failure(let error):
                print("An error has occurred: \(error.localizedDescription)")
            }
        }
        
    }
    
    func getUserLocationCityState(success:@escaping ((String)->Void)) {
        SwiftLocation.gpsLocation().then {
            let deviceLocation = $0.location
            if let deviceLocation = deviceLocation {

            }
        }
    }
    
    func getUserLocationCityState(userId:String, locationFrom:CLLocation, distance:@escaping ((String)->Void)) {
        
        let geofireRef = Database.database().reference()
        let geoFire = GeoFire(firebaseRef: geofireRef.child("user_locations"))
        geoFire.getLocationForKey(userId) { (location, error) in
          if (error != nil) {
            print(error)
          } else if (location != nil) {
            self.geocode(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude, completion: { placemark, error in
                guard let error = error else {
                    guard let placemark = placemark else { return }
                    guard let firstPlaceMark = placemark.first else { return }
                    //success(self.getUserCityState(placemark: firstPlaceMark))
                    return
                }
                print(error.localizedDescription)
            })
          } else {
            print("Couldnt find a location.")
          }
        }

        
    }
    
    func getDeviceCityState(success:@escaping ((String)->Void)) {
        SwiftLocation.gpsLocation().then {
            let deviceLocation = $0.location
            if let deviceLocation = deviceLocation {
                self.geocode(latitude: deviceLocation.coordinate.latitude, longitude: deviceLocation.coordinate.longitude, completion: { placemark, error in
                    guard let error = error else {
                        guard let placemark = placemark else { return }
                        guard let firstPlaceMark = placemark.first else { return }
                        success(self.getUserCityState(placemark: firstPlaceMark))
                        return
                    }
                    print(error.localizedDescription)
                })
            }
        }
    }
    
    private func getUserCityState(placemark:CLPlacemark) -> String {
        var address:String = ""
        
        let city = placemark.locality ?? "unknown"
        let state = placemark.administrativeArea ?? "unknown"
        
        address += city
//        address += ", "
//        address += state
        
        return address
    }
    
    func getAgeForProfile(profile:Profile) -> Int {
        let now = Date()
        let birthday: Date = profile.birthday.dateValue()
        let calendar = Calendar.current

        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
        let age = ageComponents.year!
        return age
    }
    
    func getCityStateForProfile(userId:String, address:@escaping ((String)->Void)) {
        let geofireRef = Database.database().reference()
        let geoFire = GeoFire(firebaseRef: geofireRef.child("user_locations"))
        geoFire.getLocationForKey(userId) { (location, error) in
          if (error != nil) {
            
          } else if (location != nil) {
            self.geocode(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude, completion: { placemark, error in
                guard let error = error else {
                    guard let placemark = placemark else { return }
                    guard let firstPlaceMark = placemark.first else { return }
                    address(self.getUserCityState(placemark: firstPlaceMark))
                    return
                }

                print("ProfileStore.getCityStateForProfile geocode: ", error.localizedDescription)
            })
          } else {
            print("Couldnt find a location.")
          }
        }
    }
    
    func getProfileByLocation(ids:[String]) {
        let q = self.profileRef.whereField("user_id", in: ids)
        q.getDocuments { (query, err) in
            guard let err = err else {
                guard let query = query else { return }
                query.documents.forEach { (docSnap) in
                    let data = docSnap.data()
                    print(data)
                }
                return
            }
            print(err.localizedDescription)
        }
    }
    
    func getCategoriesByProfileId(profileId:String, categoryName:String, categories:@escaping (([Transaction])->Void)) {
        let q = self.profileRef
            .document(profileId)
            .collection("transactions")
            .whereField("category", arrayContains: categoryName)
        
            q.addSnapshotListener { (querySnap, error) in
        
                guard let error = error else {
                    guard let snap = querySnap else { return }
                    var _transactions:[Transaction] = []
                    snap.documents.forEach { doc in
                        let data = doc.data()
                        let name = data["name"] as! String
                        let transaction:Transaction = Transaction(name: name)
                        _transactions.append(transaction)
                    }
                    categories(_transactions)
                    return
                }
                print(error.localizedDescription)
            }
    }

    func getStripeBalance(success: ((Balance)->Void)? = nil) {
        functions.httpsCallable("getBalance").call() { (result, err) in
            if let res = result {
                let available = self.getAmount(res: res, key: "instant_available")
                let pending = self.getAmount(res: res, key: "pending")
                if let success = success {
                    success(Balance(available:available, pending:pending))
                }
            }
        }
    }
    
    private func getAmount(res:HTTPSCallableResult, key:String) -> Int {
        let dic = res.data as! NSDictionary
        let availableArr = dic[key] as! NSArray
        let availableAmountDic = availableArr.firstObject as! NSDictionary
        return availableAmountDic["amount"] as! Int
    }
    
    func getBusinesses(success: (([Profile])->Void)? = nil ) {
        let q = self.profileRef
            .whereField("role", isEqualTo: "business")
            .whereField("isAccountEnabled", isEqualTo: true)
        
        q.addSnapshotListener { documentSnapshot, err in
            guard let documents = documentSnapshot?.documents else {
                print("Error fetching documents: \(err)")
                return
            }
            var trainers:[Profile] = []
            documents.forEach { document in
                do {
                    let trainer = try document.data(as: Profile.self)
                    if var trainer = trainer {
                        trainer.id = document.documentID
                        trainers.append(trainer)
                    }
                }catch {
                    print(error)
                }
            }
            if let success = success {
                success(trainers)
            }
        }
    }
    
    func getProfileByUserId(userId:String, success:((Profile?)->Void)? = nil, error:((Error)->Void)? = nil) {
        print("get profile for user ID")
        self.profileRef.document(userId)
            .addSnapshotListener { documentSnapshot, err in
                guard let document = documentSnapshot else {
                    if let err = err, let error = error {
                        error(err)
                    }
                    return
                }
                let _ = document.metadata.hasPendingWrites ? "Local" : "Server"
                do {
                    var profile = try document.data(as: Profile.self)
                    profile?.id = document.documentID
                    if let profile = profile {
                        if let success = success{ success(profile) }
                    }else{
                         if let success = success{ success(nil) }
                    }
                }catch {
                    print(error.localizedDescription)
                }
        }
    }
    
    func getProfileByUserIdOnce(userId:String, success:((Profile?)->Void)? = nil, error:((Error)->Void)? = nil) {
        self.profileRef.document(userId)
            .getDocument { documentSnapshot, err in
                guard let document = documentSnapshot else {
                    if let err = err, let error = error {
                        error(err)
                    }
                    return
                }
                let _ = document.metadata.hasPendingWrites ? "Local" : "Server"
                do {
                    var profile = try document.data(as: Profile.self)
                    profile?.id = document.documentID
                    if let profile = profile {
                        if let success = success{ success(profile) }
                    }else{
                         if let success = success{ success(nil) }
                    }
                }catch {
                    print(error)
                }
        }
    }
    
    func updateProfile(userId:String, data:[String:Any]) {
        self.profileRef.document(userId).setData(data, merge: true)
    }
    
    func updateOrCreateProfile(profile:Profile, success:(()->Void)? = nil, error:((Error)->Void)? = nil) {
        do {
            let functions = Functions.functions()
            functions.httpsCallable("setUserProfile").call([
                "first_name":profile.firstName,
                "last_name":profile.lastName,
                "phone":profile.phone,
                "dob": profile.birthday.dateValue().toString(),
                "profileURL":profile.profileURL,
                "bio":profile.bio ?? "",
                "hourlyPrice":profile.hourlyPrice,
                "isOnline":profile.isOnline,
                "gender":profile.gender,
                "defaultAddress":profile.defaultAddress,
                "hideVerificationSuccess":profile.hideVerificationSuccess
            ]) { (result, err) in
                print(result?.data, err?.localizedDescription)
                guard let err = err else {
                    if let success = success {
                        success()
                    }
                    return
                }
                if let error = error {
                    error(err)
                }
            }
        }catch{
            print(error)
        }
    }
    
    
    func toggleOnline(profile:Profile, success:(()->Void)? = nil, error:((Error)->Void)? = nil) {
        do {
            let functions = Functions.functions()
            functions.httpsCallable("toggleOnline").call([
                "isOnline":profile.isOnline
            ]) { (result, err) in
                //print(result?.data, err?.localizedDescription)
                guard let err = err else {
                    if let success = success {
                        success()
                    }
                    return
                }
                if let error = error {
                    error(err)
                }
            }
        }catch{
            print(error)
        }
    }
    
}






struct Balance {
    let available:Int
    let pending:Int
}
