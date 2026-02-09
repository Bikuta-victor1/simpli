//
//  ExplainResponse.swift
//  simpli
//
//  Created by Victor on 03/02/2026.
//

import Foundation

struct ExplainResponse: Codable {
    let summary: String
    let bullets: [String]
    let actionItems: [String]
    let questions: [String]
    let warnings: [String]?
}

enum ResultTab: String, CaseIterable {
    case summary = "Summary"
    case bullets = "Key Points"
    case actions = "Actions"
    case questions = "Questions"
}
