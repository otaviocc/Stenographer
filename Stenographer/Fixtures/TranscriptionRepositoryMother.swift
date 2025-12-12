#if DEBUG

    import Foundation

    enum TranscriptionRepositoryMother {

        // MARK: - Nested types

        private actor FakeTranscriptionRepository: TranscriptionRepositoryProtocol {

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
                    continuation.yield(.transcriptionUpdated("Sample transcription text for preview."))
                    continuation.yield(.completed)
                    continuation.finish()
                }
            }

            func cancel() {}
        }

        // MARK: - Public

        static func makeTranscriptionRepository() -> any TranscriptionRepositoryProtocol {
            FakeTranscriptionRepository()
        }
    }

#endif
