public struct CaptureMediaTypeID: Sendable, Hashable {
    public let rawValue: String

    public init(_ rawValue: String) throws(CaptureContractError) {
        guard !rawValue.isEmpty else {
            throw .emptyIdentifier(.mediaType)
        }
        self.rawValue = rawValue
    }

    private init(uncheckedRawValue: String) {
        self.rawValue = uncheckedRawValue
    }

    public static let video = CaptureMediaTypeID(uncheckedRawValue: "video")
    public static let audio = CaptureMediaTypeID(uncheckedRawValue: "audio")
    public static let metadata = CaptureMediaTypeID(uncheckedRawValue: "metadata")
}
