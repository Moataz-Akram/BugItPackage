//
//  NetworkService.swift
//
//
//  Created by Moataz Akram on 14/09/2024.
//

import Foundation
import GoogleSignIn

protocol NetworkServiceProtocol {
    func addBug(_ bug: Bug)
}

final class GoogleSheetsNetworkService: NetworkServiceProtocol {
    private let baseURL = "https://sheets.googleapis.com/v4/spreadsheets/"
    private var sheetId = ""
    private var tabId = ""
    private var accessToken: String {
        GIDSignIn.sharedInstance.currentUser?.accessToken.tokenString ?? ""
    }
    
    init(sheetId: String = "1qnzFl2ksZnVcs5bkjHYM6pwgbpU4LKfoT2IXT3Zchhs", tabId: String = "Sheet1") {
        self.sheetId = sheetId
        self.tabId = tabId
    }
    
    func addBug(_ bug: Bug) {
        let urlString = "\(baseURL)\(sheetId)/values/\(tabId):append"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        var request = prepareRequest(url: url)
        
        // Bug Info
        let body: [String: Any] = [
            "values": [[bug.title, bug.description, bug.imageURL]]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making API call: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
                
                if let data = data {
                    if httpResponse.statusCode == 200 {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                                print("Response: \(json)")
                            }
                        } catch {
                            print("Error parsing JSON: \(error)")
                        }
                    } else {
                        if let errorMessage = String(data: data, encoding: .utf8) {
                            print("Error message: \(errorMessage)")
                        }
                    }
                }
            }
        }
        task.resume()

    }
    
    private func prepareRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Query parameters may vary depending on the API addBug, createSpreadSheet, createSheetTab, ...
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "valueInputOption", value: "RAW"),
            URLQueryItem(name: "insertDataOption", value: "INSERT_ROWS")
        ]
        request.url = components?.url
        return request
    }
    
    private func bugsSpreadSheetExists() -> Bool { return false }
    private func createSpreadSheet() {}
    private func todaysSheetTabExists() -> Bool { return false }
    private func createSheetTab() {} // and add append columns title
}
