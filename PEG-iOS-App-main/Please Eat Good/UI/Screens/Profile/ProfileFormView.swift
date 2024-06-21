//
//  ProfileFormView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 2/25/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
import PhoneNumberKit
import SwiftDate
import Firebase
import CurrencyText
import URLImage

// extension for keyboard to dismiss
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ProfileFormView: View {
    
    @State private var firstname:String = ""
    @State private var lastname:String = ""
    @State private var dob:Date = Date()
    @State private var dobString:String = ""
    @State private var phone:String = ""
    @State private var profilePhoto:String = ""
    @State private var bdayTimestamp:Timestamp = Timestamp()
    @State private var bio:String = ""
    @State private var hourlyRate:Int = 1000
    @State private var gender:String = ""
    
    @ObservedObject var fileStore:FileUploadStore = FileUploadStore()
    @EnvironmentObject var profileStore:ProfileStore
    @EnvironmentObject var session:SessionStore
    
    @State var uploadedImage:UIImage? = nil
    @State var data:[String:Any]? = nil
    @State var isUpdating:Bool = false
    @State var didUpdateProfilePicture:Bool = false
    @State var showAlert:Bool = false
    @State var emptyFields:Bool = false
    @State var success:Bool = false
    @State var showPicker:Bool = false
    @State var countryCode:String = "+1"
    @State var alertTitle:String = ""
    @State var alertMessage:String = ""
    @State var phoneNumberError:Bool = false
    let phoneNumberKit = PhoneNumberKit()
    @State var profile:Profile? = nil
    @State private var inputAmount: Double? = 18.94
    @State var cents = 0
    @State var text = "$0.00"
    var locale: Locale = .current
    var isUpdatingProfile:Bool = false
    @State var photo1:ImageUploadFile = ImageUploadFile(folderName:"", imageName:"profilePhoto")
    @State var photos:[GalleryPhoto] = []
    @State var gallery:Gallery = Gallery(name:"photo_gallery")
    
    func onAppear() {
        
        guard let userProfile = self.profileStore.userProfile else { return }
        self.setForm(profile:userProfile)
        self.getGalleryByID(userId:userProfile.id ?? "", success: { gall in
            gall.photos.indices.forEach{ index in
                let url = gall.photos[index].url;
                if !url.isEmpty {
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
    
    func setForm(profile:Profile) {
        self.firstname = profile.firstName
        self.lastname = profile.lastName
        self.phone = profile.phone
        self.dobString = profile.birthday.dateValue().date.toFormat("MM / dd / yyyy")
        self.dob = profile.birthday.dateValue()
        self.bdayTimestamp = Timestamp(date: self.dob)
        self.profilePhoto = profile.profileURL
        self.bio = profile.bio ?? ""
        self.hourlyRate = profile.hourlyPrice
        self.gender = profile.gender
        if let currencyPrice = String(profile.hourlyPrice).asCurrency(locale: locale) {
            self.text = currencyPrice
        }
        
    }
    
    func avatar(profileURL:URL) -> some View {
        ZStack {
            ThumbnailImageView(imageURL: .constant(profileURL))
        }
    }
    
    func content() -> some View {
        ZStack {
            Color("backgroundColor")
            GeometryReader { geo in
                ZStack {
                    ScrollView {
                            VStack(spacing:0) {
                                self.formFields()
                     
                         }.onAppear(perform: onAppear)
                    }
                    
                } //end ZStack
            }
             
            
            ZStack {
                VStack(spacing:0) {
                    Spacer()
                    Divider()
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color("backgroundColor"))
                        self.buttonSaveView()
                    }.frame(height:80)
                }
            }
            self.birthdayPickerView()

        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(self.isUpdatingProfile ? "Update your profile" :  "Create your profile")
        
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
    

    func birthdayPickerView() -> some View {
        ZStack {
            if self.showPicker {
                VStack(alignment:.leading, spacing:0) {
                    Rectangle().foregroundColor(.white).opacity(0.8)
                    VStack(spacing:0) {
                        HStack(spacing:0){
                            Text("What's your birthday?").font(.system(size: 14, weight: .bold, design: .default)).foregroundColor(.white)
                            Spacer()
                            Button(action: {
                                self.updateBday()
                            }, label: {
                                Text("Done")
                            })
                        }
                        .padding(20)
                        .background(Color.black)
                        Rectangle().fill(Color("dividerColor")).frame(height:1)
                    }
                    ZStack(alignment:.topLeading) {
                        if #available(iOS 14.0, *) {
                            DatePicker("", selection: $dob, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .colorInvert()
                        } else {
                            DatePicker("", selection: $dob,  displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .colorInvert()
                        }
                    }
                    .background(Color("secondaryBtnColor"))
                }
            }
        }
    }
    
    
    
    
    
    func userAvatar(photoURL:String) -> some View {
        Group {
            
            if !photoURL.isEmpty {
                ImageUploadThumbnail(onSelected: .constant({ (uiimage) in
                    self.photo1.image = uiimage
                    self.uploadedImage = uiimage
                }),defaultButtonLabel: AnyView(self.avatar(profileURL: URL(string: photoURL)!)), afterSelectButtonLabel: AnyView(self.uploadView(image: photo1.image, progress: $photo1.uploadProgress)), imageSource:.gallery, cameraOverlay: .ticket)
            }else{
                ImageUploadThumbnail(onSelected: .constant({ (uiimage) in
                                     self.didUpdateProfilePicture = true
                                     self.uploadedImage = uiimage
                                 })).frame(width:100, height:100)
            }
        }
    }
    
    func uploadView(image:UIImage?, progress:Binding<Double>) -> some View {
        ZStack {
            Rectangle()
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
                .frame(minWidth:160, maxWidth: .infinity, maxHeight: 200)
            VStack {
                Image(systemName: "camera.viewfinder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width:30)
                Text("Scan ticket")
            }
            if image != nil {
                ZStack {
                    Image(uiImage: image!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .layoutPriority(-1)
                }
                .frame(height:213)
                .clipped()
                .cornerRadius(10)
            }
            //LoadingBar(percentage: progress)
        }
        
    }
    
    func formFields() -> some View {
        VStack{
            HStack {
                TextInputView(label: .constant("FIRST NAME"), placeholder: .constant("John"), value: $firstname)
                TextInputView(label: .constant("LAST NAME"), placeholder: .constant("Doe"), value: $lastname)
            }
            
            Button(action: {
                self.updateBday()
            }, label: {
                TextInputView(label: .constant("DATE OF BIRTH"), placeholder: .constant("MM/DD/YYYY"), value: $dobString)
            }).foregroundColor(Color("textColor"))
            
            TextInputView(label: .constant("PHONE"), placeholder: .constant("555-555-5555"), value: $phone)
            ButtonGroupView(title:"GENDER", labels: ["female", "male"], selected: $gender)
            Divider()
            TextAreaView(label: .constant("ABOUT ME"), placeholder: .constant(""), value: $bio)
        }
    }
    
    var body: some View {
        if self.isUpdatingProfile {
            self.content()
        }else{
            NavigationView {
                self.content()
            }
        }
    }
    
    private func stringToCents(text: String) -> Int {
         let filteredChars = "$.,"
         let string = text.filter { filteredChars.range(of: String($0)) == nil }
         return Int(string)!
     }
    
    private func updateBday() {
        self.hideKeyboard()
        self.showPicker.toggle()
        self.dobString = self.dob.date.toFormat("MM / dd / yyyy")
        self.bdayTimestamp = Timestamp(date: self.dob)
    }
    
    func validate(value: String) -> Bool {
            let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
            let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
            let result = phoneTest.evaluate(with: value)
            return result
    }
    
    private func buttonSaveView() -> some View {
        Button(action:{
            
            var profile = Profile(firstName: self.firstname, lastName: self.lastname, phone: self.phone, birthday: self.bdayTimestamp, profileURL: self.profilePhoto, defaultAddress: self.profile?.defaultAddress, gender: self.gender , bio:self.bio, hourlyPrice:self.stringToCents(text: self.text))
            
            profile.phone = self.phone
            
            guard self.profileStore.getAgeForProfile(profile: profile) >= 18 else {
                self.alertTitle = "Sorry"
                self.alertMessage = "You must be 18 to signup"
                self.showAlert.toggle()
                return
            }
            
            guard !profile.firstName.isEmpty else {
                self.alertTitle = "Sorry"
                self.alertMessage = "First name is required"
                self.showAlert.toggle()
                return
            }
            
            guard !profile.lastName.isEmpty else {
                self.showAlert.toggle()
                self.alertTitle = "Sorry"
                self.alertMessage = "Last name is required"
                return
            }
            
            guard !self.dobString.isEmpty else {
                self.showAlert.toggle()
                self.alertTitle = "Sorry"
                self.alertMessage = "Date of Birth is required"
                return
            }
            
            guard !profile.phone.isEmpty else {
                self.showAlert.toggle()
                self.alertTitle = "Sorry"
                self.alertMessage = "Phone number is required"
                return
            }
            
            guard !profile.gender.isEmpty else {
                self.showAlert.toggle()
                self.alertTitle = "Sorry"
                self.alertMessage = "Gender is required"
                return
            }
            

            
            guard self.validate(value: profile.phone) else {
                self.showAlert.toggle()
                self.alertTitle = "Sorry"
                self.alertTitle = "Phone number should be formmated like this 555-555-5555"
                return
            }
            
            self.save(profile: profile)
            
        }, label: {
            Text(self.isUpdating ? "Saving..." : "Save").fontWeight(.semibold)
                .foregroundColor(.black).frame(minWidth:0, maxWidth: .infinity, minHeight: 45)
        })
        .alert(isPresented: self.$showAlert) {
            Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .default(Text("Done"), action: {
                
            }))
        }
        .background(Color("primaryColor"))
        .cornerRadius(4)
        .padding(.horizontal)
        .disabled(self.isUpdating)
        .opacity(self.isUpdating ? 0.3 : 1)
    }
    
    func centsToDollars(cents:Int) -> String {
       let formatter = NumberFormatter()
        formatter.locale = Locale.current // Change this to another locale if you want to force a specific locale, otherwise this is redundant as the current locale is the default already
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        let number = cents/100
        if let formattedTipAmount = formatter.string(from: number as NSNumber) {
            return formattedTipAmount
        }
        return ""
    }
    
    func save(profile:Profile) {

        var _profile = profile
        
        guard let user = self.session.session else {
            print("No user")
            return
        }
        
        guard let newUploadedImage = self.uploadedImage else {
             self.setProfile(profile:_profile)
             return
        }
        
        let photo:ImageUploadFile = ImageUploadFile(image:newUploadedImage, folderName:user.uid, imageName:"photo1")
        
        self.isUpdating = true
        
        self.fileStore.uploadImg(imageUpload:photo, success: { imageURL in
            if let imageURL = imageURL {
                _profile.profileURL = imageURL
                self.setProfile(profile:_profile)
            }else{
                print("No image URL");
            }
        }, failed:self.onSetDataError, percentComplete: { percentageComplete in
            print(percentageComplete)
        })
        
        
        
        
        

    }
    
    private func isFieldEmpty() -> Bool {
        return self.firstname.isEmpty || self.lastname.isEmpty || self.phone.isEmpty
    }
    
    private func setProfile(profile:Profile) {
        self.isUpdating = true
        self.profileStore.updateOrCreateProfile(profile: profile, success:self.onSetDataSuccess, error:self.onSetDataError)
    }
    
    private func onSetDataSuccess() {
        self.isUpdating = false
        self.alertTitle = "Success"
        self.alertMessage = "Your profile saved"
        self.showAlert.toggle()
    }
    
    private func onSetDataError(error:Error) {
        self.isUpdating = false
        self.alertTitle = "Error"
        self.alertMessage = error.localizedDescription
        self.showAlert.toggle()
    }
    
    private func hasProfilePhoto() -> Bool {
        return (self.profile != nil && URL(string: self.profile!.profileURL) != nil)
    }
}

struct ProfileFormView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileFormView()
            .environmentObject(SessionStore())
            .environmentObject(ProfileStore())
    }
}

struct CurrencyInput: UIViewRepresentable {
    @Binding var text: String // Declare a binding value

    func makeUIView(context: Context) -> UITextField {
        let textField = CurrencyTextField()
        textField.delegate = context.coordinator
        textField.textColor = UIColor(Color("textColor"))
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text // 1. Read the binded
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            self._text = text
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.text = textField.text ?? "" // 2. Write to the binded
            }
        }
    }
}

class CurrencyTextField: UITextField {
    
/// The numbers that have been entered in the text field
    private var enteredNumbers = ""

    private var didBackspace = false

    var locale: Locale = .current

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }

    override func deleteBackward() {
        enteredNumbers = String(enteredNumbers.dropLast())
        text = enteredNumbers.asCurrency(locale: locale)
        // Call super so that the .editingChanged event gets fired, but we need to handle it differently, so we set the `didBackspace` flag first
        didBackspace = true
        super.deleteBackward()
    }

    @objc func editingChanged() {
        defer {
            didBackspace = false
            text = enteredNumbers.asCurrency(locale: locale)
        }

        guard didBackspace == false else { return }

        if let lastEnteredCharacter = text?.last, lastEnteredCharacter.isNumber {
            enteredNumbers.append(lastEnteredCharacter)
        }
    }
}

extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}

private extension Formatter {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
}

extension String {
    func asCurrency(locale: Locale) -> String? {
        Formatter.currency.locale = locale
        if self.isEmpty {
            return Formatter.currency.string(from: NSNumber(value: 0))
        } else {
            return Formatter.currency.string(from: NSNumber(value: (Double(self) ?? 0) / 100))
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
