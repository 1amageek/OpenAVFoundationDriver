public struct CaptureScalarRange: Sendable, Hashable {
    public let minimum: Double
    public let maximum: Double

    public init(
        minimum: Double,
        maximum: Double
    ) throws(CaptureContractError) {
        guard minimum.isFinite,
              maximum.isFinite,
              maximum >= minimum else {
            throw .invalidScalarRange(
                minimum: minimum,
                maximum: maximum
            )
        }

        self.minimum = minimum
        self.maximum = maximum
    }

    public func contains(_ value: Double) -> Bool {
        value.isFinite && minimum <= value && value <= maximum
    }
}
