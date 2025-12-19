//
//
//  AppDelegate.swift
//  AIChatCourse
//
//  Created by Tung Le on 16/12/2025.
//
import Firebase
import SwiftfulUtilities
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        var config: BuildConfiguration

        #if MOCK
        config = .mock(isSignedIn: true)
        #elseif DEV
        config = .dev
        #else
        config = .prod
        #endif
        
        if Utilities.isUITesting {
            let isSignedIn = ProcessInfo.processInfo.arguments.contains("SIGNED_IN")
            config = .mock(isSignedIn: isSignedIn)
        }
        
        config.configure()
        dependencies = Dependencies(config: config)
        
        return true
    }
    
} /// 🧱

enum BuildConfiguration {
    case mock(isSignedIn: Bool)
    case dev
    case prod
    
    func configure() {
        switch self {
        case .mock/*(let isSignedIn)*/:
            /// Mock build does NOT run Firebase
            break
        case .dev:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        case .prod:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        }
    }
}
