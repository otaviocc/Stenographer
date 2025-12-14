import Foundation

enum TranscriptionEvent: Sendable {

    case transcriptionUpdated(AttributedString)
    case statusChanged(String)
    case completed
}
