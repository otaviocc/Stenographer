#if DEBUG

    import Foundation

    enum ViewModelFactoryMother {

        // MARK: - Public

        static func makeViewModelFactory() -> ViewModelFactory {
            .init(
                repository: TranscriptionRepositoryMother.makeTranscriptionRepository()
            )
        }
    }

#endif
