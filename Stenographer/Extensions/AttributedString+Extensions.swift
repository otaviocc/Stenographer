import CoreMedia
import Foundation
import Speech

extension AttributedString {

    struct TimedSegment {

        let text: String
        let timeRange: CMTimeRange
    }

    func timedSegments(maxCharacters: Int) -> [TimedSegment] {
        var segments: [TimedSegment] = []

        for run in runs {
            guard let timeRange = run.audioTimeRange else {
                continue
            }

            let text = String(self[run.range].characters)
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !trimmedText.isEmpty else {
                continue
            }

            if let lastSegment = segments.last,
               lastSegment.text.count + trimmedText.count + 1 <= maxCharacters
            {
                let combinedText = lastSegment.text + text
                let combinedTimeRange = CMTimeRange(
                    start: lastSegment.timeRange.start,
                    end: timeRange.end
                )
                segments[segments.count - 1] = .init(
                    text: combinedText,
                    timeRange: combinedTimeRange
                )
            } else {
                segments.append(
                    .init(text: text, timeRange: timeRange)
                )
            }
        }

        return segments
    }
}
