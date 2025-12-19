//
//  DevSettingsView.swift
//  AIChatCourse
//
//  Created by Tung Le on 8/11/2025.
//
import SwiftUI
import SwiftfulUtilities

struct DevSettingsView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(ABTestManager.self) private var abTestManager
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var createAccountTest: Bool = false
    @State private var onboardingCommunityTest: Bool = false
    @State private var categoryRowTest: CategoryRowTestOption = .default
    @State private var paywallTest: PaywallTestOption = .default
    
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
                loadABTests()
            }
        }
    }
    /// -----> Action
    private func loadABTests() {
        createAccountTest = abTestManager.activeTests.createAccountTest
        onboardingCommunityTest = abTestManager.activeTests.onboardingCommunityTest
        categoryRowTest = abTestManager.activeTests.categoryRowTest
        paywallTest = abTestManager.activeTests.paywallTest
    }
    
    // MARK: Helper - View
    private var backButton: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.black)
            .anyButton {
                onBackButtonPressed()
            }
    }
    /// -----> action
    private func onBackButtonPressed() {
        dismiss()
    }
    
    private var abTestSection: some View {
        Section {
            Toggle("Create Acc Test", isOn: $createAccountTest)
                .onChange(of: createAccountTest, handleCreateAccountChange)
            
            Toggle("Onb Community Test", isOn: $onboardingCommunityTest)
                .onChange(of: onboardingCommunityTest, handleOnbCommunityTestChange)
            
            Picker("Category", selection: $categoryRowTest) {
                ForEach(CategoryRowTestOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .id(option)
                }
            }
            .onChange(of: categoryRowTest, handleOnbCategoryRowOptionChange)
            
            Picker("Paywall", selection: $paywallTest) {
                ForEach(PaywallTestOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .id(option)
                }
            }
            .onChange(of: paywallTest, handlePaywallOptionChange)
            
        } header: {
            Text("AB Tests")
        }
        .font(.caption)
    }
    /// -----> action
    private func handleCreateAccountChange(oldVlalue: Bool, newValue: Bool) {
        updateTest(
            property: &createAccountTest,
            newValue: newValue,
            savedValue: abTestManager.activeTests.createAccountTest,
            updateAction: { tests in
                tests.update(createAccountTest: newValue)
            }
        )
    }
    /// -----> action
    private func handleOnbCommunityTestChange(oldVlalue: Bool, newValue: Bool) {
        updateTest(
            property: &onboardingCommunityTest,
            newValue: newValue,
            savedValue: abTestManager.activeTests.onboardingCommunityTest,
            updateAction: { tests in
                tests.update(onboardingCommunityTest: newValue)
            }
        )
    }
    /// -----> action
    private func handleOnbCategoryRowOptionChange(oldVlalue: CategoryRowTestOption, newValue: CategoryRowTestOption) {
        updateTest(
            property: &categoryRowTest,
            newValue: newValue,
            savedValue: abTestManager.activeTests.categoryRowTest,
            updateAction: { tests in
                tests.update(categoryRowTest: newValue)
            }
        )
    }
    /// -----> action
    private func handlePaywallOptionChange(oldVlalue: PaywallTestOption, newValue: PaywallTestOption) {
        updateTest(
            property: &paywallTest,
            newValue: newValue,
            savedValue: abTestManager.activeTests.paywallTest,
            updateAction: { tests in
                tests.update(paywallTest: newValue)
            }
        )
    }
    /// -----> action - helper
    private func updateTest<Value: Equatable>(
        property: inout Value,
        newValue: Value,
        savedValue: Value,
        updateAction: (inout ActiveABTests) -> Void
    ) {
        if newValue != savedValue {
            do {
                var tests = abTestManager.activeTests
                updateAction(&tests)
                
                try abTestManager.override(updateTests: tests)
            } catch {
                property = savedValue
            }
        }
    }
    
    private var authSection: some View {
        Section {
            let array = authManager.auth?.eventParameters.asAlphabeticallyArray ?? []

            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Auth info")
        }
        .font(.caption)
    }
    
    private var userSection: some View {
        Section {
            let array = userManager.currentUser?.eventParameters.asAlphabeticallyArray ?? []

            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("User info")
        }
    }
    
    private var deviceSection: some View {
        Section {
            let array = Utilities.eventParameters.asAlphabeticallyArray

            ForEach(array, id: \.key) { item in
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
    DevSettingsView()
        .previewEnvironment()
}
