public struct CaptureDeviceControlID: Sendable, Hashable {
    public let rawValue: String

    public init(_ rawValue: String) throws(CaptureContractError) {
        guard !rawValue.isEmpty else {
            throw .emptyIdentifier(.control)
        }
        self.rawValue = rawValue
    }

    private init(uncheckedRawValue: String) {
        self.rawValue = uncheckedRawValue
    }

    public static let focus = CaptureDeviceControlID(
        uncheckedRawValue: "focus"
    )
    public static let exposure = CaptureDeviceControlID(
        uncheckedRawValue: "exposure"
    )
    public static let whiteBalance = CaptureDeviceControlID(
        uncheckedRawValue: "white-balance"
    )
    public static let zoom = CaptureDeviceControlID(
        uncheckedRawValue: "zoom"
    )
}
