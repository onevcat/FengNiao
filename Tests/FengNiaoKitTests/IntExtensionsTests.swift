import Testing
@testable import FengNiaoKit

@Suite("Int Extensions")
struct IntExtensionsTests {
    @Test("readable size for 0 bytes")
    func readableSizeForZeroBytes() {
        #expect(0.fn_readableSize == "0 B")
    }

    @Test("readable size for several bytes")
    func readableSizeForSeveralBytes() {
        #expect(123.fn_readableSize == "123 B")
    }

    @Test("readable size for several KB")
    func readableSizeForSeveralKB() {
        #expect(123_456.fn_readableSize == "123.46 KB")
    }

    @Test("readable size for several MB")
    func readableSizeForSeveralMB() {
        #expect(123_456_789.fn_readableSize == "123.46 MB")
    }

    @Test("readable size for several GB")
    func readableSizeForSeveralGB() {
        #expect(1_123_456_789.fn_readableSize == "1.12 GB")
    }

    @Test("readable size for more than TB")
    func readableSizeForMoreThanTB() {
        #expect(1_321_123_456_789.fn_readableSize == "1321.12 GB")
    }
}
