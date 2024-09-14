//
//  SwiftUIView.swift
//  
//
//  Created by Moataz Akram on 14/09/2024.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift


@available(iOS 15, *)
public struct LoginButtonView: View {
    public init() {}
    let rootVC = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController ?? UIViewController()

    public var body: some View {

        GoogleSignInButton {
            GoogleSignInManager.shared.signIn(presenting: rootVC)
        }
    }
}

#Preview {
    LoginButtonView()
}
