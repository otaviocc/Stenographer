import Foundation
import Observation

@MainActor
@Observable
final class StenographerAppViewModel {

    // MARK: - Properties

    var selectedLocale = Locale(identifier: "en-US")

    var isLocalePickerDisabled: Bool {
        isTranscribing || isLoadingLocales
    }

    private(set) var supportedLocales: [Locale] = []
    private(set) var transcription = AttributedString()
    private(set) var error: String?
    private(set) var isTranscribing = false
    private(set) var statusMessage = ""
    private(set) var isLoadingLocales = true

    private let service: any TranscriptionServiceProtocol
    private var transcriptionTask: Task<Void, Never>?

    // MARK: - Lifecycle

    init(
        service: any TranscriptionServiceProtocol
    ) {
        self.service = service
    }

    // MARK: - Public

    func loadSupportedLocales() {
        Task {
            let locales = await service.supportedLocales

            supportedLocales = locales.sorted { lhs, rhs in
                let lhsName = lhs.localizedString(forIdentifier: lhs.identifier) ?? lhs.identifier
                let rhsName = rhs.localizedString(forIdentifier: rhs.identifier) ?? rhs.identifier
                return lhsName.localizedCompare(rhsName) == .orderedAscending
            }

            if let englishUS = supportedLocales.first(where: { $0.identifier(.bcp47) == "en-US" }) {
                selectedLocale = englishUS
            } else if let first = supportedLocales.first {
                selectedLocale = first
            }

            isLoadingLocales = false
        }
    }

    func transcribe(
        url: URL
    ) {
        transcription = .init()
        error = nil
        isTranscribing = true
        statusMessage = "Preparing..."

        transcriptionTask?.cancel()

        transcriptionTask = Task { [weak self] in
            guard let self else { return }

            do {
                let stream = await service.transcribe(
                    url: url,
                    locale: selectedLocale
                )

                for try await event in stream {
                    handleEvent(event)
                }
            } catch {
                self.error = error.localizedDescription
                isTranscribing = false
            }
        }
    }

    func cancel() {
        transcriptionTask?.cancel()
        transcriptionTask = nil

        Task {
            await service.cancel()
        }

        isTranscribing = false
    }

    func updateDropZoneViewModel(
        _ dropZoneViewModel: DropZoneViewModel
    ) {
        dropZoneViewModel.updateTranscribingState(
            isTranscribing
        )
    }

    func updateTranscriptionViewModel(
        _ transcriptionViewModel: TranscriptionViewModel
    ) {
        transcriptionViewModel.updateState(
            transcription: transcription,
            error: error,
            isTranscribing: isTranscribing
        )
    }

    // MARK: - Private

    private func handleEvent(
        _ event: TranscriptionEvent
    ) {
        switch event {
        case let .transcriptionUpdated(text):
            transcription = text
        case let .statusChanged(message):
            statusMessage = message
        case .completed:
            isTranscribing = false
            statusMessage = "Complete"
        }
    }
}
