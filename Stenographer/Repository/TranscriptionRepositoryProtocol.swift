import Foundation

protocol TranscriptionRepositoryProtocol: Actor {

    var supportedLocales: [Locale] { get async }

    func transcribe(
        url: URL,
        locale: Locale
    ) -> AsyncThrowingStream<TranscriptionEvent, Error>

    func cancel()
}
