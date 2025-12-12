import SwiftUI

final class ViewModelFactory: Sendable {

    // MARK: - Properties

    private let repository: any TranscriptionRepositoryProtocol

    // MARK: - Lifecycle

    init(
        repository: any TranscriptionRepositoryProtocol
    ) {
        self.repository = repository
    }

    // MARK: - Public

    @MainActor
    func makeStenographerAppViewModel() -> StenographerAppViewModel {
        .init(repository: repository)
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
        repository: TranscriptionRepository()
    )
}
