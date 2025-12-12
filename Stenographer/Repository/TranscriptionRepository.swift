import AVFoundation
import Foundation
import Speech

actor TranscriptionRepository: TranscriptionRepositoryProtocol {

    // MARK: - Properties

    private var transcriptionTask: Task<Void, Never>?

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
                await self?.performTranscription(
                    url: url,
                    locale: locale,
                    continuation: continuation
                )
            }
        }
    }

    func cancel() {
        transcriptionTask?.cancel()
        transcriptionTask = nil
    }

    // MARK: - Private

    private func performTranscription(
        url: URL,
        locale: Locale,
        continuation: AsyncThrowingStream<TranscriptionEvent, Error>.Continuation
    ) async {
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
        } catch {
            continuation.finish(throwing: error)
        }
    }
}
