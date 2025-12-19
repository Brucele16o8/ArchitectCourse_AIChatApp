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
                    AppViewForUITesting()
                } else {
                    AppView(viewModel: AppViewViewModel(interactor: CoreInteractor(container: delegate.dependencies.container)))
                }
            }
            .environment(delegate.dependencies.container)
            .environment(delegate.dependencies.logManager)
        }
    }
} // 🧱

struct AppViewForUITesting: View {
    
    @Environment(DependencyContainer.self) private var container
    
    private var startOnCreatAvatar: Bool {
        ProcessInfo.processInfo.arguments.contains("STARTSCREEN_CREATEAVATAR")
    }
    
    var body: some View {
        if startOnCreatAvatar {
            CreateAvatarView(viewModel: CreateAvatarViewModel(interactor: CoreInteractor(container: container)))
        } else {
            AppView(viewModel: AppViewViewModel(interactor: CoreInteractor(container: container)))
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
