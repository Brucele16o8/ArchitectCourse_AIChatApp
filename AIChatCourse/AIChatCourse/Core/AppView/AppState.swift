//
//  AppState.swift
//  AIChatCourse
//
//  Created by Tung Le on 1/10/2025.
//

import SwiftUI

@Observable
class AppState {
    private(set) var showTabBar: Bool {
        didSet {
            UserDefaults.showTabbarView = showTabBar
        }
    }
    
    init(showTabBar: Bool = UserDefaults.showTabbarView) {
        self.showTabBar = showTabBar
    }
    
    func updateViewState(showTabBarView: Bool) {
        showTabBar = showTabBarView
    }
}

extension UserDefaults {
    
    private struct Keys {
        static let showTabbarView = "showTabbarView"
    }
    
    static var showTabbarView: Bool {
        get {
            standard.bool(forKey: Keys.showTabbarView)
        }
        set {
            standard.set(newValue, forKey: Keys.showTabbarView)
        }
    }
}
