//
//  ConfirmationConfig.swift
//  FocusFlow
//
//  Created by Okan Orkun on 19.10.2025.
//

import Foundation

struct ConfirmationConfig {
    let title: String
    let message: String
    let confirmTitle: String
    let cancelTitle: String
    
    static let deleteSession = ConfirmationConfig(
        title: "Delete Session",
        message: "Are you sure you want to delete this focus session? This action cannot be undone.",
        confirmTitle: "Delete",
        cancelTitle: "Cancel"
    )
}
