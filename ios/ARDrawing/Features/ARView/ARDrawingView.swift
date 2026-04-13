import SwiftUI
import ARKit
import SceneKit

struct ARDrawingView: View {
    let template: DrawingTemplate
    @StateObject private var viewModel: ARDrawingViewModel
    @Environment(\.dismiss) private var dismiss

    init(template: DrawingTemplate) {
        self.template = template
        _viewModel = StateObject(wrappedValue: ARDrawingViewModel(template: template))
    }

    var body: some View {
        ZStack {
            ARSceneView(viewModel: viewModel)
                .ignoresSafeArea()

            VStack {
                topBar
                Spacer()
                if viewModel.showInstructions {
                    instructionBanner
                }
                controlBar
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
            }

            Spacer()

            Text(template.name)
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())

            Spacer()
            Color.clear.frame(width: 44, height: 44) // balance
        }
        .padding()
    }

    // MARK: - Instruction banner

    private var instructionBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "camera.viewfinder")
            Text("Point camera at a flat surface")
                .font(.subheadline)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(.bottom, 8)
        .onTapGesture { viewModel.dismissInstructions() }
    }

    // MARK: - Control bar (scale + rotate)

    private var controlBar: some View {
        HStack(spacing: 24) {
            // Scale
            HStack(spacing: 12) {
                Button { viewModel.decreaseScale() } label: {
                    Image(systemName: "minus.magnifyingglass")
                }
                Button { viewModel.increaseScale() } label: {
                    Image(systemName: "plus.magnifyingglass")
                }
            }

            Divider().frame(height: 24)

            // Rotate
            HStack(spacing: 12) {
                Button { viewModel.rotateLeft() } label: {
                    Image(systemName: "rotate.left")
                }
                Button { viewModel.rotateRight() } label: {
                    Image(systemName: "rotate.right")
                }
            }
        }
        .font(.title2)
        .padding(.horizontal, 28)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding()
    }
}

// MARK: - UIViewRepresentable wrapper for ARSCNView

struct ARSceneView: UIViewRepresentable {
    @ObservedObject var viewModel: ARDrawingViewModel

    func makeCoordinator() -> ARCoordinator {
        ARCoordinator(
            viewModel: viewModel,
            svgName: viewModel.template.svgURL,
            scale: viewModel.scale,
            rotation: viewModel.rotation
        )
    }

    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.delegate = context.coordinator
        arView.automaticallyUpdatesLighting = true
        arView.autoenablesDefaultLighting = true

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        arView.session.run(config)

        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Push the latest values to the coordinator so the AR render thread can read them safely
        context.coordinator.update(scale: viewModel.scale, rotation: viewModel.rotation)
    }
}
