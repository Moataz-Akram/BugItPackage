# BugItPackage

BugItPackage is a Swift package that allows you to easily record and manage bugs in Google Sheets. Future extensions are planned to support integration with Notion and Jira.
Features

## Features
- Record bugs directly to Google Sheets
- upload images to firebase

## Installation
Add the following dependency to your `Package.swift` file:


```swift
.package(url: "https://github.com/Moataz-Akram/BugItPackage.git", from: "1.0.2")
```

## Setup
### 1. Enable Google Sheets API

  1- Go to the Google Cloud Console.
  
  2- Create a new project or select an existing one.
  
  3- Enable the Google Sheets API for your project.
  
  4- Create credentials (OAuth 2.0 Client ID) for iOS.
  
  5- Download the Info.plist file.
  
  6- Add the downloaded Info.plist to your app project.


 ### 2. Set up Firebase

  1- Go to the Firebase Console.
  
  2- Create a new project or select an existing one.
  
  3- Add an iOS app to your Firebase project.
  
  4- Download the GoogleService-Info.plist file.
  
  5- Add the downloaded GoogleService-Info.plist to your Xcode project.

## Usage
### Authentication
Before uploading bugs, users need to authenticate. Use the LoginButton provided by the package to handle the login process:

```swift
import BugItPackage

struct ContentView: View {
    var body: some View {
        LoginButton()
    }
}
```
### Uploading Bugs
Once authenticated, you can use the `BugItManager` to upload bugs to Google Sheets:

```swift
import BugItPackage

let bugItManager = BugItManager()

// Example bug data
let bug = Bug(title: "bug title", description: "bug description", image, yourUIImage)

Task {
  try await bugItManager.uploadBug(bug)
}
```


## Future Extensions
### We're planning to add support for:
- Notion integration
- Jira integration

---

Stay tuned for updates!

Contributing

Contributions are welcome! Please feel free to submit a Pull Request.



