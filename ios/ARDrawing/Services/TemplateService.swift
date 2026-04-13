import Foundation
import Combine

protocol TemplateServiceProtocol {
    func fetchTemplates() async throws -> [DrawingTemplate]
}

// MARK: - Remote service (Spring Boot backend)

final class RemoteTemplateService: TemplateServiceProtocol {
    private let baseURL: URL

    init(baseURL: URL = URL(string: "http://localhost:8080/api/v1")!) {
        self.baseURL = baseURL
    }

    func fetchTemplates() async throws -> [DrawingTemplate] {
        let url = baseURL.appendingPathComponent("templates")
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode([DrawingTemplate].self, from: data)
        return decoded
    }
}

// MARK: - Local fallback (bundled SVGs)

final class LocalTemplateService: TemplateServiceProtocol {
    func fetchTemplates() async throws -> [DrawingTemplate] {
        return DrawingTemplate.localSamples
    }
}
