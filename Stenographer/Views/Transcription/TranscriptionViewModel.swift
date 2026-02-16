// MIT License
//
// Copyright (c) 2026 Otávio C.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
            .split { $0.isWhitespace || $0.isNewline }
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
