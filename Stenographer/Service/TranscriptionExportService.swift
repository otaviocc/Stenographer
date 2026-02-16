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
