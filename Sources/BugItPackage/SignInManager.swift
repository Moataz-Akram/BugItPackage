//
//  SignInManager.swift
//
//
//  Created by Moataz Akram on 14/09/2024.
//

import UIKit
import GoogleSignIn

protocol SignInManagerProtocol {
    func signIn(presenting viewController: UIViewController)
}

class GoogleSignInManager {
    static let shared = GoogleSignInManager()
    
    private init() {}
    
    func signIn(presenting viewController: UIViewController) {
        // Needed permissions to write on google sheets
        let scopes = [
            "https://www.googleapis.com/auth/spreadsheets",
            "https://www.googleapis.com/auth/drive.file"
        ]
        
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController, hint: nil, additionalScopes: scopes) { signInResult, error in
            if let error {
                print(error)
                return
            }
            // Access token needed for APIs
            // Access token automatically get cached in GIDSignIn no need to handle it manually
            let token = signInResult?.user.accessToken.tokenString ?? ""
            print("token: \(token)")
        }
    }
    
    func shouldShowLogin() -> Bool {
        // Check if we have a stored user
        if let currentUser = GIDSignIn.sharedInstance.currentUser {
            // Check if the access token is expired
            if let expirationDate = currentUser.accessToken.expirationDate, expirationDate > Date() {
                // Token is still valid
                return false
            }
        }
        return true
    }
}
