public struct CaptureDeviceFormatID: Sendable, Hashable {
    public let rawValue: String

    public init(_ rawValue: String) throws(CaptureContractError) {
        guard !rawValue.isEmpty else {
            throw .emptyIdentifier(.format)
        }
        self.rawValue = rawValue
    }
}
