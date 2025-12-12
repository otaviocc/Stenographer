import SwiftUI

final class ViewModelFactory: Sendable {

    // MARK: - Properties

    private let service: any TranscriptionServiceProtocol

    // MARK: - Lifecycle

    init(
        service: any TranscriptionServiceProtocol
    ) {
        self.service = service
    }

    // MARK: - Public

    @MainActor
    func makeStenographerAppViewModel() -> StenographerAppViewModel {
        .init(service: service)
    }

    @MainActor
    func makeDropZoneViewModel() -> DropZoneViewModel {
        .init()
    }

    @MainActor
    func makeTranscriptionViewModel() -> TranscriptionViewModel {
        .init()
    }
}

// MARK: - Environment

extension EnvironmentValues {

    @Entry var viewModelFactory: ViewModelFactory = .placeholder
}

extension ViewModelFactory {

    static let placeholder = ViewModelFactory(
        service: TranscriptionService()
    )
}
