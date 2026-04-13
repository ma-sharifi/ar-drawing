import Foundation

struct DrawingTemplate: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let category: String
    let thumbnailURL: String?
    let svgURL: String
    let isFavorite: Bool

    init(id: String, name: String, category: String, thumbnailURL: String? = nil, svgURL: String, isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.thumbnailURL = thumbnailURL
        self.svgURL = svgURL
        self.isFavorite = isFavorite
    }
}

extension DrawingTemplate {
    static let localSamples: [DrawingTemplate] = [
        DrawingTemplate(id: "train", name: "Train", category: "Vehicles", svgURL: "train"),
        DrawingTemplate(id: "cat", name: "Cat", category: "Animals", svgURL: "cat"),
        DrawingTemplate(id: "house", name: "House", category: "Buildings", svgURL: "house"),
        DrawingTemplate(id: "star", name: "Star", category: "Shapes", svgURL: "star"),
    ]
}
