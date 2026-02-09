//
//  ExplainRequest.swift
//  simpli
//
//  Created by Victor on 03/02/2026.
//

import Foundation

struct ExplainRequest: Codable {
    let text: String
    let mode: String
    let safetyContextToggle: Bool
    let clientId: String
    let appVersion: String
    
    init(text: String, mode: ExplanationMode, safetyContextToggle: Bool, clientId: String, appVersion: String) {
        self.text = text
        self.mode = mode.rawValue
        self.safetyContextToggle = safetyContextToggle
        self.clientId = clientId
        self.appVersion = appVersion
    }
}
