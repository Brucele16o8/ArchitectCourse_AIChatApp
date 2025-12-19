//
//  CreateAvatarViewModel.swift
//  AIChatCourse
//
//  Created by Tung Le on 13/12/2025.
//
import SwiftUI

@MainActor
protocol CreateAvatarInteractor {
    func trackEvent(event: LoggableEvent)
    func generateImage(input: String) async throws -> UIImage
    func getAuthId() throws -> String
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws
}

extension CoreInteractor: CreateAvatarInteractor { }

@Observable
@MainActor
class CreateAvatarViewModel {
    let interactor: CreateAvatarInteractor
    
    private(set) var isGenerating: Bool = false
    private(set) var generatedImage: UIImage?
    private(set) var isSaving: Bool = false
    
    var characterOption: CharacterOption = .default
    var characterAction: CharacterAction = .default
    var characterLocation: CharacterLocation = .default
    var showAlert: AnyAppAlert?
    var avatarName: String = ""
    
    init(interactor: CreateAvatarInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - Helper methods
    func onBackButtonPressed(onDismiss: () -> Void) {
        interactor.trackEvent(event: Event.backButtonPressed)
        onDismiss()
    }
    
    func onGeneratingImagePressed() {
        isGenerating = true
        interactor.trackEvent(event: Event.generateImageStart)
        
        Task {
            do {
                let avatarDescriptionBuidlder = AvatarDescriptionBuidlder(
                    characterOption: characterOption,
                    characterAction: characterAction,
                    characterLocation: characterLocation
                )
                let prompt = avatarDescriptionBuidlder.characterDescription
                
                generatedImage = try await interactor.generateImage(input: prompt)
                interactor.trackEvent(event: Event.generateImageSuccess(avatarDescriptionBuidlder: avatarDescriptionBuidlder))

            } catch {
                interactor.trackEvent(event: Event.generateImageFail(error: error))
            }
            
            isGenerating = false
        }
    }
    
    func onSavePressed(onDismiss: @escaping () -> Void) {
        interactor.trackEvent(event: Event.saveAvatarStart)
        guard let generatedImage else { return }
        
        isSaving = true
        
        Task {
            do {
                try TextValidationHelper.checkIfTextIsValid(text: avatarName, minimumCharacterCount: 3)
                let uid = try interactor.getAuthId()

                let avatar = AvatarModel.newAvatar(
                    name: avatarName,
                    option: characterOption,
                    action: characterAction,
                    location: characterLocation,
                    authorId: uid
                )
                
                try await interactor.createAvatar(avatar: avatar, image: generatedImage)
                interactor.trackEvent(event: Event.saveAvatarSuccess(avatarModel: avatar))
                
                /// Dismiss Screen
                onDismiss()
            } catch {
                showAlert = AnyAppAlert(error: error)
                interactor.trackEvent(event: Event.saveAvatarFail(error: error))
            }
            
            isSaving = false
        }
    }
    
    // MARK: - Events
    enum Event: LoggableEvent {
        case backButtonPressed
        case generateImageStart
        case generateImageSuccess(avatarDescriptionBuidlder: AvatarDescriptionBuidlder)
        case generateImageFail(error: Error)
        case saveAvatarStart
        case saveAvatarSuccess(avatarModel: AvatarModel)
        case saveAvatarFail(error: Error)
        
        var eventName: String {
            switch self {
            case .backButtonPressed:            return "CreateAvatarView_BackButton_Pressed"
            case .generateImageStart:           return "CreateAvatarView_GenImage_Start"
            case .generateImageSuccess:         return "CreateAvatarView_GenImage_Success"
            case .generateImageFail:            return "CreateAvatarView_GenImage_Fail"
            case .saveAvatarStart:              return "CreateAvatarView_SaveAvatar_Start"
            case .saveAvatarSuccess:            return "CreateAvatarView_SaveAvatar_Success"
            case .saveAvatarFail:               return "CreateAvatarView_SaveAvatar_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .generateImageSuccess(avatarDescriptionBuidlder: let avatarDescriptionBuidlder):
                return avatarDescriptionBuidlder.eventParameters
            case .saveAvatarSuccess(avatarModel: let avatar):
                return avatar.eventParameters
            case .generateImageFail(error: let error), .saveAvatarFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .generateImageFail:
                return .severe
            case .saveAvatarFail:
                return .warning
            default:
                return .analytic
            }
        }
    }
}
