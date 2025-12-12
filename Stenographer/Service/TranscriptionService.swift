import AVFoundation
import Foundation
import Speech

actor TranscriptionService: TranscriptionServiceProtocol {

    // MARK: - Properties

    private var transcriptionTask: Task<Void, Never>?
    private var currentTemporaryFileURL: URL?

    var supportedLocales: [Locale] {
        get async {
            await SpeechTranscriber.supportedLocales
        }
    }

    // MARK: - Public

    func transcribe(
        url: URL,
        locale: Locale
    ) -> AsyncThrowingStream<TranscriptionEvent, Error> {
        .init { continuation in
            Task { [weak self] in
                guard let self else { return }

                let temporaryURL = copyToTemporaryLocation(from: url)

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
                attributeOptions: []
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

            var fullTranscript = ""

            for try await result in transcriber.results {
                let text = String(result.text.characters)
                fullTranscript += text
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

    private nonisolated func copyToTemporaryLocation(
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
