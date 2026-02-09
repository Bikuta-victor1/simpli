//
//  SafetyContext.swift
//  simpli
//

import Foundation

enum SafetyContext: String, CaseIterable, Identifiable {
    case legal = "legal"
    case medical = "medical"
    case financial = "financial"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .legal: return "Legal"
        case .medical: return "Medical"
        case .financial: return "Financial"
        }
    }

    var icon: String {
        switch self {
        case .legal: return "scale.3d"
        case .medical: return "cross.case"
        case .financial: return "dollarsign"
        }
    }
}
