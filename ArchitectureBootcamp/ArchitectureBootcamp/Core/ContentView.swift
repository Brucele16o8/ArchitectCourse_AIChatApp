//
//  ContentView.swift
//  ArchitectureBootcamp
//
//  Created by Tung Le on 3/12/2025.
//

import SwiftUI

/*
    ARCHITECTURE NOTES
    
    1. No Architecture (Vanilla SwiftUI)
    
    - There is no DataManager, Views are responsible for business logic & data logic
    - View holds the arrays of products
 
    Pros:
    - Simplest code
    - Easy to set up, low chance for bugs
 
    Cons:
    - No separation between View and Data layers
    - Not testable, mockable, or reusable
 
    2. MV Architecture (Vanilla SwiftUI)
    
    - DataManager is shared accross the app
    - DataManager is responsible for business logic and data logic
 
    Pros:
    - Less
    - Easy to resuse business logic
 
    Cons:
    - Tighly coupled the business logic to the data logic
    - "Too easy" to reuse data (other View's can affect each other)
    - DataManager is semi-testable
 
    3. MVC Architecture (Vanilla SwiftUI)
    
    - DataManager is shared accross the app
    - There is a DataManager, Views are responsible for business logiv but not data logic
    - View holds the array of products
 
    Pros:
    - DataManager is shared accross the application
    - DataManager is testable, mockable, & reusable
 
    Cons:
    - Business logic is not testable
    - Massive View Controller
 
    4. MVVM Architecture
    
    - DataManager is shared across the app, but access from the ViewModel
    - ViewModels are responsible for business logic
    - ViewModel holds the array of products
 
    Pros:
    - Separated the view from the business logic
    - Business logic is now testable
    - View code is much cleaner
 
    Cons:
    - More difficult to set up and inject dependencies
    - ViewModel lifecycle is outside of View lifecycle (cannot use SwiftUI Property Wrapper)
 */

@Observable
@MainActor
class UserManager {
    func getUser() async throws -> String {
        ""
    }
}

@Observable
@MainActor
class DataManager {
    
    let service: DataService
    
    init(service: DataService) {
        self.service = service
    }
    
    func getProducts() async throws -> [Product] {
        try await service.getProducts()
    }
    
    func getMovies() async throws -> [String] {
        ["MovieA"]
    }
}

// ContentViewModelProtocol, ContentViewModelDelegate, ContentViewModelDependencies, ContentViewModelInteractor
protocol ContentViewModelInteractor {
    func getProducts() async throws -> [Product]
    func getUser() async throws -> String
}
extension CoreInteractor: ContentViewModelInteractor { }

protocol HomeViewModelInteractor {
    func getMovies() async throws -> [String]
    func getUser() async throws -> String
}
extension CoreInteractor: HomeViewModelInteractor { }

protocol SettingsViewModelInteractor {
    func getUser() async throws -> String
}
extension CoreInteractor: SettingsViewModelInteractor { }

@MainActor
struct CoreInteractor {
    let dataManager: DataManager
    let userManager: UserManager
    
    init(container: DependencyContainer) {
        self.dataManager = container.resolve(DataManager.self)!
        self.userManager = container.resolve(UserManager.self)!
    }
    
    func getProducts() async throws -> [Product] {
        try await dataManager.getProducts()
    }
    
    func getUser() async throws -> String {
        try await userManager.getUser()
    }
    
    func getMovies() async throws -> [String] {
        try await dataManager.getMovies()
    }
}

@Observable
@MainActor
class ContentViewModel {
    let interactor: ContentViewModelInteractor
    
    init(interactor: ContentViewModelInteractor) {
        self.interactor = interactor
    }
    
    var products: [Product] = []

    func loadData() async {
        do {
            _ = try await interactor.getUser()
            self.products = try await interactor.getProducts()
        } catch {
            
        }
    }
}

struct ContentView: View {
    @State var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            ForEach(viewModel.products) { product in
                Text(product.title)
            }
        }
        .padding()
        .task {
            await viewModel.loadData()
        }
    }
}

@Observable
@MainActor
class HomeViewModel {
    let interactor: HomeViewModelInteractor
    
    init(interactor: HomeViewModelInteractor) {
        self.interactor = interactor
    }
    
    var movies: [String] = []

    func loadData() async {
        do {
            _ = try await interactor.getUser()
            self.movies = try await interactor.getMovies()
        } catch {
            
        }
    }
}

struct HomeView: View {
    
    @State var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            ForEach(viewModel.movies, id: \.self) { movie in
                Text(movie)
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .task {
            await viewModel.loadData()
        }
    }
}

class DependencyContainer {
    
    private var services: [String: Any] = [:]
    
    func register<T>(_ type: T.Type, service: T) {
        let key = "\(type)"
        services[key] = service
    }
    
    func register<T>(_ type: T.Type, service: () -> T) {
        let key = "\(type)"
        services[key] = service()
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        let key = "\(type)"
        return services[key] as? T
    }
}

#Preview {
    let container = DependencyContainer()
    container.register(DataManager.self, service: DataManager(service: MockDataService()))
    container.register(UserManager.self, service: UserManager())
    
    return ContentView(
        viewModel: ContentViewModel(interactor: CoreInteractor(container: container))
    )
    
//    return HomeView(
//        viewModel: HomeViewModel(interactor: CoreInteractor(container: container))
//    )
}
