//
//  Helpers.swift
//  ArchitectureBootcamp
//
//  Created by Tung Le on 3/12/2025.
//
import SwiftUI

struct ProductArray: Codable {
    let products: [Product]
}
struct Product: Codable, Identifiable {
    let id: Int
    let title: String
}

protocol DataService {
    func getProducts() async throws -> [Product]
}

struct MockDataService: DataService {
    func getProducts() async throws -> [Product] {
        guard let url = URL(string: "https://dummyjson.com/products") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let products = try JSONDecoder().decode(ProductArray.self, from: data).self
        return products.products
    }
}
