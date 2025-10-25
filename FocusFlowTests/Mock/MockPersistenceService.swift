//
//  MockPersistenceService.swift
//  FocusFlow
//
//  Created by Okan Orkun on 24.10.2025.
//


import Foundation
import SwiftData
@testable import FocusFlow

final class MockPersistenceService: DataPersistenceService {
    var storage: [any PersistentModel] = []
    var shouldThrowError = false
    var fetchCallCount = 0
    var insertCallCount = 0
    var deleteCallCount = 0
    var saveCallCount = 0
    
    func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T] {
        fetchCallCount += 1
        
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1)
        }
        
        return storage.compactMap { $0 as? T }
    }
    
    func insert<T: PersistentModel>(_ model: T) {
        insertCallCount += 1
        storage.append(model)
    }
    
    func delete<T: PersistentModel>(_ model: T) {
        deleteCallCount += 1
        storage.removeAll { ($0 as? T) === model }
    }
    
    func save() throws {
        saveCallCount += 1
        
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 2)
        }
    }
    
    func reset() {
        storage.removeAll()
        shouldThrowError = false
        fetchCallCount = 0
        insertCallCount = 0
        deleteCallCount = 0
        saveCallCount = 0
    }
}
