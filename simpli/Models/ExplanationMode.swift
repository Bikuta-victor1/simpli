//
//  ExplanationMode.swift
//  simpli
//
//  Created by Victor on 03/02/2026.
//

import Foundation

enum ExplanationMode: String, CaseIterable, Identifiable, Codable {
    case simple = "simple"
    case bullets = "bullets"
    case actions = "actions"
    case eli12 = "eli12"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .simple: return "Simple"
        case .bullets: return "Bullet Points"
        case .actions: return "Action Items"
        case .eli12: return "Explain Like I'm 12"
        }
    }
    
    var icon: String {
        switch self {
        case .simple: return "text.bubble"
        case .bullets: return "list.bullet"
        case .actions: return "checkmark.circle"
        case .eli12: return "face.smiling"
        }
    }
}
