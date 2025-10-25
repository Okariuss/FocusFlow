//
//  SwiftDataPersistenceService.swift
//  FocusFlow
//
//  Created by Okan Orkun on 24.10.2025.
//

import Foundation
import SwiftData

protocol DataPersistenceService {
    func fetch<T: PersistentModel>(_ descriptior: FetchDescriptor<T>) throws -> [T]
    func insert<T: PersistentModel>(_ model: T)
    func delete<T: PersistentModel>(_ model: T)
    func save() throws
}

final class SwiftDataPersistenceService: DataPersistenceService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetch<T: PersistentModel>(_ descriptior: FetchDescriptor<T>) throws -> [T] {
        try modelContext.fetch(descriptior)
    }
    
    func insert<T: PersistentModel>(_ model: T) {
        modelContext.insert(model)
    }
    
    func delete<T: PersistentModel>(_ model: T) {
        modelContext.delete(model)
    }
    
    func save() throws {
        try modelContext.save()
    }
}
