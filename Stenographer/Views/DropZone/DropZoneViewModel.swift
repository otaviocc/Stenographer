import Foundation
import Observation
import UniformTypeIdentifiers

@MainActor
@Observable
final class DropZoneViewModel {

    // MARK: - Properties

    var isTargeted = false
    var droppedFileURL: URL?

    private(set) var isTranscribing = false
    private(set) var originalFileName = ""

    let supportedTypes: [UTType] = [
        .audio,
        .mpeg4Audio,
        .mp3,
        .wav,
        .aiff,
        .movie,
        .mpeg4Movie,
        .quickTimeMovie
    ]

    // MARK: - Computed Properties

    var dropZoneIcon: String {
        if droppedFileURL != nil {
            return "checkmark.circle.fill"
        }
        return isTargeted ? "arrow.down.circle.fill" : "waveform.circle"
    }

    var dropZoneTitle: String {
        if droppedFileURL != nil {
            return "Drop another file to transcribe"
        }
        return isTargeted ? "Release to transcribe" : "Drop audio or video file here"
    }

    var shouldShowFileInfo: Bool {
        !originalFileName.isEmpty
    }

    var fileName: String {
        originalFileName
    }

    // MARK: - Public

    func updateTranscribingState(
        _ isTranscribing: Bool
    ) {
        self.isTranscribing = isTranscribing
    }

    func handleDrop(
        providers: [NSItemProvider]
    ) -> Bool {
        guard !isTranscribing,
              let provider = providers.first,
              let type = supportedTypes.first(where: { provider.hasItemConformingToTypeIdentifier($0.identifier) })
        else { return false }

        Task {
            guard let url = try? await provider.loadItem(forTypeIdentifier: type.identifier) as? URL else { return }

            originalFileName = url.lastPathComponent
            droppedFileURL = url
        }

        return true
    }
}
