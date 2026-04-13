import ARKit
import SceneKit
import UIKit

/// Bridges ARSCNView events into ARDrawingViewModel. One coordinator per AR session.
final class ARCoordinator: NSObject, ARSCNViewDelegate {
    private weak var viewModel: ARDrawingViewModel?
    private var overlayNode: SCNNode?

    // Thread-safe mirrors — written on the main actor via update(scale:rotation:),
    // read on the AR render thread inside renderer(_:didUpdate:).
    var currentScale: Float = 1.0
    var currentRotation: Float = 0.0
    var templateSVGName: String = ""

    init(viewModel: ARDrawingViewModel, svgName: String, scale: Float, rotation: Float) {
        self.viewModel = viewModel
        self.templateSVGName = svgName
        self.currentScale = scale
        self.currentRotation = rotation
    }

    /// Called from the main actor (ARSceneView.updateUIView) to push new values.
    func update(scale: Float, rotation: Float) {
        currentScale = scale
        currentRotation = rotation
    }

    // MARK: - Plane detected → place drawing overlay

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
              overlayNode == nil else { return }

        DispatchQueue.main.async { [weak viewModel] in viewModel?.isPlaced = true }

        let svgNode = buildSVGOverlayNode(
            svgName: templateSVGName,
            width: CGFloat(planeAnchor.planeExtent.width),
            height: CGFloat(planeAnchor.planeExtent.height)
        )
        node.addChildNode(svgNode)
        overlayNode = svgNode
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
              let overlay = overlayNode else { return }

        // Keep overlay centred on the plane as ARKit refines it
        overlay.simdPosition = simd_float3(
            planeAnchor.center.x,
            0,
            planeAnchor.center.z
        )

        // Apply user adjustments using the thread-safe mirrors
        overlay.scale = SCNVector3(currentScale, currentScale, currentScale)
        overlay.eulerAngles.y = currentRotation
    }

    // MARK: - Overlay construction

    /// Renders the SVG as a flat dotted-line texture on a transparent plane.
    /// In production, replace this with a proper SVG renderer (e.g. SVGKit).
    private func buildSVGOverlayNode(svgName: String, width: CGFloat, height: CGFloat) -> SCNNode {
        let side: CGFloat = max(0.2, min(width, height, 0.4))  // clamp 20–40 cm

        let plane = SCNPlane(width: side, height: side)
        plane.cornerRadius = 0

        // Load SVG as an image (must be rasterised in Xcode asset catalog for MVP).
        // When SVGKit is integrated, swap this for a live SVG → UIImage render.
        if let image = UIImage(named: svgName) {
            let material = SCNMaterial()
            material.diffuse.contents = image
            material.isDoubleSided = true
            material.transparency = 0.85           // let physical paper show through
            material.blendMode = .multiply
            plane.materials = [material]
        } else {
            // Fallback: draw dotted grid so the app is always functional
            plane.materials = [dottedMaterial()]
        }

        let node = SCNNode(geometry: plane)
        // Rotate flat onto the horizontal plane
        node.eulerAngles.x = -.pi / 2
        return node
    }

    private func dottedMaterial() -> SCNMaterial {
        let size = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))

            UIColor.blue.withAlphaComponent(0.9).setFill()
            let spacing: CGFloat = 32
            let dotRadius: CGFloat = 3
            var y: CGFloat = spacing / 2
            while y < size.height {
                var x: CGFloat = spacing / 2
                while x < size.width {
                    let rect = CGRect(x: x - dotRadius, y: y - dotRadius,
                                      width: dotRadius * 2, height: dotRadius * 2)
                    ctx.cgContext.fillEllipse(in: rect)
                    x += spacing
                }
                y += spacing
            }
        }

        let mat = SCNMaterial()
        mat.diffuse.contents = image
        mat.isDoubleSided = true
        mat.transparency = 0.8
        return mat
    }
}
