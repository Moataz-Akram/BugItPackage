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
                //TODO: handle error
                return
            }
            // Access token needed for APIs
            // Access token automatically get cached in GIDSignIn no need to handle it manually
            let token = signInResult?.user.accessToken.tokenString ?? ""
            print("token: \(token)")
        }
    }
}
