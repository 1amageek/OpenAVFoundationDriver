public struct CaptureFrameRateRange: Sendable, Hashable {
    public let minimum: Double
    public let maximum: Double

    public init(
        minimum: Double,
        maximum: Double
    ) throws(CaptureContractError) {
        guard minimum.isFinite,
              maximum.isFinite,
              minimum > 0,
              maximum >= minimum else {
            throw .invalidFrameRateRange(
                minimum: minimum,
                maximum: maximum
            )
        }
        self.minimum = minimum
        self.maximum = maximum
    }
}
