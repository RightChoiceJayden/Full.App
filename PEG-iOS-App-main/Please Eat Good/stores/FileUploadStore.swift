//
//  FileUploadStore.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/30/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation
import Firebase

class FileUploadStore : HTTPErrorHandler, ObservableObject {
    
    let storage:Storage = Storage.storage()
    
    func uploadImg(imageUpload:ImageUploadFile, success:((_ fileURL:String?) -> Void)? = nil, failed:((Error)->Void)? = nil, percentComplete:@escaping ((Double)->Void)) {

        let storageRef = self.storage.reference()
        guard let image = imageUpload.image else { return }
        let data = image.jpegData(compressionQuality: 0.1)
        
        if let data = data {
            let riversRef = storageRef.child("\(imageUpload.folderName)/\(imageUpload.imageName).jpg")
            
            let dd = riversRef.putData(data, metadata: nil)
            dd.observe(.progress) { snapshot in
                // A progress event occured
                let percentCompleteNumber = 100.0 * Double(snapshot.progress!.completedUnitCount)
                   / Double(snapshot.progress!.totalUnitCount)
                percentComplete(percentCompleteNumber)
                
            }
            dd.observe(.success) { snapshot in
              // Upload completed successfully
                riversRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        if let error = error {
                            self.displayErrorAlert(error)
                            if let failed = failed {
                                failed(error)
                            }
                        }
                        
                        return
                    }
                    if let success = success {
                        success(downloadURL.absoluteString)
                    }
                }
            }
            
            dd.observe(.failure) { snapshot in
                if let error = snapshot.error as NSError? {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                  // File doesn't exist
                    self.displayErrorAlert(error)
                  break
                case .unauthorized:
                  // User doesn't have permission to access file
                    self.displayErrorAlert(error)
                  break
                case .cancelled:
                  // User canceled the upload
                    self.displayErrorAlert(error)
                  break
                case .unknown:
                  // Unknown error occurred, inspect the server response
                    self.displayErrorAlert(error)
                  break
                default:
                  // A separate error occurred. This is a good place to retry the upload.
                    self.displayErrorAlert(error)
                  break
                }
              }
            }
            
        }
    }
    
}
