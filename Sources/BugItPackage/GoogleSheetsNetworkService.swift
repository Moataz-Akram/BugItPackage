//
//  NetworkService.swift
//
//
//  Created by Moataz Akram on 14/09/2024.
//

import Foundation
import GoogleSignIn

protocol NetworkServiceProtocol {
    func uploadBug(_ bug: Bug) async throws
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
    
    func uploadBug(_ bug: Bug) async throws {
        let urlString = "\(baseURL)\(sheetId)/values/\(tabId):append"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = prepareRequest(url: url)
        
        // Bug Info
        let body: [String: Any] = [
            "values": [[bug.title, bug.description, bug.imageURL]]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw NSError(domain: "UploadBugErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error serializing JSON: \(error.localizedDescription)"])
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            print("Response: \(json)")
                        }
                    } catch {
                        throw NSError(domain: "UploadBugErrorDomain", code: 2, userInfo: [NSLocalizedDescriptionKey: "Error parsing JSON: \(error.localizedDescription)"])
                    }
                } else {
                    if let errorMessage = String(data: data, encoding: .utf8) {
                        throw NSError(domain: "UploadBugErrorDomain", code: 3, userInfo: [NSLocalizedDescriptionKey: "Error message: \(errorMessage)"])
                    }
                }
            }
        } catch {
            throw NSError(domain: "UploadBugErrorDomain", code: 4, userInfo: [NSLocalizedDescriptionKey: "Error making API call: \(error.localizedDescription)"])
        }

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
