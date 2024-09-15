//
//  Date+Extension.swift
//  
//
//  Created by Moataz Akram on 15/09/2024.
//

import Foundation


extension Date {
    /// Return String representing date in form "d-M-yyyy"
    static func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d-M-yyyy"
        return dateFormatter.string(from: Date())
    }
}
