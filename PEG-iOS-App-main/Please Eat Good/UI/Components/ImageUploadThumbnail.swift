//
//  ImageUploadThumbnail.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/30/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
import SwiftUI
import AVFoundation

enum ImageSource {
    case gallery, camera
}
enum CameraOverlay {
    case id, ticket, none
}

struct ImageUploadThumbnail: View {
    @State private var isImageGalleryOpen:Bool = false
    @State private var selectedImage:UIImage? = nil
    @State private var uploadedImageThumbnail:Image? = nil
    @Binding var onSelected:((UIImage)->Void)
    var defaultButtonLabel:AnyView? = nil
    var afterSelectButtonLabel:AnyView? = nil
    @State var imageSource:ImageSource = .gallery
    @State var cameraOverlay:CameraOverlay = .none
    var body: some View {
        ZStack {
            Button(action:{
                self.isImageGalleryOpen.toggle()
            }, label:{
                if self.selectedImage == nil {
                    ZStack {
                        Group {
                            if self.defaultButtonLabel != nil {
                                self.defaultButtonLabel
                            }else{
                                Circle().stroke(Color("textColor"), lineWidth: 1) .frame(width:90, height:90).foregroundColor(Color.black)
                                VStack(spacing:0) {
                                    Text("+").foregroundColor(Color("textColor"))
                                    Text("upload").font(.system(size: 12, weight: .light, design: .default)).foregroundColor(Color("textColor"))
                                }
                            }
                        }
                    }
                }else{
                    if self.afterSelectButtonLabel != nil {
                        self.afterSelectButtonLabel
                    }else{
                        ZStack {

                            Image(uiImage: self.selectedImage!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .frame(width: 100, height: 100, alignment: .center)
                                .clipped()
                                .shadow(radius: 10.0)
                            HStack {
                                Spacer()
                                ZStack {
                                    Circle()
                                        .frame(width:27, height:27)
                                        .foregroundColor(.black)
                                    Image(systemName: "plus.circle.fill")
                                        .resizable()
                                        .frame(width:25, height:25)
                                }.offset(x:10, y:0)
                            }
                        }
                    }

                }
            })
        }.sheet(isPresented: self.$isImageGalleryOpen, onDismiss: onSelectedImage) {
            if self.imageSource == .gallery {
                ImagePickerView(image: self.$selectedImage)
            }
            if self.imageSource == .camera {
                CustomCameraPhotoView(captuedPhoto: self.$selectedImage, cameraOverlay: self.$cameraOverlay)
            }
           
        }
    }
    private func onSelectedImage() {
        if let selectedImage = self.selectedImage {
            self.onSelected(selectedImage)
            self.uploadedImageThumbnail = Image(uiImage: selectedImage)
        }
    }
}
 
struct CustomCameraPhotoView: View {
    @State private var image: Image?
    @State private var showingCustomCamera = true
    @State private var inputImage: UIImage?
    @Binding var captuedPhoto : UIImage?
    @Binding var cameraOverlay:CameraOverlay
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    CustomCameraView(image: self.$captuedPhoto, cameraOverlay: self.$cameraOverlay)
                }
                
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}


struct CustomCameraView: View {
    
    @Binding var image: UIImage?
    @State var didTapCapture: Bool = false
    @Binding var cameraOverlay:CameraOverlay
    
    var body: some View {
        ZStack() {
            CustomCameraRepresentable(image: self.$image, didTapCapture: $didTapCapture)
            if self.cameraOverlay == .id {
                Image("id_camera_overlay")
                    .opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
            }
            if self.cameraOverlay == .ticket {
                Image("ticket_camera_overlay")
                    .opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
            }
            VStack {
                Spacer()
                CaptureButtonView().onTapGesture {
                    self.didTapCapture = true
                }
            }.offset(x: 0, y: -100)
        }
    }
    
}


struct CustomCameraRepresentable: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    @Binding var didTapCapture: Bool
    
    func makeUIViewController(context: Context) -> CustomCameraController {
        let controller = CustomCameraController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ cameraViewController: CustomCameraController, context: Context) {
        
        if(self.didTapCapture) {
            cameraViewController.didTapRecord()
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
        let parent: CustomCameraRepresentable
        
        init(_ parent: CustomCameraRepresentable) {
            self.parent = parent
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            
            parent.didTapCapture = false
            
            if let imageData = photo.fileDataRepresentation() {
                parent.image = UIImage(data: imageData)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

class CustomCameraController: UIViewController {
    
    var image: UIImage?
    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    //DELEGATE
    var delegate: AVCapturePhotoCaptureDelegate?
    
    func didTapRecord() {
        
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: delegate!)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    func setup() {
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
                                                                      mediaType: AVMediaType.video,
                                                                      position: AVCaptureDevice.Position.unspecified)
        for device in deviceDiscoverySession.devices {
            
            switch device.position {
            case AVCaptureDevice.Position.front:
                self.frontCamera = device
            case AVCaptureDevice.Position.back:
                self.backCamera = device
            default:
                break
            }
        }
        
        self.currentCamera = self.backCamera
    }
    
    
    func setupInputOutput() {
        do {
            
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
            
        } catch {
            print(error)
        }
        
    }
    
    func setupPreviewLayer()
    {
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        
    }
    func startRunningCaptureSession(){
        captureSession.startRunning()
    }
}


struct CaptureButtonView: View {
    @State private var animationAmount: CGFloat = 1
    var body: some View {
        Image(systemName: "camera.circle.fill").font(.largeTitle)
            .padding(30)
            .background(Color.red)
            .foregroundColor(.white)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.red)
        )
            .onAppear
            {
                self.animationAmount = 2
        }
    }
}
