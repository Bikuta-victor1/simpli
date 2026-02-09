//
//  HomeViewModel.swift
//  simpli
//
//  Created by Victor on 03/02/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var selectedMode: ExplanationMode = .simple
    @Published var selectedSafetyContexts: Set<SafetyContext> = []
    @Published var isExplaining: Bool = false
    @Published var errorMessage: String?
    @Published var result: ExplainResponse?
    @Published var showResult: Bool = false
    
    private let maxCharacterLimit = 4000
    
    var characterCount: Int {
        inputText.count
    }
    
    var maxCharacterLimitValue: Int {
        maxCharacterLimit
    }
    
    var isOverLimit: Bool {
        characterCount > maxCharacterLimit
    }
    
    var canExplain: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !isOverLimit
            && !isExplaining
    }
    
    var validationMessage: String? {
        if inputText.isEmpty {
            return nil
        }
        if isOverLimit {
            return "Text is too long. Please shorten to \(maxCharacterLimit) characters."
        }
        return nil
    }
    
    func clearInput() {
        inputText = ""
        errorMessage = nil
    }

    func toggleSafetyContext(_ context: SafetyContext) {
        if selectedSafetyContexts.contains(context) {
            selectedSafetyContexts.remove(context)
        } else {
            selectedSafetyContexts.insert(context)
        }
    }
    
    func explain() async {
        guard canExplain else { return }
        
        isExplaining = true
        errorMessage = nil
        
        do {
            let response = try await ExplainService.shared.explain(
                text: inputText.trimmingCharacters(in: .whitespacesAndNewlines),
                mode: selectedMode,
                safetyContextToggle: !selectedSafetyContexts.isEmpty
            )
            
            result = response
            showResult = true
        } catch let error as APIError {
            handleError(error)
        } catch {
            errorMessage = "An unexpected error occurred"
        }
        
        isExplaining = false
    }
    
    private func handleError(_ error: APIError) {
        switch error {
        case .rateLimited(let retryAfter):
            if let retryAfter = retryAfter {
                let hours = retryAfter / 3600
                errorMessage = "Rate limit reached. You can make more requests in \(hours) hours."
            } else {
                errorMessage = "Rate limit reached. Please try again tomorrow."
            }
        case .validationError(let field, let message):
            errorMessage = "\(field.capitalized): \(message)"
        case .networkError:
            errorMessage = "No internet connection. Your request will be processed when you're back online."
        default:
            errorMessage = error.errorDescription
        }
    }
}
