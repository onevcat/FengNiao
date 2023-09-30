import FengNiaoKit
import SwiftUI

final class AppViewModel: ObservableObject {
    @Published var unusedFiles: [FengNiaoKit.FileInfo] = []
    @Published private(set) var contentState: ContentState = .idling
    @Published private(set) var error: Error?
    /// Scanning project path to display info in result text.
    private(set) var scanningProjectPath: String = ""

    var isLoading: Bool {
        contentState == .loading
    }

    private let queue = DispatchQueue(label: "com.onevcat.fengniao", attributes: .concurrent)

    func fetchUnusedFiles(
        from path: String,
        excludePaths: String,
        fileExtensions: [String],
        resourcesExtensions: String
    ) {
        contentState = .loading

        scanningProjectPath = path
        queue.async {
            let fengNiao = FengNiao(
                projectPath: path,
                excludedPaths: excludePaths.split(separator: " ").map(String.init),
                resourceExtensions: resourcesExtensions.split(separator: " ").map(String.init),
                searchInFileExtensions: fileExtensions
            )

            do {
                let files = try fengNiao.unusedFiles()

                DispatchQueue.main.async {
                    self.unusedFiles = files
                    self.contentState = .content
                }
            } catch {
                DispatchQueue.main.async {
                    self.contentState = .error
                    self.error = error
                }
            }
        }
    }
}

extension AppViewModel {
    enum ContentState: Equatable {
        case idling
        case loading
        case content
        case error
    }
}
