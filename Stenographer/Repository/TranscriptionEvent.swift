import Foundation

enum TranscriptionEvent: Sendable {

    case transcriptionUpdated(String)
    case statusChanged(String)
    case completed
}
