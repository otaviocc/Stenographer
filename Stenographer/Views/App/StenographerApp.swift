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

    @ViewBuilder
    private func makeTranscriptionView() -> some View {
        TranscriptionView(
            viewModel: transcriptionViewModel
        )
        .frame(minWidth: 400)
    }

    @ViewBuilder
    private func makeDropZoneSection() -> some View {
        VStack(spacing: 0) {
            makeDropZoneView()

            Divider()

            makeLocalePickerView()
        }
        .frame(minWidth: 280, maxWidth: 320)
    }

    @ViewBuilder
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

    @ViewBuilder
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
                        Text(locale.localizedString(forIdentifier: locale.identifier) ?? locale.identifier)
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
