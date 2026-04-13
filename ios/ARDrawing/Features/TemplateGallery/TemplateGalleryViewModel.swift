import Foundation
import Combine

@MainActor
final class TemplateGalleryViewModel: ObservableObject {
    @Published var templates: [DrawingTemplate] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCategory: String = "All"

    var categories: [String] {
        let cats = templates.map(\.category)
        return ["All"] + Array(Set(cats)).sorted()
    }

    var filtered: [DrawingTemplate] {
        guard selectedCategory != "All" else { return templates }
        return templates.filter { $0.category == selectedCategory }
    }

    private let service: TemplateServiceProtocol

    init(service: TemplateServiceProtocol = LocalTemplateService()) {
        self.service = service
    }

    func loadTemplates() async {
        isLoading = true
        errorMessage = nil
        do {
            templates = try await service.fetchTemplates()
        } catch {
            errorMessage = "Failed to load templates: \(error.localizedDescription)"
            templates = DrawingTemplate.localSamples // fallback
        }
        isLoading = false
    }
}
