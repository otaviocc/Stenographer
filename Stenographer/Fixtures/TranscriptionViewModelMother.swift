#if DEBUG

    import Foundation

    enum TranscriptionViewModelMother {

        // MARK: - Public

        @MainActor
        static func makeTranscriptionViewModel(
            transcription: String = "",
            error: String? = nil,
            isTranscribing: Bool = false
        ) -> TranscriptionViewModel {
            let viewModel = TranscriptionViewModel()
            viewModel.updateState(
                transcription: transcription,
                error: error,
                isTranscribing: isTranscribing
            )
            return viewModel
        }
    }

#endif
