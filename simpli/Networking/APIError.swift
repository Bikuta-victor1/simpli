//
//  APIError.swift
//  simpli
//
//  Created by Victor on 03/02/2026.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingError(Error)
    case networkError(Error)
    case rateLimited(retryAfter: Int?)
    case validationError(field: String, message: String)
    case providerError(String)
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode, let message):
            return "HTTP \(statusCode): \(message)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .rateLimited(let retryAfter):
            if let retryAfter = retryAfter {
                return "Rate limit exceeded. Try again in \(retryAfter) seconds."
            }
            return "Rate limit exceeded. Try again later."
        case .validationError(let field, let message):
            return "\(field): \(message)"
        case .providerError(let message):
            return "AI service error: \(message)"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}

struct ErrorResponse: Codable {
    let error: String
    let message: String
    let field: String?
    let retryAfter: Int?
}
