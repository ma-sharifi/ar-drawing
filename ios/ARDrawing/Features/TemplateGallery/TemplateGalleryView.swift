import SwiftUI

struct TemplateGalleryView: View {
    @StateObject private var viewModel = TemplateGalleryViewModel()
    @State private var selectedTemplate: DrawingTemplate?

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                categoryPicker
                templateGrid
            }
            .navigationTitle("Drawing Templates")
            .navigationBarTitleDisplayMode(.large)
            .task { await viewModel.loadTemplates() }
            .overlay {
                if viewModel.isLoading { ProgressView() }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .navigationDestination(item: $selectedTemplate) { template in
                ARDrawingView(template: template)
            }
        }
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.categories, id: \.self) { cat in
                    Button(cat) {
                        viewModel.selectedCategory = cat
                    }
                    .buttonStyle(.bordered)
                    .tint(viewModel.selectedCategory == cat ? .blue : .gray)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private var templateGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.filtered) { template in
                    TemplateCardView(template: template)
                        .onTapGesture {
                            selectedTemplate = template
                        }
                }
            }
            .padding()
        }
    }
}

struct TemplateCardView: View {
    let template: DrawingTemplate

    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .frame(height: 120)
                .overlay {
                    // Replace with SVGView or AsyncImage when backend is live
                    Image(systemName: iconName(for: template.category))
                        .font(.system(size: 48))
                        .foregroundColor(.blue.opacity(0.7))
                }

            Text(template.name)
                .font(.subheadline)
                .fontWeight(.medium)

            Text(template.category)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.07), radius: 6, y: 3)
    }

    private func iconName(for category: String) -> String {
        switch category {
        case "Vehicles": return "tram.fill"
        case "Animals": return "pawprint.fill"
        case "Buildings": return "house.fill"
        case "Shapes": return "star.fill"
        default: return "pencil.tip.crop.circle"
        }
    }
}

#Preview {
    TemplateGalleryView()
}
