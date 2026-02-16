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

import CoreMedia
import Foundation

enum OutputFormat: String, CaseIterable {

    case txt
    case srt

    // MARK: - Public

    var fileExtension: String {
        rawValue
    }

    func text(
        for transcript: AttributedString,
        maxLength: Int
    ) -> String {
        switch self {
        case .txt: String(transcript.characters)
        case .srt: formatSRT(from: transcript, maxLength: maxLength)
        }
    }

    // MARK: - Private

    private func formatSRT(
        from transcript: AttributedString,
        maxLength: Int
    ) -> String {
        transcript
            .timedSegments(maxCharacters: maxLength)
            .enumerated()
            .map { index, segment in
                let startTime = segment.timeRange.start.seconds.srtTimecode
                let endTime = segment.timeRange.end.seconds.srtTimecode
                let text = segment.text.trimmingCharacters(in: .whitespacesAndNewlines)

                return """
                \(index + 1)
                \(startTime) --> \(endTime)
                \(text)
                """
            }
            .joined(separator: "\n\n")
    }
}
