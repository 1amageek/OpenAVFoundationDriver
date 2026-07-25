public struct CaptureStreamID: Sendable, Hashable {
    public let rawValue: String

    public init(_ rawValue: String) throws(CaptureContractError) {
        guard !rawValue.isEmpty else {
            throw .emptyIdentifier(.stream)
        }
        self.rawValue = rawValue
    }
}
