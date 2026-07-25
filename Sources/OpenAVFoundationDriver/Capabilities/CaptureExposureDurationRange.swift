public struct CaptureExposureDurationRange: Sendable, Hashable {
    public let minimum: CMTime
    public let maximum: CMTime

    public init(
        minimum: CMTime,
        maximum: CMTime
    ) throws(CaptureContractError) {
        guard minimum.isNumeric,
              maximum.isNumeric,
              minimum > .zero,
              maximum >= minimum else {
            throw .invalidControlConfiguration(.exposure)
        }

        self.minimum = minimum
        self.maximum = maximum
    }

    public func contains(_ value: CMTime) -> Bool {
        value.isNumeric && minimum <= value && value <= maximum
    }
}
