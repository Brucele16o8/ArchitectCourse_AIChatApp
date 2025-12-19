//
//  CreateAvatar.swift
//  AIChatCourse
//
//  Created by Tung Le on 14/10/2025.
//

import SwiftUI

struct CreateAvatarView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var viewModel: CreateAvatarViewModel
    
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
            .showCustomAlert(alert: $viewModel.showAlert)
            .screenAppearAnalytics(name: "CreateAvatarView")
        }
    }
    
    // MARK: - Helper Views
    private var backButton: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.semibold)
            .anyButton(.plain) {
                viewModel.onBackButtonPressed(onDismiss: {
                    dismiss()
                })
            }
    }
    
    private var nameSection: some View {
        Section {
            TextField("Player 1", text: $viewModel.avatarName)
        } header: {
            Text("NAME YOUR AVATAR*")
                .lineLimit(1)
                .minimumScaleFactor(0.3)
        }
    }
    
    private var atributesSection: some View {
        Section {
            Picker(selection: $viewModel.characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text("\(option.rawValue.capitalized)")
                        .tag(option)
                }
            } label: {
                Text("is a...")
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
            }
            
            Picker(selection: $viewModel.characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { option in
                    Text("\(option.rawValue.capitalized)")
                        .tag(option)
                }
            } label: {
                Text("is a...")
            }
            
            Picker(selection: $viewModel.characterLocation) {
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
                            viewModel.onGeneratingImagePressed()
                        }
                        .opacity(viewModel.isGenerating ? 0 : 1)
                    
                    ProgressView()
                        .tint(.accent)
                        .opacity(viewModel.isGenerating ? 1 : 0)
                }
                .disabled(viewModel.isGenerating || viewModel.avatarName.isEmpty)
                
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .overlay {
                        ZStack {
                            if let generatedImage = viewModel.generatedImage {
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
                isLoading: viewModel.isSaving,
                title: "Save",
                action: {
                    viewModel.onSavePressed(onDismiss: {
                        dismiss()
                    })
                }
            )
            .removeListRowFormatting()
            .opacity(viewModel.generatedImage == nil ? 0.5 : 1.0)
            .disabled(viewModel.generatedImage == nil)
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
    }
    
} // 🧱

#Preview {
    CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
        .createAvatarView()
        .previewEnvironment()
}
