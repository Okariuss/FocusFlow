//
//  ArrayExtensionTests.swift
//  FocusFlow
//
//  Created by Okan Orkun on 23.10.2025.
//

import Testing
@testable import FocusFlow

@Suite("Array Extension Tests")
struct ArrayExtensionTests {
    
    @Test("uniqued removes duplicates")
    func testUniquedRemovesDuplicates() async throws {
        let array = [1, 2, 2, 3, 3, 3]
        #expect(array.uniqued() == [1, 2, 3])
    }
    
    @Test("uniqued keeps order of first appearances")
    func testUniquedOrderPreserved() async throws {
        let array = ["b", "a", "b", "c"]
        #expect(array.uniqued() == ["b", "a", "c"])
    }
}
