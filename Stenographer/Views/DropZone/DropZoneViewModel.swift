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
