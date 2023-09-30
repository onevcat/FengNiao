import SwiftUI
import FengNiaoKit
import Cocoa

struct ExportView: View {
    let unusedFiles: [FengNiaoKit.FileInfo]

    @Environment(\.dismiss) private var dismiss
    @State private var copyButtonTitle: String = "Copy CSV"
    @State private var downloadButtonTitle: String = "Download .csv"
    @State private var csvContent: String = ""
    @State private var isShowingSavePanel = false

    var body: some View {
        VStack {
            Text("Export CSV")
                .font(.title2)
                .bold()
            HStack {
                Button(copyButtonTitle) {
                    copyButtonTitle = "Copied!"
                    let pasteboard = NSPasteboard.general
                    pasteboard.declareTypes([.string], owner: nil)
                    pasteboard.setString(csvContent, forType: .string)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        copyButtonTitle = "Copy CSV"
                    }
                }

                Button(downloadButtonTitle) {
                    downloadCSV()
                    downloadButtonTitle = "Downloaded!"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        downloadButtonTitle = "Download .csv"
                    }
                }
            }

            TextEditor(text: $csvContent)

            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.accentColor)
            }
        }
        .padding()
        .onAppear {
            makeCSVContent()
        }
    }

    private func makeCSVContent() {
        var csvText = "File Name,Size,Full Path\n"
        for fileInfo in unusedFiles {
            let row = "\(fileInfo.fileName),\(fileInfo.size.fn_readableSize),\(fileInfo.path.string)\n"
            csvText.append(row)
        }
        self.csvContent = csvText
    }

    private func downloadCSV() {
        do {
            guard let fileURL = getCSVFileURL() else { return }
            try self.csvContent.write(to: fileURL, atomically: true, encoding: .utf8)

            isShowingSavePanel = true
        } catch {
            print("Error exporting CSV file: \(error.localizedDescription)")
        }
    }

    private func getCSVFileURL() -> URL? {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.commaSeparatedText]
        savePanel.nameFieldStringValue = "export.csv"
        savePanel.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first

        guard savePanel.runModal() == .OK, let fileURL = savePanel.url else {
            return nil
        }

        return fileURL
    }
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView(unusedFiles: [])
            .frame(minWidth: 300, idealWidth: 300, minHeight: 300, idealHeight: 500)
    }
}
