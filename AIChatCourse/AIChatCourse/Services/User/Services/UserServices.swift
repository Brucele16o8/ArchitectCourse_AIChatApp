//
//  UserServices.swift
//  AIChatCourse
//
//  Created by Tung Le on 23/10/2025.
//
import Foundation

protocol UserServices {
    var remote: RemoteUserService { get }
    var local: LocalUserPersistence { get }
} /// 🧱

struct MockUserServices: UserServices {
    let remote: RemoteUserService
    let local: LocalUserPersistence
    
    init(user: UserModel? = nil) {
        self.remote = MockUserService(user: user)
        self.local = MockUserPersistence(user: user)    }
    
} /// 🧱

struct ProductionUserServices: UserServices {
    let remote: RemoteUserService = FireBaseUserService()
    let local: LocalUserPersistence = FileManagerUserPersistent()
} /// 🧱
