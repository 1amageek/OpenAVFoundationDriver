public struct CaptureSystemPressureFactors:
    OptionSet,
    Sendable,
    Hashable
{
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public static let systemTemperature = Self(rawValue: 1 << 0)
    public static let peakPower = Self(rawValue: 1 << 1)
    public static let depthModuleTemperature = Self(rawValue: 1 << 2)
}
