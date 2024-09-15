//
//  BugItManager.swift
//
//
//  Created by Moataz Akram on 15/09/2024.
//

import SwiftUI
import FirebaseStorage

// the only accessible class from the package
/// BugItManager is responsible for uploading the bugs
final public class BugItManager: ObservableObject {
    public static let shared = BugItManager()
    // Google sheets specific
    @Published public var shouldShowLogin: Bool = false
    private let networkService: NetworkServiceProtocol
    
    // Can work with any other network service if implemented
    private init(networkService: NetworkServiceProtocol = GoogleSheetsNetworkService()) {
        self.networkService = networkService
    }
    
    // MARK: General methods
    public func uploadBug(bug: Bug) async throws {
        var bugInfo = bug
        do {
            let url = try await uploadImage(image: bug.image)
            bugInfo.imageURL = url
            try await networkService.uploadBug(bugInfo)
        }
    }
    
    private func uploadImage(image: UIImage?) async throws -> String {
        print("compressing")
        guard let imageData = compressImage(image) else {
            throw NSError(domain: "UploadImageErrorDomain", code: 3, userInfo: [NSLocalizedDescriptionKey: "failed to convert image to data"])
        }
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("Images/\(UUID().uuidString).jpeg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        print("uploading")
        
        // Upload the image data using continuation
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            imageRef.putData(imageData, metadata: metadata) { metadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
        
        // Get the download URL using continuation
        let urlString = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            imageRef.downloadURL { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let url = url {
                    continuation.resume(returning: url.absoluteString)
                } else {
                    continuation.resume(throwing: NSError(domain: "UploadImageErrorDomain", code: 3, userInfo: [NSLocalizedDescriptionKey: "Download URL retrieval failed"]))
                }
            }
        }
        return urlString
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

    //MARK: Google sheets specific
    public func checkLoginStatus() {
        shouldShowLogin = GoogleSignInManager.shared.shouldShowLogin()
    }
}
