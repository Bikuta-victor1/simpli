//
//  ResultViewModel.swift
//  simpli
//
//  Created by Victor on 03/02/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ResultViewModel: ObservableObject {
    @Published var response: ExplainResponse
    @Published var selectedTab: ResultTab = .summary
    
    init(response: ExplainResponse) {
        self.response = response
    }
    
    func copyToClipboard() {
        let text = formatForCopy()
        UIPasteboard.general.string = text
    }
    
    func share() {
        // Will be implemented with UIActivityViewController
        let text = formatForCopy()
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
    
    private func formatForCopy() -> String {
        var text = "\(response.summary)\n\n"
        text += "Key Points:\n"
        response.bullets.forEach { text += "• \($0)\n" }
        text += "\nAction Items:\n"
        response.actionItems.forEach { text += "• \($0)\n" }
        text += "\nQuestions:\n"
        response.questions.forEach { text += "• \($0)\n" }
        return text
    }
}
