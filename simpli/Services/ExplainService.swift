//
//  ExplainService.swift
//  simpli
//
//  Created by Victor on 03/02/2026.
//

import Foundation

@MainActor
class ExplainService {
    static let shared = ExplainService()
    
    private let apiClient = APIClient.shared
    
    func explain(
        text: String,
        mode: ExplanationMode,
        safetyContextToggle: Bool
    ) async throws -> ExplainResponse {
        let request = ExplainRequest(
            text: text,
            mode: mode,
            safetyContextToggle: safetyContextToggle,
            clientId: DeviceID.shared.id,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        )
        
        return try await apiClient.explain(request: request)
    }
}
