import AppKit
import Foundation
import UniformTypeIdentifiers

enum TranscriptionExportService {

    // MARK: - Constants

    private enum Constants {

        static let srtMaxLength = 52
    }

    // MARK: - Public

    @MainActor
    static func showSavePanel(for transcription: AttributedString) {
        let savePanel = NSSavePanel()

        savePanel.allowedContentTypes = [.plainText, .srt]
        savePanel.nameFieldStringValue = "transcription.txt"
        savePanel.title = "Save Transcription"
        savePanel.message = "Choose a location to save the transcription (.txt or .srt)"

        savePanel.begin { response in
            guard response == .OK, let url = savePanel.url else {
                return
            }

            save(transcription, to: url)
        }
    }

    // MARK: - Private

    private static func save(
        _ transcription: AttributedString,
        to url: URL
    ) {
        let format = outputFormat(for: url)
        let content = format.text(
            for: transcription,
            maxLength: Constants.srtMaxLength
        )

        try? content.write(
            to: url,
            atomically: true,
            encoding: .utf8
        )
    }

    private static func outputFormat(
        for url: URL
    ) -> OutputFormat {
        switch url.pathExtension.lowercased() {
        case "srt": .srt
        default: .txt
        }
    }
}
