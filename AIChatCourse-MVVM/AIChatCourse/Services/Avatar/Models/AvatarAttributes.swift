//
//  AvatarAttributes.swift
//  AIChatCourse
//
//  Created by Tung Le on 14/10/2025.
//

enum CharacterOption: String, CaseIterable, Hashable, Codable {
    case man, woman, alien, dog, cat
    
    static var `default`: CharacterOption {
        .man
    }
    
    var plural: String {
        switch self {
        case .man:
            return "men"
        case .woman:
            return "women"
        case .alien:
            return "aliens"
        case .dog:
            return "dogs"
        case .cat:
            return "cats"
        }
    }
    
    var startsWithVowel: Bool {
        ["a", "e", "i", "o", "u"].contains(rawValue.lowercased().first!)
    }
    
} /// 🧱

enum CharacterAction: String, CaseIterable, Hashable, Codable {
    case smiling, sitting, eating, drinking, walking, shopping, studying, working, relaxing, fighting, crying
    
    static var `default`: CharacterAction {
        .smiling
    }
    
} /// 🧱

enum CharacterLocation: String, CaseIterable, Hashable, Codable {
    case park, mall, museum, city, desert, forest, space
    
    static var `default`: CharacterLocation {
        .park
    }
    
} /// 🧱

struct AvatarDescriptionBuidlder: Codable {
    let characterOption: CharacterOption
    let characterAction: CharacterAction
    let characterLocation: CharacterLocation
    
    init(characterOption: CharacterOption, characterAction: CharacterAction, characterLocation: CharacterLocation) {
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
    }
    
    init(avatar: AvatarModel) {
        self.characterOption = avatar.characterOption ?? .default
        self.characterAction = avatar.characterAction ?? .default
        self.characterLocation = avatar.characterLocation ?? .default
    }
    
    enum CodingKeys: String, CodingKey {
        case characterOption = "character_option"
        case characterAction = "character_action"
        case characterLocation = "character_location"
    }
    
    var characterDescription: String {
        let prefix = characterOption.startsWithVowel ? "An" : "A"
        return "\(prefix) \(characterOption.rawValue) that is \(characterAction.rawValue) in the \(characterLocation.rawValue)."
    }
    
    var eventParameters: [String: Any] {
        [
            CodingKeys.characterOption.rawValue: characterOption.rawValue,
            CodingKeys.characterAction.rawValue: characterAction.rawValue,
            CodingKeys.characterLocation.rawValue: characterLocation.rawValue,
            "character_description": characterDescription
        ]
    }
} /// 🧱
