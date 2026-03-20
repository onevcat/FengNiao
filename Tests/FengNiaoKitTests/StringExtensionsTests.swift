import Testing
@testable import FengNiaoKit

@Suite("String Extensions")
struct StringExtensionsTests {
    @Test("plainFileName parses to plain name")
    func plainFileNameParsesToPlainName() {
        let paths = [
            "/usr/bin/hello/file1.swift",
            "/foo/file2.png",
            "/foo/file3@2x.jpg",
            "file4@3x.jpg",
            "bar/good/file5",
            "../bar/good/file@2x6@3x.png"
        ]
        let expected = [
            "file1.swift",
            "file2",
            "file3",
            "file4",
            "file5",
            "file@2x6"
        ]
        let result = paths.map { $0.plainFileName(extensions: ["png", "jpg"]) }
        #expect(result == expected)
    }

    @Test("generatedAssetSymbolKey works with digits")
    func generatedAssetSymbolKeyWorksWithDigits() {
        let images = [
            "ic_chat_white_24px",
            "ic-chat_white_24 px",
            "iC-ChAt_whIte_24 pX",
            "ICCHATWHITE"
        ]
        let expected = [
            ".icChatWhite24Px",
            ".icChatWhite24Px",
            ".iCChAtWhIte24PX",
            ".ICCHATWHITE"
        ]
        #expect(images.map { $0.generatedAssetSymbolKey } == expected)
    }

    @Test("generatedAssetSymbolKey treats dots as word boundaries")
    func generatedAssetSymbolKeyTreatsDotsAsWordBoundaries() {
        let images = [
            "empty.icon",
            "navigation-menu.row.icon",
            "device.battery.status.disconnected",
            "wizard.setup.complete"
        ]
        let expected = [
            ".emptyIcon",
            ".navigationMenuRowIcon",
            ".deviceBatteryStatusDisconnected",
            ".wizardSetupComplete"
        ]
        #expect(images.map { $0.generatedAssetSymbolKey } == expected)
    }
}
