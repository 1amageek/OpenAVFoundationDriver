public struct CaptureStreamEventCapabilities:
    OptionSet,
    Sendable,
    Hashable
{
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public static let interruptions = Self(rawValue: 1 << 0)
    public static let sourceDrops = Self(rawValue: 1 << 1)
    public static let systemPressure = Self(rawValue: 1 << 2)
    public static let terminalFailures = Self(rawValue: 1 << 3)
}
