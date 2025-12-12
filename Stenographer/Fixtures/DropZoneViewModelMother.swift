#if DEBUG

    import Foundation

    enum DropZoneViewModelMother {

        // MARK: - Public

        @MainActor
        static func makeDropZoneViewModel(
            isTargeted: Bool = false,
            droppedFileURL: URL? = nil,
            isTranscribing: Bool = false
        ) -> DropZoneViewModel {
            let viewModel = DropZoneViewModel()
            viewModel.isTargeted = isTargeted
            viewModel.droppedFileURL = droppedFileURL
            viewModel.updateTranscribingState(isTranscribing)
            return viewModel
        }
    }

#endif
