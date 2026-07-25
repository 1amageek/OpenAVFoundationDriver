public struct CaptureZoomConfiguration: Sendable, Hashable {
    public let factor: Double

    public init(factor: Double) throws(CaptureContractError) {
        guard factor.isFinite, factor >= 1 else {
            throw .invalidControlConfiguration(.zoom)
        }
        self.factor = factor
    }
}
