//
//  AIChatCourseApp.swift
//  AIChatCourse
//
//  Created by Tung Le on 29/9/2025.
//

import SwiftUI
import SwiftfulUtilities

@main
struct AppEntryPoint {
    
    static func main() {
        if Utilities.isUnitTesting {
            TestingApp.main()
        } else {
            AIChatCourseApp.main()
        }
    }
}

struct AIChatCourseApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            Group {
                if Utilities.isUITesting {
                    AppViewForUITesting(builder: delegate.builder)
                } else {
                    delegate.builder.appView()
                }
            }
            .environment(delegate.dependencies.logManager)
        }
    }
} // 🧱

struct AppViewForUITesting: View {
    
    var builder: CoreBuilder
    
    private var startOnCreatAvatar: Bool {
        ProcessInfo.processInfo.arguments.contains("STARTSCREEN_CREATEAVATAR")
    }
    
    var body: some View {
        if startOnCreatAvatar {
            builder.createAvatarView()
        } else {
            builder.appView()
        }
    }
}

struct TestingApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Testing!")
        }
    }
}
