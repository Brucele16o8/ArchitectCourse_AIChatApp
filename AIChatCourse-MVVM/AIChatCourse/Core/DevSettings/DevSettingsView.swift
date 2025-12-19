//
//  DevSettingsView.swift
//  AIChatCourse
//
//  Created by Tung Le on 8/11/2025.
//
import SwiftUI

struct DevSettingsView: View {

    @State var viewModel: DevSettingsViewModel
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                abTestSection
                authSection
                userSection
                deviceSection
            }
            .navigationTitle("Dev Settings 🫨")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
            }
            .screenAppearAnalytics(name: "DevSettingsView")
            .onFirstAppear {
                viewModel.loadABTests()
            }
        }
    }
    
    // MARK: Subview
    private var backButton: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.black)
            .anyButton {
                viewModel.onBackButtonPressed(onDismiss: {
                    dismiss()
                })
            }
    }
    
    private var abTestSection: some View {
        Section {
            Toggle("Create Acc Test", isOn: $viewModel.createAccountTest)
                .onChange(of: viewModel.createAccountTest, viewModel.handleCreateAccountChange)
            
            Toggle("Onb Community Test", isOn: $viewModel.onboardingCommunityTest)
                .onChange(of: viewModel.onboardingCommunityTest, viewModel.handleOnbCommunityTestChange)
            
            Picker("Category", selection: $viewModel.categoryRowTest) {
                ForEach(CategoryRowTestOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .id(option)
                }
            }
            .onChange(of: viewModel.categoryRowTest, viewModel.handleOnbCategoryRowOptionChange)
            
            Picker("Paywall", selection: $viewModel.paywallTest) {
                ForEach(PaywallTestOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .id(option)
                }
            }
            .onChange(of: viewModel.paywallTest, viewModel.handlePaywallOptionChange)
            
        } header: {
            Text("AB Tests")
        }
        .font(.caption)
    }
    
    private var authSection: some View {
        Section {
            ForEach(viewModel.authData, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Auth info")
        }
        .font(.caption)
    }
    
    private var userSection: some View {
        Section {
            ForEach(viewModel.userData, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("User info")
        }
    }
    
    private var deviceSection: some View {
        Section {
            ForEach(viewModel.utilitiesData, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Device info")
        }
    }
    
    private func itemRow(item: (key: String, value: Any)) -> some View {
        HStack {
            Text(item.key)
            Spacer(minLength: 4)
            
            if let value = String.convertToString(item.value) {
                Text(value)
            } else {
                Text("Unknown")
            }
        }
        .font(.caption)
        .lineLimit(1)
        .minimumScaleFactor(0.3)
    }
    
}

#Preview {
    DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
        .previewEnvironment()
}
