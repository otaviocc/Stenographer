# Stenographer

<img width="1134" height="757" alt="Screenshot of the Stenographer application for macOS Tahoe" src="https://github.com/user-attachments/assets/2ebe574d-8a61-445a-bbeb-680bd64ff365" />

**Stenographer** is a simple macOS application for transcribing audio and video files using Apple's on-device speech recognition. Drop a media file (MP3, M4A, WAV, etc.) onto the left panel, select a language, and watch as the transcription appears in real-time on the right. Once complete, you can copy the text to your clipboard or save it to a file.

The app leverages the new `SpeechTranscriber` and `SpeechAnalyzer` APIs introduced in macOS Tahoe (macOS 26), which provide high-quality, privacy-preserving transcription entirely on-device. Language models are downloaded automatically when needed.

## Install Stenographer

**Install via [Brew](https://brew.sh) 🤩**

```bash
brew tap otaviocc/apps
brew install --cask stenographer
```

## Learning Exercise

This project was created as a learning exercise to explore Apple's new Speech framework capabilities in macOS Tahoe. While the application is functional and produces quality transcriptions, it is not intended for release on the App Store. It serves as a reference implementation for understanding:

- The new `SpeechTranscriber` and `SpeechAnalyzer` APIs
- On-device speech recognition with `AssetInventory` for language model management
- SwiftUI patterns with `@Observable` ViewModels
- Actor-based Service architecture for thread-safe async operations

## Requirements

- macOS Tahoe (macOS 26) or later
- Xcode 26 or later
