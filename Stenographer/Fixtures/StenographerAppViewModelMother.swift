#if DEBUG

    import Foundation

    enum StenographerAppViewModelMother {

        // MARK: - Public

        @MainActor
        static func makeStenographerAppViewModel() -> StenographerAppViewModel {
            .init(
                service: TranscriptionServiceMother.makeTranscriptionService()
            )
        }
    }

#endif
