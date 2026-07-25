public struct CaptureWhiteBalanceGains: Sendable, Hashable {
    public let red: Double
    public let green: Double
    public let blue: Double

    public init(
        red: Double,
        green: Double,
        blue: Double
    ) throws(CaptureContractError) {
        guard red.isFinite,
              green.isFinite,
              blue.isFinite,
              red > 0,
              green > 0,
              blue > 0 else {
            throw .invalidControlConfiguration(.whiteBalance)
        }

        self.red = red
        self.green = green
        self.blue = blue
    }
}
