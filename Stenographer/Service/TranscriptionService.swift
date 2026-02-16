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

import AVFoundation
import Foundation
import Speech

actor TranscriptionService: TranscriptionServiceProtocol {

    // MARK: - Properties

    var supportedLocales: [Locale] {
        get async {
            await SpeechTranscriber.supportedLocales
        }
    }

    private var transcriptionTask: Task<Void, Never>?
    private var currentTemporaryFileURL: URL?

    // MARK: - Public

    func transcribe(
        url: URL,
        locale: Locale
    ) -> AsyncThrowingStream<TranscriptionEvent, Error> {
        .init { continuation in
            Task { [weak self] in
                guard let self else { return }

                let temporaryURL = await copyToTemporaryLocation(from: url)

                guard let temporaryURL else {
                    continuation.finish(
                        throwing: TranscriptionError.failedToCopyFile
                    )
                    return
                }

                await performTranscription(
                    url: temporaryURL,
                    locale: locale,
                    continuation: continuation
                )
            }
        }
    }

    func cancel() {
        transcriptionTask?.cancel()
        transcriptionTask = nil
        deleteTemporaryFile()
    }

    // MARK: - Private

    private func performTranscription(
        url: URL,
        locale: Locale,
        continuation: AsyncThrowingStream<TranscriptionEvent, Error>.Continuation
    ) async {
        currentTemporaryFileURL = url

        do {
            continuation.yield(
                .statusChanged("Checking language assets...")
            )

            for reservedLocale in await AssetInventory.reservedLocales {
                await AssetInventory.release(reservedLocale: reservedLocale)
            }

            try await AssetInventory.reserve(
                locale: locale
            )

            let transcriber = SpeechTranscriber(
                locale: locale,
                transcriptionOptions: [],
                reportingOptions: [],
                attributeOptions: [.audioTimeRange]
            )

            let modules = [transcriber]

            let request = try await AssetInventory.assetInstallationRequest(
                supporting: modules
            )

            if let request {
                continuation.yield(
                    .statusChanged("Downloading language assets...")
                )

                try await request.downloadAndInstall()
            }

            continuation.yield(
                .statusChanged("Transcribing audio...")
            )

            let analyzer = SpeechAnalyzer(modules: modules)
            let audioFile = try AVAudioFile(forReading: url)

            try await analyzer.start(
                inputAudioFile: audioFile,
                finishAfterFile: true
            )

            var fullTranscript = AttributedString()

            for try await result in transcriber.results {
                fullTranscript += result.text
                continuation.yield(.transcriptionUpdated(fullTranscript))
            }

            continuation.yield(.completed)
            continuation.finish()
            deleteTemporaryFile()
        } catch {
            continuation.finish(throwing: error)
            deleteTemporaryFile()
        }
    }

    private func copyToTemporaryLocation(
        from url: URL
    ) -> URL? {
        let temporaryURL = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(url.pathExtension)

        do {
            try FileManager.default.copyItem(at: url, to: temporaryURL)
            return temporaryURL
        } catch {
            return nil
        }
    }

    private func deleteTemporaryFile() {
        guard let url = currentTemporaryFileURL else { return }
        try? FileManager.default.removeItem(at: url)
        currentTemporaryFileURL = nil
    }
}
