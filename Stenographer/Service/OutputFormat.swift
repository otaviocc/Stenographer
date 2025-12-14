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
