import AppKit
import Foundation
import Observation

@MainActor
@Observable
final class TranscriptionViewModel {

    // MARK: - Properties

    var showCopiedFeedback = false

    private(set) var transcription = AttributedString()
    private(set) var error: String?
    private(set) var isTranscribing = false

    // MARK: - Computed Properties

    var transcriptionText: String {
        String(transcription.characters)
    }

    var wordCount: Int {
        transcriptionText
            .split(whereSeparator: { $0.isWhitespace || $0.isNewline })
            .count
    }

    var hasTranscription: Bool {
        !transcription.characters.isEmpty
    }

    var hasError: Bool {
        error != nil
    }

    var shouldShowEmptyState: Bool {
        transcription.characters.isEmpty && !isTranscribing && error == nil
    }

    var shouldShowTranscriptionContent: Bool {
        !transcription.characters.isEmpty || isTranscribing
    }

    var shouldShowProgressIndicator: Bool {
        isTranscribing && hasTranscription
    }

    var isActionDisabled: Bool {
        isTranscribing
    }

    var copyButtonTitle: String {
        showCopiedFeedback ? "Copied!" : "Copy"
    }

    var copyButtonIcon: String {
        showCopiedFeedback ? "checkmark" : "doc.on.doc"
    }

    var statusText: String {
        if isTranscribing {
            return "Processing audio..."
        } else if hasTranscription {
            return "\(wordCount) words"
        }
        return ""
    }

    // MARK: - Public

    func updateState(
        transcription: AttributedString,
        error: String?,
        isTranscribing: Bool
    ) {
        self.transcription = transcription
        self.error = error
        self.isTranscribing = isTranscribing
    }

    func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(transcriptionText, forType: .string)

        showCopiedFeedback = true

        Task {
            try? await Task.sleep(for: .seconds(2))
            showCopiedFeedback = false
        }
    }

    func saveToFile() {
        TranscriptionExportService.showSavePanel(for: transcription)
    }
}
