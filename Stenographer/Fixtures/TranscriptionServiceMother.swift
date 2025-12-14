#if DEBUG

    import Foundation

    enum TranscriptionServiceMother {

        // MARK: - Nested types

        private actor FakeTranscriptionService: TranscriptionServiceProtocol {

            // MARK: - Properties

            var supportedLocales: [Locale] {
                [
                    Locale(identifier: "en-US"),
                    Locale(identifier: "en-GB"),
                    Locale(identifier: "de-DE"),
                    Locale(identifier: "fr-FR"),
                    Locale(identifier: "es-ES")
                ]
            }

            // MARK: - Public

            func transcribe(
                url: URL,
                locale: Locale
            ) -> AsyncThrowingStream<TranscriptionEvent, Error> {
                .init { continuation in
                    continuation.yield(.statusChanged("Transcribing..."))
                    continuation.yield(
                        .transcriptionUpdated(.init("Sample transcription text for preview."))
                    )
                    continuation.yield(.completed)
                    continuation.finish()
                }
            }

            func cancel() {}
        }

        // MARK: - Public

        static func makeTranscriptionService() -> any TranscriptionServiceProtocol {
            FakeTranscriptionService()
        }
    }

#endif
