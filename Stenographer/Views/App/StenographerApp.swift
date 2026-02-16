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

import SwiftUI

struct StenographerApp: View {

    // MARK: - Properties

    @State private var viewModel: StenographerAppViewModel
    @State private var dropZoneViewModel: DropZoneViewModel
    @State private var transcriptionViewModel: TranscriptionViewModel

    // MARK: - Lifecycle

    init(
        viewModel: StenographerAppViewModel,
        dropZoneViewModel: DropZoneViewModel,
        transcriptionViewModel: TranscriptionViewModel
    ) {
        self.viewModel = viewModel
        self.dropZoneViewModel = dropZoneViewModel
        self.transcriptionViewModel = transcriptionViewModel
    }

    // MARK: - Public

    var body: some View {
        HStack(spacing: 0) {
            makeDropZoneSection()

            Divider()

            makeTranscriptionView()
        }
        .frame(minWidth: 700, minHeight: 500)
        .background(.ultraThinMaterial)
        .onAppear {
            viewModel.loadSupportedLocales()
        }
        .onChange(of: viewModel.isTranscribing) {
            viewModel.updateDropZoneViewModel(dropZoneViewModel)
            viewModel.updateTranscriptionViewModel(transcriptionViewModel)
        }
        .onChange(of: viewModel.transcription) {
            viewModel.updateTranscriptionViewModel(transcriptionViewModel)
        }
        .onChange(of: viewModel.error) {
            viewModel.updateTranscriptionViewModel(transcriptionViewModel)
        }
    }

    // MARK: - Private

    private func makeTranscriptionView() -> some View {
        TranscriptionView(
            viewModel: transcriptionViewModel
        )
        .frame(minWidth: 400)
    }

    private func makeDropZoneSection() -> some View {
        VStack(spacing: 0) {
            makeDropZoneView()

            Divider()

            makeLocalePickerView()
        }
        .frame(minWidth: 280, maxWidth: 320)
    }

    private func makeDropZoneView() -> some View {
        DropZoneView(
            viewModel: dropZoneViewModel,
            onFileDrop: { url in
                viewModel.transcribe(url: url)
            },
            onCancel: {
                viewModel.cancel()
            }
        )
    }

    private func makeLocalePickerView() -> some View {
        HStack {
            Text("Language:")
                .font(.caption)
                .foregroundStyle(.secondary)

            if viewModel.isLoadingLocales {
                ProgressView()
                    .controlSize(.small)
            } else {
                Picker("", selection: $viewModel.selectedLocale) {
                    ForEach(viewModel.supportedLocales, id: \.identifier) { locale in
                        Text(locale.localizedString(forIdentifier: locale.identifier)?.capitalized ?? locale.identifier)
                            .tag(locale)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .disabled(viewModel.isLocalePickerDisabled)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
