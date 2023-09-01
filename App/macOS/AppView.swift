import SwiftUI
import FengNiaoKit
import PathKit
import QuickLook

struct AppView: View {
    @StateObject private var viewModel: AppViewModel = AppViewModel()

    // MARK: Text Field

    @State private var projectPath: String = ""
    @State private var excludePaths: String = ""
    @State private var resourcesExtensions: String = Constants.defaultResourcesExtension
    @FocusState private var focusedField: FocusedField?

    // MARK: Show alert

    @State private var showDeleteAllAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var showErrorAlert: Bool = false

    // MARK: Toggle View

    @State private var showDeleteAllView: Bool = false
    @State private var showDeleteView: Bool = false
    @State private var showExportView: Bool = false

    // MARK: Table

    @State private var fileSelection = Set<FengNiaoKit.FileInfo.ID>()
    @State private var fileNameSortOrder = [
        KeyPathComparator(\FengNiaoKit.FileInfo.fileName),
        KeyPathComparator(\FengNiaoKit.FileInfo.size),
        KeyPathComparator(\FengNiaoKit.FileInfo.path)
    ]
    @State private var previewImageUrl: URL?

    // MARK: Checkbox

    @State private var toggleStates = [
        ToggleState(fileExtension: "h", isOn: true),
        ToggleState(fileExtension: "m", isOn: true),
        ToggleState(fileExtension: "mm", isOn: true),
        ToggleState(fileExtension: "swift", isOn: true),
        ToggleState(fileExtension: "xib", isOn: true),
        ToggleState(fileExtension: "storyboard", isOn: true),
        ToggleState(fileExtension: "plist", isOn: true)
    ]

    // MARK: - View

    var body: some View {
        VStack {
            configView

            Divider()

            unusedResourcesTable

            Spacer(minLength: 16)

            resultView
        }
        .animation(.default, value: viewModel.contentState)
        .padding()
        .onChange(of: viewModel.contentState) { state in
            if state == .error {
                showErrorAlert.toggle()
            }
        }
        .sheet(isPresented: $showDeleteAllView) {
            deleteView(filesToDelete: viewModel.unusedFiles)
                .onDisappear {
                    fetchUnusedFiles()
                }
        }
        .sheet(isPresented: $showDeleteView) {
            let fileToDelete = viewModel.unusedFiles.filter { fileSelection.contains($0.id) }
            deleteView(filesToDelete: fileToDelete)
                .onDisappear {
                    viewModel.unusedFiles.removeAll(where: { fileToDelete.contains($0) } )
                    fileSelection = []
                }
        }
        .sheet(isPresented: $showExportView) {
            ExportView(unusedFiles: viewModel.unusedFiles)
                .frame(minWidth: 500, minHeight: 300, idealHeight: 500)
        }
        .alert(
            deleteItemTitle,
            isPresented: $showDeleteAlert
        ) {
            Button("Delete", role: .destructive) {
                showDeleteView.toggle()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This item will be delete immediately.\nYou can't undo this action.")
        }
        .alert(
            "Are you sure you want to delete all items?",
            isPresented: $showDeleteAllAlert
        ) {
            Button("Delete All") {
                showDeleteAllView.toggle()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You can't undo this action.")
        }
        .alert(
            "Something went wrong",
            isPresented: $showErrorAlert
        ) {
            // Only OK action, no need to implement
        } message: {
            if let error = viewModel.error as? FengNiaoError {
                switch error {
                case .noResourceExtension:
                    Text("You need to specify some resource extensions as search target.")
                case .noFileExtension:
                    Text("You need to specify some file extensions to search in.")
                }
            } else {
                Text("Unknown Error: \(viewModel.error?.localizedDescription ?? "")")
            }
        }
    }

    @ViewBuilder
    private var configView: some View {
        VStack(alignment: .leading) {
            Text("Configurations")
                .font(.headline)

            HStack {
                Text("Project Path")
                TextField("Root path of your Xcode project", text: $projectPath)
                    .focused($focusedField, equals: .project)
                Button("Browse...") {
                    handleOpenFile()
                }
                .disabled(viewModel.isLoading)
            }

            HStack {
                Text("Exclude Paths")
                TextField(
                    "Exclude paths from search, separates with space. Example: Pods Carthage",
                    text: $excludePaths
                )
                .focused($focusedField, equals: .excludes)
            }

            HStack {
                Text("File Extensions")
                ForEach(toggleStates.indices, id: \.self) { index in
                    Toggle(toggleStates[index].fileExtension, isOn: $toggleStates[index].isOn)
                }
            }

            HStack {
                Text("Resources Extensions")
                TextField(
                    "Resource file extensions, separates with space. Default is 'imageset jpg png gif pdf'",
                    text: $resourcesExtensions
                )
                .focused($focusedField, equals: .resources)
                Button("Restore") {
                    resourcesExtensions = Constants.defaultResourcesExtension
                }
            }
            HStack {
                Spacer()
                Button(viewModel.isLoading ? "Searching... " : "Search...") {
                    if projectPath.isEmpty {
                        focusedField = .project
                        return
                    }
                    fetchUnusedFiles()
                    focusedField = nil
                }
                .disabled(viewModel.isLoading)
                .tint(Color.accentColor)
                .buttonStyle(.borderedProminent)
            }
        }
        .onTapGesture {
            focusedField = nil
        }
    }

    @ViewBuilder
    private var unusedResourcesTable: some View {
        VStack(alignment: .leading) {
            Text("Unused Files")
                .font(.headline)
            Table(
                viewModel.unusedFiles,
                selection: $fileSelection,
                sortOrder: $fileNameSortOrder
            ) {
                TableColumn("File Name", value: \.fileName) { file in
                    Text(file.fileName)
                        .contentShape(Rectangle())
                        .help(file.fileName)
                        .contextMenu {
                            Button("Copy") {
                                let pasteboard = NSPasteboard.general
                                pasteboard.declareTypes([.string], owner: nil)
                                pasteboard.setString(file.fileName, forType: .string)
                            }
                            Button("Show in Finder") {
                                NSWorkspace.shared.open(URL(fileURLWithPath: file.path.string))
                            }
                        }
                }
                .width(min: 150, ideal: 150, max: 300)

                TableColumn("Size", value: \.size) {
                    Text($0.size.fn_readableSize)
                }
                .width(min: 50, max: 150)

                TableColumn("Full Path", value: \.path.string) { file in
                    HStack {
                        Text(file.path.string)
                        Button {
                            previewImageUrl = URL(fileURLWithPath: file.path.string)
                        } label: {
                            Image(systemName: "eye")
                        }
                        .keyboardShortcut(.space)
                    }
                    .quickLookPreview($previewImageUrl)
                    .contentShape(Rectangle())
                    .contextMenu {
                        Button("Copy") {
                            let pasteboard = NSPasteboard.general
                            pasteboard.declareTypes([.string], owner: nil)
                            pasteboard.setString(file.path.string, forType: .string)
                        }
                        Button("Show in Finder") {
                            NSWorkspace.shared.open(URL(fileURLWithPath: file.path.string))
                        }
                    }
                    .help(file.path.string)
                }
            }
            .animation(.default, value: viewModel.unusedFiles)
            .onChange(of: fileNameSortOrder) { sortOrder in
                viewModel.unusedFiles.sort(using: sortOrder)
            }
        }
    }

    @ViewBuilder
    private var resultView: some View {
        if viewModel.contentState == .content {
            HStack {
                if viewModel.unusedFiles.isEmpty {
                    Text("🎉 You have no unused resources in path: \(Path(projectPath).absolute().string)")
                } else {
                    let size = viewModel.unusedFiles
                        .reduce(0) { $0 + $1.size }.fn_readableSize
                    Text("\(viewModel.unusedFiles.count) files are found. Total Size: \(size)")
                }

                Spacer()

                Button("Delete") {
                    showDeleteAlert.toggle()
                }
                .disabled(fileSelection.isEmpty)
                .disabled(viewModel.unusedFiles.isEmpty)

                Button("Delete All") {
                    showDeleteAllAlert.toggle()
                }
                .disabled(viewModel.unusedFiles.isEmpty)

                Button("Export CSV") {
                    showExportView.toggle()
                }
                .disabled(viewModel.unusedFiles.isEmpty)
            }
        } else if viewModel.contentState == .loading {
            HStack {
                HStack(alignment: .center, spacing: 8) {
                    ProgressView()
                        .controlSize(.small)
                    Text("Searching unused file. This may take a while...")
                }
                Spacer()
            }
        }
    }

    @ViewBuilder
    private func deleteView(filesToDelete: [FengNiaoKit.FileInfo]) -> some View {
        DeleteView(
            projectPath: self.projectPath,
            filesToDelete: filesToDelete
        )
        .frame(width: 500, height: 200)
    }

    // MARK: Side Effects - Private

    private var deleteItemTitle: String {
        if fileSelection.count == 1 {
            if let firstItem = fileSelection.first,
               let selectedUnusedFile = viewModel.unusedFiles.first(where: { $0.id == firstItem } ) {
                return "Are you sure you want to delete \"\(selectedUnusedFile.fileName)\""
            }
        } else {
            return "Are you sure you want to delete the \(fileSelection.count) selected items?"
        }
        return ""
    }

    private func handleOpenFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        if panel.runModal() == .OK {
            if let chosenFile = panel.url {
                let path = chosenFile.path
                projectPath = path
            }
        }
    }

    private func fetchUnusedFiles() {
        let fileExtensions: [String] = toggleStates
            .filter { $0.isOn }
            .map { $0.fileExtension }

        viewModel.fetchUnusedFiles(
            from: projectPath,
            excludePaths: excludePaths,
            fileExtensions: fileExtensions,
            resourcesExtensions: resourcesExtensions
        )
    }
}

// MARK: - FocusedField

extension AppView {
    enum FocusedField {
        case project, excludes, resources
    }
}

// MARK: - Constants

enum Constants {
    static let defaultResourcesExtension: String = "imageset jpg png gif pdf heic"
}

// MARK: - Preview

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
            .frame(width: 800, height: 800)
    }
}

// MARK: - FengNiaoKit.FileInfo + Identifiable + Hashable

extension FengNiaoKit.FileInfo: Identifiable, Hashable {
    public var id: String {
        path.string
    }

    public static func == (lhs: FileInfo, rhs: FileInfo) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - ToggleState

struct ToggleState: Hashable {
    let fileExtension: String
    var isOn: Bool
}
