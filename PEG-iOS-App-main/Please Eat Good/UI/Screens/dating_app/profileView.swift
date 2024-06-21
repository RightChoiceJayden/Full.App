//
//  profileView.swift
//  Afro Academy
//
//  Created by Christopher on 11/25/20.
//

import SwiftUI

import URLImage


struct Transaction {
    var id:UUID = UUID()
    var name:String
}

struct profileView: View {
    
    @State var plaidToken:String = ""
    @State var showPlaid:Bool = false
    @State var plaidView:UIViewController = UIViewController()
    @State var linkToken:String = ""
    @State var categories:[Category] = []
    @EnvironmentObject var sessionStore:SessionStore
    @EnvironmentObject var profileStore:ProfileStore
    @State var profile:Profile? = nil
    @State var location:String = ""
    @State var distanceFromDevice:String = ""
    @State var loading:Bool = false
    @State var gallery:Gallery = Gallery(name:"photo_gallery")
    @State var inNavigation:Bool = false
    
    func onAppear() {
        
        self.loading = true
        
        guard let profile = profile else {
            self.sessionStore.listen()
            guard let user = self.sessionStore.session else { return }
            self.profileStore.getProfileByUserId(userId: user.uid, success: { profile in
                self.profile = profile
                guard let profile = profile else { return }
                self.setProfileLocation(profile: profile)
                self.setProfileDistance(profile: profile)
                self.getGallery(profile: profile)
                self.loading = false
            }, error: { err in
                
            })
            
            return
        }
        
        self.setProfileLocation(profile: profile)
        self.setProfileDistance(profile: profile)
        self.getGallery(profile: profile)
        self.loading = false
        
    }
    
    func isGalleryEmpty(gallery:Gallery) -> Bool {
        var isEmpty = true;
        gallery.photos.forEach{ photo in
            if !photo.url.isEmpty {
                isEmpty = false
            }
        }
        return isEmpty
    }
    
    func galleryView(width:CGFloat) -> some View {
        ZStack {
                ZStack {
                    HStack(spacing:0) {
                        ScrollView(.horizontal, showsIndicators:false) {
                            HStack(spacing:0) {
                                ForEach(self.gallery.photos.indices) { index in
                                    if(URL(string: self.gallery.photos[index].url) != nil) {
                                        Button(action: {
                                            
                                        }, label: {
                                            URLImage(url: URL(string: self.gallery.photos[index].url)!,
                                                     content: { image in
                                                         image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .clipShape(Rectangle())
                                                            .frame(width: width/3, height:width/3)
                                                            .clipped()
                                                     })
                                        })
                                    }
                                }
                            }
                        } //end scroll view
                    }
                }
        }
        .background(Color.gray.opacity(0.02))
    }
    
    func getGallery(profile:Profile) {
        self.getGalleryByID(userId:profile.id ?? "", success: { gall in
            gall.photos.indices.forEach{ index in
                let url = gall.photos[index].url;
                if !url.isEmpty && index != 0 {
                    self.gallery.photos[index].url = gall.photos[index].url
                }
            }
        })
    }
    
    func getGalleryByID(userId:String, success:@escaping ((Gallery)->Void)) {
        self.profileStore.getGallery(userId: userId, galleryName: gallery.name) { _gallery in
            if let gall = _gallery {
                success(gall)
            }
        }
    }
    
    func isMyProfile() -> Bool {
        guard let user = self.sessionStore.session else { return false }
        if(user.uid == (self.profile?.id ?? "")) {
            return true
        }else{
            return false
        }
    }
    
    func setProfileLocation(profile:Profile) {
        self.profileStore.getCityStateForProfile(userId: profile.id ?? "", address: { cityState in
            self.location = cityState
        })
    }
    
    func setProfileDistance(profile:Profile) {
        guard let user = self.sessionStore.session else { return }
        self.profileStore.getLatLonForProfile(userId: profile.id ?? "", coords: { location in
            self.profileStore.getUserDistanceFromLocation(userId: user.uid, locationFrom: location, distance: { dis in
                self.distanceFromDevice = dis
            })
        })
    }
    
    @State var hideNav:Bool = true
    
    var body: some View {
        GeometryReader { geo in
            if self.inNavigation {
                NavigationView {
                    Text("Add profile info")
                    //self.contentSection(width: geo.size.width)
                        .navigationBarTitle("Your profile")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }else{
                Text("Add profile info")
                //self.contentSection(width: geo.size.width)
            }
            
        }
        .onAppear(perform: self.onAppear)
    }
    


    
    
    func profilePhoto(profile:Profile?, width:CGFloat) -> some View {
        Group {
            GeometryReader { geo in
                if(self.hasProfilePhoto()) {
                    URLImage(url: URL(string: profile?.profileURL ?? "" )!,
                             content: { image in
                                 image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(Rectangle())
                                    .frame(width: width/2, height:width/2)
                                    .cornerRadius(3)
                                    .clipped()
                             })
                }else{
                    Image("image-placeholder")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: width/2)
                        .cornerRadius(5)
                        .clipped()
                }
            }
        }
    }
 
    
    func request(profile:Profile) -> some View {
        Button(action:{
            
        }, label: {
            Text("Request \(profile.firstName)'s interest")
                .font(.system(size: 20))
                .fontWeight(.semibold)
                .foregroundColor(.white).frame(minWidth:0, maxWidth: .infinity, minHeight: 60)
        })
        .background(Color("primaryColor"))
        .cornerRadius(50)
    }
    
    @State var isLoadingPlaid:Bool = false
    
 
    
    private func hasProfilePhoto() -> Bool {
        return (self.profile != nil && URL(string: self.profile!.profileURL) != nil)
    }
    
    func avatar(profileURL:URL) -> some View {
        ZStack {
            ThumbnailImageView(imageURL: .constant(profileURL))
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .frame(width:27, height:27)
                        .foregroundColor(.black)
                }.offset(x:10, y:0)
            }
        }
    }
    
    func profileInfo() -> some View {
        VStack() {
            Text("Annalisa")
            Spacer().frame(height:75)
        }
    }
    
    func profilePhoto() -> some View {
        
        Image("image-placeholder")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipped()
    }
    
    
}




struct profileView_Previews: PreviewProvider {
    static var previews: some View {
        profileView()
    }
}
