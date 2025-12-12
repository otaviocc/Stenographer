import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {

    // MARK: - Properties

    @State private var viewModel: DropZoneViewModel

    private let onFileDrop: (URL) -> Void
    private let onCancel: () -> Void

    // MARK: - Lifecycle

    init(
        viewModel: DropZoneViewModel,
        onFileDrop: @escaping (URL) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onFileDrop = onFileDrop
        self.onCancel = onCancel
    }

    // MARK: - Public

    var body: some View {
        ZStack {
            makeDropZoneBackground()
            makeDropZoneContent()
        }
        .onDrop(of: viewModel.supportedTypes, isTargeted: $viewModel.isTargeted) { providers in
            viewModel.handleDrop(providers: providers)
        }
        .onChange(of: viewModel.droppedFileURL) { _, newURL in
            if let url = newURL {
                onFileDrop(url)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.isTargeted)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isTranscribing)
    }

    // MARK: - Private

    @ViewBuilder
    private func makeDropZoneBackground() -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(viewModel.isTargeted ? AnyShapeStyle(Color.accentColor.opacity(0.1)) : AnyShapeStyle(Color.clear))
            .strokeBorder(
                viewModel.isTargeted ? Color.accentColor : Color.secondary.opacity(0.3),
                style: StrokeStyle(lineWidth: 2, dash: [8, 4])
            )
            .padding(20)
    }

    @ViewBuilder
    private func makeDropZoneContent() -> some View {
        VStack(spacing: 16) {
            if viewModel.isTranscribing {
                makeTranscribingContent()
            } else {
                makeIdleContent()
            }
        }
        .padding(40)
    }

    @ViewBuilder
    private func makeTranscribingContent() -> some View {
        ProgressView()
            .controlSize(.large)
            .scaleEffect(1.5)

        Text("Transcribing...")
            .font(.headline)
            .foregroundStyle(.secondary)

        Button("Cancel", role: .cancel) {
            onCancel()
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
    }

    @ViewBuilder
    private func makeIdleContent() -> some View {
        Image(systemName: viewModel.dropZoneIcon)
            .font(.system(size: 48, weight: .light))
            .foregroundStyle(viewModel.isTargeted ? Color.accentColor : .secondary)
            .symbolEffect(.bounce, value: viewModel.isTargeted)

        VStack(spacing: 8) {
            Text(viewModel.dropZoneTitle)
                .font(.headline)
                .foregroundStyle(.primary)

            Text("MP3, M4A, WAV, AIFF, or video files")
                .font(.caption)
                .foregroundStyle(.secondary)
        }

        if viewModel.shouldShowFileInfo {
            makeFileInfoView()
        }
    }

    @ViewBuilder
    private func makeFileInfoView() -> some View {
        VStack(spacing: 4) {
            Divider()
                .padding(.vertical, 8)

            Label {
                Text(viewModel.fileName)
                    .lineLimit(1)
                    .truncationMode(.middle)
            } icon: {
                Image(systemName: "doc.fill")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview

#if DEBUG

    #Preview {
        DropZoneView(
            viewModel: DropZoneViewModelMother.makeDropZoneViewModel(),
            onFileDrop: { _ in },
            onCancel: {}
        )
        .frame(width: 300, height: 400)
    }

#endif
