public struct CaptureZoomCapabilities: Sendable, Hashable {
    public let factorRange: CaptureScalarRange

    public init(
        factorRange: CaptureScalarRange
    ) throws(CaptureContractError) {
        guard factorRange.minimum >= 1 else {
            throw .invalidScalarRange(
                minimum: factorRange.minimum,
                maximum: factorRange.maximum
            )
        }
        self.factorRange = factorRange
    }
}
