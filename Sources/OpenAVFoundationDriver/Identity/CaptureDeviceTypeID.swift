public struct CaptureDeviceTypeID: Sendable, Hashable {
    public let rawValue: String

    public init(_ rawValue: String) throws(CaptureContractError) {
        guard !rawValue.isEmpty else {
            throw .emptyIdentifier(.deviceType)
        }
        self.rawValue = rawValue
    }
}
