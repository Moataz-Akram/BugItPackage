//
//  BugModel.swift
//
//
//  Created by Moataz Akram on 14/09/2024.
//

import SwiftUI

public struct Bug {
    public var title: String
    public var description: String?
    public var image: UIImage
    public var imageURL: String?
    
    public init(title: String, description: String? = nil, image: UIImage, imageURL: String? = nil) {
        self.title = title
        self.description = description
        self.image = image
        self.imageURL = imageURL
    }
}


