import SwiftUI

@main
struct StenographerApplication: App {

    // MARK: - Properties

    private let viewModelFactory: ViewModelFactory

    // MARK: - Lifecycle

    init() {
        let service = TranscriptionService()
        viewModelFactory = ViewModelFactory(service: service)
    }

    // MARK: - Public

    var body: some Scene {
        WindowGroup {
            makeAppView()
        }
        .windowStyle(.automatic)
        .defaultSize(width: 900, height: 600)
    }

    // MARK: - Private

    @MainActor
    @ViewBuilder
    private func makeAppView() -> some View {
        StenographerApp(
            viewModel: viewModelFactory.makeStenographerAppViewModel(),
            dropZoneViewModel: viewModelFactory.makeDropZoneViewModel(),
            transcriptionViewModel: viewModelFactory.makeTranscriptionViewModel()
        )
        .environment(\.viewModelFactory, viewModelFactory)
    }
}
