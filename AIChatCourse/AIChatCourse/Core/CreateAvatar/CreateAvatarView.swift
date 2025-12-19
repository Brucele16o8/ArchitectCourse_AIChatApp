//
//  CreateAvatar.swift
//  AIChatCourse
//
//  Created by Tung Le on 14/10/2025.
//

import SwiftUI

struct CreateAvatarView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AIManager.self) private var aiManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager
    
    @State private var avatarName: String = ""
    @State private var characterOption: CharacterOption = .default
    @State private var characterAction: CharacterAction = .default
    @State private var characterLocation: CharacterLocation = .default
    
    @State private var isGenerating: Bool = false
    @State private var generatedImage: UIImage?
    
    @State private var isSaving: Bool = false
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        NavigationStack {
            List {
                nameSection
                atributesSection
                imageSection
                saveSection
            }
            .navigationTitle("Create Avatar")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
            }
            .showCustomAlert(alert: $showAlert)
            .screenAppearAnalytics(name: "CreateAvatarView")
        }
    }
    
    // MARK: - Helper Views
    private var backButton: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.semibold)
            .anyButton(.plain) {
                onBackButtonPressed()
            }
    }
    
    private var nameSection: some View {
        Section {
            TextField("Player 1", text: $avatarName)
        } header: {
            Text("NAME YOUR AVATAR*")
                .lineLimit(1)
                .minimumScaleFactor(0.3)
        }
    }
    
    private var atributesSection: some View {
        Section {
            Picker(selection: $characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text("\(option.rawValue.capitalized)")
                        .tag(option)
                }
            } label: {
                Text("is a...")
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
            }
            
            Picker(selection: $characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { option in
                    Text("\(option.rawValue.capitalized)")
                        .tag(option)
                }
            } label: {
                Text("is a...")
            }
            
            Picker(selection: $characterLocation) {
                ForEach(CharacterLocation.allCases, id: \.self) { option in
                    Text("\(option.rawValue.capitalized)")
                        .tag(option)
                }
            } label: {
                Text("in the...")
            }

        } header: {
            Text("ATTRIBUTES")
        }
    }
    
    private var imageSection: some View {
        Section {
            HStack(alignment: .top) {
                ZStack {
                    Text("  Generate image")
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)
                        .underline()
                        .foregroundStyle(.accent)
                        .anyButton {
                            onGeneratingImagePressed()
                        }
                        .opacity(isGenerating ? 0 : 1)
                    
                    ProgressView()
                        .tint(.accent)
                        .opacity(isGenerating ? 1 : 0)
                }
                .disabled(isGenerating || avatarName.isEmpty)
                
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .overlay {
                        ZStack {
                            if let generatedImage {
                                Image(uiImage: generatedImage)
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                    .clipShape(Circle())
                    .frame(maxWidth: .infinity, maxHeight: 400)
            }
            .removeListRowFormatting()
        }
    }
    
    private var saveSection: some View {
        Section {
            AsyncCallToActionButton(
                isLoading: isSaving,
                title: "Save",
                action: onSavePressed
            )
            .removeListRowFormatting()
            .opacity(generatedImage == nil ? 0.5 : 1.0)
            .disabled(generatedImage == nil)
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
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
    
    // MARK: - Helper methods
    private func onBackButtonPressed() {
        logManager.trackEvent(event: Event.backButtonPressed)
        dismiss()
    }
    
    private func onGeneratingImagePressed() {
        isGenerating = true
        logManager.trackEvent(event: Event.generateImageStart)
        
        Task {
            do {
                let avatarDescriptionBuidlder = AvatarDescriptionBuidlder(
                    characterOption: characterOption,
                    characterAction: characterAction,
                    characterLocation: characterLocation
                )
                let prompt = avatarDescriptionBuidlder.characterDescription
                
                generatedImage = try await aiManager.generateImage(input: prompt)
                logManager.trackEvent(event: Event.generateImageSuccess(avatarDescriptionBuidlder: avatarDescriptionBuidlder))

            } catch {
                logManager.trackEvent(event: Event.generateImageFail(error: error))
            }
            
            isGenerating = false
        }
    }
    
    private func onSavePressed() {
        logManager.trackEvent(event: Event.saveAvatarStart)
        guard let generatedImage else { return }
        
        isSaving = true
        
        Task {
            do {
                try TextValidationHelper.checkIfTextIsValid(text: avatarName, minimumCharacterCount: 3)
                let uid = try authManager.getAuthId()

                let avatar = AvatarModel.newAvatar(
                    name: avatarName,
                    option: characterOption,
                    action: characterAction,
                    location: characterLocation,
                    authorId: uid
                )
                
                try await avatarManager.createAvatar(avatar: avatar, image: generatedImage)
                logManager.trackEvent(event: Event.saveAvatarSuccess(avatarModel: avatar))
                
                /// Dismiss Screen
                dismiss()
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.saveAvatarFail(error: error))
            }
            
            isSaving = false
        }
    }
    
} // 🧱

#Preview {
    CreateAvatarView()
        .environment(AIManager(service: MockAIService()))
        .environment(AvatarManager(service: MockAvatarService()))
        .environment(AuthManager(service: MockAuthService()))
        .previewEnvironment()
}
