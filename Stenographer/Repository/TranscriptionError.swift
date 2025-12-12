import Foundation

enum TranscriptionError: LocalizedError {

    case failedToCopyFile

    var errorDescription: String? {
        switch self {
        case .failedToCopyFile:
            "Failed to copy the file for transcription."
        }
    }
}
