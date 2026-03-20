import Testing
@testable import FengNiaoKit

@Suite("Search Rule")
struct SearchRuleTests {
    @Test("plain rule with image extensions applies")
    func plainRuleWithImageExtensionsApplies() {
        let searcher = PlainImageSearchRule(extensions: ["png", "jpg"])
        let content = "<h2>Spectacular Mountain</h2>\n<img src=\"public/image/mountain.jpg\" alt=\"Mountain View\" style=\"width:304px;height:228px;\">\n<img src=\"cat.png\">\n<img src=\"dog.svg\">"
        let result = searcher.search(in: content)
        let expected: Set<String> = ["mountain", "cat"]
        #expect(result == expected)
    }

    @Test("plain rule with empty extension applies")
    func plainRuleWithEmptyExtensionApplies() {
        let searcher = PlainImageSearchRule(extensions: [])
        let content = "<h2>Spectacular Mountain</h2>\n<img src=\"public/image/mountain.jpg\" alt=\"Mountain View\" style=\"width:304px;height:228px;\">\n<img src=\"cat.png\">\n<img src=\"dog.svg\">"
        let result = searcher.search(in: content)
        #expect(result.isEmpty)
    }

    @Test("ObjC search rule applies")
    func objcSearchRuleApplies() {
        let searcher = ObjCImageSearchRule(extensions: [])
        let content = "[UIImage imageName:@\"hello\"]\nNSString *imageName = @\"world@2x\"\n[[NSBundle mainBundle] pathForResource:@\"foo/bar/aaa\" ofType:@\"png\"]"
        let result = searcher.search(in: content)
        let expected: Set<String> = ["hello", "world", "aaa", "png"]
        #expect(result == expected)
    }

    @Test("Swift search rule applies")
    func swiftSearchRuleApplies() {
        let searcher = SwiftImageSearchRule(extensions: ["jpg"])
        let content = "UIImage(named: \"button_image\")\nlet s = \"foo.jpg\"\n"
        let result = searcher.search(in: content)
        let expected: Set<String> = ["button_image", "foo"]
        #expect(result == expected)
    }

    @Test("Swift search rule with empty string applies")
    func swiftSearchRuleWithEmptyStringApplies() {
        let searcher = SwiftImageSearchRule(extensions: ["jpg"])
        let content = "let item = TableItem(name: \"\", image: UIImage(named: \"foo\")!)"
        let result = searcher.search(in: content)
        let expected: Set<String> = ["", "foo"]
        #expect(result == expected)
    }

    @Test("xib search rule applies")
    func xibSearchRuleApplies() {
        let searcher = XibImageSearchRule()
        let content = "<resources>\n<image name=\"btn_error\" width=\"39\" height=\"39\"/>\n<image name=\"disconnect_wifi\" width=\"61\" height=\"49\"/>\n</resources>\n<userDefinedRuntimeAttribute type=\"image\" keyPath=\"defaultBackgroundImage\" value=\"live_btn_add_follow\"/>"
        let result = searcher.search(in: content)
        let expected: Set<String> = ["btn_error", "disconnect_wifi", "live_btn_add_follow"]
        #expect(result == expected)
    }

    @Test("plist alternate icon search rule applies")
    func plistAlternateIconSearchRuleApplies() {
        let searcher = PlistImageSearchRule(extensions: ["png"])
        let content = "<key>CFBundleIcons</key>\n<dict>\n<key>CFBundleAlternateIcons</key>\n<dict>\n<key>ChristmasIcon</key>\n<dict>\n<key>CFBundleIconFiles</key>\n<array>\n<string>ChristmasIcon_20pt</string>\n<string>ChristmasIcon_29pt</string>\n<string>ChristmasIcon_40pt</string>\n<string>ChristmasIcon_60pt</string>\n<string>ChristmasIcon_76pt</string>\n<string>ChristmasIcon_83.5pt</string>\n<string>ChristmasIcon_1024pt</string>\n</array>\n<key>UIPrerenderedIcon</key>\n<false/>\n</dict>\n<key>NewYearIcon</key>\n<dict>\n<key>CFBundleIconFiles</key>\n<array>\n<string>NewYearIcon_20pt</string>\n<string>NewYearIcon_29pt</string>\n<string>NewYearIcon_40pt</string>\n<string>NewYearIcon_60pt</string>\n<string>NewYearIcon_76pt</string>\n<string>NewYearIcon_83.5pt</string>\n<string>NewYearIcon_1024pt</string>\n</array>\n<key>UIPrerenderedIcon</key>\n<false/>\n</dict>\n</dict>\n</dict>"
        let result = searcher.search(in: content)
        let expected: Set<String> = [
            "ChristmasIcon_20pt",
            "ChristmasIcon_29pt",
            "ChristmasIcon_40pt",
            "ChristmasIcon_60pt",
            "ChristmasIcon_76pt",
            "ChristmasIcon_83.5pt",
            "ChristmasIcon_1024pt",
            "NewYearIcon_20pt",
            "NewYearIcon_29pt",
            "NewYearIcon_40pt",
            "NewYearIcon_60pt",
            "NewYearIcon_76pt",
            "NewYearIcon_83.5pt",
            "NewYearIcon_1024pt"
        ]
        #expect(result == expected)
    }

    @Test("Swift member access rule applies to generated symbols")
    func swiftMemberAccessRuleAppliesToGeneratedSymbols() {
        let searcher = SwiftMemberAccessSearchRule()
        let content = """
        let flag = UIImage.icFlag
        let highlighted: UIImage = .icFlagHighlighted
        let legacy = NSImage .icFlagSecondary
        let accent = Color .customAccent
        """
        let result = searcher.search(in: content)
        let expected: Set<String> = [".icFlag", ".icFlagHighlighted", ".icFlagSecondary", ".customAccent"]
        #expect(result == expected)
    }

    @Test("Swift member access rule applies to generated symbols for function parameters")
    func swiftMemberAccessRuleAppliesToGeneratedSymbolsForFunctionParameters() {
        let searcher = SwiftMemberAccessSearchRule()
        let content = """
        generateThumbnail(.icFlag)
        generateThumbnail(
            image: .icFlagHighlighted
        )
        generateThumbnail(
            image: .icFlagSecondary,
            isRight: true
        )
        generateThumbnail(image: .customAccent, isRight: false)
        """
        let result = searcher.search(in: content)
        let expected: Set<String> = [".icFlag", ".icFlagHighlighted", ".icFlagSecondary", ".customAccent"]
        #expect(result == expected)
    }

    @Test("Swift member access rule ignores regular property access")
    func swiftMemberAccessRuleIgnoresRegularPropertyAccess() {
        let searcher = SwiftMemberAccessSearchRule()
        let content = """
        let icon = image.icFlag
        let other = viewModel.output.imageName
        let chained = someFactory.imageProvider.icLater
        """
        let result = searcher.search(in: content)
        #expect(result.isEmpty)
    }

    @Test("Swift member access rule ignores method call")
    func swiftMemberAccessRuleIgnoresMethodCall() {
        let searcher = SwiftMemberAccessSearchRule()
        let content = """
        view.addSubView()
        """
        let result = searcher.search(in: content)
        #expect(result.isEmpty)
    }

    @Test("Swift member access rule applies to nested member access patterns")
    func swiftMemberAccessRuleAppliesToNestedMemberAccessPatterns() {
        let searcher = SwiftMemberAccessSearchRule()
        let content = """
        Image(.Icons.Navigation.menuIcon)
        let icon = Image(.Images.Animals.dogFace)
        UIImage(.Background.landscapeCard)
        Color(.Theme.Primary.background)
        """
        let result = searcher.search(in: content)
        let expected: Set<String> = [
            ".Icons.Navigation.menuIcon",
            ".Images.Animals.dogFace",
            ".Background.landscapeCard",
            ".Theme.Primary.background"
        ]
        #expect(result == expected)
    }

    @Test("Swift member access rule applies to nested patterns with whitespace")
    func swiftMemberAccessRuleAppliesToNestedPatternsWithWhitespace() {
        let searcher = SwiftMemberAccessSearchRule()
        let content = """
        Image( .Icons.Navigation.menuIcon )
        let icon = Image(
            .Images.Animals.dogFace
        )
        UIImage(  .Background.landscapeCard  )
        """
        let result = searcher.search(in: content)
        let expected: Set<String> = [
            ".Icons.Navigation.menuIcon",
            ".Images.Animals.dogFace",
            ".Background.landscapeCard"
        ]
        #expect(result == expected)
    }

    @Test("Swift member access rule handles both simple and nested patterns together")
    func swiftMemberAccessRuleHandlesBothSimpleAndNestedPatternsTogether() {
        let searcher = SwiftMemberAccessSearchRule()
        let content = """
        let flag = UIImage.icFlag
        let device = Image(.Icons.Navigation.menuIcon)
        let highlighted: UIImage = .icFlagHighlighted
        let nested = Image(.Images.Animals.dogFace)
        """
        let result = searcher.search(in: content)
        let expected: Set<String> = [
            ".icFlag",
            ".Icons.Navigation.menuIcon",
            ".icFlagHighlighted",
            ".Images.Animals.dogFace"
        ]
        #expect(result == expected)
    }

    @Test("Swift member access rule handles deeply nested patterns")
    func swiftMemberAccessRuleHandlesDeeplyNestedPatterns() {
        let searcher = SwiftMemberAccessSearchRule()
        let content = """
        Image(.Level1.Level2.Level3.Level4.deepAsset)
        Image(.A.B.C.veryNestedIcon)
        """
        let result = searcher.search(in: content)
        let expected: Set<String> = [
            ".Level1.Level2.Level3.Level4.deepAsset",
            ".A.B.C.veryNestedIcon"
        ]
        #expect(result == expected)
    }

    @Test("Swift member access rule handles Image and ImageResource types")
    func swiftMemberAccessRuleHandlesImageAndImageResourceTypes() {
        let searcher = SwiftMemberAccessSearchRule()
        let content = """
        Image(.myIcon)
        UIImage(.anotherIcon)
        NSImage(.macIcon)
        """
        let result = searcher.search(in: content)
        let expected: Set<String> = [
            ".myIcon",
            ".anotherIcon",
            ".macIcon"
        ]
        #expect(result == expected)
    }

    @Test("Swift member access rule handles ImageResource dot notation")
    func swiftMemberAccessRuleHandlesImageResourceDotNotation() {
        let searcher = SwiftMemberAccessSearchRule()
        let content = """
        Image(ImageResource.homeIcon)
        let icon = ImageResource.Icons.Settings.logo
        ImageResource .Symbols.plug
        """
        let result = searcher.search(in: content)
        let expected: Set<String> = [
            ".homeIcon",
            ".Icons.Settings.logo",
            ".Symbols.plug"
        ]
        #expect(result == expected)
    }

    @Test("Swift member access rule handles mixed ImageResource and direct patterns")
    func swiftMemberAccessRuleHandlesMixedImageResourceAndDirectPatterns() {
        let searcher = SwiftMemberAccessSearchRule()
        let content = """
        Image(.directIcon)
        Image(ImageResource.resourceIcon)
        UIImage(.simpleIcon)
        let nested = Image(.Icons.Settings.logo)
        let resource = ImageResource.Icons.Dashboard.quickAction
        """
        let result = searcher.search(in: content)
        let expected: Set<String> = [
            ".directIcon",
            ".resourceIcon",
            ".simpleIcon",
            ".Icons.Settings.logo",
            ".Icons.Dashboard.quickAction"
        ]
        #expect(result == expected)
    }
}
