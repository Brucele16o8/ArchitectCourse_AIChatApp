//
//  MockUserPersistence.swift
//  AIChatCourse
//
//  Created by Tung Le on 23/10/2025.
//

struct MockUserPersistence: LocalUserPersistence {
    
    let currentUser: UserModel?
    
    init(user: UserModel? = nil) {
        self.currentUser = user
    }
    
    func getCurrentUser() -> UserModel? {
        currentUser
    }
    
    func saveCurrentUser(user: UserModel?) throws {
        
    }
    
}
