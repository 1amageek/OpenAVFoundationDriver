public struct CaptureDriverID: Sendable, Hashable {
    public let rawValue: String

    public init(_ rawValue: String) throws(CaptureContractError) {
        guard !rawValue.isEmpty else {
            throw .emptyIdentifier(.driver)
        }
        self.rawValue = rawValue
    }
}
