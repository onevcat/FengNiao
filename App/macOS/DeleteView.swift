import SwiftUI
import FengNiaoKit

struct DeleteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showDetailStatus: Bool = true
    @StateObject private var viewModel: DeleteStatusViewModel

    init(
        projectPath: String,
        filesToDelete: [FengNiaoKit.FileInfo]
    ) {
        _viewModel = StateObject(
            wrappedValue: DeleteStatusViewModel(
                projectPath: projectPath,
                unusedFilesToDelete: filesToDelete
            )
        )
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: showDetailStatus ? "chevron.down" : "chevron.right")
                    .font(.subheadline)
                Text("Deleting unused files...")
                    .font(.body)
                    .bold()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showDetailStatus.toggle()
            }
            .animation(.spring(response: 0.15), value: showDetailStatus)

            if showDetailStatus {
                Text(viewModel.consoleStatus)
                .font(.subheadline)
                .foregroundColor(Color(NSColor.secondaryLabelColor))
                .animation(.spring(response: 0.3), value: showDetailStatus)
            }

            Spacer()

            ProgressView(
                viewModel.deleteAmount == 100 ? "Finished!" : "Deleting...",
                value: viewModel.deleteAmount,
                total: 100
            )
            .foregroundColor(Color(NSColor.secondaryLabelColor))

            Spacer()

            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .disabled(viewModel.deleteAmount < 100)
                .tint(Color.accentColor)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .onAppear {
            viewModel.deleteUnusedFiles()
        }
        .alert("Something went wrong", isPresented: $viewModel.showError) {
            // only need OK button
        } message: {
            Text(viewModel.errorAlertMessage)
        }

    }
}

struct DeleteStatusView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteView(projectPath: "", filesToDelete: [])
            .frame(width: 500, height: 200)
    }
}
