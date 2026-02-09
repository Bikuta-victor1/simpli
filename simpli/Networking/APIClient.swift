//
//  APIClient.swift
//  simpli
//
//  Created by Victor on 03/02/2026.
//

import Foundation

class APIClient {
    static let shared = APIClient()
    
    private let session: URLSession
    private let baseURL: String
    
    init(session: URLSession = .shared, baseURL: String = Configuration.baseURL) {
        self.session = session
        self.baseURL = baseURL
    }
    
    func explain(request: ExplainRequest) async throws -> ExplainResponse {
        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = Configuration.headers
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            throw APIError.decodingError(error)
        }
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Handle errors
            if httpResponse.statusCode != 200 {
                let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
                
                switch httpResponse.statusCode {
                case 400:
                    if let errorResponse = errorResponse {
                        throw APIError.validationError(
                            field: errorResponse.field ?? "unknown",
                            message: errorResponse.message
                        )
                    }
                    throw APIError.httpError(statusCode: 400, message: "Bad request")
                case 429:
                    throw APIError.rateLimited(retryAfter: errorResponse?.retryAfter)
                case 500:
                    if let errorResponse = errorResponse, errorResponse.error == "provider_error" {
                        throw APIError.providerError(errorResponse.message)
                    }
                    throw APIError.serverError(errorResponse?.message ?? "Internal server error")
                default:
                    throw APIError.httpError(
                        statusCode: httpResponse.statusCode,
                        message: errorResponse?.message ?? "Unknown error"
                    )
                }
            }
            
            // Parse success response
            do {
                let response = try JSONDecoder().decode(ExplainResponse.self, from: data)
                return response
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}
