//
//  NetworkService.swift
//
//
//  Created by Moataz Akram on 14/09/2024.
//

import Foundation
import GoogleSignIn

protocol NetworkServiceProtocol {
    func uploadBug(_ bug: Bug, date: String) async throws
}

enum googleSheetsAPI {
    case uploadBug
    case createSheetTab
}

final class GoogleSheetsNetworkService: NetworkServiceProtocol {
    private let baseURL = "https://sheets.googleapis.com/v4/spreadsheets/"
    private var todaysTabExists = false
    private var sheetId = ""
    private var tabId = ""
    private var accessToken: String {
        GIDSignIn.sharedInstance.currentUser?.accessToken.tokenString ?? ""
    }
    
    init(sheetId: String = "1qnzFl2ksZnVcs5bkjHYM6pwgbpU4LKfoT2IXT3Zchhs", tabId: String = "Sheet1") {
        self.sheetId = sheetId
        self.tabId = tabId
    }
    
    func uploadBug(_ bug: Bug, date: String) async throws {
        if !todaysTabExists {
            await createSheetTab(sheetTitle: date)
        }
        let urlString = "\(baseURL)\(sheetId)/values/\(date):append"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = prepareRequest(url: url, api: .uploadBug)
        
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
    
    private func createSheetTab(spreadsheetId: String = "1qnzFl2ksZnVcs5bkjHYM6pwgbpU4LKfoT2IXT3Zchhs", sheetTitle: String) async {
        let urlString = "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId):batchUpdate"
        guard let url = URL(string: urlString) else {
            return
        }
        
        var request = prepareRequest(url: url, api: .createSheetTab)

        let body: [String: Any] = [
            "requests": [
                [
                    "addSheet": [
                        "properties": [
                            "title": sheetTitle
                        ]
                    ]
                ]
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch  {
            print(error)
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let replies = json["replies"] as? [[String: Any]],
               let addSheetReply = replies.first?["addSheet"] as? [String: Any],
               let properties = addSheetReply["properties"] as? [String: Any],
               let sheetId = properties["sheetId"] as? Int {
                // success case
                todaysTabExists = true
                print("Sheet ID: \(sheetId)")
            }
            
        } catch {
            print(error)
        }

    }
    
    private func prepareRequest(url: URL, api: googleSheetsAPI) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Query parameters may vary depending on the API addBug, createSpreadSheet, createSheetTab, ...
        switch api {
        case .uploadBug:
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = [
                URLQueryItem(name: "valueInputOption", value: "RAW"),
                URLQueryItem(name: "insertDataOption", value: "INSERT_ROWS")
            ]
            request.url = components?.url
        case .createSheetTab:
            break
        }
        
        return request
    }
    
    private func bugsSpreadSheetExists() -> Bool { return false }
    private func createSpreadSheet() {}
    private func todaysSheetTabExists() -> Bool { return false }
}
