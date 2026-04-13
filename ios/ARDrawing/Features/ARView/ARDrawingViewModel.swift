import Foundation
import ARKit
import Combine
import SwiftUI

@MainActor
final class ARDrawingViewModel: ObservableObject {
    let template: DrawingTemplate

    @Published var scale: Float = 1.0
    @Published var rotation: Float = 0.0
    @Published var isPlaced = false
    @Published var showInstructions = true

    init(template: DrawingTemplate) {
        self.template = template
    }

    func increaseScale() {
        scale = min(scale + 0.1, 3.0)
    }

    func decreaseScale() {
        scale = max(scale - 0.1, 0.2)
    }

    func rotateLeft() {
        rotation -= .pi / 12  // -15°
    }

    func rotateRight() {
        rotation += .pi / 12  // +15°
    }

    func dismissInstructions() {
        withAnimation { showInstructions = false }
    }
}
