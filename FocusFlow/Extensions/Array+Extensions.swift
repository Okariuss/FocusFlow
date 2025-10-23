//
//  Array+Extensions.swift
//  FocusFlow
//
//  Created by Okan Orkun on 22.10.2025.
//

import Foundation

extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
