import SwiftUI

struct TranscriptionView: View {

    // MARK: - Properties

    @State private var viewModel: TranscriptionViewModel

    // MARK: - Lifecycle

    init(
        viewModel: TranscriptionViewModel
    ) {
        self.viewModel = viewModel
    }

    // MARK: - Public

    var body: some View {
        VStack(spacing: 0) {
            makeHeaderView()
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

            Divider()

            makeContentView()
        }
        .background(.background)
    }

    // MARK: - Private

    @ViewBuilder
    private func makeHeaderView() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Transcription")
                    .font(.headline)

                if !viewModel.statusText.isEmpty {
                    Text(viewModel.statusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if viewModel.hasTranscription {
                makeActionButtons()
            }
        }
    }

    @ViewBuilder
    private func makeActionButtons() -> some View {
        HStack(spacing: 8) {
            Button {
                viewModel.copyToClipboard()
            } label: {
                Label(viewModel.copyButtonTitle, systemImage: viewModel.copyButtonIcon)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isActionDisabled)

            Button {
                viewModel.saveToFile()
            } label: {
                Label("Save", systemImage: "square.and.arrow.down")
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isActionDisabled)
        }
    }

    @ViewBuilder
    private func makeContentView() -> some View {
        if viewModel.hasError {
            makeErrorView()
        } else if viewModel.shouldShowEmptyState {
            makeEmptyStateView()
        } else {
            makeTranscriptionContentView()
        }
    }

    @ViewBuilder
    private func makeEmptyStateView() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "text.alignleft")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(.tertiary)

            Text("Transcription will appear here")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Drop an audio or video file to get started")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func makeTranscriptionContentView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if viewModel.shouldShowProgressIndicator {
                    HStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Transcribing...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }

                Text(viewModel.transcriptionText)
                    .font(.body)
                    .textSelection(.enabled)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
            }
        }
        .scrollIndicators(.automatic)
    }

    @ViewBuilder
    private func makeErrorView() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.red)

            Text("Transcription Failed")
                .font(.headline)

            Text(viewModel.error ?? "")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#if DEBUG

    #Preview("Empty") {
        TranscriptionView(
            viewModel: TranscriptionViewModelMother.makeTranscriptionViewModel()
        )
        .frame(width: 500, height: 400)
    }

    #Preview("With Content") {
        TranscriptionView(
            viewModel: TranscriptionViewModelMother.makeTranscriptionViewModel(
                transcription: "This is a sample transcription text."
            )
        )
        .frame(width: 500, height: 400)
    }

#endif
