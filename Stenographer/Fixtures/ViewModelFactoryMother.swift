#if DEBUG

    import Foundation

    enum ViewModelFactoryMother {

        // MARK: - Public

        static func makeViewModelFactory() -> ViewModelFactory {
            .init(
                service: TranscriptionServiceMother.makeTranscriptionService()
            )
        }
    }

#endif
