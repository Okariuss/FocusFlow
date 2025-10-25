//
//  HapticFeedbackService.swift
//  FocusFlow
//
//  Created by Okan Orkun on 24.10.2025.
//

import UIKit

protocol HapticFeedbackProviding {
    func success()
    func light()
    func medium()
}

final class HapticFeedbackService: HapticFeedbackProviding {
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
