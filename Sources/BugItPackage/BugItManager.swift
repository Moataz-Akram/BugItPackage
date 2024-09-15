//
//  BugItManager.swift
//
//
//  Created by Moataz Akram on 15/09/2024.
//

import SwiftUI
import FirebaseStorage

final public class BugItManager {
    public static let shared = BugItManager()

    private init() {}
        
    public func uploadImage(image: UIImage?) {
        print("compressing")
        guard let imageData = compressImage(image) else {
            // Error
            return
        }
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("Images/\(UUID().uuidString).jpeg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        print("uploading")
        imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                print(error)
                return
            }
            imageRef.downloadURL { (url, error) in
                if let error = error {
                    print(error)
                } else if let url = url {
                    print(url)
                }
            }
        }
    }
    
    // reduce image size
    private func compressImage(_ image: UIImage?, maxSizeKB: Int = 200) -> Data? {
        // Convert to JPEG
        guard var imageData = image?.jpegData(compressionQuality: 0.8) else { return nil }
        
        // If already smaller than maxSizeKB, return the original data
        if imageData.count <= maxSizeKB * 1024 { return imageData }
        
        let minQuality: CGFloat = 0.01
        var maxQuality: CGFloat = 1.0
        var quality: CGFloat = maxQuality
        
        while imageData.count > maxSizeKB * 1024 && maxQuality - minQuality > 0.01 {
            quality = (minQuality + maxQuality) / 2
            guard let newData = image?.jpegData(compressionQuality: quality) else { return nil }
            imageData = newData
            if newData.count <= maxSizeKB * 1024 {
                break
            }
            maxQuality = quality
        }
        
        return imageData
    }

}
